import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qf/appbar_gradientlook.dart';
import 'package:qf/cart_page_old.dart';
import 'package:qf/colors.dart';
import 'package:qf/commonaddtocart.dart';
import 'package:qf/globalurls.dart';
import 'package:qf/home_page.dart';
import 'package:qf/single_product_view.dart';

// import 'package:qf/sqliteop.dart';
import 'package:qf/values/colors.dart';
import 'package:qf/values/dimens.dart';
import 'package:qf/values/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bottom_navigation/bottom_navigation.dart';
import 'commondropdown.dart';
import 'localstore.dart';
import 'manage/static_method.dart';

class SubProductCategoriesScreen extends StatefulWidget {
  final sCategory, sSubCategory, sTitle;
  final selectedIndex;
  final spincode;

  const SubProductCategoriesScreen({
    super.key,
    this.sCategory,
    this.sSubCategory,
    this.selectedIndex,
    this.sTitle,
    this.spincode,
  });

  @override
  State<StatefulWidget> createState() {
    return SubProductCategoriesScreenState();
  }
}

class SubProductCategoriesScreenState
    extends State<SubProductCategoriesScreen> {
  late BuildContext ctx;

  bool isLoaded = false, isLoaded2 = false;

  String? sCategory, sSubCategory, sTitle;

  // DatabaseHelper helper = DatabaseHelper.instance;

  List<dynamic> categoryList = [];
  int selectedCategory = 0;
  List<dynamic> resultList = [];
  List<String> databaseList = [];
  List<int> countList = [];
  List<dynamic> addToCart = [];

  Future<void> _addItem(medicine_id, varientid, name, image, price, actualPrice,
      description, counter) async {
    await Store.createItem(medicine_id, varientid, name, image, price,
        actualPrice, description, counter);
  }

  Future<void> _updateItem(medicine_id, varientid, name, image, price,
      actualPrice, description, counter) async {
    await Store.updateItem(medicine_id, varientid, name, image, price,
        actualPrice, description, counter);
  }

  _refreshData() async {
    var data = await Store.getItems();
    setState(() {
      addToCart = data;
    });
    print(addToCart);
  }
  String? Pincode;
  getSession() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      Pincode = sp.getString('pincode') ?? "";
      print("${Pincode}jmhgdasfsa  Pincode");
    });
    STM().checkInternet(context, widget).then((value) {
      if (value) {
        getData();
        _refreshData();
      }
    });
  }

  static StreamController<dynamic> controller =
      StreamController<dynamic>.broadcast();

  @override
  void initState() {
    controller.stream.listen((dynamic event) {
      getSession();
      _refreshData();
    });
    sCategory = widget.sCategory;
    sSubCategory = widget.sSubCategory;
    selectedCategory = widget.selectedIndex;
    sTitle = widget.sTitle;
    // getDatabase();
    // updateBadgeCount();
    getSession();

    super.initState();
  }

  // void getDatabase() async {
  //   var rows = await helper.queryAllRows();
  //   databaseList = rows.map((e) => e['product_id'].toString()).toList();
  //   for (int i = 0; i < rows.length; i++) {
  //     countList.add(rows[i]['quantity']);
  //   }
  // }

  void getData() async {
    setState(() {
      isLoaded2 = false;
    });
    var dio = Dio();
    var formData = FormData.fromMap({
      'category_id': sCategory.toString(),
      'sub_category_id': sSubCategory.toString(),
      'pincode': Pincode.toString()
    });
    print('${formData.fields}shgjdfsadfsahfdashjfdsahgfad');
    final response = await dio.post(getSubCategoriesUrl(), data: formData);
    var result = json.decode(response.data);
    var error = result['error'];
    if (!error) {
      setState(() {
        isLoaded = true;
        isLoaded2 = true;
        categoryList = result['sub_categories_array'];
        resultList = result['product_array'];
        for (var v in resultList) {
          int pos = databaseList
              .indexWhere((e) => e.toString() == v['ID'].toString());
          Map<String, dynamic> map = {
            'dropdown_value':
                v['variant'].isNotEmpty ? v['variant'][0]['weight'] : '',
            'dropdown_price': v['variant'].isNotEmpty
                ? v['variant'][0]['final_price']
                : v['final_price'],
            'count':
                databaseList.contains(v['ID'].toString()) ? countList[pos] : 1,
            'is_exist': databaseList.contains(v['ID'].toString()),
          };
          v.addEntries(map.entries);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ctx = context;
    return WillPopScope(
      onWillPop: () async {
        STM().finishAffinity(ctx, HomeScreen());
        return false;
      },
      child: Scaffold(
        bottomNavigationBar: bottomBarLayout(ctx, 1),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: InkWell(
              onTap: () {
                STM().finishAffinity(ctx, HomeScreen());
              },
              child: BackButton(color: Color(0xff244D73))),
          centerTitle: true,
          title: Html(
            data: sTitle.toString(),
            style: {
              "*": Style(
                color: const Color(0xff00182E),
                fontWeight: FontWeight.w500,
                fontSize: FontSize(18),
              )
            },
          ),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: ((context) {
                    return const CartScreen(type: 'home');
                  }))).then((_) {
                    // updateBadgeCount();
                    print("Cart update called");
                  });
                },
                icon: Stack(
                  fit: StackFit.loose,
                  children: [
                    Container(
                        height: 44,
                        width: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          gradient: LinearGradient(colors: <Color>[
                            Clr().appbarColor.withOpacity(0.9),
                            Clr().appbarColor1.withOpacity(0.9),
                          ]),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(7.0),
                          child: SvgPicture.asset(
                            'assets/img/cartimg.svg',
                            color: Color(0xffFFEEE5),
                          ),
                        )),
                    addToCart.length == 0
                        ? Positioned(bottom: 2, right: -8, child: Container())
                        : Positioned(
                            bottom: 18,
                            right: 4,
                            child: Container(
                              // child: Center(
                              //     child: Text(
                              //   // '${contentInCart}',
                              //   '${addToCart.length}',
                              //   style: Sty().smallText.copyWith(
                              //         color: Clr().green,
                              //         fontSize: 12,
                              //     fontWeight: FontWeight.w900
                              //       ),
                              // )),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Color(0xffFF7534), width: 0.5),
                                shape: BoxShape.circle,
                                color: Clr().successGreen,
                              ),
                              width: 12,
                              height: 8,
                            )),
                  ],
                )),
          ],
          flexibleSpace: barGredient(),
        ),
        body: isLoaded
            ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(2, 20),
                            spreadRadius: 2,
                            blurRadius: 1,
                            color: const Color(0xffFFEEE5).withOpacity(0.5),
                          )
                        ],
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: categoryList.length,
                        itemBuilder: (context, index) {
                          return itemMain(categoryList[index], index);
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: isLoaded2
                        ? resultList.isNotEmpty
                            ? GridView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.all(8),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisExtent: Dim().d220,
                                ),
                                itemCount: resultList.length,
                                itemBuilder: (context, index) {
                                  return itemSub(resultList[index]);
                                },
                              )
                            : Center(
                                child: Text(
                                  "No Data Found",
                                  style: TextStyle(
                                    color: primary(),
                                    fontSize: 25,
                                  ),
                                ),
                              )
                        : Container(
                            margin: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width / 3,
                            ),
                            child: Row(
                              children: const [
                                Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget priceStrikeWidget(String amount) {
    return Container(
      margin: const EdgeInsets.fromLTRB(3, 0, 0, 0),
      child: Text(
        "₹$amount",
        style: const TextStyle(
          decoration: TextDecoration.lineThrough,
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
    );
  }

  var rBuildMainCategories;

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

  Widget itemMain(v, index) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedCategory = index;
          sSubCategory = v['ID'].toString();
        });
        getData();
      },
      child: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(blurRadius: 8.0),
            BoxShadow(color: Colors.white, offset: Offset(0, -16)),
            BoxShadow(color: Colors.white, offset: Offset(0, 16)),
            BoxShadow(color: Colors.white, offset: Offset(-16, -16)),
            BoxShadow(color: Colors.white, offset: Offset(-16, 16)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 5, bottom: 3),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        border: Border.all(
                            width: 0, color: const Color(0xfffdb17a)),
                        borderRadius: BorderRadius.circular(45),
                        color: index == selectedCategory
                            ? const Color(0xffF16624)
                            : const Color(0xfffff8f3),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10000.0),
                        child: CachedNetworkImage(
                          imageUrl: v['image_path'],
                          placeholder: (context, url) =>
                              Image.asset("assets/img/logo (6).png"),
                          errorWidget: (context, url, error) =>
                              Image.asset("assets/img/logo (6).png"),
                          width: 40,
                          height: 40,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 60,
                    width: 60,
                    child: Html(
                      data: '${v['name']}',
                      style: {
                        "*": Style(
                            textAlign: TextAlign.center,
                            textOverflow: TextOverflow.ellipsis,
                            maxLines: 3,
                            fontSize: FontSize(10),
                            fontWeight: index == selectedCategory
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: const Color(0xffF16624),
                            fontFamily: 'Opensans')
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  color: index == selectedCategory ? primary() : const Color(0),
                  borderRadius: BorderRadius.circular(10)),
              height: 100,
              width: index == selectedCategory ? 3 : 5,
              margin: const EdgeInsets.only(left: 5),
            ),
          ],
        ),
      ),
    );
  }

  Widget itemSub(v) {
    print(v['qty']);
    return StatefulBuilder(
      builder: (context, setState2) {
        return Container(
          width: MediaQuery.of(ctx).size.width,
          margin: EdgeInsets.all(
            Dim().d4,
          ),
          child: InkWell(
            onTap: () {
              v['qty'] == null
                  ? Container()
                  : Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProductDetail(
                          productID: v['ID'].toString(),
                          type: 'subProduct',
                          sCategory: widget.sCategory,
                          selectedIndex: widget.selectedIndex,
                          spincode: widget.spincode,
                          sSubCategory: widget.sSubCategory,
                          sTitle: widget.sTitle,
                        ),
                      ),
                      // ).then((_) => updateBadgeCount());
                    );
            },
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Clr().borderColor.withOpacity(0.5),
                        spreadRadius: 0.1,
                        blurRadius: 8,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(right: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: Clr().borderColor,
                        width: 0.2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (v['variant'].isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 8,
                                right: 8,
                                left: 8,
                              ),
                              child: Container(
                                padding: const EdgeInsets.only(
                                  top: 10,
                                  bottom: 10,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1, color: const Color(0xffE5F3FF)),
                                  borderRadius: BorderRadius.circular(10),
                                  color: const Color(0xffE5F3FF),
                                ),
                                child: Stack(
                                  fit: StackFit.loose,
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: v['images'].isNotEmpty
                                          ? v['images'][0]['img_product']
                                          : '',
                                      placeholder: (context, url) =>
                                          Image.asset(
                                              "assets/img/logo (6).png"),
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                              "assets/img/logo (6).png"),
                                      width: 110,
                                      height: 60,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (v['variant'].isEmpty)
                          Html(
                            data: '${v['name']}',
                            style: {
                              "*": Style(
                                maxLines: 1,
                                textOverflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                fontSize: FontSize(12),
                                color: Clr().primaryColor,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Opensans',
                              )
                            },
                          ),
                        if (v['variant'].isNotEmpty)
                          commonDropdown(v: v, type: 'subProduct'),
                        if (v['variant'].isEmpty)
                          v['qty'] == null
                              ? Container()
                              : Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: v['final_price'].toString().replaceAll(new RegExp(r"\D"), "") ==
                                          v['actual_price'].toString().replaceAll(new RegExp(r"\D"), "")
                                      ? Container()
                                      : priceStrikeWidget(
                                          '${v['actual_price']}'),
                                ),
                        // if(v['variant'].isEmpty || v['qty'] == 0)
                        //   Padding(
                        //     padding:  EdgeInsets.only(left: 16.0,bottom: 4),
                        //     child: Text('Out of Stock',style: TextStyle(color: Colors.red),),
                        //   ),
                        if (v['variant'].isEmpty)
                          v['qty'] == null
                              ? Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: Dim().d8,
                                      vertical: Dim().d12),
                                  child: Text('Out Of Stock',
                                      style: Sty()
                                          .mediumText
                                          .copyWith(color: Clr().errorRed)),
                                )
                              : Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: Dim().d12,
                                      vertical: Dim().d4),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '₹ ${v['final_price']}',
                                          style: TextStyle(
                                            fontSize: Dim().d12,
                                            color: Clr().textSecondaryColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                          flex: 2, child: addtoCartLayout(v: v))
                                    ],
                                  ),
                                ),
                        SizedBox(height: Dim().d4),
                      ],
                    ),
                  ),
                ),
                // Opacity(
                //   opacity: v['qty'] == 0 ? 0.5 : 2,
                //   child: ,
                // ),
                // if(v['qty'] != 0 && v['discount'].toString() != "0")
                //   Positioned(
                //       top: 10,
                //       right: 11,
                //       child: Transform.scale(
                //         scaleX: -1.5,
                //         child: SvgPicture.asset(
                //           "assets/img/lable.svg",
                //           width: 25,
                //           height: 25,
                //           color: primary(),
                //         ),
                //       )),
                if (v['qty'] != null)
                  v['discount'].toString() != "0"
                      ? Positioned(
                          top: 0,
                          left: 0,
                          child: Container(
                            height: Dim().d32,
                            width: Dim().d72,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(Dim().d12),
                                    bottomRight: Radius.circular(Dim().d20)),
                                color: Color(0xffFF7534)),
                            child: Center(
                              child: Text(
                                v['discount'] + "% off",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          // Text(
                          //   v['discount'] + "% off",
                          //   style: const TextStyle(color: Colors.white),
                          // ),
                        )
                      : Container(),
                // if(v['qty'] == 0)
                //   Flex(direction: Axis.horizontal, children: [
                //     Expanded(
                //       child: Align(
                //         alignment: Alignment.topCenter,
                //         child: Container(
                //           margin: const EdgeInsets.only(top: 10),
                //           // padding: EdgeInsets.only(left:80, right:80),
                //           width: double.infinity,
                //           height: 20,
                //           color: primary(),
                //           child: const Center(
                //               child: Text(
                //                 "Out of Stock",
                //                 style: TextStyle(
                //                     fontSize: 14, color: Colors.white),
                //               )),
                //         ),
                //       ),
                //     ),
                //   ])
              ],
            ),
          ),
        );
      },
    );
  }
}
