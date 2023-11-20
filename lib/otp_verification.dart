import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:qf/colors.dart';
import 'package:qf/globalurls.dart';
import 'package:qf/home_page.dart';
import 'package:qf/login.dart';
import 'package:qf/backstack_based_main_app_screen.dart';
import 'package:qf/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './sheet_curve.dart';

class OTPScreen extends StatefulWidget {
  // const OTPScreen({Key? key}) : super(key: key);
  String method;
  String name;
  String email;
  String mobile;
  // String otp;

  OTPScreen(
      {required this.method,
      required this.name,
      required this.email,
      required this.mobile});

  @override
  State<OTPScreen> createState() => OTPScreenState(
      method: this.method,
      name: this.name,
      email: this.email,
      mobile: this.mobile);
}

class OTPScreenState extends State<OTPScreen> {
  String method;
  String name;
  String email;
  String mobile;
  // String otp;

  OTPScreenState(
      {required this.method,
      required this.name,
      required this.email,
      required this.mobile});

  // TextEditingController loginMoblieNumber = TextEditingController();
  TextEditingController otpCtrl = TextEditingController();
  int totaltime = 60;
  bool resendEnabled = false;
  bool shouldStop = true;
  bool isNotDisabled = true;
  bool timeEnded = false;

  StreamController<ErrorAnimationType> errorController =
      StreamController<ErrorAnimationType>();

  var periodicTimer;

  void verifyLoginAndRegister(String theOTP) async {
    // Debug fields
    print(this.name + " " + this.mobile + " " + this.email + " " + this.method);

    if (method == "sign_up") {
      // Sign up logic here...
      setState(() {
        isNotDisabled = false;
      });
      print(theOTP);
      var dio = Dio();
      var formData = FormData.fromMap({
        "otp": theOTP,
        "name": this.name,
        "mobile": this.mobile,
        "email": this.email
      });
      final response = await dio.post(verifyRegisterOtpUrl(), data: formData);
      var res = json.decode(response.data);
      setState(() {
        isNotDisabled = true;
      });
      print(res);
      if (res["error"] == true) {
        SnackBar snk = new SnackBar(
          content: Text(res['message']),
        );
        ScaffoldMessenger.of(context).showSnackBar(snk);
      } else {
        // SnackBar snk = new SnackBar(
        //   content: Text(res['message']),
        // );
        SnackBar snk = new SnackBar(
          content: Text('Login successful'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snk);
        shouldStop = true;

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isLoggedIn', true);
        prefs.setString('name', this.name.toString());
        prefs.setString('mobile', this.mobile.toString());
        prefs.setString('email', this.email.toString());
        prefs.setString('user_id', res["user_id"].toString());
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
      }
    }
    else if(method == 'login'){
      // Verify login logic here...
      setState(() {
        isNotDisabled = false;
      });
      print(theOTP);
      var dio = Dio();
      var formData = FormData.fromMap({
        "otp": theOTP,
        // "name": this.name,
        "mobile": this.mobile,
        // "email": this.email,
        'page_type': this.method
      });
      final response = await dio.post(verifyLoginOtpUrl(), data: formData);
      var res = json.decode(response.data);
      print(res);
      setState(() {
        isNotDisabled = true;
      });
      if (res["error"] == true) {
        SnackBar snk = new SnackBar(
          content: Text(res['message']),
        );
        ScaffoldMessenger.of(context).showSnackBar(snk);
      } else {
        SnackBar snk = new SnackBar(
          content: Text(res['message']),
        );
        ScaffoldMessenger.of(context).showSnackBar(snk);
        shouldStop = true;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isLoggedIn', true);
        prefs.setString('name', res["user_name"].toString());
        prefs.setString('mobile', this.mobile.toString());
        prefs.setString('email', res['user_email'].toString());
        prefs.setString('user_id', res["user_id"].toString());
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
      }
    }
    else{
      print("Error : Invalid method");
      SnackBar snk = new SnackBar(
          content: Text("Invalid method"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snk);
    }
  }

  void resendOTP() async {
    var dio = Dio();
      var formData = FormData.fromMap({
        "mobile": this.mobile,
      });
      final response = await dio.post(resendOTPUrl(), data: formData);
      var res = json.decode(response.data);
      print(res);
      SnackBar snk = new SnackBar(
          content: Text(res["message"]),
        );
        ScaffoldMessenger.of(context).showSnackBar(snk);

    setState(() {
         totaltime = 60;
         resendEnabled = false;
         shouldStop = true;
         isNotDisabled = true;
         timeEnded = false;
         resendOtpTimer();
    });
        
  }

  void resendOtpTimer(){
    shouldStop = false;

    periodicTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        
        // Update user about remaining time
        setState(() {
          if (timer.isActive) {
            print("Timer Active...");
            if (shouldStop) {
            timer.cancel();
          }
        }
          if(totaltime <= 0){
            resendEnabled = true;
            shouldStop = true;
            totaltime = 0;
            timeEnded = true;
          }
          else{
            totaltime--;
          }
          
        });
        
      });
    

  }

  @override
  void dispose() {
    super.dispose();
    print("[i] Disposing timer periodic....");
    periodicTimer?.cancel();
    print("[+] Dispose executed...");
  }

  @override
  void initState() {
    // TODO: implement initState
    resendOtpTimer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(children: [
          // inkCurve("OTP Verification", context),
          SizedBox(
            height: 30,
          ),
          SvgPicture.asset('assets/img/otp verification.svg'),

          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'OTP ',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 24,
                    color: Color(0xffF16624),
                  ),
                ),
                TextSpan(
                  text: ' Verification',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 24,
                    color: Color(0xff244D73),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 8,
          ),
          // SvgPicture.asset('otp verification.svg'),
          Container(
              child: Align(
                  alignment: Alignment.center,
                  child: Text("Enter OTP sent on " + '+91 '+ mobile,
                      style:
                          TextStyle(fontSize: 14, color: Color(0xff244D73))))),
          SizedBox(
            height: 40,
          ),

          Container(
            margin: EdgeInsets.only(left: 50, right: 50),
            child: PinCodeTextField(
              keyboardType: TextInputType.number,
              length: 4,
              obscureText: false,
              animationType: AnimationType.scale,
              cursorColor: primary(),
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.circle,
                borderRadius: BorderRadius.circular(2),
                fieldHeight: 50,
                fieldWidth: 50,
                activeFillColor: Colors.white,
                selectedFillColor: Colors.white,
                inactiveFillColor: Colors.white,
                inactiveColor: Colors.grey[300],
                activeColor: Colors.black,borderWidth: 1,
                selectedColor: Colors.grey[300],
              ),
              animationDuration: Duration(milliseconds: 300),
              enableActiveFill: true,
              controller: otpCtrl,
              onCompleted: (v) {
                print("Completed");
                print(v);
              },
              onChanged: (value) {},
              validator: (value) {
                if (value!.isEmpty || !RegExp(r'(.{4,})').hasMatch(value)) {
                  return "";
                } else {
                  return null;
                }
              },
              appContext: context,
            ),
          ),
          SizedBox(height: 10,),

          (isNotDisabled) ? InkWell(
            onTap: () {
              verifyLoginAndRegister(otpCtrl.text);
            },
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              child: Container(
                width: MediaQuery.of(context).size.width *0.6,
                height: 45,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    end:  Alignment(0.0, 0.4),
                    begin:  Alignment(0.0, -1),
                    colors: [Color(0xFFFF7534), Color(0xFFE35511)],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),

                child: Center(
                  child: Text(
                    'Verify',
                    style:TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w400
                    ),
                  ),
                ),
              ),
            ),
          ): Center(child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Text("Please wait while we verify..."),
              CircularProgressIndicator()
            ],
          )),
          // Container(
          //   margin: EdgeInsets.all(25),
          //   child: SizedBox(
          //       width: MediaQuery.of(context).size.width,
          //       height: 45,
          //       child: (isNotDisabled) ? ElevatedButton(
          //         style: ButtonStyle(
          //             backgroundColor: MaterialStateProperty.all<Color>(primary()),
          //             elevation: MaterialStateProperty.all(0),
          //             shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          //                 RoundedRectangleBorder(
          //                     borderRadius: BorderRadius.circular(10.0)))),
          //         onPressed: () {
          //           verifyLoginAndRegister(otpCtrl.text);
          //         },
          //         child: Text(
          //           "Submit",
          //           style: TextStyle(fontSize: 20),
          //         ),
          //       ) : Center(child: Row(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         crossAxisAlignment: CrossAxisAlignment.center,
          //         children: [
          //           // Text("Please wait while we verify..."),
          //           CircularProgressIndicator()
          //         ],
          //       ))),
          // ),
          SizedBox(height: 10,),
          Container(
              child: Align(
                  alignment: Alignment.center,
                  child: !timeEnded ?
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: 'Resend Code in ',
                    style: TextStyle(fontSize: 14, color: Colors.black)),
                        TextSpan(
                          text: '00:${totaltime.toString()}',
                          style: TextStyle(fontSize: 15, color: Colors.deepOrange)
                        ),
                      ],
                    ),
                  ) : TextButton(
              style: ButtonStyle(overlayColor: resendEnabled ? MaterialStateProperty.all<Color>(primary()) : MaterialStateProperty.all<Color>(Color.fromARGB(255, 224, 224, 224))),
              onPressed: () {
                if(resendEnabled){
                  resendOTP();
                }
                else{
                  // SnackBar snk = new SnackBar(
                  //   content: Text("Please wait (60 sec)"),
                  // );
                  // ScaffoldMessenger.of(context).showSnackBar(snk);
                }
              },
              child: Text("Resend OTP", style: TextStyle(color: resendEnabled ? Colors.black : Colors.grey))), )),
          SizedBox(
            height: 10,
          ),
          // TextButton(
          //     style: ButtonStyle(overlayColor: resendEnabled ? MaterialStateProperty.all<Color>(primary()) : MaterialStateProperty.all<Color>(Color.fromARGB(255, 224, 224, 224))),
          //     onPressed: () {
          //       if(resendEnabled){
          //         resendOTP();
          //       }
          //       else{
          //         // SnackBar snk = new SnackBar(
          //         //   content: Text("Please wait (60 sec)"),
          //         // );
          //         // ScaffoldMessenger.of(context).showSnackBar(snk);
          //       }
          //     },
          //     child: Text("Resend OTP", style: TextStyle(color: resendEnabled ? Colors.black : Colors.grey))),


        ]),
      ),
    );
  }
}
