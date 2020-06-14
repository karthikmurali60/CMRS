import 'package:flash_chat/screens/hospital_details.dart';
import 'package:flash_chat/screens/inputpage.dart';
import 'package:flash_chat/screens/login_main.dart';
import 'package:flash_chat/screens/prioritizer_screen.dart';
import 'package:flash_chat/screens/recommendation.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flash_chat/screens/login_screen.dart';
import 'package:flash_chat/screens/registration_screen.dart';
import 'package:flutter/services.dart';
import 'package:flash_chat/screens/registration_main.dart';
import 'package:flash_chat/screens/login_screen_hospital.dart';
import 'package:flash_chat/screens/user_options.dart';
import 'package:flash_chat/screens/registration_hospital.dart';
import 'package:flash_chat/screens/dashboard.dart';
import 'package:flash_chat/screens/hospital_UI.dart';
import 'screens/dashboard.dart';
import 'screens/welcome_screen.dart';

void main() => runApp(FlashChat());

class FlashChat extends StatelessWidget {
  @override

    Widget build(BuildContext context) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    return MaterialApp(
      initialRoute: WelcomeScreen.id,
      routes: {

        LoginScreen2.id: (context) =>             LoginScreen2(),
        LoginScreen1.id: (context) =>             LoginScreen1(),
        WelcomeScreen.id: (context) =>          WelcomeScreen(),
        LoginScreen1.id: (context) =>             LoginScreen1(),
        RegistrationScreen3.id: (context) =>      RegistrationScreen3(),
        Prioritisation.id: (context) =>               Prioritisation(),
        InputPage.id: (context)=>                InputPage(),
        MainLogin.id: (context)=>                MainLogin(),
        MainRegistration.id: (context)=>                MainRegistration(),
        UserOptions.id: (context)=>                UserOptions(),
        HospitalDetails.id: (context)=>                HospitalDetails(),
        RegistrationScreen1.id: (context) =>      RegistrationScreen1(),
        HospitalDashboard.id: (context) =>             HospitalDashboard(ambulances: null,),
        HospitalUI.id: (context) =>             HospitalUI(),
        RecommendationScreen.id: (context) => RecommendationScreen(documentIDs: null,)
      },
    );
  }
}
