import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'appbar_gradientlook.dart';
import 'checkout.dart';
import 'colors.dart';
import 'globalurls.dart';
import 'manage/static_method.dart';
import 'values/colors.dart';
import 'values/dimens.dart';
import 'values/styles.dart';

class CouponCode extends StatefulWidget {
  final  price ,discount;
  const CouponCode({super.key, required this.price, required this.discount});

  @override
  State<StatefulWidget> createState() {
    return CouponCodePage();
  }
}

class CouponCodePage extends State<CouponCode> {
  late BuildContext ctx;
  GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();

  List<Widget> offerItemList = [];
  TextEditingController couponField = TextEditingController();
  bool isloaded = false;
  dynamic? discount,price;
  bool couponFieldEnabled = true;
  String couponAppliedText = "";
  double couponDiscount = 0.0;
  bool isLoggedIn = false;


  Widget offerItem(String code, String details) {

    return Card(
      elevation: 0,
      margin:  EdgeInsets.only(bottom: 15),
      shape:  RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey,width:0.4),
          borderRadius:
          BorderRadius.all(Radius.circular(10))),
      color: const Color(0xffFFFFFF),
      child:Padding(
        padding: EdgeInsets.all(Dim().d16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              // crossAxisAlignment: CrossAxisAlignment.spaceBetween,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SvgPicture.asset('assets/img/coupancode.svg'),
                    SizedBox(width: Dim().d4,),
                    Text(code, style: Sty().smallText.copyWith(
                        color: Clr().textPrimaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                    ),
                  ],
                ),
                SizedBox(height: Dim().d8,width:Dim().d16 ),
                Padding(
                  padding:  EdgeInsets.only(left: 24.0),
                  child: Text('Pay with visa card to avail the offer ',style: Sty().smallText.copyWith(
                      color: Clr().textSecondaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 11),
                  ),
                ),
              ],
            ),

            SizedBox(
              height: Dim().d32,
              width: Dim().d80,

              child: Container(
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
                      SharedPreferences sp = await SharedPreferences.getInstance();
                      applyCoupon(code:code.toString());
                      print(widget.price);
                      print(code.toString());
                      print(widget.discount);
                      print(sp.getString('user_id').toString());

                    },
                    child: Center(
                      child: Text(
                        'Apply',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  void applyCoupon({code}) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    var dio = Dio();
    // print(price - discount);
    var formData = FormData.fromMap({
      'coupon_name': code,
      'order_amt': widget.price,
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
      // var total = (widget.price - widget.discount);
      CheckoutScreenPage.controller.sink.add({
        "codeame": code,
        "discount": res['final_amount'].toString(),
        "discountprice": double.parse(res['discount_amount'].toString()),
      });
      STM().back2Previous(ctx);
      setState(() {
        couponAppliedText = "Coupon Applied!";
        couponFieldEnabled = false;
        discount = double.parse(res['discount_amount'].toString()) ;
      });
      SnackBar sn = SnackBar(content: Text(res['message']));
      ScaffoldMessenger.of(context).showSnackBar(sn);
    }
  }


  void getOffers() async {
    setState(() {
      isloaded = false;
    });
    var dio = Dio();
    var formData = FormData.fromMap({
      // 'user_id' : '2'
    });
    final response = await dio.post(couponsDataPageUrl(), data: formData);
    var res = json.decode(response.data);
    print(res);

    offerItemList = [];
    for(int i = 0; i < res['result_array'].length; i++){
      offerItemList.add(offerItem(res['result_array'][i]['code'], res['result_array'][i]['detail']));
    }

    setState(() {
      offerItemList = offerItemList;
      isloaded = true;
    });
  }

  void initState(){
    getOffers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ctx = context;
    return Scaffold(

      key: scaffoldState,
      appBar: AppBar(
        backgroundColor:Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_outlined,color: Color(0xff244D73)),
          // iconSize: 35,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("Coupon Code", style: TextStyle(
            color: Color(0xff00182E),
            fontWeight: FontWeight.w500,
            fontSize: 18)),
        flexibleSpace: barGredient(),
      ),

      backgroundColor: Clr().white,
      body :isloaded ? offerItemList.length > 0 ? Container(
        child: Center(
          child: Scrollbar(
            child: Container(
              margin: EdgeInsets.all(15),
              child: ListView(
                children: offerItemList.length > 0 ? offerItemList : [Center(child: Text("No Offers Found"))],
              ),
            ),
          ),
        ),
      ) : Center(child: Text("No Data Found", style: TextStyle(color: primary(), fontSize:25),)) : Center(child: CircularProgressIndicator(),),

    );
  }
}
