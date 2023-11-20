import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qf/globalurls.dart';
import 'package:qf/otp_verification.dart';
import 'package:qf/values/colors.dart';
import 'package:validators/validators.dart';
import './signup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  TextEditingController loginMoblieNumber = TextEditingController();
  bool isNotdisabled = true;

  void startLogin() async {
    setState(() {
      isNotdisabled = false;
    });
    var dio = Dio();
    var formData = FormData.fromMap(
        {'mobile': loginMoblieNumber.text.toString(), 'type': 'login'});
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
                method: 'login',
                name: '',
                email: 'loginnonrequiredemail@email.com',
                mobile: loginMoblieNumber.text.toString()),
          ));
    }
  }

  void initState() {
    //
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // bottomNavigationBar: bottomNavBar(),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(children: [
          SizedBox(
            height: 30,
          ),
          SvgPicture.asset('assets/img/sign in.svg'),
          SizedBox(
            height: 8,
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Welcome',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 24,
                    color: Color(0xffF16624),
                  ),
                ),
                TextSpan(
                  text: '  Back',
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
          Container(
              margin: EdgeInsets.fromLTRB(25, 2, 25, 25),
              child: Column(
                children: [
                  Container(
                      child: Align(
                          alignment: Alignment.center,
                          child: Text("Welcome back! Glad to see you again!",
                              style: TextStyle(
                                  fontSize: 14, color: Color(0xff00182E))))),
                  SizedBox(
                    height: 50,
                  ),
                  TextFormField(
                    maxLength: 10,
                    keyboardType: TextInputType.number,
                    controller: loginMoblieNumber,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(35),
                          borderSide: BorderSide(
                            color: Colors.grey,
                          )),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Clr().textPrimaryColor, width: 1),
                        borderRadius: BorderRadius.circular(35),
                      ),
                      contentPadding: EdgeInsets.only(left: 20),
                      hintText: "Enter Mobile Number",
                      filled: true,
                      counterText: "",
                      // contentPadding: EdgeInsets.symmetric(vertical: 14,horizontal: 12),
                      fillColor: Colors.transparent,
                      // prefixIcon: Icon(Icons.phone_in_talk_outlined, size: 30, color: primary(),),
                      // prefixIconColor: primary()
                    ),
                  )
                ],
              )),
          // Container(
          //   margin: EdgeInsets.symmetric(horizontal: 25,vertical: 15),
          //   child: SizedBox(
          //       width: MediaQuery.of(context).size.width,
          //       height: 45,
          //       child: (isNotdisabled) ? ElevatedButton(
          //         style: ButtonStyle(
          //           backgroundColor: MaterialStateProperty.all<Color>(primary()),
          //             elevation: MaterialStateProperty.all(0),
          //             shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          //                 RoundedRectangleBorder(
          //                     borderRadius: BorderRadius.circular(10.0)))),
          //         onPressed: () {
          //           if(isLength(loginMoblieNumber.text, 10)){
          //             startLogin();
          //           }
          //           else{
          //             SnackBar sn = SnackBar(content: Text("Number should be at least 10 digits..."));
          //               ScaffoldMessenger.of(context).showSnackBar(sn);
          //           }
          //         },
          //         child: Text(
          //           "Sign In",
          //           style: TextStyle(fontSize: 20),
          //         ),
          //       ) : Center(child: Text("Please wait..."))),
          // ),
          (isNotdisabled)
              ? InkWell(
                  onTap: () {
                    if (isLength(loginMoblieNumber.text, 10)) {
                      startLogin();
                    } else {
                      SnackBar sn = SnackBar(
                          content:
                              Text("Number should be at least 10 digits..."));
                      ScaffoldMessenger.of(context).showSnackBar(sn);
                    }
                  },
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      height: 45,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          end: Alignment(0.0, 0.4),
                          begin: Alignment(0.0, -1),
                          colors: [Color(0xFFFF7534), Color(0xFFE35511)],
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                  ),
                )
              : Center(child: Text("Please wait...")),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: SizedBox(
          //       width: MediaQuery.of(context).size.width,
          //       height: 45,
          //       child: (isNotdisabled) ? ElevatedButton(
          //
          //         style: ButtonStyle(
          //             backgroundColor: MaterialStateProperty.all<Color>(primary()),
          //             elevation: MaterialStateProperty.all(0),
          //             shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          //                 RoundedRectangleBorder(
          //                     borderRadius: BorderRadius.circular(10.0)))),
          //         onPressed: () {
          //           if(isLength(loginMoblieNumber.text, 10)){
          //             startLogin();
          //           }
          //           else{
          //             SnackBar sn = SnackBar(content: Text("Number should be at least 10 digits..."));
          //             ScaffoldMessenger.of(context).showSnackBar(sn);
          //           }
          //         },
          //         child: Text(
          //           "Sign In",
          //           style: TextStyle(fontSize: 20),
          //         ),
          //       ) : Center(child: Text("Please wait..."))),
          // ),
          SizedBox(
            height: 12,
          ),
          Container(
            child: InkWell(
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => SignUpScreen()));
              },
              child: RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: "Don’t have an account? ",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xff00182E),
                    ),
                  ),
                  TextSpan(
                      text: "Register Now",
                      style: TextStyle(
                        color: Color.fromARGB(255, 240, 83, 16),
                        fontSize: 14,
                      )),
                ]),
              ),
            ),
          ),

          // Card(
          //   elevation: 2,
          //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          //   child: Container(
          //     width: MediaQuery.of(context).size.width *0.7,
          //     height: 45,
          //     decoration: BoxDecoration(
          //       gradient: LinearGradient(
          //         end:  Alignment(0.0, 0.4),
          //         begin:  Alignment(0.0, -1),
          //         colors: [Color(0xFFFF7534), Color(0xFFE35511)],
          //       ),
          //       borderRadius: BorderRadius.circular(25),
          //     ),
          //
          //     child: Center(
          //       child: Text(
          //         'Login',
          //         style:TextStyle(
          //             color: Colors.white,
          //             fontSize: 18,
          //             fontWeight: FontWeight.w500
          //         ),
          //       ),
          //     ),
          //   ),
          // )
        ]),
      ),
    );
  }
}
