// ignore_for_file: prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:badges/badges.dart';
import 'package:cashfree_pg/cashfree_pg.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:qf/cart_page_old.dart';
import 'package:qf/category_screen.dart';
import 'package:qf/colors.dart';
import 'package:qf/globalurls.dart';
import 'package:qf/home_page.dart';
import 'package:qf/localstore.dart';
import 'package:qf/login.dart';
import 'package:qf/main_app_screen.dart';
import 'package:qf/manage/static_method.dart';
import 'package:qf/myaddress.dart';
import 'package:qf/myprofile.dart';
import 'package:qf/sqliteop.dart';
import 'package:qf/values/colors.dart';
import 'package:qf/values/dimens.dart';
import 'package:qf/values/styles.dart';
import 'package:qf/webview.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import './appbar_gradientlook.dart';
import './appbar_gradientlook.dart';
import 'bottomnav.dart';
import 'couponcode.dart';
import 'myorders.dart';

// Replace this with your own code...

class CheckoutScreen extends StatefulWidget {
  final price;
  double discount;
  double delivery_charges;
  double mainDiscount;
  double mainTotal;
  double serviceCharges;
  double tax_charge;

  CheckoutScreen(
      {required this.price,
        required this.discount,
        required this.delivery_charges,
        required this.mainDiscount,
        required this.mainTotal,
        required this.serviceCharges,
        required this.tax_charge});

  @override
  State<StatefulWidget> createState() {
    return CheckoutScreenPage();
  }
}

class CheckoutScreenPage extends State<CheckoutScreen> {
  var _razorpay = Razorpay();
  String sTotalPrice = "0";
  List<String> paymentoptions = ["cash", "online"];
  String paymentvalue = "";
  bool isloaded = false;
  var addressSelectedValue;
  List<Widget> alladress = [];
  List<bool> selectedIndex = [];
  List<String> theaddress = [];
  List<String> alladdressString = [];
  TextEditingController couponField = TextEditingController();
  static StreamController<dynamic> controller =
  StreamController<dynamic>.broadcast();
  bool couponFieldEnabled = true;
  String couponAppliedText = "";
  double couponDiscount = 0.0;
  bool isLoggedIn = false;
  String? discount;
  String discountprice = "0";
  TextEditingController codenameCtrl = TextEditingController();
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();
  var time = DateTime.now();
  dynamic data;
  var message;

  checkLoggedIn() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    if (sp.getBool('isLoggedIn') == false) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginScreen()))
          .then((_) {
        // updateBadgeCount();
        print("Cart update called");
      });
    }
    if (sp.getBool("isLoggedIn") != null) {
      isLoggedIn = true;
      setState(() {
        isLoggedIn = true;
      });
      getAddress();
      print("Looks logged in...");
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyProfileScreen()));
    } else {
      isLoggedIn = false;
      print("looks not logged in...");
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginScreen()))
          .then((_) {
        // updateBadgeCount();
        print("Cart update called");
      });
    }
  }

  late final db;
  var totalamount = 0;
  var discountedtotalamount = 0;
  int contentInCart = 0;

  // void updateBadgeCount() async {
  //   final db = DatabaseHelper.instance;
  //   final allRows = await db.queryAllRows();
  //
  //   setState(() {
  //     contentInCart = allRows.length;
  //     contentInCart = contentInCart;
  //   });
  // }

  @override
  void initState() {
    controller.stream.listen(
          (dynamic event) {
          setState(() {
            discountedtotalamount = int.parse(event['discount']);
            couponField = TextEditingController(text: event['codeame'].toString());
            discountprice = event['discountprice'].toString();
          });
      },
    );
    // db = DatabaseHelper.instance;
    apiTime();
    checkLoggedIn();
    // updateBadgeCount();
    print("LOGGED IN BOOL: " + isLoggedIn.toString());

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    super.initState();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Do something when payment succeeds
    addOrderApi(transid: response.paymentId);
    debugPrint(response.paymentId);
    debugPrint('payment succeeds');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
    debugPrint('payment Failed');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('payment External');
    // Do something when an external wallet is selected
  }

  @override
  void dispose() {
    _razorpay.clear(); // Removes all listeners
    super.dispose();
  }

  void removeCoupon() {
    setState(() {
      // price = price + discount;
      widget.discount = 0;
      couponFieldEnabled = true;
      couponAppliedText = "";
      couponDiscount = 0.0;
      // price = price;
      // discount = discount;
      // delivery_charges = delivery_charges;
    });
  }

  void addOrderApi({transid}) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    var dio = Dio();
    var formData = FormData.fromMap({
      'user_id': sp.getString('user_id').toString(),
      'txn_id': transid,
      'address_id': addressSelectedValue.toString(),
      'deliveryamount': widget.serviceCharges.toString(),
      'tax_charge': widget.tax_charge.toString(),
      'total': widget.price.toString(),
      // 'coupon_code':Newtest,
      // 'coupon_name': couponField.text,
      // 'order_amt': price - discount,
      // 'user_id': sp.getString('user_id').toString()
    });
    final response =
    await dio.post(paymentOnlineAndPlaceOrder(), data: formData);
    var res = json.decode(response.data);
    print(res);

    if (res['error'] == true) {
      SnackBar sn = SnackBar(content: Text(res['message']));
      ScaffoldMessenger.of(context).showSnackBar(sn);
      // db.clear();
      // _showPlaceOrderDialog(ctx: context,message: res['message']);
    } else {
      // discount = double.parse(res['discount_amount'].toString());
      // couponDiscount = double.parse(res['discount_amount'].toString());
      // setState(() {
      //   couponAppliedText = "Coupon Applied!";
      //   couponFieldEnabled = false;
      //   discount = double.parse(res['discount_amount'].toString());
      // });
      SnackBar sn = SnackBar(content: Text(res['message']));
      ScaffoldMessenger.of(context).showSnackBar(sn);
      db.clear();
      _showPlaceOrderDialog(ctx: context, message: res['message']);
      // STM().successDialogWithAffinity(context, res['message'], MyOrdersScreen());
      // STM().successDialogWithAffinity(context, MyOrdersScreen());
    }
  }

  void applyCoupon() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    var dio = Dio();
    print(widget.price - widget.discount);
    var formData = FormData.fromMap({
      'coupon_name': couponField.text,
      'order_amt': widget.price - widget.discount,
      'user_id': sp.getString('user_id').toString()
    });
    final response = await dio.post(applyCouponUrl(), data: formData);
    var res = json.decode(response.data);
    print(res);

    if (res['error'] == true) {
      SnackBar sn = SnackBar(content: Text(res['message']));
      ScaffoldMessenger.of(context).showSnackBar(sn);
    } else {
      // discount = double.parse(res['discount_amount'].toString());
      couponDiscount = double.parse(res['discount_amount'].toString());
      setState(() {
        couponAppliedText = "Coupon Applied!";
        couponFieldEnabled = false;
        widget.discount = double.parse(res['discount_amount'].toString());
      });
      SnackBar sn = SnackBar(content: Text(res['message']));
      ScaffoldMessenger.of(context).showSnackBar(sn);
    }
  }

  void setAlllist() {
    setState(() {
      alladress = [];
      for (int i = 0; i < alladdressString.length; i++) {
        alladress.add(addressRadioItem(
            alladdressString[i].toString(), selectedIndex[i], i));
      }
    });
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
        // updateBadgeCount();
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
    // addressSelectedValue = "" + res['result_array'][0]['name'] + " " + res['result_array'][0]['mobile'] + " " + res['result_array'][0]['address'] + " " + res['result_array'][0]['landmark'] + " " + res['result_array'][0]['pincode'] + " " + res['result_array'][0]['ID'].toString() + " ";
    for (int i = 0; i < res['result_array'].length; i++) {
      selectedIndex.add(false);
    }

    if (res['result_array'].length > 0) {
      selectedIndex[0] = true;
    }

    print(selectedIndex);
    theaddress = [];
    for (int i = 0; i < res['result_array'].length; i++) {
      theaddress.add(res['result_array'][i]['ID'].toString());
    }

    alladress = [];
    for (int i = 0; i < theaddress.length; i++) {
      alladress.add(addressRadioItem(
          "" +
              res['result_array'][i]['name'] +
              ", " +
              res['result_array'][i]['mobile'] +
              " \n" +
              res['result_array'][i]['address'] +
              ", " +
              res['result_array'][i]['landmark'] +
              ", " +
              res['result_array'][i]['pincode'] +
              " ",
          selectedIndex[i],
          i));
      alladdressString.add("" +
          res['result_array'][i]['name'] +
          ", " +
          res['result_array'][i]['mobile'] +
          " \n" +
          res['result_array'][i]['address'] +
          ", " +
          res['result_array'][i]['landmark'] +
          ", " +
          res['result_array'][i]['pincode'] +
          " ");
    }

    print(alladress);

    if (alladress.length > 0) {
      addressSelectedValue = theaddress[0];
    }

    // if (alladress.length > 0) {
    // } else {
    //   SnackBar sn = SnackBar(content: Text(res['message']));
    //   ScaffoldMessenger.of(context).showSnackBar(sn);
    // }

    setState(() {
      alladress = alladress;
      alladress = alladress;
      selectedIndex = selectedIndex;
      addressSelectedValue = addressSelectedValue;
    });
    setState(() {
      isloaded = true;
    });
  }

  Widget addressRadioItem(String address, bool selIndex, int currentIndex) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Clr().borderColor.withOpacity(0.7),
            spreadRadius: 0.1,
            blurRadius: 8,
            offset: Offset(0, 0), // changes position of shadow
          ),
        ],
        border: Border.all(width: 1, color: Colors.white),
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: selectedIndex[currentIndex]
            ? Color.fromARGB(255, 255, 247, 236)
            : white(),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(12),
        selected: selectedIndex[currentIndex],
        selectedColor: Colors.black,
        // textColor: selectedIndex[currentIndex] == true ? primary() : Colors.black,
        onTap: () {
          setState(() {
            for (int i = 0; i < selectedIndex.length; i++) {
              selectedIndex[i] = false;
            }
            selectedIndex[currentIndex] = true;
            setAlllist();

            print(theaddress[currentIndex]);
            addressSelectedValue = theaddress[currentIndex];

            print(selectedIndex);
          });
        },
        title: Text(address.toString()),
        //  + " selected :" +  selectedIndex[currentIndex].toString()
        // value: address,
        // groupValue: addressSelectedValue,
        // onChanged: (value) {
        //   // print(value);
        //   addressSelectedValue = value;
        //   setState(() {
        //     print("SetState called...");
        //     addressSelectedValue = addressSelectedValue;
        //   });
        //   print("New address value: " + addressSelectedValue);
        // },
      ),
    );
  }

  Widget infoPart(totalamount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        showMessage(),
        Container(
            margin: EdgeInsets.only(top: 16, bottom: 4, right: 16, left: 16),
            child: Row(
              children: [
                SvgPicture.asset('assets/img/walleticon.svg'),
                SizedBox(
                  width: 5,
                ),
                Text("Total Summary",
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: Clr().textSecondaryColor)),
              ],
            )),
        Divider(
          height: 2,
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Order Amount",
                  style: TextStyle(fontWeight: FontWeight.w400)),
              Text("₹" + widget.price.toString())
            ],
          ),
        ),

        Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Delivery charges",
                  style: TextStyle(fontWeight: FontWeight.w400)),
              Text("₹" + widget.serviceCharges.toString())
            ],
          ),
        ),
        // Container(
        //   margin: EdgeInsets.all(15),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       Text("Service charges",
        //           style: TextStyle(fontWeight: FontWeight.bold)),
        //       Text("₹" + this.serviceCharges.toString())
        //     ],
        //   ),
        // ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Tax", style: TextStyle(fontWeight: FontWeight.w400)),
              Text("₹" + widget.tax_charge.toString())
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Coupon Discount",
                  style: TextStyle(fontWeight: FontWeight.w400)),
              Text("- ₹" + '${discountprice}')
              // Text("- ₹" + discountprice)
            ],
          ),
        ),
        Divider(
          height: 2,
          indent: 16,
          endIndent: 16,
          color: Color(0xffF16624),
        ),
        Container(
          margin: EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total Amount",
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Color(0xffF16624),
                      fontSize: 16)),
              Text(
                "₹ ${discountedtotalamount != 0 ? discountedtotalamount :  totalamount}",
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Color(0xffF16624),
                    fontSize: 16),
              )
            ],
          ),
        ),
        Divider(
          height: 2,
        ),
        Container(
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.only(left: 10, right: 4),
            decoration: BoxDecoration(
                border: Border.all(width: 0.5, color: primary()),
                borderRadius: BorderRadius.circular(35)),
            child: TextField(
                controller: couponField,
                enabled: couponFieldEnabled,
                decoration: InputDecoration(
                    hintText: "Apply promo code",
                    hintStyle: TextStyle(
                        fontSize: 14,
                        color: Clr().themePrimary,
                        fontFamily: 'Opensans'),
                    // contentPadding: EdgeInsets.only(left: 20,right: 10),
                    border: InputBorder.none,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: SvgPicture.asset('assets/img/coupancode.svg',
                          height: 10, width: 10, color: Clr().themePrimary),
                    ),
                    suffixIcon: InkWell(
                        onTap: () {
                          applyCoupon();
                        },
                        child: Icon(Icons.chevron_right))))),
        Container(
          margin: EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Row(
                    children: [
                      Text(couponAppliedText.toString()),
                      !couponFieldEnabled
                          ? TextButton(
                        child: Icon(
                          Icons.delete_outline,
                          color: primary(),
                        ),
                        onPressed: () {
                          removeCoupon();
                        },
                      )
                          : Container(),
                    ],
                  ),
                ],
              ),
              InkWell(
                child: Text("View all coupons"),
                onTap: () {
                  STM().redirect2page(
                      context,
                      CouponCode(
                        discount: widget.discount,
                        price: widget.price,
                      ));
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => OfferScreen())).then((_) {
                  //   updateBadgeCount();
                  print("Cart update called");
                  // });
                },
              )
            ],
          ),
        ),
        // Container(
        //   margin: EdgeInsets.all(15),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [Text("Discount"), Text("₹" + this.discount.toString())],
        //   ),
        // ),
        // Divider(
        //   height: 2,
        // ),
        // Container(
        //   margin: EdgeInsets.all(15),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       Text("Total", style: TextStyle(fontWeight: FontWeight.bold)),
        //       Text("₹" + totalamount.toString())
        //     ],
        //   ),
        // ),
        Divider(
          height: 2,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: 16,
            ),
            SvgPicture.asset('assets/img/walleticon.svg'),
            SizedBox(
              width: 5,
            ),
            Text("Delivery Address",
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                    color: Clr().textSecondaryColor)),
            // Container(
            //   margin: EdgeInsets.only(left: 15, top: 15),
            //   child: Align(
            //     child: Text("Delivery Address"),
            //     alignment: Alignment.centerLeft,
            //   ),
            // ),
            Container(
              margin: EdgeInsets.only(right: 15, top: 15),
              child: InkWell(
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MyAddressScreen())).then((_) {
                      // updateBadgeCount();
                      print("Cart update called");
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: SvgPicture.asset(
                      'assets/img/editicon.svg',
                      height: 15,
                      width: 15,
                    ),
                  )),
            ),
          ],
        ),
        Container(
          margin: EdgeInsets.only(top: 15),
          child: isloaded
              ? alladress.length > 0
              ? Column(
            children: alladress,
          )
              : Container(
              margin: EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    MyAddressScreen())).then((_) {
                          // updateBadgeCount();
                          print("Cart update called");
                        });
                      },
                      child: Text("Add a new address"))
                ],
              ))
              : Container(
              margin: EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // CircularProgressIndicator(),
                ],
              )),
        ),
        Divider(
          height: 2,
        ),
        SizedBox(
          height: 12,
        ),
        Container(
            margin: EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              "Payment Options",
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  color: Clr().textSecondaryColor),
            )),
        RadioListTile(
          title: Transform.translate(
            offset: Offset(-15, 0),
            child: Text(
              "Cash on delivery",
              style: TextStyle(fontSize: 16),
            ),
          ),
          value: paymentoptions[0],
          dense: true,
          groupValue: paymentvalue,
          onChanged: (value) {
            setState(() {
              paymentvalue = value as String;
            });
            print("Payment Option: " + paymentvalue.toString());
          },
        ),
        RadioListTile(
          dense: true,
          title: Transform.translate(
            offset: Offset(-15, 0),
            child: Text(
              "Online payment",
              style: TextStyle(fontSize: 16),
            ),
          ),
          value: paymentoptions[1],
          groupValue: paymentvalue,
          onChanged: (value) {
            setState(() {
              paymentvalue = value as String;
            });
            print("Payment Option: " + paymentvalue.toString());
          },
        )
      ],
    );
  }

  // void _onItemTapped(int index) {
  //   print(index);
  //   // setState(() {
  //   //   _selectedIndex = index;
  //   // });
  //   switch (index) {
  //     case 0:
  //       Navigator.of(context)
  //           .push(MaterialPageRoute(builder: ((context) => HomeScreen())))
  //           .then((_) {
  //         updateBadgeCount();
  //         print("Cart update called");
  //       });
  //       break;
  //     case 1:
  //       Navigator.of(context)
  //           .push(MaterialPageRoute(builder: ((context) => CategoriesScreen())))
  //           .then((_) {
  //         updateBadgeCount();
  //         print("Cart update called");
  //       });
  //       break;
  //     case 2:
  //       Navigator.of(context)
  //           .push(MaterialPageRoute(builder: ((context) => OfferScreen())))
  //           .then((_) {
  //         updateBadgeCount();
  //         print("Cart update called");
  //       });
  //       break;
  //     case 3:
  //       Navigator.of(context)
  //           .push(MaterialPageRoute(builder: ((context) => MyProfileScreen())))
  //           .then((_) {
  //         updateBadgeCount();
  //         print("Cart update called");
  //       });
  //       break;
  //     case 4:
  //       Navigator.of(context)
  //           .push(MaterialPageRoute(builder: ((context) => CartScreen())))
  //           .then((_) {
  //         updateBadgeCount();
  //         print("Cart update called");
  //       });
  //       break;
  //   }
  // }

  static Future getToken(orderID, orderAmount) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      //For test mode
      'x-client-id': '19493159dce3270e39874e55e9139491',
      'x-client-secret': '199d4c817cdab2d9d6d4ced50d5747f9800f8dc5',
      //For live mode
      // 'x-client-id': '243319c21c999f2a4d2d66866e913342',
      // 'x-client-secret': '2eb206bcf54c2a5c383bd5b861570d6c761601a4',
    };
    http.Response response = await http.post(
      // For test mode
      Uri.parse('https://test.cashfree.com/api/v2/cftoken/order'),
      //For live mode
      // Uri.parse('https://api.cashfree.com/api/v2/cftoken/order'),
      headers: headers,
      body: jsonEncode({
        'orderId': orderID,
        'orderAmount': orderAmount,
        'orderCurrency': 'INR'
      }),
    );
    var jsonData = json.decode(response.body);
    return jsonData;
  }

  @override
  Widget build(BuildContext context) {
    var totalamount;
    try{
      totalamount =  ((int.parse(widget.price.toString()) - widget.discount) +
          widget.serviceCharges +
          widget.tax_charge);
    }catch(_){
      totalamount =  ((double.parse(widget.price.toString()) - widget.discount) +
          widget.serviceCharges +
          widget.tax_charge);
    }
    return WillPopScope(
      onWillPop: () async {
        STM().back2Previous(context);
        return false;
      },
      child: Scaffold(
        // bottomNavigationBar: BottomNavigationBar(
        //   type: BottomNavigationBarType.fixed,
        //   items: <BottomNavigationBarItem>[
        //     BottomNavigationBarItem(
        //       icon: SvgPicture.asset(
        //         "assets/img/Home.svg",
        //       ),
        //       label: 'Home',
        //     ),
        //     BottomNavigationBarItem(
        //       icon: SvgPicture.asset(
        //         "assets/img/Categories.svg",
        //       ),
        //       label: 'Categories',
        //     ),
        //     BottomNavigationBarItem(
        //       icon: SvgPicture.asset(
        //         "assets/img/Offers.svg",
        //       ),
        //       label: 'Offers',
        //     ),
        //     BottomNavigationBarItem(
        //       icon: SvgPicture.asset(
        //         "assets/img/My Profile.svg",
        //       ),
        //       label: 'My Profile',
        //     ),
        //     // BottomNavigationBarItem(
        //     //   icon: contentInCart > 0
        //     //       ? Badge(
        //     //           child: SvgPicture.asset(
        //     //             "assets/img/Cart.svg",
        //     //           ),
        //     //           badgeColor: primary(),
        //     //           badgeContent: Text(
        //     //             contentInCart.toString(),
        //     //             style: TextStyle(color: Colors.white),
        //     //           ),
        //     //         )
        //     //       : SvgPicture.asset(
        //     //           "assets/img/Cart.svg",
        //     //         ),
        //     //   // icon: SvgPicture.asset("assets/img/Cart.svg"),
        //     //   label: 'Cart',
        //     // ),
        //   ],
        //   currentIndex: 0,
        //   showSelectedLabels: true,
        //   showUnselectedLabels: true,
        //   selectedItemColor: greyLite(),
        //   unselectedItemColor: greyLite(),
        //   selectedIconTheme: IconThemeData(size: 25.0, color: primary()),
        //   selectedLabelStyle: TextStyle(fontSize: 15.0, color: primary()),
        //   unselectedIconTheme: IconThemeData(size: 25.0, color: secondary()),
        //   unselectedLabelStyle: TextStyle(fontSize: 15.0, color: secondary()),
        //   onTap: _onItemTapped,
        // ),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: InkWell(
                onTap: () {
                  STM().back2Previous(context);
                },
                child: BackButton(color: Color(0xff244D73))),
            centerTitle: true,
            title: Text("Checkout",
                style: TextStyle(
                    color: Color(0xff00182E),
                    fontWeight: FontWeight.w500,
                    fontSize: 18)),
            flexibleSpace: barGredient(),
          ),
          body: isLoggedIn
              ? Column(
                children: [
                Expanded(
                  child: Container(
                      child: SingleChildScrollView(
                          child: infoPart(totalamount)))),
              Container(
                margin: EdgeInsets.all(25),
                child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 45,
                    child: isloaded
                        ? alladress.length > 0
                        ? Container(
                        width: MediaQuery.of(context).size.width *
                            0.6,
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
                            await SharedPreferences
                                .getInstance();
                            print("ADDRESS (SELECTED):" +
                                addressSelectedValue);
                            print("PAYMENT METHOD: " +
                                paymentvalue);
                            print("PAYMENT AMOUNT: " +
                                totalamount.toString());
                            print("COUPON CODE:" +
                                couponField.text.toString());
                            print("DELIVERY AMOUNT: " +
                                widget.delivery_charges
                                    .toString());
                            print("USER ID:" +
                                sp
                                    .getString('user_id')
                                    .toString());

                            if (paymentvalue == "cash") {
                              setState(() {
                                isloaded = false;
                              });
                              print("Its cash");
                              // PROCESS PAYMENT OFFLINE CASH
                              var dio = Dio();
                              var formData = FormData.fromMap({
                                'user_id': sp
                                    .getString('user_id')
                                    .toString(),
                                'address_id': addressSelectedValue
                                    .toString(),
                                'deliveryamount':
                                widget.serviceCharges,
                                'total': widget.price.toString(), //discountedtotalamount != 0 ? discountedtotalamount : totalamount,
                                'coupon_code':
                                couponField.text.toString(),
                                'payment_mode':
                                "CASH ON DELIVERY",
                              });
                              print(formData.fields.toString());
                              final response = await dio.post(
                                  paymentCashAndPlaceOrder(),
                                  data: formData);
                              var res =
                              json.decode(response.data);
                              print(res);
                              if (!res['error']) {
                                // updateBadgeCount();
                                // final db =
                                //     DatabaseHelper
                                //         .instance;
                                // db.clear();
                                // await Store.deleteAll();
                                // Navigator.of(context).pop();
                                // showDialog(
                                //     context: context,
                                //     builder: (context) {
                                //       return AlertDialog(
                                //         title: Text(
                                //           "Success",
                                //           style: TextStyle(
                                //             color: const Color(
                                //                 0xFF4A8028),
                                //           ),
                                //         ),
                                //         content: Text(res['message']),
                                //         actions: [
                                //           TextButton(
                                //               onPressed: () {
                                //                 Navigator.pushReplacement(
                                //                     context,
                                //                     MaterialPageRoute(
                                //                         builder:
                                //                             (context) =>
                                //                             MyOrdersScreen())).then(
                                //                         (_) {
                                //                       print(
                                //                           "Cart update called");
                                //                     });
                                //               },
                                //               child: Text("OK"))
                                //         ],
                                //       );
                                //     });
                                _showerrorOrderDialog(
                                    ctx: context,
                                    message: res['message']);
                              } else {
                                // db.clear();
                                await Store.deleteAll();
                                _showPlaceOrderDialog(
                                    ctx: context,
                                    message: res['message']);
                                // STM().successDialogWithAffinity(context, res['message'], MyOrdersScreen());
                                //   showDialog(
                                //       context: context,
                                //       builder: (context) {
                                //         return AlertDialog(
                                //           title: Text(
                                //             "Success",
                                //             // "Error",
                                //             style: TextStyle(
                                //               color: const Color(
                                //                   0xFF4A8028
                                //                   // 0xFFB00020
                                //               ),
                                //             ),
                                //           ),
                                //           content: Text(res['message']),
                                //           actions: [
                                //             TextButton(
                                //                 onPressed: () {
                                //
                                //                   Navigator.pushReplacement(
                                //                       context,
                                //                       MaterialPageRoute(
                                //                           builder:
                                //                               (context) =>
                                //                               MyOrdersScreen())).then(
                                //                           (_) {
                                //                         print(
                                //                             "Cart update called");
                                //                       });
                                //                 },
                                //                 child: Text("OK"))
                                //           ],
                                //           // actions: [
                                //           //   TextButton(
                                //           //       onPressed: () {
                                //           //         Navigator.of(context)
                                //           //             .pop();
                                //           //       },
                                //           //       child: Text("OK"))
                                //           // ],
                                //         );
                                //       });
                                // }
                                setState(() {
                                  isloaded = true;
                                });
                              }
                            } else if (paymentvalue == "online") {
                              print("Its online");
                              // Navigator.push(context, MaterialPageRoute(builder: ((context) => WebViewPage(selectedAddressId: addressSelectedValue.toString(),
                              //   deliveryAmount: serviceCharges.toString(),
                              //   total: price.toString(),tax_charge: tax_charge.toString(),
                              //   coupon_code: couponField.text.toString(),))));
                              // var long2 = double.parse(sTotalPrice);
                              // var price = long2 * 100;
                              // var options = {
                              //   'key': 'rzp_test_NJqCirEAXGLENl',
                              //   'amount': '20',
                              //   //in the smallest currency sub-unit.
                              //   'name': 'Quality Foods',
                              //   // 'order_id': 'order_EMBFqjDHEEn80l', // Generate order_id using Orders API
                              //   'order': {
                              //     "id": "order_DaZlswtdcn9UNV",
                              //     "entity": "order",
                              //     "amount": '20',
                              //     "amount_paid": 0,
                              //     // "amount_due": '${price.toString()}',
                              //     "amount_due": '20',
                              //     "currency": "INR",
                              //     // "receipt": "Receipt #20",
                              //     "status": "created",
                              //     "attempts": 0,
                              //     // "notes": {"key1": "value1", "key2": "value2"},
                              //     // "created_at": 1572502745
                              //   },
                              //   // 'description': 'Demo',
                              //   'theme.color': '#991404',
                              //   'timeout': 900,
                              //   // in seconds
                              //   // 'prefill': {
                              //   //   'contact': '',
                              //   //   'email': ''
                              //   // }
                              // };
                              // _razorpay.open(options);

                              print(addressSelectedValue
                                  .toString() +
                                  " \n${widget.serviceCharges.toString() + widget.price.toString()}" +
                                  widget.tax_charge.toString() +
                                  couponField.text.toString());

                              // var long2 = double.parse(sTotalPrice);
                              var pricenew = discountedtotalamount != 0 ? discountedtotalamount * 100 : totalamount * 100;
                              print('${pricenew}okoko');
                              print('${widget.price.toString()}dtrtrtt');
                              var options = {
                                // 'key': 'rzp_test_2Nsm4ZGj6heV50',
                                // 'key': 'rzp_test_NJqCirEAXGLENl',
                                'key': 'rzp_live_bKf6FafTP3KhKm',
                                'amount': pricenew.toString(),
                                'name': 'Quality Foods',
                                // 'description': 'Fruits Purchase',
                                // 'retry': {'enabled': true, 'max_count': 1},
                                // 'send_sms_hash': true,
                                // 'prefill': {
                                //   'contact': '',
                                //   'email': 'abc@gmail.com'
                                // },
                                'order': {
                                  // "id": "order_DaZlswtdcn9UNV",
                                  "entity": "order",
                                  "amount": '${pricenew.toString()}',
                                  // "amount_paid": '0',
                                  // "amount_due": '100000',
                                  "currency": "INR",
                                  // "receipt": "Receipt #20",
                                  "status": "created",
                                  "attempts": 0,
                                  // "notes": {"key1": "value1", "key2": "value2"},
                                  // "created_at": 1572502745
                                },
                                'theme.color': '#F16624',
                                'timeout': 900,
                                'external': {
                                  'wallets': ['paytm']
                                }
                              };

                              try {
                                _razorpay.open(options);
                              } catch (e) {
                                debugPrint('Error: e');
                                print(e.toString());
                              }

                              // Navigator.push(context, MaterialPageRoute(builder: ((context) => WebViewPage(selectedAddressId: addressSelectedValue.toString(), deliveryAmount: serviceCharges.toString(), total: price.toString(),tax_charge: tax_charge.toString(),coupon_code: couponField.text.toString(),))));
                              // SharedPreferences sp =
                              //     await SharedPreferences
                              //         .getInstance();
                              // Random random = Random();
                              // int orderId = random.nextInt(999999);
                              // var result = await getToken(
                              //     orderId.toString(),
                              //     totalamount.toString());
                              // if (result['status'] == "OK") {
                              //   String sToken = result['cftoken'];
                              //   String stage = "TEST";
                              //   String orderAmount =
                              //       totalamount.toString();
                              //   String customerName =
                              //       sp.getString("name") ?? "TEST";
                              //   String orderNote = "Order_Note";
                              //   String orderCurrency = "INR";
                              //   String customerPhone =
                              //       sp.getString('mobile') ??
                              //           "8888888881";
                              //   String customerEmail =
                              //       sp.getString('email') ??
                              //           "test@email.com";
                              //   //For test mode
                              //   String appId =
                              //       "19493159dce3270e39874e55e9139491";
                              //   //For live mode
                              //   // String appId =
                              //   //     "243319c21c999f2a4d2d66866e913342";
                              //   String notifyUrl =
                              //       "https://test.gocashfree.com/notify";
                              //
                              //   Map<String, dynamic> inputParams = {
                              //     "orderId": orderId,
                              //     "orderAmount": orderAmount,
                              //     "customerName": customerName,
                              //     "orderNote": orderNote,
                              //     "orderCurrency": orderCurrency,
                              //     "appId": appId,
                              //     "customerPhone": customerPhone,
                              //     "customerEmail": customerEmail,
                              //     "stage": stage,
                              //     "tokenData": sToken,
                              //     "notifyUrl": notifyUrl
                              //   };
                              //
                              //   CashfreePGSDK.doPayment(inputParams)
                              //       .then((value) async {
                              //     if (value!['txStatus'] ==
                              //         "SUCCESS") {
                              //       updateBadgeCount();
                              //       final db =
                              //           DatabaseHelper
                              //               .instance;
                              //       db.clear();
                              //       showDialog(
                              //           context: context,
                              //           builder: (context) {
                              //             return AlertDialog(
                              //               title: Text(
                              //                 "Success",
                              //                 style: TextStyle(
                              //                   color: const Color(
                              //                       0xFF4A8028),
                              //                 ),
                              //               ),
                              //               content:
                              //                   Text(value['txMsg']),
                              //               actions: [
                              //                 TextButton(
                              //                     onPressed: () {
                              //                       Navigator.of(
                              //                               context)
                              //                           .pop();
                              //                       Navigator.pushReplacement(
                              //                           context,
                              //                           MaterialPageRoute(
                              //                               builder:
                              //                                   (context) =>
                              //                                       MyOrdersScreen())).then(
                              //                           (_) {
                              //                         print(
                              //                             "Cart update called");
                              //                       });
                              //                     },
                              //                     child: Text("OK"))
                              //               ],
                              //             );
                              //           });
                              //     } else {
                              //       showDialog(
                              //           context: context,
                              //           builder: (context) {
                              //             return AlertDialog(
                              //               title: Text(
                              //                 "Error",
                              //                 style: TextStyle(
                              //                   color: const Color(
                              //                       0xFFB00020),
                              //                 ),
                              //               ),
                              //               content:
                              //                   Text(value['txMsg']),
                              //               actions: [
                              //                 TextButton(
                              //                     onPressed: () {
                              //                       Navigator.of(
                              //                               context)
                              //                           .pop();
                              //                     },
                              //                     child: Text("OK"))
                              //               ],
                              //             );
                              //           });
                              //     }
                              //
                              //     setState(() {
                              //       isloaded = true;
                              //     });
                              //   });
                              // }
                            } else {
                              print(
                                  "ERROR: No Payment method...");
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text("Error",
                                          style: TextStyle(
                                              color: Colors.red)),
                                      content: Text(
                                          "Please select a payment method"),
                                      actions: [
                                        TextButton(
                                          child: Text("OK"),
                                          onPressed: () =>
                                              Navigator.of(
                                                  context)
                                                  .pop(),
                                        )
                                      ],
                                    );
                                  });
                            }
                          },
                          child: Center(
                            child: Text(
                              'Place Order',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                        ))
                        : Container(
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          crossAxisAlignment:
                          CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                  width: MediaQuery.of(context)
                                      .size
                                      .width *
                                      0.6,
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
                                      shadowColor:
                                      Colors.transparent,
                                      //make color or elevated button transparent
                                    ),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text("Error",
                                                  style: TextStyle(
                                                      color: Colors
                                                          .red)),
                                              content: Text(
                                                  "Please add an address to continue"),
                                              actions: [
                                                TextButton(
                                                  child: Text("OK"),
                                                  onPressed: () =>
                                                      Navigator.of(
                                                          context)
                                                          .pop(),
                                                )
                                              ],
                                            );
                                          });
                                    },
                                    child: Center(
                                      child: Text(
                                        'Place Order',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 17,
                                            fontWeight:
                                            FontWeight.w400),
                                      ),
                                    ),
                                  )),
                            )
                          ],
                        ))
                        : Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                          ],
                        ))),
              ),
            ],
          )
              : Center(
            child: Column(children: [
              Text(
                "Please login in order to view checkout",
              ),
              TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LoginScreen()))
                        .then((_) {
                      // updateBadgeCount();
                      print("Cart update called");
                    });
                  },
                  child: Text("Login"))
            ]),
          )),
    );
  }

  _showPlaceOrderDialog({ctx, message}) {
    AwesomeDialog(
      // padding: EdgeInsets.all(20),
      dialogBorderRadius: BorderRadius.circular(0),
      borderSide: BorderSide.none,
      width: double.infinity,
      // isDense: true,
      context: ctx,
      dismissOnBackKeyPress: false,
      dismissOnTouchOutside: false,
      dialogType: DialogType.NO_HEADER,
      animType: AnimType.BOTTOMSLIDE,
      alignment: Alignment.centerLeft,
      body: Container(
        padding: EdgeInsets.all(Dim().d16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Success",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF4A8028),
              ),
            ),
            SizedBox(
              height: Dim().d12,
            ),
            Text(message,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                )),
            SizedBox(
              height: Dim().d16,
            ),
            TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => MyOrdersScreen()),
                        (Route<dynamic> route) => false,
                  ).then((_) {
                    print("Cart update called");
                  });
                },
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text("OK",
                      style: TextStyle(fontSize: 14, color: Colors.orange)),
                ))
          ],
        ),
      ),
    ).show();
  }
  _showerrorOrderDialog({ctx, message}) {
    AwesomeDialog(
      // padding: EdgeInsets.all(20),
      dialogBorderRadius: BorderRadius.circular(0),
      borderSide: BorderSide.none,
      width: double.infinity,
      // isDense: true,
      context: ctx,
      dismissOnBackKeyPress: false,
      dismissOnTouchOutside: false,
      dialogType: DialogType.NO_HEADER,
      animType: AnimType.BOTTOMSLIDE,
      alignment: Alignment.centerLeft,
      body: Container(
        padding: EdgeInsets.all(Dim().d16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Failed",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Clr().red,
              ),
            ),
            SizedBox(
              height: Dim().d12,
            ),
            Text(message,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                )),
            SizedBox(
              height: Dim().d16,
            ),
            TextButton(
                onPressed: () {
                 STM().back2Previous(ctx);
                },
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text("OK",
                      style: TextStyle(fontSize: 14, color: Colors.orange)),
                ))
          ],
        ),
      ),
    ).show();
  }

  apiTime() async {
    FormData body = FormData.fromMap(
        {'date': DateFormat('dd-MM-yyyy').format(DateTime.now())});
    var result =
    await STM().postWithoutDialog(context, 'time_service.php', body);
    if (result['error'] == false) {
      setState(() {
        message = result['message'];
        print(DateTime.now());
        startTime = DateTime.parse('${DateFormat('yyyy-MM-dd').format(DateTime.now())} ${result['time_1']}');
        print(startTime);
        data = result;
        endTime = DateTime.parse('${DateFormat('yyyy-MM-dd').format(DateTime.now())} ${result['time_2']}');
        print(endTime);
      });
    }
  }

  Widget showMessage() {
    return time.isAfter(startTime) && time.isBefore(endTime)
        ? Padding(
      padding: EdgeInsets.symmetric(vertical: Dim().d20),
      child: Text('Note: $message',
          textAlign: TextAlign.center,
          style: Sty().mediumText.copyWith(color: Colors.orange)),
    )
        : Container();
  }
}
