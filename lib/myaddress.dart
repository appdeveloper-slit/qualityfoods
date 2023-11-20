import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qf/add_new_my_address.dart';
import 'package:qf/colors.dart';
import 'package:qf/login.dart';
import 'package:qf/values/colors.dart';
import 'package:qf/values/dimens.dart';
import 'package:qf/values/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:validators/validators.dart';

import './appbar_gradientlook.dart';
import 'globalurls.dart';

class MyAddressScreen extends StatefulWidget {
  const MyAddressScreen({Key? key}) : super(key: key);

  @override
  State<MyAddressScreen> createState() => MyAddressScreenState();
}

class MyAddressScreenState extends State<MyAddressScreen> {
  TextEditingController addressName = TextEditingController();
  TextEditingController addressNumber = TextEditingController();
  TextEditingController addressField = TextEditingController();
  TextEditingController addressLandmark = TextEditingController();
  bool isloaded = false;

  // TextEditingController addressPassword = TextEditingController();
  var pincodeDropDownItems = [];
  var dropdownvalue = "";

  List<Widget> addressItemList = [];

  void getPincodes() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    var dio = Dio();
    var formData = FormData.fromMap({
      'user_id': sp.getString("user_id").toString()
      // 'user_id' : '2'
    });
    final response = await dio.post(getAddressDataUrl(), data: formData);
    var res = json.decode(response.data);
    print(res);

    for (int i = 0; i < res['pin_codes'].length; i++) {
      pincodeDropDownItems.add(res['pin_codes'][i]['pincode'].toString());
    }
    dropdownvalue = res['pin_codes'][0]['pincode'].toString();

    setState(() {
      pincodeDropDownItems = pincodeDropDownItems;
      dropdownvalue = dropdownvalue;
    });
  }

  Widget addressItem(String name, String mobile, String address,
      String landmark, String pincode, String addresIdentifier) {
    return Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Clr().borderColor.withOpacity(0.7),
              spreadRadius: 0.1,
              blurRadius: 8,
              offset: Offset(0, 0), // changes position of shadow
            ),
          ],
        ),
        child: Card(
          elevation: 0,
          // margin: EdgeInsets.only(right: 4),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: Clr().borderColor, width: 0.2)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 8),
                        SvgPicture.asset(
                          'assets/img/profileicon.svg',
                          height: 15,
                          width: 15,
                        ),
                        SizedBox(width: 8),
                        Text(
                          name,
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            addressName.text = name;
                            addressNumber.text = mobile;
                            addressField.text = address;
                            addressLandmark.text = landmark;
                            dropdownvalue = pincode;

                            showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) {
                                  return StatefulBuilder(
                                      builder: (context, setState) {
                                    return AlertDialog(
                                      scrollable: true,
                                      content: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Container(
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                Text("Edit Address",
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xff00182E),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 18)),
                                                SizedBox(
                                                  height: 30,
                                                ),
                                                // Container(
                                                //     margin: EdgeInsets.all(5),
                                                //     child: Align(
                                                //         alignment: Alignment.centerLeft,
                                                //         child: Text("Name",
                                                //             style: TextStyle(
                                                //                 fontSize: 16,
                                                //                 color: primary())))),
                                                TextFormField(
                                                  controller: addressName,
                                                  decoration: InputDecoration(
                                                    counterText: "",
                                                    // contentPadding: EdgeInsets.symmetric(vertical: 14,horizontal: 12),
                                                    border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(35),
                                                        borderSide: BorderSide(
                                                          color: Colors.grey,
                                                        )),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Clr()
                                                              .textPrimaryColor,
                                                          width: 1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              35),
                                                    ),
                                                    contentPadding:
                                                        EdgeInsets.only(
                                                            top: 0,
                                                            right: 5,
                                                            bottom: 0),
                                                    hintText: "Name",
                                                    prefixIcon: Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 16, bottom: 16),
                                                      child: SvgPicture.asset(
                                                        'assets/img/profileicon.svg',
                                                        height: 15,
                                                        width: 15,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 20,
                                                ),
                                                // Container(
                                                //     margin: EdgeInsets.all(5),
                                                //     child: Align(
                                                //         alignment: Alignment.centerLeft,
                                                //         child: Text("Mobile Number",
                                                //             style: TextStyle(
                                                //                 fontSize: 16,
                                                //                 color: primary())))),
                                                TextFormField(
                                                  maxLength: 10,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  controller: addressNumber,
                                                  decoration: InputDecoration(
                                                    counterText: "",
                                                    border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(35),
                                                        borderSide: BorderSide(
                                                          color: Colors.grey,
                                                        )),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Clr()
                                                              .textPrimaryColor,
                                                          width: 1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              35),
                                                    ),
                                                    contentPadding:
                                                        EdgeInsets.only(
                                                            left: 20),
                                                    hintText: "Mobile Number",
                                                    prefixIcon: Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 16, bottom: 16),
                                                      child: SvgPicture.asset(
                                                        'assets/img/phoneicon.svg',
                                                        height: 15,
                                                        width: 15,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 20,
                                                ),
                                                // Container(
                                                //     margin: EdgeInsets.all(5),
                                                //     child: Align(
                                                //         alignment: Alignment.centerLeft,
                                                //         child: Text("Address",
                                                //             style: TextStyle(
                                                //                 fontSize: 16,
                                                //                 color: primary())))),
                                                Container(
                                                  margin: EdgeInsets.fromLTRB(
                                                      0, 2, 0, 0),
                                                  child: TextFormField(
                                                    controller: addressField,
                                                    maxLines: 5,
                                                    decoration: InputDecoration(
                                                      counterText: "",
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 14,
                                                              horizontal: 12),
                                                      border:
                                                          OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          35),
                                                              borderSide:
                                                                  BorderSide(
                                                                color:
                                                                    Colors.grey,
                                                              )),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Clr()
                                                                .textPrimaryColor,
                                                            width: 1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(35),
                                                      ),
                                                      hintText: "Address",
                                                      prefixIcon: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                top: 2,
                                                                bottom: 80),
                                                        child: SvgPicture.asset(
                                                          'assets/img/locationicon.svg',
                                                          height: 15,
                                                          width: 15,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 20,
                                                ),
                                                // Container(
                                                //     margin: EdgeInsets.all(5),
                                                //     child: Align(
                                                //         alignment: Alignment.centerLeft,
                                                //         child: Text("Landmark",
                                                //             style: TextStyle(
                                                //                 fontSize: 16,
                                                //                 color: primary())))),
                                                TextFormField(
                                                  controller: addressLandmark,
                                                  decoration: InputDecoration(
                                                    counterText: "",
                                                    border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(35),
                                                        borderSide: BorderSide(
                                                          color: Colors.grey,
                                                        )),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Clr()
                                                              .textPrimaryColor,
                                                          width: 1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              35),
                                                    ),
                                                    contentPadding:
                                                        EdgeInsets.only(
                                                            left: 20),
                                                    hintText: "Landmark",
                                                    prefixIcon: Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 16, bottom: 16),
                                                      child: SvgPicture.asset(
                                                        'assets/img/locationicon.svg',
                                                        height: 15,
                                                        width: 15,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 20,
                                                ),
                                                // Container(
                                                //     margin: EdgeInsets.all(5),
                                                //     child: Align(
                                                //         alignment: Alignment.centerLeft,
                                                //         child: Text("Pincode",
                                                //             style: TextStyle(
                                                //                 fontSize: 16,
                                                //                 color: primary())))),
                                                Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              35),
                                                      border: Border.all(
                                                          color: Colors.grey,
                                                          width: 1)),
                                                  child:
                                                      DropdownButtonHideUnderline(
                                                    child: DropdownButton(
                                                      icon: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Icon(
                                                            Icons
                                                                .keyboard_arrow_down,
                                                            color: Color(
                                                                0xff00182E)),
                                                      ),
                                                      // dropdownColor: Colors.grey[100],
                                                      iconSize: 30,
                                                      iconEnabledColor:
                                                          primary(),
                                                      isExpanded: true,
                                                      items:
                                                          pincodeDropDownItems
                                                              .map((items) {
                                                        return DropdownMenuItem(
                                                          value: items,
                                                          child: Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      left: 10,
                                                                      right:
                                                                          10),
                                                              child: Row(
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        right:
                                                                            8.0),
                                                                    child: SvgPicture
                                                                        .asset(
                                                                      'assets/img/locationicon.svg',
                                                                      height:
                                                                          15,
                                                                      width: 15,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      width: 5),
                                                                  Text(items),
                                                                ],
                                                              )),
                                                        );
                                                      }).toList(),
                                                      value: dropdownvalue,
                                                      onChanged: (newValue) {
                                                        print(newValue);
                                                        setState(() {
                                                          dropdownvalue =
                                                              newValue
                                                                  .toString();
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      actions: [
                                        SizedBox(
                                          height: 45,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.3,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                Radius.circular(45),
                                              ),
                                              color: Clr().white,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.3),
                                                  spreadRadius: 0.5,
                                                  blurRadius: 7,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                style: ElevatedButton.styleFrom(
                                                    elevation: 0,
                                                    backgroundColor:
                                                        Clr().white,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        45))),
                                                child: Text(
                                                  'Cancel',
                                                  style:
                                                      Sty().mediumText.copyWith(
                                                            color: Clr().red,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                )),
                                          ),
                                        ),
                                        SizedBox(width: Dim().d16),
                                        // TextButton(
                                        //     onPressed: () {
                                        //       Navigator.of(context).pop();
                                        //     },
                                        //     child: Text("Cancel")),
                                        Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.3,
                                            height: 45,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                end: Alignment(0.0, 0.4),
                                                begin: Alignment(0.0, -1),
                                                colors: [
                                                  Color(0xFF065197),
                                                  Color(0xFF337ec4)
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(25),
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
                                                if (isLength(
                                                    addressName.text, 3)) {
                                                  if (isLength(
                                                      addressNumber.text, 10)) {
                                                    if (isLength(
                                                        addressField.text, 5)) {
                                                      if (isLength(
                                                          addressLandmark.text,
                                                          3)) {
                                                        var dio = Dio();
                                                        var formData =
                                                            FormData.fromMap({
                                                          'addrs_id':
                                                              addresIdentifier
                                                                  .toString(),
                                                          'name': addressName
                                                              .text
                                                              .toString(),
                                                          'mobile':
                                                              addressNumber.text
                                                                  .toString(),
                                                          'address':
                                                              addressField.text
                                                                  .toString(),
                                                          'landmark':
                                                              addressLandmark
                                                                  .text
                                                                  .toString(),
                                                          'pincode':
                                                              dropdownvalue
                                                                  .toString(),
                                                          // 'user_id' : '2'
                                                        });
                                                        final response =
                                                            await dio.post(
                                                                updateAddressUrl(),
                                                                data: formData);
                                                        var res = json.decode(
                                                            response.data);
                                                        print(res);
                                                        if (res['error'] ==
                                                            true) {
                                                          SnackBar sn = SnackBar(
                                                              content: Text(res[
                                                                      'message']
                                                                  .toString()));
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(sn);
                                                        } else {
                                                          SnackBar sn = SnackBar(
                                                              content: Text(res[
                                                                      'message']
                                                                  .toString()));
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(sn);
                                                          getAddress();
                                                          Navigator.of(context)
                                                              .pop();
                                                        }
                                                      } else {
                                                        showDialog(
                                                            context: context,
                                                            builder: (ctx) {
                                                              return AlertDialog(
                                                                content: Text(
                                                                    "Landmark should be at least 3 characters long..."),
                                                              );
                                                            });
                                                      }
                                                    } else {
                                                      showDialog(
                                                          context: context,
                                                          builder: (ctx) {
                                                            return AlertDialog(
                                                              content: Text(
                                                                  "Address should be at least 5 characters long..."),
                                                            );
                                                          });
                                                    }
                                                  } else {
                                                    showDialog(
                                                        context: context,
                                                        builder: (ctx) {
                                                          return AlertDialog(
                                                            content: Text(
                                                                "Number invalid..."),
                                                          );
                                                        });
                                                  }
                                                } else {
                                                  showDialog(
                                                      context: context,
                                                      builder: (ctx) {
                                                        return AlertDialog(
                                                          content: Text(
                                                              "Name should be 3 characters at least..."),
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
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                              ),
                                            )),
                                        // TextButton(
                                        //     onPressed: () async {
                                        //       if (isLength(addressName.text, 3)) {
                                        //         if (isLength(addressNumber.text, 10)) {
                                        //           if (isLength(addressField.text, 5)) {
                                        //             if (isLength(
                                        //                 addressLandmark.text, 3)) {
                                        //               var dio = Dio();
                                        //               var formData = FormData.fromMap({
                                        //                 'addrs_id':
                                        //                     addresIdentifier.toString(),
                                        //                 'name':
                                        //                     addressName.text.toString(),
                                        //                 'mobile': addressNumber.text
                                        //                     .toString(),
                                        //                 'address': addressField.text
                                        //                     .toString(),
                                        //                 'landmark': addressLandmark.text
                                        //                     .toString(),
                                        //                 'pincode':
                                        //                     dropdownvalue.toString(),
                                        //                 // 'user_id' : '2'
                                        //               });
                                        //               final response = await dio.post(
                                        //                   updateAddressUrl(),
                                        //                   data: formData);
                                        //               var res =
                                        //                   json.decode(response.data);
                                        //               print(res);
                                        //               if (res['error'] == true) {
                                        //                 SnackBar sn = SnackBar(
                                        //                     content: Text(res['message']
                                        //                         .toString()));
                                        //                 ScaffoldMessenger.of(context)
                                        //                     .showSnackBar(sn);
                                        //               } else {
                                        //                 SnackBar sn = SnackBar(
                                        //                     content: Text(res['message']
                                        //                         .toString()));
                                        //                 ScaffoldMessenger.of(context)
                                        //                     .showSnackBar(sn);
                                        //                 getAddress();
                                        //                 Navigator.of(context).pop();
                                        //               }
                                        //             } else {
                                        //               showDialog(
                                        //                   context: context,
                                        //                   builder: (ctx) {
                                        //                     return AlertDialog(
                                        //                       content: Text(
                                        //                           "Landmark should be at least 3 characters long..."),
                                        //                     );
                                        //                   });
                                        //             }
                                        //           } else {
                                        //             showDialog(
                                        //                 context: context,
                                        //                 builder: (ctx) {
                                        //                   return AlertDialog(
                                        //                     content: Text(
                                        //                         "Address should be at least 5 characters long..."),
                                        //                   );
                                        //                 });
                                        //           }
                                        //         } else {
                                        //           showDialog(
                                        //               context: context,
                                        //               builder: (ctx) {
                                        //                 return AlertDialog(
                                        //                   content:
                                        //                       Text("Number invalid..."),
                                        //                 );
                                        //               });
                                        //         }
                                        //       } else {
                                        //         showDialog(
                                        //             context: context,
                                        //             builder: (ctx) {
                                        //               return AlertDialog(
                                        //                 content: Text(
                                        //                     "Name should be 3 characters at least..."),
                                        //               );
                                        //             });
                                        //       }
                                        //     },
                                        //     child: Text("Update")),
                                        SizedBox(width: Dim().d8),
                                      ],
                                    );
                                  });
                                });
                          },
                          // onTap: (){
                          //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyAddressEdit())).then((_) { updateBadgeCount(); print("Cart update called");});
                          // },
                          child: Container(
                            margin: EdgeInsets.all(5),
                            padding: EdgeInsets.all(3),
                            child: SvgPicture.asset('assets/img/editicon.svg',
                                height: 15,
                                width: 15,
                                color: Color(0xffF16624)),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            var dio = Dio();
                            var formData = FormData.fromMap({
                              'addrs_id': addresIdentifier.toString(),
                            });
                            final response = await dio.post(deleteAdressUrl(),
                                data: formData);
                            var res = json.decode(response.data);
                            print(res);

                            SnackBar sn = SnackBar(content: Text("Deleted!"));
                            ScaffoldMessenger.of(context).showSnackBar(sn);

                            getAddress();
                          },
                          child: Container(
                            margin: EdgeInsets.all(5),
                            padding: EdgeInsets.all(3),
                            child: SvgPicture.asset('assets/img/deletecart.svg',
                                height: 15,
                                width: 15,
                                color: Color(0xff00182E)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    SizedBox(width: 8),
                    SvgPicture.asset(
                      'assets/img/phoneicon.svg',
                      height: 15,
                      width: 15,
                    ),
                    SizedBox(width: 8),
                    Container(
                        // padding: EdgeInsets.only(top: 5, left: 5, bottom: 2),
                        child: Text(
                      '+ ' '${mobile}',
                      style: TextStyle(fontSize: 16, height: 1.5),
                    )),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 8,
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 8),
                      SvgPicture.asset(
                        'assets/img/locationicon.svg',
                        height: 15,
                        width: 15,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          ' ${address}' + ' ${landmark}' + ' ${pincode}',
                          style: TextStyle(fontSize: 16, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  void getAddress() async {
    setState(() {
      isloaded = false;
    });
    SharedPreferences sp = await SharedPreferences.getInstance();
    if (sp.getBool('isLoggedIn') == false) {
      Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => LoginScreen()))
          .then((_) {

        print("Cart update called");
      });
    }
    var dio = Dio();
    var formData = FormData.fromMap({
      'user_id': sp.getString("user_id").toString()
      // 'user_id' : '2'
    });
    final response = await dio.post(getAddressDataUrl(), data: formData);
    var res = json.decode(response.data);
    print(res);

    addressItemList = [];
    for (int i = 0; i < res['result_array'].length; i++) {
      addressItemList.add(addressItem(
          res['result_array'][i]['name'],
          res['result_array'][i]['mobile'],
          res['result_array'][i]['address'],
          res['result_array'][i]['landmark'],
          res['result_array'][i]['pincode'],
          res['result_array'][i]['ID'].toString()));
    }

    setState(() {
      addressItemList = addressItemList;
      isloaded = true;
    });
  }

  checkLoggedIn() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.getBool("isLoggedIn") != null
        ? sp.getBool("isLoggedIn")
        : false
            ? Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => MyAddressScreen()))
                .then((_) {

                print("Cart update called");
              })
            : Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  void initState() {
    checkLoggedIn();
    getAddress();
    getPincodes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // elevation: 0.2,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_outlined, color: Color(0xff244D73)),
          // iconSize: 35,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("My Address",
            style: TextStyle(
                color: Color(0xff00182E),
                fontWeight: FontWeight.w500,
                fontSize: 18)),
        flexibleSpace: barGredient(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MyAddressNewAddScreen())).then((_) {
            print("Cart update called");
          });
        },
        child: Container(
          width: 60,
          height: 60,
          child: Icon(
            Icons.add,
            size: 20,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              end: Alignment(0.0, 0.4),
              begin: Alignment(0.0, -1),
              colors: [Color(0xFF065197), Color(0xFF337ec4)],
            ),
            borderRadius: BorderRadius.circular(45),
          ),
        ),
        // child: Text(
        //   "+",
        //   style: TextStyle(fontSize: 26),
        // ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
      ),
      body: isloaded
          ? addressItemList.length > 0
              ? Container(
                  child: Center(
                    child: Scrollbar(
                      child: Container(
                        margin: EdgeInsets.all(15),
                        child: ListView(
                          children: addressItemList,
                        ),
                      ),
                    ),
                  ),
                )
              : Center(
                  child: Text("No Data Found",
                      style: TextStyle(color: primary(), fontSize: 25)),
                )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
