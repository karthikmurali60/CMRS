import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/story_brain.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:edge_alert/edge_alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';


class GoogleMaps {

  GoogleMaps._();
  static Future<void> openMap(double latitude, double longitude) async {
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }
}

StoryBrain storyBrain = StoryBrain();


class Prioritisation extends StatefulWidget {

  static const String id = 'story_screen';

  _PrioritisationState createState() => _PrioritisationState();
}

class _PrioritisationState extends State<Prioritisation> {

  Position position;
  GeoPoint myLocation = GeoPoint(56,-122);

  getHospitalLocations(int n) async {
    return await Firestore.instance.collection('hospitals').where('beds', isGreaterThan: n).getDocuments();
  }

  int number=108;
  int mnumber= 09844088147;

  void _launchCaller(int number) async{
    var url = "tel:${number.toString()}";
    if(await canLaunch(url)){
      await launch(url);
    }
    else{
      throw 'Could not place call';
    }
  }

  bool giveAlert(){
    return storyBrain.alert();
  }

  @override
  void initState() {
    super.initState();
    getHospitalLocations(0).then((results) {
      setState(() {
        querySnapshot = results;
      });
    });
  }


  QuerySnapshot querySnapshot;

  int phoneNumber ;
  String descr = "";

  void getLocationOfNearestHospital(int n) async {
    try {
      List<String> locations = [];
      List<String> phoneNumbers = [];
      GeoPoint minDistanceLocation ;
      position = await Geolocator().getLastKnownPosition(
          desiredAccuracy: LocationAccuracy.high);
      myLocation = GeoPoint(position.latitude, position.longitude);
      EdgeAlert.show(context, title: 'Your location', description: '$position', gravity: EdgeAlert.BOTTOM);

      for (int i = 0; i < querySnapshot.documents.length; i++) {
        if(querySnapshot.documents[i].data['ambulances']>0){
          locations.add(querySnapshot.documents[i].data['location']);
          phoneNumbers.add(querySnapshot.documents[i].data['phone number']);
        }
      }
      double min = await Geolocator().distanceBetween(myLocation.latitude, myLocation.longitude, double.parse(locations[0].split(",")[0]), double.parse(locations[0].split(",")[1]));
      int minIndex = 0;
      for (int i = 1; i < locations.length; i++) {
        final double endLatitude = double.parse(locations[i].split(",")[0]);
        final double endLongitude = double.parse(locations[i].split(",")[1]);
        double myDistances = await Geolocator().distanceBetween(
            myLocation.latitude, myLocation.longitude, endLatitude,
            endLongitude);
        if(myDistances<min){
          min = myDistances;
          minIndex = i;
        }
      }
      minDistanceLocation = GeoPoint(double.parse(locations[minIndex].split(",")[0]), double.parse(locations[minIndex].split(",")[1]));
      phoneNumber = int.parse(phoneNumbers[minIndex]);
      if(n==1){
        GoogleMaps.openMap(minDistanceLocation.latitude,minDistanceLocation.longitude);
      }
      else if(n==2) {
        _launchCaller(phoneNumber);
      }
    }
    on PlatformException catch(e){
      if(e.code == 'PERMISSION_DISABLED'){
        //error = 'Permission denied';
        EdgeAlert.show(context, title: 'Your location', description: 'Please Switch on your location in phone', gravity: EdgeAlert.BOTTOM);
      }
      else{
        print(position);
        EdgeAlert.show(context, title: 'Your location', description: '$position', gravity: EdgeAlert.BOTTOM);
      }
    }
  }

  void getNameOfNearestHospital() async {
    List<String> locations = [];
    GeoPoint minDistanceLocation ;
    position = await Geolocator().getLastKnownPosition(
        desiredAccuracy: LocationAccuracy.high);
    myLocation = GeoPoint(position.latitude, position.longitude);
    print(position);
    EdgeAlert.show(context, title: 'Your location', description: '$position', gravity: EdgeAlert.BOTTOM);
    for (int i = 0; i < querySnapshot.documents.length; i++) {
      if(querySnapshot.documents[i].data['ambulances']>0){
        locations.add(querySnapshot.documents[i].data['location']);
      }
    }
    print(locations.length);
    double min = await Geolocator().distanceBetween(myLocation.latitude, myLocation.longitude, double.parse(locations[0].split(",")[0]), double.parse(locations[0].split(",")[1]));
    int minIndex = 0;
    for (int i = 1; i < locations.length; i++) {
      final double endLatitude = double.parse(locations[i].split(",")[0]);
      final double endLongitude = double.parse(locations[i].split(",")[1]);
      double myDistances = await Geolocator().distanceBetween(
          myLocation.latitude, myLocation.longitude, endLatitude,
          endLongitude);
      if(myDistances<min){
        min = myDistances;
        minIndex = i;
      }
    }
    minDistanceLocation = GeoPoint(double.parse(locations[minIndex].split(",")[0]), double.parse(locations[minIndex].split(",")[1]));
    String minDistance = minDistanceLocation.latitude.toString()+","+minDistanceLocation.longitude.toString();
    QuerySnapshot name = await Firestore.instance.collection('hospitals').where('location', isEqualTo: minDistance).getDocuments();
    descr = name.documents[0].data['name'];
    //return (name.documents[0].data['name']);
    Alert(
      context: context,
      type: AlertType.error,
      title: "Patient in Immediate danger",
      desc: "The nearest hospital is $descr",
      buttons: [
        DialogButton(
          child: Text(
            "Call hospital",

            style: TextStyle(
                color: Colors.white, fontSize: 20),
          ),
          width: 120,
          onPressed: () {
            getLocationOfNearestHospital(2);
            storyBrain.restart();
          },

        ),
        DialogButton(
          child: Text(
            "Hospital Route ",

            style: TextStyle(
                color: Colors.white, fontSize: 20),
          ),
          width: 120,
          onPressed: () {
            getLocationOfNearestHospital(1);
            storyBrain.restart();
          },

        )
      ],
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/whitebackgroung.png'),
              fit: BoxFit.cover,
            ),
          ),
          padding: EdgeInsets.symmetric(vertical: 50.0, horizontal: 15.0),
          constraints: BoxConstraints.expand(),
          child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    flex: 12,
                    child: Center(
                      child: Text(
                        storyBrain.getStory(),
                        style: TextStyle(
                            fontSize: 25.0,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Visibility(
                      visible: storyBrain.buttonShouldBeVisible1(),
                      child: FlatButton(
                        onPressed: () {
                          if(giveAlert()) {

                          }
                            if (storyBrain.storynumber == 7) {
                              storyBrain.restart();
                              Alert(
                                context: context,
                                type: AlertType.error,
                                title: "Patient is not critical call a regular ambulance",
                                desc: "Call ",
                                buttons: [
                                  DialogButton(
                                    child: Text(
                                      "Call",

                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                    width: 120,
                                    onPressed: () {
                                      _launchCaller(number);
                                      storyBrain.restart();
                                      Navigator.pop(context);
                                    },
                                  )
                                ],
                              ).show();
                            }

                          setState(() {
                            storyBrain.nextStory(1);
                          });
                        },
                        color: Colors.green,
                        child: Text(
                          storyBrain.getChoice1(),
                          style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),
                  ),//GREEN
                  SizedBox(
                    height: 20.0,
                  ),
                  Expanded(
                    flex: 2,

                    child: Visibility(
                      visible: storyBrain.buttonShouldBeVisible(),
                      child: FlatButton(
                        onPressed: () {
                          //Choice 2 made by user.
                          if(giveAlert()) {
                            if (storyBrain.storynumber == 9) {
                              getNameOfNearestHospital();
                            }
                          }

                          setState(() {
                            storyBrain.nextStory(2);
                          });
                        },
                        color: Colors.redAccent,
                        child: Text(

                          storyBrain.getChoice2(),
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),//RED
                  SizedBox(
                    height: 10.0,
                  ),
                  Expanded(
                    flex: 2,
                    child: Visibility(
                      visible: storyBrain.buttonShouldBeVisible2(),
                      child: FlatButton(
                        onPressed: () {
                          //Choice 2 made by user.
                          if(giveAlert()) {
                            if (storyBrain.storynumber == 10) {
                              Alert(
                                context: context,
                                type: AlertType.error,
                                title: "Patient is not critical",
                                desc: "call normal ambulance",
                                buttons: [
                                  DialogButton(
                                    child: Text(
                                      "Call hospital",

                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                    width: 120,
                                    onPressed: () {
                                      _launchCaller(number);
                                      storyBrain.restart();
                                      Navigator.pop(context);
                                    },

                                  ),

                                ],
                              ).show();
                            }
                          }

                          setState(() {
                            storyBrain.nextStory(2);
                          });
                        },
                        color: Colors.yellowAccent,
                        child: Text(

                          "What to do now?",
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),//YELLOW
                  SizedBox(
                    height: 10.0,
                  ),
                  Expanded(
                    flex: 2,

                    child: Visibility(
                      visible: storyBrain.buttonShouldBeVisible3(),
                      child: FlatButton(
                        onPressed: () {
                          //Choice 2 made by user.
                          if(giveAlert()) {
                            if(storyBrain.storynumber==8){
                              Alert(
                                context: context,
                                type: AlertType.error,
                                title: "Mortuary Van",
                                desc: "Call St Peters Undertaker service",
                                buttons: [
                                  DialogButton(
                                    child: Text(
                                      "Call",

                                      style: TextStyle(color: Colors.white, fontSize: 20),
                                    ),
                                    width: 120,
                                    onPressed: () {
                                      _launchCaller(mnumber);
                                      storyBrain.restart();
                                      Navigator.pop(context);
                                    },

                                  )
                                ],
                              ).show();
                            }
                          }

                          setState(() {
                            storyBrain.nextStory(2);
                          });
                        },
                        color: Colors.grey,
                        child: Text(

                          "What to do now?",
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),// GREY
                ],
              )
          ),
        ));
  }
}

/*
Expanded(
flex: 12,
child: Center(
child: Text(
storyBrain.getStory(),
style: TextStyle(
fontSize: 25.0,
fontWeight: FontWeight.bold
),
),
),
),
Expanded(
flex: 2,
child: Visibility(
visible: storyBrain.buttonShouldBeVisible1(),
child: FlatButton(
onPressed: () {
if(giveAlert())
{
if(storyBrain.storynumber==9){
Alert(
context: context,
type: AlertType.error,
title: "Patient in Immediate danger",
desc: "Get CMRS to the nearest hospital with ICU beds",
buttons: [
DialogButton(
child: Text(
"Click here!",

style: TextStyle(color: Colors.white, fontSize: 20),
),
width: 120,
onPressed: () {
getLocationOfNearestHospital(1);
storyBrain.restart();
Navigator.pop(context);
},

)
],
).show();
}

if(storyBrain.storynumber==10){
Alert(
context: context,
type: AlertType.error,
title: "Patient is not critical call a regular ambulance",
desc: "Call 108",
buttons: [
DialogButton(
child: Text(
"Call",

style: TextStyle(color: Colors.white, fontSize: 20),
),
width: 120,
onPressed: () {
_launchCaller(number);
storyBrain.restart();
Navigator.pop(context);
},


)
],
).show();
}

if(storyBrain.storynumber==8){
Alert(
context: context,
type: AlertType.error,
title: "Mortuary Van",
desc: "Call St Peters Undertaker service",
buttons: [
DialogButton(
child: Text(
"Call",

style: TextStyle(color: Colors.white, fontSize: 20),
),
width: 120,
onPressed: () {
_launchCaller(mnumber);
storyBrain.restart();
Navigator.pop(context);
},

)
],
).show();
}

}

if(storyBrain.storynumber==7){
storyBrain.restart();
Alert(
context: context,
type: AlertType.error,
title: "Patient is not critical call a regular ambulance",
desc: "Call ",
buttons: [
DialogButton(
child: Text(
"Call",

style: TextStyle(color: Colors.white, fontSize: 20),
),
width: 120,
onPressed: () {
storyBrain.restart();
_launchCaller(number);
},
)
],
).show();
}
setState(() {
storyBrain.nextStory(1);
});
},
color: Colors.green,
child: Text(
storyBrain.getChoice1(),
style: TextStyle(
fontSize: 20.0,
fontWeight: FontWeight.bold
),
),
),
),
),
SizedBox(
height: 20.0,
),
Expanded(
flex: 2,
child: Visibility(
visible: storyBrain.buttonShouldBeVisible(),
child: FlatButton(
onPressed: () {
//Choice 2 made by user.
if(giveAlert()) {
if (storyBrain.storynumber == 9) {
Alert(
context: context,
type: AlertType.error,
title: "Patient in Immediate danger",
desc: "Get CMRS the nearest hospital with ICU bed",
buttons: [
DialogButton(
child: Text(
"Call hospital",

style: TextStyle(
color: Colors.white, fontSize: 20),
),
width: 120,
onPressed: () {
getLocationOfNearestHospital(2);
storyBrain.restart();
},

),
DialogButton(
child: Text(
"Hospital Route ",

style: TextStyle(
color: Colors.white, fontSize: 20),
),
width: 120,
onPressed: () {
getLocationOfNearestHospital(1);
storyBrain.restart();
},

)
],
).show();
}
}

setState(() {
storyBrain.nextStory(2);
});
},
color: Colors.redAccent,
child: Text(

storyBrain.getChoice2(),
style: TextStyle(
fontSize: 20.0,
fontWeight: FontWeight.bold,
),
),
),
),
),
],
),

 */
