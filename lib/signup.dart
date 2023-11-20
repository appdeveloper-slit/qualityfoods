import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qf/colors.dart';
import 'package:qf/globalurls.dart';
import 'package:qf/otp_verification.dart';
import 'package:qf/values/colors.dart';
import 'package:validators/validators.dart';
import './sheet_curve.dart';
import './login.dart';
import 'manage/static_method.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  TextEditingController signUpName = TextEditingController();
  TextEditingController signUpEmail = TextEditingController();
  TextEditingController signUpMobileNumber = TextEditingController();
  bool isNotdisabled = true; 

  void startSignUp() async {
    setState(() {
      isNotdisabled = false;
    });
    var dio = Dio();
    var formData = FormData.fromMap(
        {'mobile': signUpMobileNumber.text.toString(), 'type': 'sign_up'});
    final response = await dio.post(sendOTP(), data: formData);
    var res = json.decode(response.data);
    setState(() {
      isNotdisabled = true;
    });
    print(res);
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
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OTPScreen(
                method: 'sign_up',
                name: signUpName.text.toString(),
                email: signUpEmail.text.toString(),
                mobile: signUpMobileNumber.text.toString()),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(children: [
          // inkCurve("Sign Up", context),
          SizedBox(
            height: 30,
          ),
          SvgPicture.asset('assets/img/singupimg.svg'),
          SizedBox(
            height: 8,
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Sign',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 24,
                    color: Color(0xffF16624),
                  ),
                ),
                TextSpan(
                  text: ' Up',
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
          Align(
              alignment: Alignment.center,
              child: Text("Hello! Register to get started",
                  style: TextStyle(
                      fontSize: 14, color: Color(0xff00182E)))),
          Container(
              margin: EdgeInsets.fromLTRB(25, 2, 25, 25),
              child: Column(
                children: [
                  // Container(
                  //     child: Align(
                  //         alignment: Alignment.centerLeft,
                  //         child: Text("Name",
                  //             style: TextStyle(
                  //                 fontSize: 16, color: Colors.deepOrange)))),
                  SizedBox(
                    height: 30,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    controller: signUpName,
                    decoration: InputDecoration(
                        counterText: "",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(35),
                            borderSide: BorderSide(color: Colors.grey,)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Clr().textPrimaryColor, width: 1),
                          borderRadius: BorderRadius.circular(35),
                        ),
                        contentPadding: EdgeInsets.only(left: 20),
                        hintText: "Enter Name",
                        // filled: true,
                        fillColor: Colors.grey[100],
                        // prefixIcon: Icon(Icons.person_outline,
                        //     size: 30, color: primary()),
                        // prefixIconColor: primary()
                      ),
                  )
                ],
              )),

              Container(
              margin: EdgeInsets.fromLTRB(25, 2, 25, 25),
              child: Column(
                children: [
                  // Container(
                  //     child: Align(
                  //         alignment: Alignment.centerLeft,
                  //         child: Text("Email Id",
                  //             style: TextStyle(
                  //                 fontSize: 16, color: Colors.deepOrange)))),
                  // SizedBox(
                  //   height: 4,
                  // ),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: signUpEmail,
                    decoration: InputDecoration(
                        counterText: "",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(35),

                            borderSide: BorderSide(color: Colors.grey,)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Clr().textPrimaryColor, width: 1),
                          borderRadius: BorderRadius.circular(35),
                        ),
                        // contentPadding: EdgeInsets.only(left: 20),
                        // border: InputBorder.none,
                        hintText: "Enter Email Address",
                        // filled: true,
                        // fillColor: Colors.transparent,
                        contentPadding: EdgeInsets.only(left: 20),
                        // prefixIcon: Icon(
                        //   Icons.email_outlined,
                        //   size: 30,
                        //   color: primary(),
                        // ),
                        // prefixIconColor: primary()
                      ),
                  )
                ],
              )),


          Container(
              margin: EdgeInsets.fromLTRB(25, 2, 25, 25),
              child: Column(
                children: [
                  // Container(
                  //     child: Align(
                  //         alignment: Alignment.centerLeft,
                  //         child: Text("Mobile Number",
                  //             style: TextStyle(
                  //                 fontSize: 16, color: Colors.deepOrange)))),
                  // SizedBox(
                  //   height: 8,
                  // ),
                  TextFormField(
                    maxLength: 10,
                    keyboardType: TextInputType.number,
                    controller: signUpMobileNumber,
                    decoration: InputDecoration(
                        counterText: "",

                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(35),

                            borderSide: BorderSide(color: Colors.grey,)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Clr().textPrimaryColor, width: 1),
                          borderRadius: BorderRadius.circular(35),
                        ),
                        contentPadding: EdgeInsets.only(left: 20),
                        hintText: "Enter Mobile Number",
                        // filled: true,
                        // fillColor: Colors.grey[100],
                        // prefixIcon: Icon(
                        //   Icons.phone_in_talk_outlined,
                        //   size: 30,
                        //   color: primary(),
                        // ),
                        // prefixIconColor: primary()
                      ),
                  ),
                ],
              )),

          (isNotdisabled) ? InkWell(
            onTap: () {
              if (isLength(signUpName.text, 3)) {
                if (isLength(signUpMobileNumber.text, 10)) {
                  if(isEmail(signUpEmail.text)){
                    startSignUp();
                  }
                  else {
                    SnackBar sn = SnackBar(content: Text("Email invalid"));
                    ScaffoldMessenger.of(context).showSnackBar(sn);
                  }

                } else {
                  SnackBar sn = SnackBar(content: Text("Number should be at least 10 digits..."));
                  ScaffoldMessenger.of(context).showSnackBar(sn);
                }
              } else {
                SnackBar sn = SnackBar(content: Text("Name should be at least three characters long..."));
                ScaffoldMessenger.of(context).showSnackBar(sn);
              }
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
                    'Sign Up',
                    style:TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w400
                    ),
                  ),
                ),
              ),
            ),
          ): Center(child: Text("Please wait...")),

          // Container(
          //   margin: EdgeInsets.all(25),
          //   child: SizedBox(
          //       width: MediaQuery.of(context).size.width,
          //       height: 45,
          //       child: (isNotdisabled) ? ElevatedButton(
          //         style: ButtonStyle(
          //             backgroundColor:
          //                 MaterialStateProperty.all<Color>(primary()),
          //             elevation: MaterialStateProperty.all(0),
          //             shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          //                 RoundedRectangleBorder(
          //                     borderRadius: BorderRadius.circular(10.0)))),
          //         onPressed: () {
          //           if (isLength(signUpName.text, 3)) {
          //             if (isLength(signUpMobileNumber.text, 10)) {
          //               if(isEmail(signUpEmail.text)){
          //                 startSignUp();
          //               }
          //               else {
          //               SnackBar sn = SnackBar(content: Text("Email invalid"));
          //               ScaffoldMessenger.of(context).showSnackBar(sn);
          //             }
          //
          //             } else {
          //               SnackBar sn = SnackBar(content: Text("Number should be at least 10 digits..."));
          //               ScaffoldMessenger.of(context).showSnackBar(sn);
          //             }
          //           } else {
          //             SnackBar sn = SnackBar(content: Text("Name should be at least three characters long..."));
          //             ScaffoldMessenger.of(context).showSnackBar(sn);
          //           }
          //         },
          //
          //         child: Text(
          //           "Sign Up",
          //           style: TextStyle(fontSize: 20),
          //         ),
          //       ) : Center(child: Text("Please wait..."))),
          // ),
          SizedBox(height: 12,),
          Container(
            child: InkWell(
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              },
              child: RichText(
            text: TextSpan(children: [
            TextSpan(
              text: "Already have an account?",
              style: TextStyle(
                fontSize: 14,
                color: Color(0xff00182E),
              ),
            ),
              TextSpan(
                  text: " Login Now",
                  style: TextStyle(color: Color.fromARGB(255, 240, 83, 16),fontSize: 14,)),
              ]),
      ),
            ),
          ),
          SizedBox(
            height: 40,
          ),
          Container(
            margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
            child: Align(
              alignment: Alignment.center,
              child:InkWell(
                onTap: (){
                  STM().openWeb('https://qualityfoods.info/terms.php');
                },
                child: RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: "By Continuing I agree to",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xff00182E),
                      ),
                    ),
                    TextSpan(
                        text: " Terms & Conditions",
                        style: TextStyle(color:  Color(0xff065197),fontSize: 14,)),
                  ]),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 30,
          )
        ]),
      ),
    );
  }
}
