import 'package:flash_chat/screens/login_screen_hospital.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flash_chat/screens/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/components/rounded_button.dart';

class HospitalUI extends StatefulWidget {
  static const String id = 'hui_screen';
  @override
  _HospitalUIState createState() => _HospitalUIState();
}

class _HospitalUIState extends State<HospitalUI> {
  String gender;
  int bedInt;
  int ambInt;
  String beds = "" ;
  String ambulance = "";
  String hospitalName='';
  Position position;
  GeoPoint myLocation;
  String finalLocation;
  final firestore = Firestore.instance;
  int flag  = 0;

  final auth = FirebaseAuth.instance;

  void sendDataToNextScreen(BuildContext context) {
    initialise2();
  }

  void initialise2() async {
    final FirebaseUser user = await auth.currentUser();
    final String uid = user.uid;
    firestore.collection('hospitals').document(uid)
    // ignore: non_constant_identifier_names
        .get().then((DocumentSnapshot) =>
    ambulance = DocumentSnapshot.data['ambulances'].toString());

    firestore.collection('hospitals').document(uid)
    // ignore: non_constant_identifier_names
        .get().then((DocumentSnapshot) =>
    beds = DocumentSnapshot.data['beds'].toString());

    firestore.collection('hospitals').document(uid)
    // ignore: non_constant_identifier_names
        .get().then((DocumentSnapshot) =>
    hospitalName = DocumentSnapshot.data['name']);
    String ambulances = ambulance;
    String bed = beds;
    String concat = ambulances+","+bed;
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HospitalDashboard(ambulances: concat,),
        ));
  }

  void initialise() async {
    final FirebaseUser user = await auth.currentUser();
    final uid = user.uid;
    firestore.collection('hospitals').document(uid)
        // ignore: non_constant_identifier_names
        .get().then((DocumentSnapshot) =>
    ambulance = DocumentSnapshot.data['ambulances'].toString());

    firestore.collection('hospitals').document(uid)
        // ignore: non_constant_identifier_names
        .get().then((DocumentSnapshot) =>
    beds = DocumentSnapshot.data['beds'].toString());
    print(beds);
    print(ambulance);
    firestore.collection('hospitals').document(uid)
    // ignore: non_constant_identifier_names
        .get().then((DocumentSnapshot) =>
    hospitalName = DocumentSnapshot.data['name']);
  }


  TextEditingController _controller;

  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => initialise());
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _signOut() async {
    await auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.white,

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
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

            Expanded(
              child: ReusableCard(
                colour: Colors.teal,
                cardChild: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),

                    Container(
                      padding: EdgeInsets.all(20),

                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text('Welcome To CMRS',style: GoogleFonts.pacifico(
                            textStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black
                            )
                          ),
                          ),
                          SizedBox(
                            height: 50,
                          ),

                          Text(hospitalName, style: GoogleFonts.pacifico(
                            textStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.black
                            ),
                          )
                          ),
                        ],
                      )
                    ),
                  ],
                ),
              ),
            ),
            RoundedButton(
              title: 'Go to Dashboard',
              colour: Colors.lightBlueAccent,
              onPressed: () {
                if(flag==0) {
                  flag=1;
                  initialise();
                  sendDataToNextScreen(context);
                 }
                else{
                  flag=0;
                  initialise2();
                  sendDataToNextScreen(context);
                }
                },
            ),

            SizedBox(
              width:30,
            ),

            RoundedButton(
              title: 'Logout from CMRS',
              colour: Colors.lightBlueAccent,
              onPressed: () {
                _signOut();
                Navigator.pop(context, LoginScreen2.id);
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



