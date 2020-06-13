import 'package:flash_chat/screens/registration_hospital.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/screens/registration_screen.dart';
import 'package:flash_chat/components/rounded_button.dart';

class MainRegistration extends StatefulWidget {
  static const String id = 'main_registration_screen';

  @override
  _MainRegistrationState createState() => _MainRegistrationState();
}

class _MainRegistrationState extends State<MainRegistration>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation animation;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(duration: Duration(seconds: 1), vsync: this);
    animation = ColorTween(begin: Colors.blueGrey, end: Colors.white)
        .animate(controller);
    controller.forward();
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animation.value,
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
              title: 'Register as User',
              colour: Colors.lightBlueAccent,
              onPressed: () {
                Navigator.popAndPushNamed(context, RegistrationScreen1.id);
              },
            ),
            RoundedButton(
              title: 'Register as Hospital ',
              colour: Colors.blueAccent,
              onPressed: () {
                Navigator.popAndPushNamed(context, RegistrationScreen3.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
