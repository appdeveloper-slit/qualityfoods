import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:qf/checkout.dart';
import 'package:qf/colors.dart';
import 'package:qf/home_page.dart';
import 'package:qf/login.dart';
import 'package:qf/main_app_screen.dart';
import 'package:qf/manage/static_method.dart';
import 'package:qf/sqliteop.dart';
import 'package:qf/values/colors.dart';
import 'package:qf/values/dimens.dart';
import 'package:qf/values/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './appbar_gradientlook.dart';
import 'globalurls.dart';
import 'localstore.dart';

// Replace this with your own code...
// data1 => product id
// data4 => count
// data6 => variant

class CartScreen extends StatefulWidget {
  final type;

  const CartScreen({Key? key, this.type}) : super(key: key);

  @override
  State<CartScreen> createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
  var final_total_cart = 0.0;
  bool isLoggedIn = false;
  var message;
  List<Map<String, dynamic>> resultList = [];
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();

  // void getCartItems() async {
  //   final db = DatabaseHelper.instance;
  //   final allRows = await db.queryAllRows();
  //   print('query all rows:');
  //   resultList = [];
  //
  //   for (int i = 0; i < allRows.length; i++) {
  //     resultList.add({
  //       "name": allRows[i][DatabaseHelper.columnName],
  //       "amount": allRows[i][DatabaseHelper.columnPrice],
  //       "totamount": allRows[i][DatabaseHelper.columnTotalAmount],
  //       "amt": allRows[i][DatabaseHelper.columnVariantArray],
  //       // "data6": json
  //       //     .decode(allRows[i][DatabaseHelper.columnVariantArray])['weight']
  //       //     .toString(),
  //       "data6": allRows[i][DatabaseHelper.columnVariant],
  //       "normal_weight_text": allRows[i][DatabaseHelper.columnVariant], // variant => data6
  //       // "normal_weight_text": json
  //       //     .decode(allRows[i][DatabaseHelper.columnVariantArray])['weight']
  //       //     .toString(), // variant => data6
  //       "data4": allRows[i][DatabaseHelper.columnQuantity], // count => data4
  //       "data1": allRows[i][DatabaseHelper.columnProductUniqueId],
  //       "image": allRows[i][DatabaseHelper.columnImage],
  //       "product_qty": allRows[i][DatabaseHelper.columnProductQty]
  //     });
  //
  //     print("PRODUCT ID: ${allRows[i][DatabaseHelper.columnProductUniqueId]}");
  //     // print(
  //     //     "GOT VARIANT WEIGHT: ${json.decode(allRows[i][DatabaseHelper.columnVariantArray])}");
  //   }
  //
  //   final_total_cart = 0;
  //   for (int i = 0; i < resultList.length; i++) {
  //     // print(json.decode(json.encode(resultList[i]).toString())['totamount']);
  //     final_total_cart = final_total_cart +
  //         double.parse(json.decode(json.encode(resultList[i]).toString())['totamount'].toString());
  //   }
  //
  //   setState(() {
  //     resultList = resultList;
  //     final_total_cart = final_total_cart;
  //   });
  //   print('${resultList}' + 'gsgsg');
  // }

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
      //  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }

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
  var time = DateTime.now();
  List<dynamic> addToCart = [];
  bool isLoading = true;
  String sTotalPrice = "0";
  String? sUserid;
  dynamic data;

  Future<void> _updateItem(medicine_id, varientid, name, image, price,
      actualPrice, description, counter) async {
    await Store.updateItem(medicine_id, varientid, name, image, price,
        actualPrice, description, counter);
  }

  void _refreshData() async {
    var data = await Store.getItems();
    var price = await Store.getTotalPrice();
    setState(() {
      addToCart = data;
      isLoading = false;
      sTotalPrice = price;
      print(addToCart);
      listofCartLayout();
    });
    print('${resultList}okokok');
  }

  @override
  void initState() {
    print(addToCart);
    checkLoggedIn();
    apiTime();
    _refreshData();
    // getCartItems();
    // updateBadgeCount();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        widget.type == 'home'
            ? STM().finishAffinity(context, HomeScreen())
            : STM().back2Previous(context);
        return false;
      },
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            // elevation: 0.2,
            leading: InkWell(
                onTap: () {
                  widget.type == 'home'
                      ? STM().finishAffinity(context, HomeScreen())
                      : STM().back2Previous(context);
                },
                child: BackButton(color: Color(0xff244D73))),
            centerTitle: true,
            title: Text("My Cart",
                style: TextStyle(
                    color: Color(0xff00182E),
                    fontWeight: FontWeight.w500,
                    fontSize: 18)),
            flexibleSpace: barGredient(),
          ),
          body: addToCart.length > 0
              ? Column(
                  children: [
                    showMessage(),
                    Card(
                      margin: EdgeInsets.only(
                          left: 12, right: 12, bottom: 8, top: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      color: Color(0xffFFEEE5),
                      // child: Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     Text('Total Items added:'),
                      //   Column(
                      //       mainAxisAlignment: MainAxisAlignment.spaceAround,
                      //       children: [
                      //         Text('Sub Total:',style: TextStyle(color: Color(0xffF16624),height: 16)),
                      //         Text('₹ 800',style: TextStyle(color: Color(0xffF16624),height: 16))
                      //       ],
                      //     ),
                      //   ],
                      // ),

                      child: ListTile(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                        title: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                  text: ' Total Items added:',
                                  style: TextStyle(
                                      color: Color(0xffF16624), fontSize: 15)),
                              TextSpan(
                                text: ' ${addToCart.length}',
                                style: TextStyle(
                                    color: Color(0xffF16624),
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),

                          // title: RichText(text: TextSpan(
                          //   text: 'Total Items added:',style: TextStyle(color: Color(0xffF16624),fontSize: 16)
                          // ),
                        ),
                        // title: Text('Total Items added:3',style: TextStyle(color: Color(0xffF16624),fontSize: 16)),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text('Sub Total:',
                                style: TextStyle(
                                    color: Color(0xffF16624),
                                    fontSize: 16,
                                    fontFamily: 'Opensans')),
                            Text("₹ $sTotalPrice",
                                style: TextStyle(
                                    color: Color(0xffF16624),
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: addToCart.length,
                        // padding: EdgeInsets.only(top:4),
                        itemBuilder: (context, index) {
                          return StatefulBuilder(builder: (context, setState) {
                            // resultList[index]['count'] = 0;
                            return ItemLayout(context, index, addToCart);
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      height: Dim().d8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        addToCart.length != 0
                            ? ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  primary: Colors.transparent,
                                  onSurface: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  //make color or elevated button transparent
                                ),
                                onPressed: () {
                                  Store.deleteAll().then((value) {
                                    _refreshData();
                                  });
                                },
                                child: Center(
                                  child: Text(
                                    'Clear All',
                                    style: Sty().mediumText,
                                  ),
                                ))
                            : Container(),
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
                              if (addToCart.length > 0) {
                                SharedPreferences sp =
                                    await SharedPreferences.getInstance();
                                print(json.encode(resultList).toString());
                                print("USER ID: ${sp.getString('user_id')}");
                                if (sp.getBool('isLoggedIn') == false ||
                                    sp.getString('user_id') == null) {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              LoginScreen())).then((_) {
                                    // updateBadgeCount();
                                    print("Cart update called");
                                  });
                                } else {
                                  var dio = Dio();
                                  var formData = FormData.fromMap({
                                    'products': jsonEncode(resultList),
                                    'user_id':
                                        sp.getString('user_id').toString()
                                  });
                                  final response = await dio.post(
                                      updateCartInformation(),
                                      data: formData);
                                  var res = json.decode(response.data);
                                  print(res);
                                  debugPrint(formData.fields.toString());
                                  if (res['error'] == true) {
                                    SnackBar sn =
                                        SnackBar(content: Text(res['message']));
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(sn);
                                  } else {
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //       builder: (context) => CheckoutScreen(price:  final_total_cart, discount: 0, delivery_charges: 0, mainDiscount: 0, mainTotal: final_total_cart,)));
                                    //  double.parse(res['result'][0]['GrandTotal'].toString())
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CheckoutScreen(
                                                  tax_charge: double.parse(
                                                      res['result'][0]
                                                              ['tax_charge']
                                                          .toString()),
                                                  serviceCharges: double.parse(
                                                      res['result'][0]
                                                              ['ServiceCharge']
                                                          .toString()),
                                                  price: sTotalPrice.toString(),
                                                  discount: 0,
                                                  delivery_charges: 0,
                                                  mainDiscount: 0,
                                                  mainTotal: double.parse(
                                                      res['result'][0]
                                                              ['GrandTotal']
                                                          .toString()),
                                                ))).then((_) {
                                      // updateBadgeCount();
                                      print("Cart update called");
                                    });
                                  }
                                }
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(
                                            "Looks like there is nothing in your cart. Please add something in order to proceed."),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text("OK"))
                                        ],
                                      );
                                    });
                                print("ZERO ITEMS IN CART BRO!!");
                              }
                            },
                            child: Center(
                              child: Text(
                                'Proceed to Checkout',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: Dim().d20,
                    ),
                    // Container(
                    //   decoration: BoxDecoration(
                    //       border: Border.all(width: 2, color: primary()),
                    //       borderRadius: BorderRadius.circular(10.0)),
                    //   padding: EdgeInsets.all(2),
                    //   margin:
                    //       EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                    //   child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //       children: [
                    //         Container(
                    //           margin: EdgeInsets.only(left: 10),
                    //           child: Row(
                    //             children: [
                    //               Text("Total: "),
                    //               Text(
                    //                 "₹" + final_total_cart.toString(),
                    //                 style:
                    //                     TextStyle(fontSize: 20, color: primary()),
                    //               ),
                    //             ],
                    //           ),
                    //         ),
                    //         Container(
                    //           margin: EdgeInsets.only(right: 10),
                    //           child: TextButton(
                    //               onPressed: () async {
                    //                 if (resultList.length > 0) {
                    //                   SharedPreferences sp =
                    //                       await SharedPreferences.getInstance();
                    //                   print(json.encode(resultList).toString());
                    //                   print("USER ID: " +
                    //                       sp.getString('user_id').toString());
                    //                   if (sp.getBool('isLoggedIn') == false ||
                    //                       sp.getString('user_id') == null) {
                    //                     Navigator.pushReplacement(
                    //                         context,
                    //                         MaterialPageRoute(
                    //                             builder: (context) =>
                    //                                 LoginScreen())).then((_) {
                    //                       updateBadgeCount();
                    //                       print("Cart update called");
                    //                     });
                    //                   } else {
                    //                     var dio = Dio();
                    //                     var formData = FormData.fromMap({
                    //                       'products':
                    //                           json.encode(resultList).toString(),
                    //                       'user_id':
                    //                           sp.getString('user_id').toString()
                    //                     });
                    //                     final response = await dio.post(
                    //                         updateCartInformation(),
                    //                         data: formData);
                    //                     var res = json.decode(response.data);
                    //                     print(res);
                    //
                    //                     if (res['error'] == true) {
                    //                       SnackBar sn = SnackBar(
                    //                           content: Text(res['message']));
                    //                       ScaffoldMessenger.of(context)
                    //                           .showSnackBar(sn);
                    //                     } else {
                    //                       // Navigator.push(
                    //                       //   context,
                    //                       //   MaterialPageRoute(
                    //                       //       builder: (context) => CheckoutScreen(price:  final_total_cart, discount: 0, delivery_charges: 0, mainDiscount: 0, mainTotal: final_total_cart,)));
                    //                       //  double.parse(res['result'][0]['GrandTotal'].toString())
                    //                       Navigator.push(
                    //                           context,
                    //                           MaterialPageRoute(
                    //                               builder: (context) =>
                    //                                   CheckoutScreen(
                    //                                     tax_charge: double.parse(
                    //                                         res['result'][0]
                    //                                                 ['tax_charge']
                    //                                             .toString()),
                    //                                     serviceCharges: double
                    //                                         .parse(res['result']
                    //                                                     [0][
                    //                                                 'ServiceCharge']
                    //                                             .toString()),
                    //                                     price: double.parse(
                    //                                         res['result'][0]
                    //                                                 ['Total']
                    //                                             .toString()),
                    //                                     discount: 0,
                    //                                     delivery_charges: 0,
                    //                                     mainDiscount: 0,
                    //                                     mainTotal: double.parse(
                    //                                         res['result'][0]
                    //                                                 ['GrandTotal']
                    //                                             .toString()),
                    //                                   ))).then((_) {
                    //                         updateBadgeCount();
                    //                         print("Cart update called");
                    //                       });
                    //                     }
                    //                   }
                    //                 } else {
                    //                   showDialog(
                    //                       context: context,
                    //                       builder: (context) {
                    //                         return AlertDialog(
                    //                           title: Text(
                    //                               "Looks like there is nothing in your cart. Please add something in order to proceed."),
                    //                           actions: [
                    //                             TextButton(
                    //                                 onPressed: () {
                    //                                   Navigator.of(context).pop();
                    //                                 },
                    //                                 child: Text("OK"))
                    //                           ],
                    //                         );
                    //                       });
                    //                   print("ZERO ITEMS IN CART BRO!!");
                    //                 }
                    //               },
                    //               child: Text(
                    //                 "Proceed to checkout",
                    //                 style:
                    //                     TextStyle(fontSize: 20, color: primary()),
                    //               )),
                    //         ),
                    //       ]),
                    // ),
                  ],
                )
              : Container(
                  child: Align(
                  alignment: Alignment.center,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset('assets/img/emptycart.svg'),
                      Text(
                        "Your shopping cart is empty",
                        style: TextStyle(
                            fontSize: 24,
                            color: Color(0xff244D73),
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                        child: InkWell(
                          onTap: () {
                            STM().redirect2page(context, HomeScreen());
                          },
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
                            child: Center(
                              child: Text(
                                'Shop Now',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ))
          //  : Container(
          //   margin: EdgeInsets.only(top: 50),
          //   child: Center(child: Column(
          //     children: [
          //       Text("Please login to view your cart"),
          //       TextButton(onPressed: (){
          //         Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
          //       }, child: Text("Login"))
          //     ],
          //   ),),
          // ),
          ),
    );
  }

  Widget ItemLayout(ctx, index, list) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 12),
      child: Container(
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
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(color: Clr().borderColor, width: 0.2)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Container(
                //         child: CachedNetworkImage(
                //             width: 80,
                //             height: 100,
                //             placeholder: (context, url) =>
                //                 Image.asset("assets/img/logo (6).png"),
                //             imageUrl: list[index]['image'].toString())),
                Container(
                    child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: CachedNetworkImage(
                    imageUrl: list[index]['image'].isNotEmpty
                        ? list[index]['image'].toString()
                        : '',
                    placeholder: (context, url) => Image.network(
                      "https://www.famunews.com/wp-content/themes/newsgamer/images/dummy.png",
                      width: 85,
                      height: 88,
                      fit: BoxFit.fitHeight,
                    ),
                    errorWidget: (context, url, error) => Image.network(
                      "https://www.famunews.com/wp-content/themes/newsgamer/images/dummy.png",
                      width: 85,
                      height: 88,
                      fit: BoxFit.fitHeight,
                    ),
                    width: 80,
                    height: 100,
                    fit: BoxFit.fitHeight,
                  ),
                )),
                // Image.network(
                //   list[index]['image'],
                //   width: 180,
                //   height: 120,
                // )
                // Container(child: Center(child: Text("No Image"),)

                SizedBox(
                  width: 8,
                ),
                Expanded(
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
                                          'Are you sure you want to delete product ?',
                                          style: Sty()
                                              .mediumText
                                              .copyWith(color: Colors.black)),
                                      actions: [
                                        TextButton(
                                            // onPressed: () async {
                                            //   final db = DatabaseHelper.instance;
                                            //   var deletedID =
                                            //   await db.deleteWhereProductUniwueId(
                                            //       list[index]['data1'].toString());
                                            //   print(deletedID);
                                            //   // resultList.removeAt(index);
                                            //   getCartItems();
                                            //   updatecountbadge();
                                            //   setState(() {});
                                            //   updateBadgeCount();
                                            //   Navigator.of(context).pop();
                                            // },
                                            onPressed: () {
                                              setState(() {
                                                Store.deleteItem(
                                                        addToCart[index]
                                                            ['medicine_id'],
                                                        addToCart[index]
                                                            ['varientid'])
                                                    .then((value) {
                                                  _refreshData();
                                                  Navigator.of(context).pop();
                                                });
                                                // HomeState.controller1.sink.add(addToCart.length);
                                                // HomeState.streamCtrl.sink.add("Updated");
                                                // OrderBookState.streamCtrl.sink.add("Updated");
                                              });
                                            },
                                            child: Text("YES",
                                                style: Sty()
                                                    .mediumText
                                                    .copyWith(
                                                        color: Colors.orange))),
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text("NO",
                                                style: Sty()
                                                    .mediumText
                                                    .copyWith(
                                                        color: Colors.orange)))
                                      ],
                                    );
                                  });
                            }
                            // onTap: () async {
                            //   final db = DatabaseHelper.instance;
                            //   var deletedID =
                            //       await db.deleteWhereProductUniwueId(
                            //           list[index]['data1'].toString());
                            //   print(deletedID);
                            //   // resultList.removeAt(index);
                            //   getCartItems();
                            //   updatecountbadge();
                            //   setState(() {});
                            //   updateBadgeCount();
                            // },
                            ,
                            child: SvgPicture.asset(
                              'assets/img/deletecart.svg',
                              height: 16,
                              width: 16,
                            )),
                      ),
                      InkWell(
                        onTap: () {},
                        child: Text(list[index]['name'],
                            style: Sty().mediumText.copyWith(
                                  fontSize: Dim().d14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xff00182E),
                                )),
                      ),
                      SizedBox(
                        height: Dim().d8,
                      ),
                      if (list[index]['description'] != '1')
                        Text(
                          textAlign: TextAlign.right,
                          list[index]['description'].toString(),
                          style:
                              TextStyle(fontSize: Dim().d16, color: Clr().grey),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "₹ ${list[index]['price']}",
                              maxLines: 1,
                              softWrap: false,
                              style: TextStyle(
                                  overflow: TextOverflow.fade,
                                  fontSize: 14,
                                  color: Color(0xff065197),
                                  height: 2),
                            ),
                          ),
                          Wrap(
                            children: [
                              StatefulBuilder(builder: (context, setState) {
                                // cartamt = 0;
                                return Row(
                                  children: [
                                    SizedBox(
                                      width: 30,
                                      child: TextButton(
                                          style: ButtonStyle(
                                            foregroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(primary()),
                                          ),
                                          // onPressed: () async {
                                          //   // print(cartamt);
                                          //   if (list[index]['data4'] <= 1) {
                                          //     final db = DatabaseHelper.instance;
                                          //     var deletedID =
                                          //     await db.deleteWhereProductUniwueId(
                                          //         list[index]['data1'].toString());
                                          //     print(deletedID);
                                          //     // resultList.removeAt(index);
                                          //     getCartItems();
                                          //     updatecountbadge();
                                          //     setState(() {});
                                          //     updateBadgeCount();
                                          //     // Navigator.of(context).pop();
                                          //     // SnackBar sn = SnackBar(content: Text("You must have at least one of this item in the cart"), backgroundColor: Colors.red,);
                                          //     // ScaffoldMessenger.of(context).showSnackBar(sn);
                                          //     // showDialog(
                                          //     //     context: context,
                                          //     //     builder: (context) {
                                          //     //       return AlertDialog(
                                          //     //         title: Text("Error",
                                          //     //             style: TextStyle(
                                          //     //                 color:
                                          //     //                     Colors.red)),
                                          //     //         content: Text(
                                          //     //             "You must have at least one of these items in the cart"),
                                          //     //         actions: [
                                          //     //           TextButton(
                                          //     //             child: Text("OK"),
                                          //     //             onPressed: () =>
                                          //     //                 Navigator.of(
                                          //     //                         context)
                                          //     //                     .pop(),
                                          //     //           )
                                          //     //         ],
                                          //     //       );
                                          //     //     });
                                          //   } else {
                                          //     final db =
                                          //         DatabaseHelper.instance;
                                          //     final allRows =
                                          //         await db.queryAllRows();
                                          //     print('query all rows:');
                                          //     var variantData = {
                                          //       'id': list[index]['data6']
                                          //           .toString(),
                                          //       'weight': list[index]
                                          //               ['normal_weight_text']
                                          //           .toString(),
                                          //       'quantity': 'someB data',
                                          //       'data4':
                                          //           (list[index]['data4'] - 1)
                                          //               .toString(),
                                          //     };
                                          //
                                          //     Map<String, dynamic> row = {
                                          //       DatabaseHelper.columnQuantity:
                                          //           (list[index]['data4'] - 1)
                                          //               .toString(),
                                          //       DatabaseHelper
                                          //               .columnProductUniqueId:
                                          //           list[index]['data1'],
                                          //       DatabaseHelper
                                          //               .columnVariantArray:
                                          //           json
                                          //               .encode(variantData)
                                          //               .toString(),
                                          //       DatabaseHelper
                                          //               .columnTotalAmount:
                                          //           (list[index]['totamount'] -
                                          //               list[index]['amount'])
                                          //     };
                                          //     final rowsAffected =
                                          //         await db.update(row);
                                          //     print(
                                          //         'updated $rowsAffected row(s)');
                                          //     getCartItems();
                                          //     setState(() {
                                          //       list[index]['data4']--;
                                          //       resultList = resultList;
                                          //     });
                                          //   }
                                          // },
                                          onPressed: () {
                                            removeItem(index);
                                          },
                                          child: Text(
                                            "-",
                                            style: TextStyle(
                                                fontSize: 22,
                                                color:
                                                    Clr().textSecondaryColor),
                                          )),
                                    ),
                                    Container(
                                      child: Text(
                                        list[index]['counter'].toString(),
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 1,
                                              color: Clr().textSecondaryColor),
                                          borderRadius:
                                              BorderRadius.circular(55.0)),
                                      padding: EdgeInsets.all(10),
                                      height: 35,
                                    ),
                                    SizedBox(
                                      width: 20,
                                      child: TextButton(
                                          style: ButtonStyle(
                                            foregroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(primary()),
                                          ),
                                          onPressed: () {
                                            addItem(index);
                                          },
                                          // onPressed: () async {
                                          //   if (int.parse(list[index]
                                          //               ['product_qty']
                                          //           .toString()) >
                                          //       int.parse(list[index]['data4']
                                          //           .toString())) {
                                          //     final db =
                                          //         DatabaseHelper.instance;
                                          //     var variantData = {
                                          //       'id': list[index]['data6']
                                          //           .toString(),
                                          //       'weight': list[index]
                                          //               ['normal_weight_text']
                                          //           .toString(),
                                          //       'quantity': 'someB data',
                                          //       'data4':
                                          //           (list[index]['data4'] + 1)
                                          //               .toString(),
                                          //     };
                                          //
                                          //     Map<String, dynamic> row = {
                                          //       DatabaseHelper.columnQuantity:
                                          //           (list[index]['data4'] + 1)
                                          //               .toString(),
                                          //       DatabaseHelper
                                          //               .columnProductUniqueId:
                                          //           list[index]['data1'],
                                          //       DatabaseHelper
                                          //               .columnVariantArray:
                                          //           json
                                          //               .encode(variantData)
                                          //               .toString(),
                                          //       DatabaseHelper
                                          //               .columnTotalAmount:
                                          //           (list[index]['totamount'] +
                                          //               list[index]['amount'])
                                          //     };
                                          //     await db.update(row);
                                          //     getCartItems();
                                          //     setState(() {
                                          //       list[index]['data4']++;
                                          //       resultList = resultList;
                                          //     });
                                          //   } else {
                                          //     showDialog(
                                          //         context: context,
                                          //         builder: (context) {
                                          //           return AlertDialog(
                                          //             title: Text(
                                          //               "Error",
                                          //               style: TextStyle(
                                          //                 color: Colors.red,
                                          //               ),
                                          //             ),
                                          //             content: Text(
                                          //                 "Maximum available quantity reached for " +
                                          //                     list[index]
                                          //                         ['name']),
                                          //             actions: [
                                          //               TextButton(
                                          //                 child: Text("OK"),
                                          //                 onPressed: () =>
                                          //                     Navigator.of(
                                          //                             context)
                                          //                         .pop(),
                                          //               )
                                          //             ],
                                          //           );
                                          //         });
                                          //   }
                                          // },
                                          child: Text(
                                            "+",
                                            style: TextStyle(
                                                fontSize: 22,
                                                color:
                                                    Clr().textSecondaryColor),
                                          )),
                                    ),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                      // SizedBox(
                      //   height: 4,
                      // ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget ItemLayout2(ctx, index, list) {
  //   return Padding(
  //     padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
  //     child: Container(
  //       decoration: BoxDecoration(
  //         boxShadow: [
  //           BoxShadow(
  //             color: Clr().borderColor.withOpacity(0.7),
  //             spreadRadius: 0.1,
  //             blurRadius: 8,
  //             offset: Offset(0, 0), // changes position of shadow
  //           ),
  //         ],
  //       ),
  //       child: Card(
  //         elevation: 0,
  //         margin: EdgeInsets.only(right: 4),
  //         shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(15),
  //             side: BorderSide(color: Clr().borderColor, width: 0.2)),
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.start,
  //           children: [
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.start,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 list[index]['image'].isNotEmpty
  //                     ? Container(
  //                         margin: EdgeInsets.only(left: 10, right: 10),
  //                         child: CachedNetworkImage(
  //                             width: 80,
  //                             height: 70,
  //                             placeholder: (context, url) =>
  //                                 Image.asset("assets/img/logo (6).png"),
  //                             imageUrl: list[index]['image'].toString()))
  //                     // Image.network(
  //                     //   list[index]['image'],
  //                     //   width: 180,
  //                     //   height: 120,
  //                     // )
  //                     // Container(child: Center(child: Text("No Image"),)
  //                     : Image.asset(
  //                         "assets/img/logo (6).png",
  //                         height: 90,
  //                         width: 100,
  //                       ),
  //                 Container(
  //                   // margin: EdgeInsets.only(top: 2),
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: [
  //                       Row(
  //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                         children: [
  //                           Container(
  //                             width: 180,
  //                             child: Text(
  //                               list[index]['name'],
  //                               maxLines: 3,
  //                               overflow: TextOverflow.ellipsis,
  //                               style: TextStyle(
  //                                   // fontWeight: FontWeight.bold,
  //                                   fontSize: 18),
  //                               textAlign: TextAlign.left,
  //                             ),
  //                           ),
  //                           TextButton(
  //                               style: ButtonStyle(
  //                                 foregroundColor:
  //                                     MaterialStateProperty.all<Color>(
  //                                         primary()),
  //                               ),
  //                               onPressed: (){
  //
  //                               },
  //                               // onPressed: () async {
  //                               //   final db = DatabaseHelper.instance;
  //                               //   var deletedID =
  //                               //       await db.deleteWhereProductUniwueId(
  //                               //           list[index]['data1'].toString());
  //                               //   print(deletedID);
  //                               //   // resultList.removeAt(index);
  //                               //   getCartItems();
  //                               //   updatecountbadge();
  //                               //   setState(() {});
  //                               //   updateBadgeCount();
  //                               // },
  //                               child: SvgPicture.asset(
  //                                   'assets/img/deletecart.svg')),
  //                         ],
  //                       ),
  //                       Text(
  //                         textAlign: TextAlign.right,
  //                         "₹${list[index]['totamount']}",
  //                         style: TextStyle(
  //                             fontSize: 16,
  //                             color: Color(0xff065197),
  //                             height: 2),
  //                       ),
  //                       // SizedBox(
  //                       //   width: 160,
  //                       //   child: Row(
  //                       //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                       //     children: [
  //                       //       // Expanded(
  //                       //       //   child: Text("Amount",
  //                       //       //       style: TextStyle(
  //                       //       //           fontSize: 16,
  //                       //       //           // fontWeight: FontWeight.bold
  //                       //       //           )),
  //                       //       // ),
  //                       //       // Text(":"),
  //                       //       // Expanded(
  //                       //       //   child: Text(
  //                       //       //     textAlign: TextAlign.right,
  //                       //       //     "₹" + list[index]['totamount'].toString(),
  //                       //       //     style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 46, 127, 49)),
  //                       //       //   ),
  //                       //       // )
  //                       //     ],
  //                       //   ),
  //                       // ),
  //                       list[index]['normal_weight_text'].toString().isNotEmpty
  //                           ? SizedBox(
  //                               width: 160,
  //                               child: Row(
  //                                 mainAxisAlignment:
  //                                     MainAxisAlignment.spaceEvenly,
  //                                 children: [
  //                                   Expanded(
  //                                     child: Text(
  //                                       "Variant",
  //                                       style: TextStyle(
  //                                         fontSize: 16,
  //                                         //  fontWeight: FontWeight.bold
  //                                       ),
  //                                     ),
  //                                   ),
  //                                   Text(":"),
  //                                   Expanded(
  //                                     child: Text(
  //                                       textAlign: TextAlign.right,
  //                                       list[index]['normal_weight_text']
  //                                           .toString(),
  //                                       style: TextStyle(fontSize: 16),
  //                                     ),
  //                                   )
  //                                 ],
  //                               ),
  //                             )
  //                           : Text(""),
  //                       // SizedBox(
  //                       //   width: 160,
  //                       //   child: Row(
  //                       //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                       //     children: [
  //                       //       Expanded(
  //                       //         child: Text(
  //                       //           "Qty",
  //                       //           style: TextStyle(
  //                       //               fontSize: 18, fontWeight: FontWeight.bold),
  //                       //         ),
  //                       //       ),
  //                       //       Text(":"),
  //                       //       Expanded(
  //                       //         child: Text(
  //                       //           textAlign: TextAlign.right,
  //                       //           '1',
  //                       //           style: TextStyle(fontSize: 18),
  //                       //         ),
  //                       //       )
  //                       //     ],
  //                       //   ),
  //                       // ),
  //                     ],
  //                   ),
  //                 )
  //               ],
  //             ),
  //             SizedBox(
  //               width: MediaQuery.of(context).size.width - 10,
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   StatefulBuilder(builder: (context, setState) {
  //                     // cartamt = 0;
  //                     return Row(
  //                       children: [
  //                         TextButton(
  //                             style: ButtonStyle(
  //                               foregroundColor:
  //                                   MaterialStateProperty.all<Color>(primary()),
  //                             ),
  //                             // onPressed: () async {
  //                             //   // print(cartamt);
  //                             //   print(
  //                             //       "PRODUCT QUANTITY : ${list[index]['product_qty']}");
  //                             //   print(
  //                             //       "LIST DATA 4 QUANTITY : ${list[index]['data4']}");
  //                             //   if (int.parse(
  //                             //           list[index]['product_qty'].toString()) >
  //                             //       int.parse(
  //                             //           list[index]['data4'].toString())) {
  //                             //     print("Can be added");
  //                             //     final db = DatabaseHelper.instance;
  //                             //     final allRows = await db.queryAllRows();
  //                             //     print('query all rows:');
  //                             //     print(resultList);
  //                             //     var variantData = {
  //                             //       'id': list[index]['data6'].toString(),
  //                             //       'weight': list[index]['normal_weight_text']
  //                             //           .toString(),
  //                             //       'quantity': 'someB data',
  //                             //       'data4':
  //                             //           (list[index]['data4'] + 1).toString(),
  //                             //     };
  //                             //
  //                             //     Map<String, dynamic> row = {
  //                             //       DatabaseHelper.columnQuantity:
  //                             //           (list[index]['data4'] + 1).toString(),
  //                             //       DatabaseHelper.columnProductUniqueId:
  //                             //           list[index]['data1'],
  //                             //       DatabaseHelper.columnVariantArray:
  //                             //           json.encode(variantData).toString(),
  //                             //       DatabaseHelper.columnTotalAmount:
  //                             //           (list[index]['totamount'] +
  //                             //               list[index]['amount'])
  //                             //     };
  //                             //     final rowsAffected = await db.update(row);
  //                             //     print('updated $rowsAffected row(s)');
  //                             //     getCartItems();
  //                             //     setState(() {
  //                             //       list[index]['data4']++;
  //                             //       resultList = resultList;
  //                             //     });
  //                             //   } else {
  //                             //     print("Cannot be added anymore");
  //                             //     // SnackBar sn = SnackBar(content: Text("Maximum quantity reached"));
  //                             //     // ScaffoldMessenger.of(context).showSnackBar(sn);
  //                             //     showDialog(
  //                             //         context: context,
  //                             //         builder: (context) {
  //                             //           return AlertDialog(
  //                             //             title: Text("Error",
  //                             //                 style:
  //                             //                     TextStyle(color: Colors.red)),
  //                             //             content: Text(
  //                             //                 "Maximum available quantity reached for " +
  //                             //                     list[index]['name']),
  //                             //             actions: [
  //                             //               TextButton(
  //                             //                 child: Text("OK"),
  //                             //                 onPressed: () =>
  //                             //                     Navigator.of(context).pop(),
  //                             //               )
  //                             //             ],
  //                             //           );
  //                             //         });
  //                             //   }
  //                             // },
  //                             onPressed: (){
  //                               addItem(index);
  //
  //                             },
  //                             child: Text(
  //                               "+",
  //                               style: TextStyle(
  //                                   fontSize: 22,
  //                                   color: Clr().textSecondaryColor),
  //                             )),
  //                         Container(
  //                           child: Text(
  //                             list[index]['counter'].toString(),
  //                             style: TextStyle(fontSize: 12),
  //                           ),
  //                           decoration: BoxDecoration(
  //                               border: Border.all(
  //                                   width: 1, color: Clr().textSecondaryColor),
  //                               borderRadius: BorderRadius.circular(55.0)),
  //                           padding: EdgeInsets.all(10),
  //                           height: 35,
  //                         ),
  //                         TextButton(
  //                             style: ButtonStyle(
  //                               foregroundColor:
  //                                   MaterialStateProperty.all<Color>(primary()),
  //                             ),
  //                             onPressed: (){
  //                               removeItem(index);
  //                             },
  //                             // onPressed: () async {
  //                             //   // print(cartamt);
  //                             //   if (list[index]['data4'] <= 1) {
  //                             //     // SnackBar sn = SnackBar(content: Text("You must have at least one of this item in the cart"), backgroundColor: Colors.red,);
  //                             //     // ScaffoldMessenger.of(context).showSnackBar(sn);
  //                             //
  //                             //     showDialog(
  //                             //         context: context,
  //                             //         builder: (context) {
  //                             //           return AlertDialog(
  //                             //             title: Text("Error",
  //                             //                 style:
  //                             //                     TextStyle(color: Colors.red)),
  //                             //             content: Text(
  //                             //                 "You must have at least one of these items in the cart"),
  //                             //             actions: [
  //                             //               TextButton(
  //                             //                 child: Text("OK"),
  //                             //                 onPressed: () =>
  //                             //                     Navigator.of(context).pop(),
  //                             //               )
  //                             //             ],
  //                             //           );
  //                             //         });
  //                             //   } else {
  //                             //     final db = DatabaseHelper.instance;
  //                             //     final allRows = await db.queryAllRows();
  //                             //     print('query all rows:');
  //                             //     var variantData = {
  //                             //       'id': list[index]['data6'].toString(),
  //                             //       'weight': list[index]['normal_weight_text']
  //                             //           .toString(),
  //                             //       'quantity': 'someB data',
  //                             //       'data4':
  //                             //           (list[index]['data4'] - 1).toString(),
  //                             //     };
  //                             //
  //                             //     Map<String, dynamic> row = {
  //                             //       DatabaseHelper.columnQuantity:
  //                             //           (list[index]['data4'] - 1).toString(),
  //                             //       DatabaseHelper.columnProductUniqueId:
  //                             //           list[index]['data1'],
  //                             //       DatabaseHelper.columnVariantArray:
  //                             //           json.encode(variantData).toString(),
  //                             //       DatabaseHelper.columnTotalAmount:
  //                             //           (list[index]['totamount'] -
  //                             //               list[index]['amount'])
  //                             //     };
  //                             //     final rowsAffected = await db.update(row);
  //                             //     print('updated $rowsAffected row(s)');
  //                             //     getCartItems();
  //                             //     setState(() {
  //                             //       list[index]['data4']--;
  //                             //       resultList = resultList;
  //                             //     });
  //                             //   }
  //                             // },
  //                             child: Text(
  //                               "-",
  //                               style: TextStyle(
  //                                   fontSize: 22,
  //                                   color: Clr().textSecondaryColor),
  //                             )),
  //                       ],
  //                     );
  //                   }),
  //                   Expanded(child: SizedBox()),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  // remove item
  removeItem(index) {
    int counter = addToCart[index]['counter'];
    var acutal;
    try {
      acutal = double.parse(addToCart[index]['actualPrice'].toString());
    } catch (_) {
      acutal = int.parse(addToCart[index]['actualPrice'].toString());
    }
    ;
    var price;
    try {
      price = double.parse(addToCart[index]['price'].toString());
    } catch (_) {
      price = int.parse(addToCart[index]['price'].toString());
    }
    ;
    counter--;
    var newPrice = price - acutal;
    if (counter > 0) {
      _updateItem(
              addToCart[index]['medicine_id'],
              addToCart[index]['varientid'] ?? 0,
              addToCart[index]['name'].toString(),
              addToCart[index]['image'].toString(),
              newPrice.toString(),
              addToCart[index]['actualPrice'].toString(),
              addToCart[index]['description'].toString(),
              counter)
          .then((value) {
        newPrice = 0;
        counter = 0;
        _refreshData();
      });
    }
  }

  // add item
  addItem(index) {
    int counter = addToCart[index]['counter'];
    var acutal;
    try {
      acutal = double.parse(addToCart[index]['actualPrice'].toString());
    } catch (_) {
      acutal = int.parse(addToCart[index]['actualPrice'].toString());
    }
    ;
    var price;
    try {
      price = double.parse(addToCart[index]['price'].toString());
    } catch (_) {
      price = int.parse(addToCart[index]['price'].toString());
    };
    counter++;
    var newPrice = price + acutal;
    _updateItem(
            addToCart[index]['medicine_id'],
            addToCart[index]['varientid'] ?? 0,
            addToCart[index]['name'].toString(),
            addToCart[index]['image'].toString(),
            newPrice.toString(),
            addToCart[index]['actualPrice'].toString(),
            addToCart[index]['description'].toString(),
            counter)
        .then((value) {
      newPrice = 0;
      counter = 0;
      _refreshData();
    });
  }

  void timeApi() async {
    var dio = Dio();
    var formData = FormData.fromMap({
      // 'user_id' : '2'
    });
    final response = await dio.post(cartTime(), data: formData);
    var res = json.decode(response.data);
    // mapkey = res['google_map_key'];
    print(res);
    print(res['message']);
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(res['message']),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"))
            ],
          );
        });
  }

  ///
  apiTime() async {
    FormData body = FormData.fromMap(
        {'date': DateFormat('dd-MM-yyyy').format(DateTime.now())});
    var result =
        await STM().postWithoutDialog(context, 'time_service.php', body);
    if (result['error'] == false) {
      setState(() {
        message = result['message'];
        print(DateTime.now());
        startTime = DateTime.parse(
            '${DateFormat('yyyy-MM-dd').format(DateTime.now())} ${result['time_1']}');
        print(startTime);
        data = result;
        endTime = DateTime.parse(
            '${DateFormat('yyyy-MM-dd').format(DateTime.now())} ${result['time_2']}');
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

  listofCartLayout() {
    List listofcart = [];
    setState(() {
      listofcart.clear();
      resultList.clear();
      listofcart = addToCart;
    });
    for (int a = 0; a < addToCart.length; a++) {
      if (addToCart[a]['description'] == '') {
        setState(() {
          resultList.add({
            'product_id': addToCart[a]['medicine_id'],
            'cart_qty': addToCart[a]['counter'],
            'weight': ''
          });
        });
      } else {
        setState(() {
          resultList.add({
            'product_id': addToCart[a]['medicine_id'],
            'cart_qty': addToCart[a]['counter'],
            'weight': addToCart[a]['description']
          });
        });
      }
    }
  }
}
