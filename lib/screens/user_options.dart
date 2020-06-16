import 'dart:collection';
import 'package:flash_chat/screens/inputpage.dart';
import 'package:flash_chat/screens/login_screen.dart';
import 'package:flash_chat/screens/recommendation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/components/rounded_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:edge_alert/edge_alert.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

class UserOptions extends StatefulWidget {
  static const String id = 'user_options_screen';

  @override
  _UserOptionsState createState() => _UserOptionsState();
}

class _UserOptionsState extends State<UserOptions>
    with SingleTickerProviderStateMixin {

  AnimationController controller;
  Animation animation;
  Position position;
  GeoPoint myLocation = GeoPoint(56,-122);
  QuerySnapshot querySnapshot;
  QuerySnapshot querySnapshotNew;

  GeoPoint minDistanceLocation ;
  String name ="";
  String names1;
  List<String> namesString = [];
  final auth = FirebaseAuth.instance;
  final firestore = Firestore.instance;
  final String _collection = 'hospitals';
  final _fireStore = Firestore.instance;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  _signOut() async {
    await _firebaseAuth.signOut();
  }

  getHospitalLocations(int n) async {
    return await Firestore.instance.collection('hospitals').where('beds', isGreaterThan: n).getDocuments();
  }

  getData() async {
    return await _fireStore.collection(_collection).getDocuments();
  }

  @override
  void initState() {
    super.initState();
    getHospitalLocations(0).then((results) {
      setState(() {
        querySnapshot = results;
      });
    });

    getData().then((val) {
      setState(() {
        querySnapshotNew = val;
      });
    });
  }

  /*void getLocationOfNearestHospital() async {
    try {
      List<String> locations = [];
      position = await Geolocator().getLastKnownPosition(
          desiredAccuracy: LocationAccuracy.high);
      myLocation = GeoPoint(position.latitude, position.longitude);
      EdgeAlert.show(context, title: 'Your location', description: '$position', gravity: EdgeAlert.BOTTOM);
      for (int i = 0; i < querySnapshot.documents.length; i++) {
        locations.add(querySnapshot.documents[i].data['location']);
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
     GoogleMaps.openMap(minDistanceLocation.latitude,minDistanceLocation.longitude);
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
  }*/

    void getNameOfNearestHospital() async {
    List<String> docID = [];
    docID.clear();
    List<double> myDist = []; // Stores all distances
    myDist.clear();
    double myDist1;
    List<String> locations = [];
    String namesConcat = "";
    String locationsConcat = "";
    String phonesConcat = "";
    List<String> allDocs = [];
    List<String> requiredNames = [];
    List<String> requireLocations = [];
    List<String> requiredPhone = [];

    position = await Geolocator().getLastKnownPosition(
        desiredAccuracy: LocationAccuracy.high);
    myLocation = GeoPoint(position.latitude, position.longitude);

    EdgeAlert.show(context, title: 'Your location',
        description: '$position',
        gravity: EdgeAlert.BOTTOM);
    for (int i = 0; i < querySnapshot.documents.length; i++) {
      locations.add(querySnapshot.documents[i].data['location']);
      docID.add(querySnapshot.documents[i].documentID);
    }

    for (int i = 0; i < locations.length; i++) {
      final double endLatitude = double.parse(locations[i].split(",")[0]);
      final double endLongitude = double.parse(locations[i].split(",")[1]);
      myDist1 = await Geolocator().distanceBetween(
          myLocation.latitude, myLocation.longitude, endLatitude,
          endLongitude);
      myDist.add(myDist1);
    }

    final SplayTreeMap<double, List<String>> st = SplayTreeMap<double, List<String>>();
    for(int i=0;i<myDist.length;i++){
        if(!(st.containsKey(docID))) {
          st.putIfAbsent(myDist[i], () => List<String>());
        }
    }

    for(int i=0;i<myDist.length;i++) {
      st[myDist[i]].add(docID[i]);
    }
    List<String> top5 = [];
    st.forEach((key,value) {
          for (int k = 0; k < value.length; k++) {
              top5.add(value[k]);
          }
        });

      for (int i = 0; i < querySnapshotNew.documents.length; i++) {
        allDocs.add(querySnapshotNew.documents[i].documentID);
      }

      for (int i = 0; i < top5.length; i++) {
        for (int j = 0; j < allDocs.length; j++) {
          if (top5[i] == allDocs[j]) {
            requiredNames.add(querySnapshotNew.documents[j].data['name']);
            requiredPhone.add(querySnapshotNew.documents[j].data['phone number']);
            requireLocations.add(querySnapshotNew.documents[j].data['location']);
          }
        }
      }
      namesConcat = requiredNames[0].trim();
      for (int i = 1; i < requiredNames.length; i++) {
        namesConcat = namesConcat + "," + requiredNames[i].trim();
      }

      phonesConcat =requiredPhone[0].trim();
      for (int i = 1; i < requiredNames.length; i++) {
        phonesConcat = phonesConcat + "," + requiredPhone[i].trim();
      }

      locationsConcat = requireLocations[0].trim();
      for(int i = 1;i < requireLocations.length;i++) {
        locationsConcat = locationsConcat + " " + requireLocations[i].trim();
      }
      String finalConcat = namesConcat+";"+locationsConcat+";"+phonesConcat;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecommendationScreen(documentIDs: finalConcat,),
        ));
    }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Container(
                    child: Image.asset('images/playstore.png'),
                    height: 60.0,
                  ),
                ),
                Text(
                  'C M R S',
                  style: TextStyle(
                    fontSize: 45.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            RoundedButton(
              title: 'Request ambulance or report incident',
              colour: Colors.lightBlueAccent,
              onPressed: () {
                Navigator.pushNamed(context, InputPage.id);
              },
            ),
            RoundedButton(
              title: 'Get nearest hospital (self ambulance)',
              colour: Colors.blueAccent,
              onPressed: () {
                getNameOfNearestHospital();
              },
            ),
            SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 1,
                ),
               FlatButton(
                  color: Colors.teal,
                  textColor: Colors.white,
                  disabledColor: Colors.grey,
                  disabledTextColor: Colors.black,
                  padding: EdgeInsets.all(8.0),
                  splashColor: Colors.blueAccent,
                  onPressed: () {
                    _signOut();
                    Navigator.pop(context, LoginScreen1.id);
                  },
                  child: Text(
                    "Logout",
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontSize: 10.0),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}



