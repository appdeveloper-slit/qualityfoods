import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qf/home_page.dart';
import 'package:qf/login.dart';
// import 'package:qf/backstack_based_main_app_screen.dart';
import 'package:qf/main_app_screen.dart';
import 'package:qf/otp_verification.dart';
import 'package:shared_preferences/shared_preferences.dart';
class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  bool? isLoggedIn = false;

  // test_network_and_start() async {
  //   try {
  //     final result = await InternetAddress.lookup('google.com');
  //     if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      
  //       print('connected');
  //     }
  //   } on SocketException catch (_) {
  //     print('not connected');
  //      SnackBar snackBar = SnackBar(
  //           content: Text("No Internet"),
  //         );

  //         ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //   }
  // }

  @override
  void initState() {
    getSessionData();
    super.initState();
    Timer(
        Duration(seconds: 1),
        () {
                // Navigator.pushReplacement(
      // context, MaterialPageRoute(builder: (context) => OTPScreen(method: "test", name: "test", mobile: "test", email: "test",)));

          // test_network_and_start();

          isLoggedIn! ?Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen())) : Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
          
          // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));

        } );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
          children: [
            // SvgPicture.asset('assets/img/spscreen.svg', fit: BoxFit.fill),
            Image.asset(
            "assets/img/sp.png", fit: BoxFit.fill,),
          //   Container(
          // child: Image.asset("assets/img/logo (6).png")),
          // Text("Build: Efwfmpqfe cz Wjwfl Ujxbsj (ENC 1 caesar)"),
   ] );
  }

  getSessionData() async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    isLoggedIn = sp.getBool("isLoggedIn") != null ? sp.getBool("isLoggedIn")! : false;
  }
}

