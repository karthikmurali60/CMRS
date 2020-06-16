import 'package:flash_chat/screens/hospital_UI.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:edge_alert/edge_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/components/bottom_button.dart';

class HospitalDetails extends StatefulWidget {
  static const String id = 'hdetails_screen';
  @override
  _HospitalDetailsState createState() => _HospitalDetailsState();
}

class _HospitalDetailsState extends State<HospitalDetails> {

  String gender;
  int bedInt;
  int ambInt;
  String beds ;
  String ambulance;
  String hospitalName;
  String phoneNumber;
  Position position;
  GeoPoint myLocation;
  String finalLocation;
  TextEditingController _controller;
  final auth = FirebaseAuth.instance;
  final _firestore = Firestore.instance;


  void sendDataToNextScreen(BuildContext context) {
    //String ambulances = ambulance;
    //String bed = beds;
    //String concat = ambulances+","+bed;
    /*Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HospitalDashboard(ambulances: concat,),
        ));*/
    Navigator.popAndPushNamed(context, HospitalUI.id);
  }


  void getLocation() async {
    try {
      position = await Geolocator().getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
      myLocation = GeoPoint(position.latitude,position.longitude);
      print(position);
      String myLatitude = myLocation.latitude.toString();
      String myLongitude = myLocation.longitude.toString();
      finalLocation = myLatitude+","+myLongitude;
      print(finalLocation);
      EdgeAlert.show(context, title: 'Your location', description: '$position', gravity: EdgeAlert.BOTTOM);
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


  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void inputData() async {
    final FirebaseUser user = await auth.currentUser();
    final uid = user.uid;
    _firestore.collection('hospitals').document(uid).setData({
      'beds': bedInt,
      'ambulances': ambInt,
      'name': hospitalName,
      'location': finalLocation,
      'phone number': phoneNumber
    });
    _firestore.collection('hospitals');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text('Registration  details'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: ReusableCard(
                colour: kActiveCardColour,
                cardChild: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Hospital details ',
                      style: kLabelTextStyle,
                    ),
                    Container(
                      padding: EdgeInsets.all(20),
                      child: TextField(
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        decoration: kTextFieldInputDecoration,
                        onChanged: (value) {
                          hospitalName = value;
                          print(value);
                        },
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(20),
                      child: TextField(
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        decoration: kTextFieldInputDecoration2,
                        onChanged: (value) {
                          phoneNumber = value;
                          print(value);
                        },
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(20),
                      child: TextField(
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        decoration: kTextFieldInputDecoration3,
                        onChanged: (value) {
                          beds = value;
                          bedInt = int.parse(beds);
                          print(value);
                        },
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(20),
                      child: TextField(
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        decoration: kTextFieldInputDecoration4,
                        onChanged: (value) {
                          ambulance = value;
                          ambInt = int.parse(ambulance);
                          print(value);
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text(
                          'press to enter location',
                          style: kLabelTextStyle,
                        ),
                        FloatingActionButton(
                          onPressed: getLocation,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            BottomButton(
              buttonTitle: 'Register Hospital for CMRS',
              onTap: () {
                if(hospitalName==null){
                  EdgeAlert.show(context, title: "Enter all the details",description: 'Enter Hospital Name',gravity: EdgeAlert.BOTTOM);
                }
                else if(phoneNumber == null){
                  EdgeAlert.show(context, title: "Enter all the details",description: 'Enter Phone Number',gravity: EdgeAlert.BOTTOM);
                }
                else if(phoneNumber.length>10 || phoneNumber.length<10){
                  EdgeAlert.show(context, title: "Enter all the details",description: 'Enter Valid Phone Number',gravity: EdgeAlert.BOTTOM);
                }
                else if(bedInt == null){
                  EdgeAlert.show(context, title: "Enter all the details",description: 'Enter Beds',gravity: EdgeAlert.BOTTOM);
                }
                else if(ambInt == null){
                  EdgeAlert.show(context, title: "Enter all the details",description: 'Enter Ambulances',gravity: EdgeAlert.BOTTOM);
                }
                else if(finalLocation == null){
                  EdgeAlert.show(context, title: "Enter all the details",description: 'Select Location',gravity: EdgeAlert.BOTTOM);
                }
                else {
                  inputData();
                  //Navigator.pop(context);
                  sendDataToNextScreen(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}



class ReusableCard extends StatelessWidget {
  ReusableCard({@required this.colour, this.cardChild, this.onPress});

  final Color colour;
  final Widget cardChild;
  final Function onPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        child: cardChild,
        margin: EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: colour,
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}

class IconContent extends StatelessWidget {
  IconContent({this.icon, this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          icon,
          size: 80.0,
        ),
        SizedBox(
          height: 15.0,
        ),
        Text(
          label,
          style: kLabelTextStyle,
        )
      ],
    );
  }
}



