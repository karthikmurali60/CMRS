import 'package:flash_chat/screens/hospital_UI.dart';
import 'package:flash_chat/screens/login_main.dart';
import 'package:edge_alert/edge_alert.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/components/rounded_button.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen2 extends StatefulWidget {
  static const String id = 'login_screen_hospital';
  @override
  _LoginScreenState2 createState() => _LoginScreenState2();
}

class _LoginScreenState2 extends State<LoginScreen2> {
  bool showSpinner = false;
  final _auth = FirebaseAuth.instance;
  final _firestore = Firestore.instance;
  String email;
  String password;
  String beds;
  String ambulances;


  void initialise() async {
    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;
    _firestore.collection('hospitals').document(uid)
        // ignore: non_constant_identifier_names
        .get().then((DocumentSnapshot) =>
    ambulances = DocumentSnapshot.data['ambulances'].toString());

    _firestore.collection('hospitals').document(uid)
        // ignore: non_constant_identifier_names
        .get().then((DocumentSnapshot) =>
    beds = DocumentSnapshot.data['beds'].toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/playstore.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  email = value.trim();
                },
                decoration:
                kTextFieldDecoration.copyWith(hintText: 'Enter your email'),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                obscureText: true,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  password = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Enter your password'),
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                title: 'Log In',
                colour: Colors.lightBlueAccent,
                onPressed: () async {
                  setState(() {
                    showSpinner = true;
                  });
                  try {
                    final user = await _auth.signInWithEmailAndPassword(
                        email: email, password: password);
                    if (user != null) {
                      Navigator.popAndPushNamed(context, HospitalUI.id);
                    }
                    setState(() {
                      showSpinner = false;
                    });
                  } catch (e) {
                    EdgeAlert.show(context, title: 'Invalid Credentials', description: 'Invalid user name or password', gravity: EdgeAlert.BOTTOM);
                    Navigator.popAndPushNamed(context, MainLogin.id);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
