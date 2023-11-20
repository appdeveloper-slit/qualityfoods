import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qf/colors.dart';
import 'package:qf/globalurls.dart';
import 'package:qf/values/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:validators/validators.dart';

import './appbar_gradientlook.dart';
import './login.dart';
import 'bottom_navigation/bottom_navigation.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({Key? key}) : super(key: key);

  @override
  State<MyProfileScreen> createState() => MyProfileScreenState();
}

class MyProfileScreenState extends State<MyProfileScreen> {
  late BuildContext ctx;
  TextEditingController profileName = TextEditingController();
  TextEditingController profileEmail = TextEditingController();
  TextEditingController profileNumber = TextEditingController();
  TextEditingController profilePassword = TextEditingController();
  TextEditingController newMobileNumber = TextEditingController();
  TextEditingController otpField = TextEditingController();
  bool isOTPsent = false;

  // String errorText = "";
  bool isLoggedIn = false;

  bool otpsendload = true;

  // String errorText = "";
  ValueNotifier<String> errorText = ValueNotifier<String>('');
  ValueNotifier<int> totaltime = ValueNotifier<int>(60);
  ValueNotifier<bool> resendEnabled = ValueNotifier<bool>(false);
  bool shouldStop = true;
  bool isNotDisabled = true;
  var periodicTimer;

  void updateCurrentProfile() async {
    SharedPreferences sp = await SharedPreferences.getInstance();

    if (sp.getBool('isLoggedIn') == false) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
    profileName.text = sp.getString('name').toString();
    profileEmail.text = sp.getString('email').toString();
    profileNumber.text = sp.getString('mobile').toString();
    // profileName.text = sp.getString('name').toString();
  }

  checkLoggedIn() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    if (sp.getBool("isLoggedIn") != null) {
      setState(() {
        isLoggedIn = true;
      });
      print("Looks logged in...");
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyProfileScreen()));
    } else {
      isLoggedIn = false;
      print("looks not logged in...");
      Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }

  void initState() {
    checkLoggedIn();
    // setState(() {
    //   isLoggedIn = isLoggedIn;
    // });
    updateCurrentProfile();
    super.initState();
  }

  void sendAnOTP() async {
    setState(() {
      otpsendload = false;
    });
    var dio = Dio();
    var formData =
        FormData.fromMap({'mobile': newMobileNumber.text.toString()});
    final response = await dio.post(sendOTP(), data: formData);
    var res = json.decode(response.data);
    print(res);
    setState(() {
      isOTPsent = true;
      otpsendload = true;
      errorText.value = "OTP sent please enter";
    });
    if (res["error"] == true) {
      errorText.value = res['message'].toString();
    } else {
      resendOtpTimer();
      errorText.value = res['message'].toString();
    }
  }

  void saveNameAndEmail() async {
    var dio = Dio();
    SharedPreferences sp = await SharedPreferences.getInstance();
    var formData = FormData.fromMap({
      'user_id': sp.getString('user_id').toString(),
      'name': profileName.text.toString(),
      'email': profileEmail.text.toString()
    });
    final response = await dio.post(updateProfileUrl(), data: formData);
    var res = json.decode(response.data);
    print(res);
    if (res["error"] == true) {
      SnackBar sn = SnackBar(content: Text(res['message'].toString()));
      ScaffoldMessenger.of(context).showSnackBar(sn);
    } else {
      SharedPreferences sp = await SharedPreferences.getInstance();
      sp.setString("name", profileName.text.toString());
      sp.setString("email", profileEmail.text.toString());
      SnackBar sn = SnackBar(content: Text(res['message'].toString()));
      ScaffoldMessenger.of(context).showSnackBar(sn);
    }
  }

  // void verifyOTPAndSaveMobile(setState, ctx) async {
  //   // var dio = Dio();
  //   // SharedPreferences sp = await SharedPreferences.getInstance();
  //   // var formData =
  //   //     FormData.fromMap({
  //   //     'mobile': newMobileNumber.text.toString(),
  //   //     'user_id' : sp.getString('user_id').toString(),
  //   //     'otp' : otpField.text.toString()
  //   //     });
  //   // final response = await dio.post(updateProfileMobileUrl(), data: formData);
  //   // var res = json.decode(response.data);
  //   // print(res);

  //   // if (res["error"] == true) {
  //   //   setState((setState){
  //   //     errorText = res['message'].toString();
  //   //   });
  //   // } else {
  //   //   sp.setString('mobile', newMobileNumber.text);
  //   //   setState((setState) {
  //   //     errorText = "Verified and saved!";
  //   //   });
  //   // }
  // }

  void resendOtpTimer() {
    shouldStop = false;
    resendEnabled.value = false;
    totaltime.value = 60;

    periodicTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Update user about remaining time
      setState(() {
        if (timer.isActive) {
          print("Timer Active...");
          if (shouldStop) {
            timer.cancel();
          }
        }
        if (totaltime.value <= 0) {
          resendEnabled.value = true;
          shouldStop = true;
          totaltime.value = 0;
        } else {
          totaltime.value--;
        }
      });
    });
  }

  void resendtheOTP() async {
    errorText.value = "Please wait...";
    var dio = Dio();
    var formData = FormData.fromMap({
      "mobile": newMobileNumber.text.toString(),
    });
    final response = await dio.post(resendOTPUrl(), data: formData);
    var res = json.decode(response.data);
    print(res);
    // SnackBar snk = new SnackBar(
    //     content: Text(res["message"]),
    //   );
    errorText.value = res["message"].toString();
    resendOtpTimer();
    // ScaffoldMessenger.of(context).showSnackBar(snk);
  }

  void changeMobilePopUp() async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          newMobileNumber.text = "";
          errorText.value = "";
          otpsendload = true;
          isOTPsent = false;
          otpField.text = "";
          totaltime.value = 60;
          return StatefulBuilder(builder: (context, setState) {
            errorText.addListener(() {
              setState(() {
                errorText = errorText;
              });
            });

            totaltime.addListener(() {
              setState(() {
                totaltime = totaltime;
              });
            });

            resendEnabled.addListener(() {
              setState(() {
                resendEnabled = resendEnabled;
              });
            });

            return SizedBox(
              // height: (!(MediaQuery.of(context).size.height < 500))
              //     ? MediaQuery.of(context).size.height - 800
              //     : MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: AlertDialog(
                // insetPadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                title: Center(child: Text("Change mobile number")),
                content: SizedBox(
                  // height: (!(MediaQuery.of(context).size.height < 500))
                  //     ? MediaQuery.of(context).size.height -
                  //         (isOTPsent ? 650 : 700)
                  //     : MediaQuery.of(context).size.height,
                  // width:
                  //     MediaQuery.of(context).size.width,
                  child: SingleChildScrollView(
                    physics: const ScrollPhysics(),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.only(
                          top: 25, left: 10, right: 10, bottom: 25),
                      child: Column(
                          // crossAxisAlignment:
                          //     CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextFormField(
                              keyboardType: TextInputType.number,
                              controller: newMobileNumber,
                              maxLength: 10,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Mobile Number",
                                  filled: true,
                                  counterText: "",
                                  fillColor: Colors.grey[100],
                                  prefixIcon: Icon(
                                    Icons.phone_in_talk_outlined,
                                    color: primary(),
                                  ),
                                  prefixIconColor: primary()),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            (isOTPsent)
                                ? TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: otpField,
                                    maxLength: 4,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Enter OTP",
                                        filled: true,
                                        counterText: "",
                                        fillColor: Colors.grey[100],
                                        prefixIcon: Icon(
                                          Icons.lock_outline,
                                          color: primary(),
                                        ),
                                        prefixIconColor: primary()),
                                  )
                                : Container(),
                            SizedBox(
                              height: 15,
                            ),
                            (errorText.value.toString().isNotEmpty)
                                ? Center(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Icon(Icons.info_outline),
                                        Expanded(
                                            child: Container(
                                                child: Text(errorText.value),
                                                margin:
                                                    EdgeInsets.only(left: 10))),
                                      ],
                                    ),
                                  )
                                : Text(errorText.value.toString()),
                            isOTPsent
                                ? resendEnabled.value
                                    ? Center(
                                        child: InkWell(
                                          onTap: () {
                                            resendtheOTP();
                                          },
                                          child: RichText(
                                              text: TextSpan(
                                                  text: "",
                                                  children: [
                                                    TextSpan(
                                                        text:
                                                            "If you didn't receive code! "),
                                                    TextSpan(
                                                      text: "Resend",
                                                      style: TextStyle(
                                                          color: primary(),
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                  ],
                                                  style: TextStyle(
                                                      color: Colors.black))),
                                        ),
                                      )
                                    : Text("Resend OTP in " +
                                        totaltime.value.toString() +
                                        " seconds")
                                : Text("")
                          ]),
                    ),
                  ),
                ),
                actionsAlignment: MainAxisAlignment.spaceEvenly,
                actions: [
                  TextButton(
                      onPressed: () {
                        isOTPsent = false;
                        Navigator.of(context).pop();
                      },
                      child: Text("Cancel")),
                  (isOTPsent)
                      ? otpsendload
                          ? SizedBox(
                              child: ElevatedButton(
                                  style: ButtonStyle(
                                      elevation:
                                          MaterialStateProperty.all<double>(0)),
                                  onPressed: () async {
                                    if (isLength(otpField.text, 4)) {
                                      // verifyOTPAndSaveMobile(setState, context);
                                      setState(() {
                                        otpsendload = false;
                                      });

                                      var dio = Dio();
                                      SharedPreferences sp =
                                          await SharedPreferences.getInstance();
                                      var formData = FormData.fromMap({
                                        'mobile':
                                            newMobileNumber.text.toString(),
                                        'user_id': sp.getString('user_id'),
                                        'otp': otpField.text.toString()
                                      });
                                      final response = await dio.post(
                                          updateProfileMobileUrl(),
                                          data: formData);
                                      var res = json.decode(response.data);
                                      print(res);

                                      if (res["error"] == true) {
                                        setState(() {
                                          otpsendload = true;
                                          errorText.value =
                                              res['message'].toString();
                                        });
                                      } else {
                                        sp.setString(
                                            'mobile', newMobileNumber.text);
                                        profileNumber.text =
                                            sp.getString('mobile').toString();
                                        setState(() {
                                          otpsendload = true;
                                          errorText.value =
                                              "Verified and saved!";
                                        });
                                        Navigator.of(context).pop();
                                      }
                                    }
                                  },
                                  child: Text("Verify")),
                            )
                          : SizedBox(
                              child: CircularProgressIndicator(),
                              width: 20,
                              height: 20,
                            )
                      : otpsendload
                          ? SizedBox(
                              child: ElevatedButton(
                                  style: ButtonStyle(
                                      elevation:
                                          MaterialStateProperty.all<double>(0)),
                                  onPressed: () {
                                    if (isLength(newMobileNumber.text, 10)) {
                                      sendAnOTP();

                                      setState(() {
                                        errorText = errorText;
                                        isOTPsent = isOTPsent;
                                      });
                                    } else {
                                      errorText.value = "Invalid mobile number";
                                      setState(
                                        () {
                                          errorText = errorText;
                                        },
                                      );
                                    }
                                  },
                                  child: Text("Send OTP")),
                            )
                          : SizedBox(
                              child: CircularProgressIndicator(),
                              width: 20,
                              height: 20,
                            ),
                ],
              ),
            );
          });
        }).then((value) {
      print("[i] Disposing timer periodic....");
      periodicTimer?.cancel();
      print("[+] Dispose executed...");
    });
  }

  //   void _onItemTapped(int index) {
  //   print(index);
  //   // setState(() {
  //   //   _selectedIndex = index;
  //   // });
  //   switch (index){
  //     case 0:
  //       Navigator.of(context).push(MaterialPageRoute(builder: ((context) => HomeScreen()))).then((_) { updateBadgeCount(); print("Cart update called");});
  //       break;
  //     case 1:
  //       Navigator.of(context).push(MaterialPageRoute(builder: ((context) => CategoriesScreen()))).then((_) { updateBadgeCount(); print("Cart update called");});
  //       break;
  //     case 2:
  //       Navigator.of(context).push(MaterialPageRoute(builder: ((context) => OfferScreen()))).then((_) { updateBadgeCount(); print("Cart update called");});
  //       break;
  //     case 3:
  //       Navigator.of(context).push(MaterialPageRoute(builder: ((context) => MyProfileScreen()))).then((_) { updateBadgeCount(); print("Cart update called");});
  //       break;
  //     case 4:
  //       Navigator.of(context).push(MaterialPageRoute(builder: ((context) => CartScreen()))).then((_) { updateBadgeCount(); print("Cart update called");});
  //       break;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    ctx = context;
    return Scaffold(
      bottomNavigationBar: bottomBarLayout(ctx, 3),
      // bottomNavigationBar: BottomNavigationBar(
      //     type: BottomNavigationBarType.fixed,
      //     items: <BottomNavigationBarItem>[
      //       BottomNavigationBarItem(
      //         icon: SvgPicture.asset("assets/img/Home.svg",),
      //         label: 'Home',
      //       ),
      //       BottomNavigationBarItem(
      //         icon: SvgPicture.asset("assets/img/Categories.svg",),
      //         label: 'Categories',
      //       ),
      //       BottomNavigationBarItem(
      //         icon: SvgPicture.asset("assets/img/Offers.svg",),
      //         label: 'Offers',
      //       ),
      //       BottomNavigationBarItem(
      //         icon: SvgPicture.asset("assets/img/My Profile.svg",),
      //         label: 'My Profile',
      //       ),
      //       // BottomNavigationBarItem(
      //       //   icon: contentInCart > 0 ? Badge(child: SvgPicture.asset("assets/img/Cart.svg",), badgeColor: primary(), badgeContent: Text(contentInCart.toString(), style: TextStyle(color: Colors.white),),) : SvgPicture.asset("assets/img/Cart.svg",),
      //       //   // icon: SvgPicture.asset("assets/img/Cart.svg"),
      //       //   label: 'Cart',
      //       // ),
      //     ],
      //     currentIndex: 0,
      //     showSelectedLabels: true,
      //     showUnselectedLabels: true,
      //     selectedItemColor: greyLite(),
      //     unselectedItemColor: greyLite(),
      //     selectedIconTheme: IconThemeData(size: 25.0, color: primary()),
      //     selectedLabelStyle: TextStyle(fontSize: 15.0, color: primary()),
      //     unselectedIconTheme: IconThemeData(size: 25.0, color:secondary()),
      //     unselectedLabelStyle: TextStyle(fontSize: 15.0, color:secondary()),
      //     onTap: _onItemTapped,
      //   ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Color(0xff244D73)),
        centerTitle: true,
        title: Text("My Profile",
            style: TextStyle(
                color: Color(0xff00182E),
                fontWeight: FontWeight.w500,
                fontSize: 18)),
        flexibleSpace: barGredient(),
      ),
      backgroundColor: Colors.white,
      body: isLoggedIn
          ? SingleChildScrollView(
              child: Column(children: [
                SizedBox(
                  height: 16,
                ),
                Container(
                    margin: EdgeInsets.fromLTRB(16, 2, 16, 16),
                    child: Column(
                      children: [
                        TextFormField(
                          keyboardType: TextInputType.text,
                          controller: profileName,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(35),
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                )),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Clr().textPrimaryColor, width: 1),
                              borderRadius: BorderRadius.circular(35),
                            ),
                            contentPadding:
                                EdgeInsets.only(left: 20, right: 10),
                            hintText: "Name",
                            // filled: true,
                            // fillColor: Colors.grey[100],
                            prefix: Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: SvgPicture.asset(
                                'assets/img/profileicon.svg',
                                height: 15,
                                width: 15,
                              ),
                            ),
                            // prefixIcon: SvgPicture.asset('assets/img/profileicon.svg',height: 5,width: 5,)
                            // prefixIconColor: Color(0xff00182E)
                          ),
                        )
                      ],
                    )),
                Container(
                    margin: EdgeInsets.fromLTRB(16, 2, 16, 16),
                    child: Column(
                      children: [
                        TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            controller: profileEmail,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(35),
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                  )),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Clr().textPrimaryColor, width: 1),
                                borderRadius: BorderRadius.circular(35),
                              ),
                              contentPadding: EdgeInsets.only(left: 20),
                              hintText: "Email",
                              // filled: true,
                              // fillColor: Colors.grey[100],
                              prefix: Padding(
                                padding: EdgeInsets.only(right: 8, top: 4),
                                child: SvgPicture.asset(
                                  'assets/img/emailicon.svg',
                                  height: 15,
                                  width: 15,
                                ),
                              ),
                            ))
                      ],
                    )),
                Container(
                    margin: EdgeInsets.fromLTRB(16, 2, 16, 16),
                    child: Column(
                      children: [
                        Row(children: [
                          Expanded(
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              // enabled: false,
                              controller: profileNumber,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(35),
                                    borderSide: BorderSide(
                                      color: Colors.grey,
                                    )),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Clr().textPrimaryColor, width: 1),
                                  borderRadius: BorderRadius.circular(35),
                                ),
                                contentPadding: EdgeInsets.only(left: 20),
                                hintText: "Mobile Number",
                                prefix: Padding(
                                  padding: EdgeInsets.only(right: 8, top: 4),
                                  child: SvgPicture.asset(
                                    'assets/img/phoneicon.svg',
                                    height: 15,
                                    width: 15,
                                  ),
                                ),
                                suffix: InkWell(
                                  onTap: () {
                                    changeMobilePopUp();
                                  },
                                  child: Padding(
                                    padding:
                                        EdgeInsets.only(left: 8, right: 20),
                                    child: SvgPicture.asset(
                                      'assets/img/editicon.svg',
                                      height: 15,
                                      width: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Container(
                          //   color: Colors.grey[100],
                          //   child: IconButton(
                          //       onPressed: () {
                          //         changeMobilePopUp();
                          //       },
                          //       color: primary(),
                          //       icon: Icon(
                          //         Icons.edit_outlined,
                          //         color: primary(),
                          //       )),
                          // ),
                        ])
                      ],
                    )),
                // Container(
                // margin: EdgeInsets.fromLTRB(25, 2, 25, 25),
                // child: Column(
                //   children: [

                //     TextFormField(
                //       keyboardType: TextInputType.visiblePassword,
                //       controller: profilePassword,
                //       decoration: InputDecoration(
                //           border: InputBorder.none,
                //           hintText: "Password",
                //           filled: true,
                //           fillColor: Colors.grey[100],
                //           suffixIcon: Icon(Icons.edit_outlined, color: primary(),),
                //           prefixIcon: Icon(Icons.lock_outlined, color: primary(),),
                //           prefixIconColor: primary()),
                //     )
                //   ],
                // )),
                SizedBox(
                  height: 12,
                ),
                Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: 45,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        end: Alignment(0.0, 0.4),
                        begin: Alignment(0.0, -1),
                        colors: [Color(0xFF065197), Color(0xFF337ec4)],
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        primary: Colors.transparent,
                        onSurface: Colors.transparent,
                        shadowColor: Colors.transparent,
                        //make color or elevated button transparent
                      ),
                      onPressed: () async {
                        SharedPreferences sp =
                            await SharedPreferences.getInstance();
                        // if(profileName.text.toString() == sp.getString("name").toString() || profileEmail.text.toString() == sp.getString("email").toString())
                        if (isLength(profileName.text.toString(), 3)) {
                          if (isEmail(profileEmail.text)) {
                            saveNameAndEmail();
                          } else {
                            showDialog(
                                context: context,
                                builder: (ctx) {
                                  return AlertDialog(
                                    content: Text("Enter a valid email"),
                                  );
                                });
                          }
                        } else {
                          showDialog(
                              context: context,
                              builder: (ctx) {
                                return AlertDialog(
                                  content: Text("Enter a valid name"),
                                );
                              });
                        }
                      },
                      child: Center(
                        child: Text(
                          'Update',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    )),
                // Container(
                //   margin: EdgeInsets.all(25),
                //   child: SizedBox(
                //       width: MediaQuery.of(context).size.width,
                //       height: 45,
                //       child: ElevatedButton(
                //         style: ButtonStyle(
                //             backgroundColor:
                //                 MaterialStateProperty.all<Color>(primary()),
                //             elevation: MaterialStateProperty.all(0),
                //             shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                //                 RoundedRectangleBorder(
                //                     borderRadius: BorderRadius.circular(10.0)))),
                //         onPressed: () async {
                //           SharedPreferences sp = await SharedPreferences.getInstance();
                //           // if(profileName.text.toString() == sp.getString("name").toString() || profileEmail.text.toString() == sp.getString("email").toString())
                //           if(isLength(profileName.text.toString(), 3)){
                //             if(isEmail(profileEmail.text)){
                //               saveNameAndEmail();
                //             }
                //             else{
                //               showDialog(context: context, builder: (ctx){
                //                return AlertDialog(content: Text("Enter a valid email"),);
                //               });
                //             }
                //           }
                //           else{
                //             showDialog(context: context, builder: (ctx){
                //                return AlertDialog(content: Text("Enter a valid name"),);
                //               });
                //           }
                //
                //         },
                //         child: Text(
                //           "Save",
                //           style: TextStyle(fontSize: 20),
                //         ),
                //       )),
                // ),
                SizedBox(
                  height: 8,
                ),
              ]),
            )
          : Container(
              margin: EdgeInsets.only(top: 50),
              child: Center(
                child: Column(
                  children: [
                    Text("Please login to view your profile"),
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()));
                        },
                        child: Text("Login"))
                  ],
                ),
              ),
            ),
    );
  }
}
