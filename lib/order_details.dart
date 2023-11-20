import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:qf/appbar_gradientlook.dart';
import 'package:qf/manage/static_method.dart';
import 'package:qf/myorders.dart';
import 'package:qf/values/colors.dart';
import 'package:qf/values/dimens.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'globalurls.dart';
import 'login.dart';

class OrderDetailsScreen extends StatefulWidget {
  // Transaction details
  String? orderNumber;
  String? purchaseDetails;
  String? amountPayable;
  String? paymentMode;
  String? orderStaus;
  String? order_identifier;

  // Delivery Status
  String? address;
  String? date;

  // product details
  List? productDetailsList;

  // order summary
  String? price;
  String? discount;
  String? delivery_charges;
  String? tax_charge;

  String? final_total_amount;

  OrderDetailsScreen(
      {this.orderNumber,
      this.purchaseDetails,
      this.amountPayable,
      this.paymentMode,
      this.orderStaus,
      this.order_identifier,
      this.address,
      this.date,
      this.productDetailsList,
      this.price,
      this.discount,
      this.delivery_charges,
      this.final_total_amount,
      this.tax_charge});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  List<Widget> orderCardWidgetList = [];
  bool isloaded = false;

  Widget productItem(String imagepath, String amount, String variant,
      String qty, String productName) {
    return Container(
      margin: EdgeInsets.only(top: 5),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: Dim().d4, right: Dim().d8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Html(
                          data: productName.toString(),
                          style: {
                            "body": Style(
                              // margin: EdgeInsets.zero,
                              color: Clr().primaryColor,
                              fontWeight: FontWeight.w400,
                              fontSize: FontSize(14.0),
                            )
                          },
                        ),
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Text(
                        'x  ${qty.toString()}',
                        style: TextStyle(
                            color: Clr().primaryColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w400),
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Expanded(
                        child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "\u20b9 ${amount.toString()}",
                              style: TextStyle(
                                  color: Clr().primaryColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400),
                            )),
                      ),
                    ],
                  ),
                ),

                // SizedBox(
                //   height: 5,
                // ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Expanded(
                //       child: Text("Amount",
                //           style: TextStyle(fontWeight: FontWeight.bold)),
                //     ),
                //     Text(":"),
                //     SizedBox(width: 20),
                //     Expanded(
                //         child: Text(
                //       "₹" + amount.toString(),
                //     ))
                //   ],
                // ),
                // SizedBox(
                //   height: 5,
                // ),
                // if (variant.isNotEmpty)
                //   Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Expanded(
                //         child: Text("Variant",
                //             style: TextStyle(fontWeight: FontWeight.bold)),
                //       ),
                //       Text(":"),
                //       SizedBox(
                //         width: 20,
                //       ),
                //       Expanded(
                //         child: Text(
                //           variant.toString(),
                //         ),
                //       ),
                //     ],
                //   ),
                // SizedBox(
                //   height: 5,
                // ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Expanded(
                //       child: Text("Qty",
                //           style: TextStyle(fontWeight: FontWeight.bold)),
                //     ),
                //     Text(":"),
                //     SizedBox(width: 20),
                //     Expanded(
                //         child: Text(
                //       qty.toString(),
                //     ))
                //   ],
                // ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    // print(this.widget.orderNumber +
    //     this.widget.purchaseDetails +
    //     this.widget.amountPayable +
    //     this.widget.paymentMode +
    //     this.widget.address +
    //     this.widget.address +
    //     this.widget.orderStaus +
    //     this.widget.date);
    // print(this.widget.productDetailsList);
    // print(this.widget.price +
    //     this.widget.discount +
    //     this.widget.delivery_charges);

    return WillPopScope(
      onWillPop: ()async{
        STM().finishAffinity(context, MyOrdersScreen());
        return false;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
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
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_outlined, color: Color(0xff244D73)),
            // iconSize: 35,
            onPressed: () => STM().finishAffinity(context, MyOrdersScreen()),
          ),
          title: Text(this.widget.orderNumber.toString(),
              style: TextStyle(
                  color: Color(0xff00182E),
                  fontWeight: FontWeight.w500,
                  fontSize: 18)),
          flexibleSpace: barGredient(),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Image.asset(
                    'assets/img/productimg.png',
                    height: 306,
                    fit: BoxFit.fitWidth,
                    width: MediaQuery.of(context).size.width,
                  ),
                  Positioned(
                      top: 104,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 200,
                        child: SingleChildScrollView(
                          physics: NeverScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              if (this.widget.orderStaus.toString() == "Ordered")
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Your Order Is Getting Packed And Will Be \n Delivered To You Shortly',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Clr().textSecondaryColor,
                                    ),
                                  ),
                                ),
                              if (this.widget.orderStaus.toString() ==
                                  "Delivered")
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Your Order is Delivered Successfully!!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Clr().textSecondaryColor,
                                    ),
                                  ),
                                ),
                              if (this.widget.orderStaus.toString() ==
                                  "Cancelled")
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Your Order has been Cancelled!!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Clr().textSecondaryColor,
                                    ),
                                  ),
                                ),
                              SizedBox(
                                height: 16,
                              ),
                              if (this.widget.orderStaus.toString() ==
                                  "Cancelled")
                                SvgPicture.asset(
                                  'assets/img/cancelorder.svg',
                                  height: 170,
                                ),
                              if (this.widget.orderStaus.toString() ==
                                  "Delivered")
                                SvgPicture.asset(
                                  'assets/img/ordersucces.svg',
                                  height: 170,
                                ),
                              if (this.widget.orderStaus.toString() == "Ordered")
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 20),
                                      child: Column(
                                        children: [
                                          Lottie.asset('animation/stopwatch.json',
                                              height: 90, fit: BoxFit.cover),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          TweenAnimationBuilder<Duration>(
                                              duration: Duration(minutes: 15),
                                              tween: Tween(
                                                  begin: Duration(minutes: 15),
                                                  end: Duration.zero),
                                              onEnd: () {
                                                print('Timer ended');
                                              },
                                              builder: (BuildContext context,
                                                  Duration value, Widget? child) {
                                                final minutes = value.inMinutes;
                                                final seconds =
                                                    value.inSeconds % 60;
                                                return Text('$minutes:$seconds',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Color(0xffF16624),
                                                        fontSize: 24,
                                                        fontWeight:
                                                            FontWeight.w500));
                                              }),
                                          // Text(
                                          //     "15:00 ",
                                          //     style:
                                          //     TextStyle(
                                          //         color: Color(0xffF16624),
                                          //         fontSize: 24,
                                          //         fontWeight: FontWeight.w500)),
                                          Text("Min Remaining",
                                              style: TextStyle(
                                                  color: Clr().textSecondaryColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500)),
                                          SizedBox(
                                            height: 6,
                                          )
                                        ],
                                      ),
                                    ),
                                    Lottie.asset('animation/belt animation.json',
                                        height: 150, fit: BoxFit.cover),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ))
                ],
              ),
              Container(
                  decoration: BoxDecoration(
                      color: Clr().white,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20),
                          topLeft: Radius.circular(20))),
                  // padding: EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            margin: EdgeInsets.only(
                                top: 16, bottom: 2, right: 8, left: 16),
                            child: Row(
                              children: [
                                SvgPicture.asset('assets/img/producticon.svg'),
                                SizedBox(
                                  width: 5,
                                ),
                                Text("Product Summary",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 18,
                                        color: Clr().textSecondaryColor)),
                              ],
                            )),
                        Divider(
                          color: Color(0xff90ABC3),
                          endIndent: 16,
                          indent: 16,
                        ),
                        SingleChildScrollView(
                          physics: ScrollPhysics(),
                          child: Column(
                            children: [
                              for (int i = 0;
                                  i < this.widget.productDetailsList!.length;
                                  i++)
                                productItem(
                                    this
                                        .widget
                                        .productDetailsList![i]['Product_img']
                                        .toString(),
                                    this.widget.productDetailsList![i]
                                        ['Product_price'],
                                    this.widget.productDetailsList![i]
                                        ['Product_weight'],
                                    this.widget.productDetailsList![i]
                                        ['Product_qty'],
                                    this.widget.productDetailsList![i]
                                        ['Product_name'])
                            ],
                          ),
                        ),

                        Divider(
                          color: Color(0xff90ABC3),
                          endIndent: 16,
                          indent: 16,
                        ),

                        Container(
                            margin: EdgeInsets.only(
                                top: 16, bottom: 4, right: 16, left: 16),
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
                          margin:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Order Amount",
                                  style: TextStyle(fontWeight: FontWeight.w400)),
                              Text(
                                "₹" + this.widget.price.toString(),
                              )
                            ],
                          ),
                        ),

                        Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Delivery charges",
                                  style: TextStyle(fontWeight: FontWeight.w400)),
                              Text(
                                "₹" + this.widget.delivery_charges.toString(),
                              )
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
                          margin:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Tax",
                                  style: TextStyle(fontWeight: FontWeight.w400)),
                              Text(
                                "₹" + this.widget.tax_charge.toString(),
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Coupon Discount",
                                  style: TextStyle(fontWeight: FontWeight.w400)),
                              Text("₹" + this.widget.discount.toString())
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
                          margin:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Total Amount",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xffF16624),
                                      fontSize: 16)),
                              Text(
                                "₹" + this.widget.final_total_amount.toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xffF16624),
                                    fontSize: 16),
                              )
                            ],
                          ),
                        ),
                        // Divider(
                        //   height: 2,
                        // ),
                        // Container(
                        //   padding: EdgeInsets.all(2),
                        //   child: Row(
                        //     children: [
                        //       Expanded(
                        //         child: Text("Order Number",
                        //             style: TextStyle(fontWeight: FontWeight.bold)),
                        //       ),
                        //       Text(":"),
                        //       SizedBox(
                        //         width: 20,
                        //       ),
                        //       Expanded(
                        //           child: Text(
                        //             this.widget.orderNumber.toString(),
                        //           ))
                        //     ],
                        //   ),
                        // ),
                        // Container(
                        //   padding: EdgeInsets.all(2),
                        //   child: Row(
                        //     children: [
                        //       Expanded(
                        //         child: Text("Purchase Details",
                        //             style: TextStyle(fontWeight: FontWeight.bold)),
                        //       ),
                        //       Text(":"),
                        //       SizedBox(
                        //         width: 20,
                        //       ),
                        //       Expanded(
                        //           child: Text(
                        //             this.widget.purchaseDetails.toString(),
                        //           ))
                        //     ],
                        //   ),
                        // ),
                        Container(
                          padding: EdgeInsets.all(2),
                          child: Row(
                            children: [
                              // Expanded(
                              //   child: Text("Amount Payable",
                              //       style: TextStyle(fontWeight: FontWeight.bold)),
                              // ),
                              // Text(":"),
                              // SizedBox(
                              //   width: 20,
                              // ),
                              // Expanded(
                              //     child: Text(
                              //       "₹" + this.widget.amountPayable.toString(),
                              //     ))
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(2),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text("Payment Mode",
                                    textAlign: TextAlign.center,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Text(":"),
                              // Text(this.widget.orderStaus.toString()),
                              SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                  child: Text(
                                this.widget.paymentMode.toString(),
                              ))
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          child: Divider(
                            height: 2,
                          ),
                        ),
                        Container(
                            margin: EdgeInsets.only(
                                top: 16, bottom: 2, right: 8, left: 16),
                            child: Row(
                              children: [
                                SvgPicture.asset('assets/img/deliveryicon.svg'),
                                SizedBox(
                                  width: 5,
                                ),
                                Text("Delivery Address",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 18,
                                        color: Clr().textSecondaryColor)),
                              ],
                            )),
                        Container(
                          margin: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              border: Border.all(color: Color(0xffE5F3FF))),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      margin: EdgeInsets.only(top: 5),
                                      child: Text("Address",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold))),
                                  Container(
                                      margin: EdgeInsets.only(top: 5),
                                      child: Text(this.widget.address.toString(),
                                          style: TextStyle(
                                              color: Clr().primaryColor,
                                              fontFamily: 'Opensans'))),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Text(this.widget.orderStaus.toString()),

                        this.widget.orderStaus.toString() == "Delivered" ||
                                this.widget.orderStaus.toString() == "Cancelled"
                            ? Container()
                            : Align(
                                alignment: Alignment.center,
                                child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.6,
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
                                        // CheckoutScreenPage.controller.sink.add({
                                        //   "codeame": code,
                                        //   "discount":res['final_amount'].toString(),
                                        //   "discountprice": double.parse(res['discount_amount'].toString()),
                                        // });
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                content: Text(
                                                    "Do you really want to cancel this order?"),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () async {
                                                        var dio = Dio();
                                                        var formData =
                                                            FormData.fromMap({
                                                          // 'user_id' : sp.getString('user_id').toString(),
                                                          'order_id': this
                                                              .widget
                                                              .order_identifier
                                                              .toString(),
                                                        });
                                                        final response =
                                                            await dio.post(
                                                                cancelOrderUrl(),
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
                                                          // Navigator.pushReplacement(context, MaterialPageRoute(
                                                          //     builder: (context) => MyOrdersScreen()));
                                                          // Navigator.of(context).pushReplacement( MaterialPageRouter(builder: (context) => MyOrdersScreen()));
                                                          getUserOrder();
                                                          Navigator.of(context)
                                                              .pop();
                                                        }
                                                      },
                                                      child: Text("YES")),
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text("NO")),
                                                ],
                                              );
                                            });
                                      },
                                      // onPressed: () {
                                      //   Navigator.push(
                                      //       context,
                                      //       MaterialPageRoute(
                                      //         builder: (context) => OrderDetailsScreen(
                                      //           orderNumber: orderNumber.toString(),
                                      //           purchaseDetails: orderDate.toString(),
                                      //           amountPayable: orderTotal.toString(),
                                      //           paymentMode: paymentMode.toString(),
                                      //           address: address.toString(),
                                      //           date: deliveryDate.toString(),
                                      //           productDetailsList: productList,
                                      //           price: price.toString(),
                                      //           discount: discount.toString(),
                                      //           delivery_charges: delivery_charges.toString(),
                                      //           final_total_amount: orderTotal.toString(),
                                      //           tax_charge: tax_charge.toString(), orderStaus: orderStaus.toString(),),
                                      //       )).then((_) {
                                      //     updateBadgeCount();
                                      //     print("Cart update called");
                                      //   });
                                      // },
                                      child: Center(
                                        child: Text(
                                          'Cancel Order',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                    )),
                              ),
                        SizedBox(
                          height: 30,
                        )
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

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
    // for (int i = 0; i < res['result_array'].length; i++) {
    //   print("================================");
    //   print(res['result_array'][i]['Products']);
    //   orderCardWidgetList.add(orderCard(
    //       res['result_array'][i]['ID'].toString(),
    //       res['result_array'][i]['order_number'].toString(),
    //       res['result_array'][i]['status'].toString(),
    //       res['result_array'][i]['placement_date'].toString(),
    //       res['result_array'][i]['final_total'].toString(),
    //       res['result_array'][i]['Products'],
    //       res['result_array'][i]['payment_mode'].toString(),
    //       "${res['result_array'][i]['address']} ${res['result_array'][i]['landmark']} Pincode: ${res['result_array'][i]['pincode']}",
    //       res['result_array'][i]['delivery_date'].toString(),
    //       res['result_array'][i]['total'].toString(),
    //       res['result_array'][i]['discount'].toString(),
    //       res['result_array'][i]['DeliveryCharge'].toString(),
    //       res['result_array'][i]['tax_charge'].toString()));
    // }

    setState(() {
      orderCardWidgetList = orderCardWidgetList;
      isloaded = true;
    });
  }
}
