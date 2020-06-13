import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/components/icon_content.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flash_chat/constants.dart';
import 'package:edge_alert/edge_alert.dart';
import 'package:flash_chat/components/round_icon_button.dart';
import 'package:flash_chat/components/reusable_card.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HospitalDashboard extends StatefulWidget {
  static const String id = 'hospital_dashboard';
  final String ambulances;
  HospitalDashboard({Key key, @required this.ambulances}) : super(key: key);

  @override
  _HospitalDashboardState createState() => _HospitalDashboardState();
}

class _HospitalDashboardState extends State<HospitalDashboard> {

  final FirebaseAuth auth = FirebaseAuth.instance;
  final _firestore = Firestore.instance;

  int ambulance = 0;
  int beds = 0;

  void initialise() async {
    ambulance = int.parse(widget.ambulances.split(",")[0]);
    beds = int.parse(widget.ambulances.split(",")[1]);
  }


  void inputDataBeds() async {
    final FirebaseUser user = await auth.currentUser();
    final uid = user.uid;
    _firestore.collection('hospitals').document(uid).updateData({
      'beds': beds,
      });
  }

  void inputDataAmbulances() async {
    final FirebaseUser user = await auth.currentUser();
    final uid = user.uid;
    _firestore.collection('hospitals').document(uid).updateData({
      'ambulances': ambulance,
    });
  }



  @override
  void initState() {
    super.initState();
    initialise();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CMRS',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
        backgroundColor: Colors.teal,

      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[

              SizedBox(
                width: 1,
              ),
            ],
          ),
          Expanded(
            child: ReusableCard(
              colour: kActiveCardColour,
              cardChild: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Please Update the number of ambulances',
                    style: kLabelTextStyle,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: <Widget>[
                      SizedBox(
                        width: 30,
                      ),
                      IconContent(
                        icon: FontAwesomeIcons.ambulance,
                        label: 'Ambulances',
                      ),
                      SizedBox(
                        width: 90,
                      ),
                      Text(
                        ambulance.toString(),
                        style: kNumberTextStyle,
                      ),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                          width: 100
                      ),

                      RoundIconButton(
                        icon: FontAwesomeIcons.minus,
                        onPressed: () {
                          setState(
                                () {
                              if(ambulance>0) {
                                ambulance--;
                              }
                             else{
                                EdgeAlert.show(context, title: 'invalid input', description: 'cannot be less than 0', gravity: EdgeAlert.BOTTOM);
                              }
                            },
                          );
                          inputDataAmbulances();
                        },
                      ),
                      SizedBox(
                        width: 20.0,
                      ),
                      RoundIconButton(
                          icon: FontAwesomeIcons.plus,
                          onPressed: () {
                            setState(() {
                              ambulance++;
                            });
                            inputDataAmbulances();
                          })
                    ],
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: ReusableCard(
              colour: kActiveCardColour,
              cardChild: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Please Update the number of beds',
                    style: kLabelTextStyle,
                  ),
                  Row(
                    children: <Widget>[
                      SizedBox(
                        width: 30,
                      ),
                      IconContent(
                        icon: FontAwesomeIcons.bed,
                        label: 'ICU Beds',
                      ),
                      SizedBox(
                        width: 100,
                      ),
                      Text(
                        beds.toString(),
                        style: kNumberTextStyle,
                      ),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[

                      SizedBox(
                        width: 100
                      ),

                      RoundIconButton(
                        icon: FontAwesomeIcons.minus,
                        onPressed: () {
                          setState(
                                () {
                                  if(beds>0)   {
                                    beds--;
                                  }
                                  else{
                                    EdgeAlert.show(context, title: 'invalid input', description: 'cannot be less than 0', gravity: EdgeAlert.BOTTOM);
                                  }
                            },
                          );
                          inputDataBeds();
                        },
                      ),
                      SizedBox(
                        width: 20.0,
                      ),
                      RoundIconButton(
                          icon: FontAwesomeIcons.plus,
                          onPressed: () {
                            setState(() {
                              beds++;
                            });
                            inputDataBeds();
                          })
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
