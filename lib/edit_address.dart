import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qf/colors.dart';
import 'package:qf/globalurls.dart';
import 'package:qf/myaddress.dart';
import 'package:qf/values/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:validators/validators.dart';

import './appbar_gradientlook.dart';

class MyAddressEdit extends StatefulWidget {
  const MyAddressEdit({Key? key}) : super(key: key);

  @override
  State<MyAddressEdit> createState() => MyAddressEditState();
}

class MyAddressEditState extends State<MyAddressEdit> {
  TextEditingController addressName = TextEditingController();
  // TextEditingController addressEmail = TextEditingController();
  TextEditingController addressNumber = TextEditingController();
  TextEditingController addressField = TextEditingController();
  TextEditingController addressLandmark = TextEditingController();

  // TextEditingController addressPassword = TextEditingController();
  var pincodeDropDownItems = [];
  var dropdownvalue = "";

  void addAdress() async {
    print(dropdownvalue);
    SharedPreferences sp = await SharedPreferences.getInstance();
    var dio = Dio();
    var formData = FormData.fromMap({
      'user_id': sp.getString("user_id").toString(),
      'name' : addressName.text.toString(),
      'mobile' : addressNumber.text.toString(),
      'address' : addressField.text.toString(),
      'landmark' : addressLandmark.text.toString(),
      'pincode' : dropdownvalue.toString(),
      // 'user_id' : '2'
    });
    final response = await dio.post(addAdressUrl(), data: formData);
    var res = json.decode(response.data);
    print(res);

    SnackBar sn = SnackBar(content: Text(res['message'].toString()));
    ScaffoldMessenger.of(context).showSnackBar(sn);
    Navigator.of(context).pop();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  MyAddressScreen(),));
  }

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

    for(int i = 0; i < res['pin_codes'].length; i++){
      pincodeDropDownItems.add(res['pin_codes'][i]['pincode'].toString());
    }
    dropdownvalue = res['pin_codes'][0]['pincode'].toString();

  setState(() {
    pincodeDropDownItems = pincodeDropDownItems;
    dropdownvalue = dropdownvalue;
  });
  }



  @override
  void initState() {
    getPincodes();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        elevation: 0.2,
        leading: BackButton(color: Color(0xff244D73)),
        centerTitle: true,
        title: Text("Edit Address",style: TextStyle(
            color: Color(0xff00182E),
            fontWeight: FontWeight.w500,
            fontSize: 18)), flexibleSpace: barGredient(),
      ),
      backgroundColor: Colors.white,
      // bottomNavigationBar: bottomNavBar(),
      body: SingleChildScrollView(
        child: Column(children: [
          SizedBox(
            height: 30,
          ),
          Container(
              margin: EdgeInsets.fromLTRB(16, 2, 16, 16),
              child: Column(
                children: [
                  // Container(
                  //   margin: EdgeInsets.all(5),
                  //     child: Align(
                  //         alignment: Alignment.centerLeft,
                  //         child: Text("Name",
                  //             style: TextStyle(
                  //                 fontSize: 16, color: primary())))),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    controller: addressName,
                    decoration: InputDecoration(
                      counterText: "",
                        // contentPadding: EdgeInsets.symmetric(vertical: 14,horizontal: 12),
                        border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(35),

                  borderSide: BorderSide(color: Colors.grey,)),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Clr().textPrimaryColor, width: 1),
                borderRadius: BorderRadius.circular(35),
              ),
                      contentPadding:EdgeInsets.only(top: 0, right: 5, bottom: 0),
                        hintText: "Name",
                      prefixIcon: Padding(
                        padding:  EdgeInsets.only(top:16,bottom:16),
                        child: SvgPicture.asset('assets/img/profileicon.svg',height: 15,width: 15,),
                      ),

                        // prefixIcon: Icon(Icons.person_outline, color: primary(),),
                        // prefixIconColor: primary()
                    ),
                  )
                ],
              )),

              Container(
              margin:  EdgeInsets.fromLTRB(16, 2, 16, 16),
              child: Column(
                children: [

                  // Container(
                  //   margin: EdgeInsets.all(5),
                  //     child: Align(
                  //         alignment: Alignment.centerLeft,
                  //         child: Text("Mobile Number",
                  //             style: TextStyle(
                  //                 fontSize: 16, color:primary())))),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                    controller: addressNumber,
                    decoration: InputDecoration(
                      counterText: "",
                        // contentPadding: EdgeInsets.symmetric(vertical: 14,horizontal: 12),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(35),

                            borderSide: BorderSide(color: Colors.grey,)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Clr().textPrimaryColor, width: 1),
                          borderRadius: BorderRadius.circular(35),
                        ),
                        contentPadding: EdgeInsets.only(left: 20),
                        hintText: "Mobile Number",

                      prefixIcon: Padding(
                          padding: EdgeInsets.only(top: 16,bottom: 16),
                          child: SvgPicture.asset('assets/img/phoneicon.svg',height: 15,width: 15,),
                        ),
                        // prefixIcon: Icon(Icons.phone_in_talk_outlined, color:primary(),),
                        // prefixIconColor: Colors.orange),
                    ) )
                ],
              )),
              Container(
              margin: EdgeInsets.fromLTRB(16, 2, 16, 16),
              child: Column(
                children: [
                  // Container(
                  //   margin: EdgeInsets.all(5),
                  //     child: Align(
                  //         alignment: Alignment.centerLeft,
                  //         child: Text("Address",
                  //             style: TextStyle(
                  //                 fontSize: 16, color:primary())))),
                  TextFormField(
                    controller: addressField,
                    maxLines: 5,
                    decoration: InputDecoration(
                      counterText: "",
                        contentPadding: EdgeInsets.symmetric(vertical: 14,horizontal: 12),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(35),

                            borderSide: BorderSide(color: Colors.grey,)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Clr().textPrimaryColor, width: 1),
                          borderRadius: BorderRadius.circular(35),
                        ),
                        // contentPadding: EdgeInsets.only(left: 20),
                        hintText: "Address",
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(top: 2,bottom: 80),
                        child: SvgPicture.asset('assets/img/locationicon.svg',height: 15,width: 15,),
                      ),),
                  )
                ],
              )),
              Container(
              margin:  EdgeInsets.fromLTRB(16, 2, 16, 16),
              child: Column(
                children: [
                  // Container(
                  //   margin: EdgeInsets.all(5),
                  //     child: Align(
                  //         alignment: Alignment.centerLeft,
                  //         child: Text("Landmark",
                  //             style: TextStyle(
                  //                 fontSize: 16, color:primary())))),
                  TextFormField(
                    controller: addressLandmark,
                    decoration: InputDecoration(
                      counterText: "",
                        // contentPadding: EdgeInsets.symmetric(vertical: 14,horizontal: 12),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(35),
                            borderSide: BorderSide(color: Colors.grey,)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Clr().textPrimaryColor, width: 1),
                          borderRadius: BorderRadius.circular(35),
                        ),
                        contentPadding: EdgeInsets.only(left: 20),
                        hintText: "Landmark",
                        // filled: true,
                        // fillColor: Colors.grey[100],
                      prefixIcon: Padding(
                        padding:  EdgeInsets.only(top: 16,bottom: 16),
                        child: SvgPicture.asset('assets/img/locationicon.svg',height: 15,width: 15,),
                      ),),
                  )
                ],
              )),


              Container(
              margin:  EdgeInsets.fromLTRB(16, 2, 16, 16),
              child: Column(
                children: [
                  
                  // Container(
                  //   margin: EdgeInsets.all(5),
                  //     child: Align(
                  //         alignment: Alignment.centerLeft,
                  //         child: Text("Pincode",
                  //             style: TextStyle(
                  //                 fontSize: 16, color:primary())))),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(35),
                      border: Border.all(color: Colors.grey,width: 1)
                    ),
                    // color: Colors.grey[100],
                    child: DropdownButtonHideUnderline(
              child: DropdownButton(
                icon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.keyboard_arrow_down,color: Color(0xff00182E)),
                ),
                // dropdownColor: Colors.grey[100],
                iconSize: 30,
                iconEnabledColor: primary(),
                isExpanded: true,
                items: pincodeDropDownItems.map((items) {
                    return DropdownMenuItem(
                      value: items,
                      child: Container(margin: EdgeInsets.only(left: 10, right: 10), child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: SvgPicture.asset('assets/img/locationicon.svg',height: 15,width: 15,),
                          ),
                          SizedBox(width:5),
                          Text(items),
                        ],
                      )),
                    );
                }).toList(),
                value: dropdownvalue,
                onChanged: (newValue) {
                    print(newValue);
                    setState(() {
                      dropdownvalue = newValue.toString();
                    });
                },
              ),
            ),
                  )
                ],
              )),
          SizedBox(
            height:12,
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
                onPressed: () {
                  if(isLength(addressName.text, 3)){
                    if(isLength(addressNumber.text, 10)){
                      if(isLength(addressField.text, 5)){
                        if(isLength(addressLandmark.text, 3)){
                          addAdress();
                        }
                        else{
                          SnackBar sn = SnackBar(content: Text("Landmark should be at least 3 characters long..."));
                          ScaffoldMessenger.of(context).showSnackBar(sn);
                        }
                      }
                      else{
                        SnackBar sn = SnackBar(content: Text("Address should be at least 5 characters long..."));
                        ScaffoldMessenger.of(context).showSnackBar(sn);
                      }
                    }
                    else{
                      SnackBar sn = SnackBar(content: Text("Number invalid..."));
                      ScaffoldMessenger.of(context).showSnackBar(sn);
                    }
                  }
                  else{
                    SnackBar sn = SnackBar(content: Text("Name should be 3 characters at least..."));
                    ScaffoldMessenger.of(context).showSnackBar(sn);
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
          //           backgroundColor:MaterialStateProperty.all<Color>(primary()),
          //             elevation: MaterialStateProperty.all(0),
          //             shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          //                 RoundedRectangleBorder(
          //                     borderRadius: BorderRadius.circular(10.0)))),
          //         onPressed: () {
          //           if(isLength(addressName.text, 3)){
          //             if(isLength(addressNumber.text, 10)){
          //               if(isLength(addressField.text, 5)){
          //                 if(isLength(addressLandmark.text, 3)){
          //                   addAdress();
          //                 }
          //                 else{
          //                   SnackBar sn = SnackBar(content: Text("Landmark should be at least 3 characters long..."));
          //                   ScaffoldMessenger.of(context).showSnackBar(sn);
          //                 }
          //               }
          //               else{
          //                 SnackBar sn = SnackBar(content: Text("Address should be at least 5 characters long..."));
          //                 ScaffoldMessenger.of(context).showSnackBar(sn);
          //               }
          //             }
          //             else{
          //               SnackBar sn = SnackBar(content: Text("Number invalid..."));
          //             ScaffoldMessenger.of(context).showSnackBar(sn);
          //             }
          //           }
          //           else{
          //             SnackBar sn = SnackBar(content: Text("Name should be 3 characters at least..."));
          //             ScaffoldMessenger.of(context).showSnackBar(sn);
          //           }
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
      ),
    );
  }
}
