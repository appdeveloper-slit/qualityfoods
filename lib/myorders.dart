// ignore_for_file: prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qf/colors.dart';
import 'package:qf/globalurls.dart';
import 'package:qf/home_page.dart';
import 'package:qf/login.dart';
import 'package:qf/myaddress.dart';
import 'package:qf/order_details.dart';
import 'package:qf/values/colors.dart';
import 'package:qf/values/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './appbar_gradientlook.dart';
import 'manage/static_method.dart';

// Replace this with your own code...

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({Key? key}) : super(key: key);

  @override
  State<MyOrdersScreen> createState() => MyOrdersScreenState();
}

class MyOrdersScreenState extends State<MyOrdersScreen> {
  List<Widget> orderCardWidgetList = [];
  static StreamController<dynamic> controller =
      StreamController<dynamic>.broadcast();
  bool isloaded = false;
  getUserOrder() async {
    setState(() {
      isloaded = false;
    });
    SharedPreferences sp = await SharedPreferences.getInstance();
    print("CHECKING LOGGED IN IN GETTING USER DATA");
    if (sp.getBool('isLoggedIn') == false) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
    print(sp.getString('user_id').toString());
    var dio = Dio();
    var formData = FormData.fromMap({
      'user_id': sp.getString('user_id').toString(),
      // 'user_id': '1',
    });
    final response = await dio.post(getAllOrdersOddUser(), data: formData);
    var res = json.decode(response.data);
    print(res);

    orderCardWidgetList = [];
    for (int i = 0; i < res['result_array'].length; i++) {
      print("================================");
      print(res['result_array'][i]['Products']);
      orderCardWidgetList.add(orderCard(
          res['result_array'][i]['ID'].toString(),
          res['result_array'][i]['order_number'].toString(),
          res['result_array'][i]['status'].toString(),
          res['result_array'][i]['placement_date'].toString(),
          res['result_array'][i]['final_total'].toString(),
          res['result_array'][i]['Products'],
          res['result_array'][i]['payment_mode'].toString(),
          "${res['result_array'][i]['address']} ${res['result_array'][i]['landmark']} Pincode: ${res['result_array'][i]['pincode']}",
          res['result_array'][i]['delivery_date'].toString(),
          res['result_array'][i]['total'].toString(),
          res['result_array'][i]['discount'].toString(),
          res['result_array'][i]['DeliveryCharge'].toString(),
          res['result_array'][i]['tax_charge'].toString()));
    }

    setState(() {
      orderCardWidgetList = orderCardWidgetList;
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
            : Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => LoginScreen()));
    // SharedPreferences sp = await SharedPreferences.getInstance();
    //   if(sp.getBool("isLoggedIn") != false){
    //     setState(() {
    //       // isLoggedIn = true;
    //     });
    //     print("Looks logged in...");
    //     // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyProfileScreen()));
    //   }else{
    //     // isLoggedIn = false;
    //     print("looks not logged in...");
    //      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
    //   }
  }

  @override
  void initState() {
    // controller.stream.listen(
    //       (dynamic event) {
    //     setState(() {
    //       totalamount = int.parse(event['discount']);
    //       codenameCtrl = TextEditingController(text: event['codename'].toString());
    //       discountprice = event['discountprice'].toString();
    //     });
    //   },
    // );

    checkLoggedIn();
    getUserOrder();

    super.initState();
  }

  Widget orderCard(
      String order_identifier,
      String orderNumber,
      String orderStaus,
      String orderDate,
      String orderTotal,
      List productList,
      String paymentMode,
      String address,
      String deliveryDate,
      String price,
      String discount,
      String delivery_charges,
      String tax_charge) {
    return Padding(
      padding: EdgeInsets.only(
        right: 2,
        left: 2,
        top: 8,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topLeft,
        children: [
          Container(
            margin: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 5),
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
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(
                                    "Alert!",
                                    style: TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                  content: Text(
                                      'Are you sure you want to delete order history ?',
                                      style: Sty()
                                          .mediumText
                                          .copyWith(color: Colors.black)),
                                  actions: [
                                    TextButton(
                                        onPressed: () async {
                                          var dio = Dio();
                                          var formData = FormData.fromMap({
                                            // 'user_id' : sp.getString('user_id').toString(),
                                            'order_id':
                                                order_identifier.toString(),
                                          });
                                          final response = await dio.post(
                                              getdeletemyorderUrl(),
                                              data: formData);
                                          var res = json.decode(response.data);
                                          print(res);
                                          if (res['error'] == true) {
                                            SnackBar sn = SnackBar(
                                                content: Text(
                                                    res['message'].toString()));
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(sn);
                                          } else {
                                            SnackBar sn = SnackBar(
                                                content: Text(
                                                    res['message'].toString()));
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(sn);
                                            // Navigator.of(context).pushReplacement( MaterialPageRouter(builder: (context) => MyOrdersScreen()));
                                            getUserOrder();
                                            Navigator.of(context).pop();
                                          }
                                        },
                                        child: Text("YES",
                                            style: Sty().mediumText.copyWith(
                                                color: Colors.orange))),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("NO",
                                            style: Sty().mediumText.copyWith(
                                                color: Colors.orange)))
                                  ],
                                );
                              });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: SvgPicture.asset(
                            'assets/img/deletecart.svg',
                            height: 16,
                            width: 16,
                          ),
                        ),
                      ),
                    ),
                    // Container(
                    //   margin: EdgeInsets.all(2),
                    //   child: Row(
                    //     children: [
                    //       Expanded(
                    //         child: Text("Order",
                    //             style: TextStyle(fontWeight: FontWeight.bold)),
                    //       ),
                    //       Text(":"),
                    //       SizedBox(
                    //         width: 20,
                    //       ),
                    //       Expanded(
                    //           child: Text(
                    //         orderNumber.toString(),
                    //       ))
                    //     ],
                    //   ),
                    // ),
                    Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                          child: Text(
                            orderDate.toString(),
                            style: TextStyle(fontFamily: 'Opensans'),
                          ),
                        )),
                    // Text.rich(
                    //   TextSpan(
                    //     children: [
                    //       TextSpan(
                    //           text: ' Items:',
                    //           style: TextStyle(
                    //               color: Color(0xffF16624), fontSize: 15)),
                    //       TextSpan(
                    //         text: ' ${productList.length}',
                    //         style: TextStyle(
                    //             color: Color(0xffF16624),
                    //             fontWeight: FontWeight.bold),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    Container(
                      margin: EdgeInsets.only(right: 2, left: 2, bottom: 4),
                      child: Row(
                        children: [
                          Text("Items:",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: Color(0xff00182E))),
                          SizedBox(
                            width: 5,
                          ),
                          Text('${productList.length}',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  fontFamily: 'Opensans',
                                  color: Color(0xff065197)))
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(2),
                      child: Row(
                        children: [
                          Text("Total :",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: Color(0xff00182E))),
                          SizedBox(
                            width: 5,
                          ),
                          Text("₹ $orderTotal",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  fontFamily: 'Opensans',
                                  color: Color(0xff065197)))
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: EdgeInsets.all(2),
                          child: Row(
                            children: [
                              // Expanded(
                              //   child: Text("Status",
                              //       style: TextStyle(fontWeight: FontWeight.bold)),
                              // ),
                              Icon(Icons.circle,
                                  size: 10,
                                  color: (orderStaus.toString() == "Ordered")
                                      ? Colors.black
                                      : (orderStaus.toString() == "Cancelled")
                                          ? Colors.red
                                          : Colors.green),

                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                orderStaus.toString(),
                                style: TextStyle(
                                    fontSize: 16,
                                    color: (orderStaus.toString() == "Ordered")
                                        ? Colors.black
                                        : (orderStaus.toString() == "Cancelled")
                                            ? Colors.red
                                            : Colors.green),
                              )
                            ],
                          ),
                        ),
                        Container(
                            width: MediaQuery.of(context).size.width * 0.4,
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
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OrderDetailsScreen(
                                          orderNumber: orderNumber.toString(),
                                          purchaseDetails: orderDate.toString(),
                                          amountPayable: orderTotal.toString(),
                                          paymentMode: paymentMode.toString(),
                                          address: address.toString(),
                                          date: deliveryDate.toString(),
                                          productDetailsList: productList,
                                          price: price.toString(),
                                          discount: discount.toString(),
                                          delivery_charges:
                                              delivery_charges.toString(),
                                          final_total_amount:
                                              orderTotal.toString(),
                                          tax_charge: tax_charge.toString(),
                                          orderStaus: orderStaus.toString(),
                                          order_identifier:
                                              order_identifier.toString()),
                                    ));
                              },
                              child: Center(
                                child: Text(
                                  'View Order',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 8,
            child: Container(

                // height: 10,
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Clr().borderColor.withOpacity(0.7),
                        spreadRadius: 0.5,
                        blurRadius: 8,
                        offset: Offset(0, 0), // changes position of shadow
                      ),
                    ],
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    color: Color(0xffFFEEE5)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Order ID: ',
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: Color(0xff90ABC3),
                              fontSize: 14),
                        ),
                        TextSpan(
                          text: '${orderNumber.toString()}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                )),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          STM().replacePage(context, HomeScreen());
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_outlined, color: Color(0xff244D73)),
            // iconSize: 35,
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                STM().replacePage(context, HomeScreen());
              }
            },
          ),
          title: Text("My Orders",
              style: TextStyle(
                  color: Color(0xff00182E),
                  fontWeight: FontWeight.w500,
                  fontSize: 18)),
          flexibleSpace: barGredient(),
        ),
        body: isloaded
            ? orderCardWidgetList.length > 0
                ? SingleChildScrollView(
                    child: Container(
                    child: Column(
                        children: orderCardWidgetList.length > 0
                            ? orderCardWidgetList
                            : [
                                Center(
                                  child: Container(
                                      margin: EdgeInsets.only(top: 15),
                                      child: Text("No Orders Found")),
                                )
                              ]),
                  ))
                : Center(
                    child: Text(
                    "No Data Found",
                    style: TextStyle(color: primary(), fontSize: 25),
                  ))
            : Center(
                child: Container(
                    margin: EdgeInsets.only(top: 15),
                    child: CircularProgressIndicator()),
              ),
      ),
    );
  }
}
