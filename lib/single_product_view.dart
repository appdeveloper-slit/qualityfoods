import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qf/colors.dart';
import 'package:qf/globalurls.dart';
import 'package:qf/home_page.dart';
import 'package:qf/manage/static_method.dart';
import 'package:qf/sub_product_category_screen.dart';

// import 'package:qf/sqliteop.dart';
import 'package:qf/values/colors.dart';
import 'package:qf/values/dimens.dart';
import 'package:qf/values/styles.dart';

import 'cart_page_old.dart';
import 'localstore.dart';

class ProductDetail extends StatefulWidget {
  final String productID;
  final type, varientID;
  final  sCategory, sSubCategory, sTitle;
  final  selectedIndex;
  final  spincode;

  ProductDetail(
      {required this.productID, Key? key, this.type, this.varientID, this.sCategory,
        this.sSubCategory,
        this.selectedIndex,
        this.sTitle, this.spincode,})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ProductDetailState();
  }
}

class ProductDetailState extends State<ProductDetail> {
  late BuildContext ctx;

  List<String> imgList = [];
  int qtyno = 1;

  bool isExist = false;

  Map<String, dynamic> v = {};
  List<dynamic> resultList = [];
  List<String> databaseList = [];
  List<int> countList = [];

  String? discountPrice = "";
  String? mainPrice = "";
  String? discounts;
  bool addEnabled = false;
  int selected = 0;
  String dropdownvalue = '';
  var variantDropDownItems = [];
  List variantData = [];
  String currentProductWeight = "";
  String currentProductQuantity = "0";
  bool outOfStock = false;
  final CarouselController _controller = CarouselController();
  String? varientname, varientprice, varientsellingprice, varientdiscount;
  int? varientid;
  var dropdownValue,
      dropdownVarientId,
      dropdownVarientWeight,
      dropdownFinalPrice;
  List<dynamic> addToCart = [];
  bool isLoading = true;
  String? sUserid;
  var price;
  String sTotalPrice = "0";

  Future<void> _updateItem(medicine_id, varientid, name, image, price,
      actualPrice, description, counter) async {
    await Store.updateItem(medicine_id, varientid, name, image, price,
        actualPrice, description, counter);
  }

  void _refreshData() async {
    var data = await Store.getItems();
    setState(() {
      addToCart = data;
      isLoading = false;
    });
    print(addToCart);
  }

  String? usertoken;

  Future<void> _addItem(medicine_id, varientid, name, image, price, actualPrice,
      description, counter) async {
    await Store.createItem(medicine_id, varientid, name, image, price,
        actualPrice, description, counter);
  }

  // DatabaseHelper helper = DatabaseHelper.instance;

  @override
  void initState() {
    // check();
    // _refreshData();
    getProductDetails();
    print(widget.productID);
    _refreshData();
    print('hsgwsg');
    super.initState();
  }

  // void getDatabase() async {
  //   var rows = await helper.queryAllRows();
  //   databaseList = rows.map((e) => e['product_id'].toString()).toList();
  //   for (int i = 0; i < rows.length; i++) {
  //     countList.add(rows[i]['quantity']);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    ctx = context;
    int positionOfCart = v.isEmpty
        ? 0
        : v['variant'].isEmpty
        ? addToCart.indexWhere((element) =>
    element['medicine_id'].toString() ==
        widget.productID.toString())
        : addToCart.indexWhere((element) =>
    element['varientid'].toString() ==
        dropdownVarientId.toString());
    return WillPopScope(
      onWillPop: () async {
        widget.type == 'subProduct' ? SubProductCategoriesScreenState.controller.sink.add('okk') : Container();
        widget.type == 'subProduct'
            ? STM().back2Previous(ctx)
            : STM().finishAffinity(ctx, HomeScreen());
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          // toolbarHeight: Dim().d100,
          leadingWidth: 50,
          leading: InkWell(
              onTap: () {
                widget.type == 'subProduct' ? SubProductCategoriesScreenState.controller.sink.add('okk') : Container();
                widget.type == 'subProduct'
                    ? STM().back2Previous(ctx)
                    : STM().finishAffinity(ctx, const HomeScreen());
              },
              child: Icon(Icons.arrow_back, color: Color(0xff244D73))),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: addEnabled
            ? Stack(children: [
          topContent(v),
          Positioned(
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20, right: 16),
              child: SizedBox(
                child: addEnabled
                    ? v['qty'] == null ?  Padding(
                      padding:  EdgeInsets.symmetric(horizontal: Dim().d24),
                      child: Text('Out Of Stock',style: Sty().mediumText.copyWith(color: Clr().errorRed),),
                    )  : Container(
                  height: 60,
                  margin:
                  EdgeInsets.symmetric(horizontal: Dim().d12),
                  decoration: const BoxDecoration(
                      color: Color(0xffE5F3FF),
                      borderRadius:
                      BorderRadius.all(Radius.circular(35))),
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(15),
                        child: Row(
                          children: [
                            addToCart
                                .map((e) => v['variant'].isEmpty
                                ? e['medicine_id']
                                .toString()
                                : e['varientid'].toString())
                                .contains(v['variant'].isEmpty
                                ? v['ID'].toString()
                                : dropdownVarientId
                                .toString())
                                ? Text(
                              'item | ${addToCart.length}',
                              style: TextStyle(
                                fontSize: Dim().d16,
                                fontWeight: FontWeight.w500,
                                color:
                                Clr().textSecondaryColor,
                              ),
                            )
                                : Container(),
                            // addToCart
                            //     .map((e) => v['variant'].isEmpty ?
                            // e['medicine_id'].toString() : dropdownVarientId.toString())
                            //     .contains(v['variant'].isEmpty ? v['ID'].toString() : dropdownVarientId.toString(),
                            SizedBox(width: Dim().d20),
                            Text(
                              '₹ ${v['dropdown_price']}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                                color: Clr().textSecondaryColor,
                              ),
                            ),
                            if (v['discount'].toString() != "0")
                              Text(
                                '₹ ${v['dropdown_price1']}',
                                style: const TextStyle(
                                  decoration:
                                  TextDecoration.lineThrough,
                                  fontSize: 16,
                                  color: Color(0xff90ABC3),
                                ),
                              ),
                            // (discountPrice == mainPrice)
                            //     ? priceWidget(
                            //         discountPrice.toString())
                            //     : priceWidget(mainPrice.toString()),
                            // (discounts != "0")
                            //     ? priceStrikeWidget(
                            //         discountPrice.toString())
                            //     : const Text("")
                          ],
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 15.0),
                          height: 45,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              end: Alignment(0.0, 0.4),
                              begin: Alignment(0.0, -1),
                              colors: [
                                Color(0xFF065197),
                                Color(0xFF337ec4)
                              ],
                            ),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: Dim().d12),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              onPressed: () {
                                print(
                                    'hgzdfshv   $dropdownVarientId');
                                print('hgzdfshv  ${v['ID']}');
                                _refreshData();
                                addToCart
                                    .map((e) => v['variant']
                                    .isEmpty
                                    ? e['medicine_id']
                                    .toString()
                                    : e['varientid']
                                    .toString())
                                    .contains(
                                    v['variant'].isEmpty
                                        ? v['ID'].toString()
                                        : dropdownVarientId
                                        .toString())
                                    ? STM().redirect2page(
                                    ctx,
                                    CartScreen(
                                      type: 'singleproduct',
                                    ))
                                    : _addItem(
                                  int.parse(v['ID']),
                                  int.parse(
                                      dropdownVarientId ??
                                          '0'.toString()),
                                  '${v['name'].toString()} ',
                                  // '${v['name'].toString()} ${varientname}',
                                  v['images'].isNotEmpty
                                      ? v['images'][0]
                                  ['img_product']
                                      .toString()
                                      : '',
                                  dropdownFinalPrice ??
                                      '${v['dropdown_price']}',
                                  dropdownFinalPrice ??
                                      '${v['dropdown_price']}',
                                  (v['variant'].isNotEmpty)
                                      ? '${v['dropdown_value'] ?? ''.toString()}'
                                      : '',
                                  1,
                                ).then((value) {
                                  _refreshData();
                                  Fluttertoast.showToast(
                                      msg:
                                      'Item added to cart',
                                      toastLength:
                                      Toast.LENGTH_SHORT,
                                      gravity: ToastGravity
                                          .CENTER);
                                });
                              },
                              child: Center(
                                child: Text(
                                  addToCart
                                      .map((e) =>
                                  v['variant'].isEmpty
                                      ? e['medicine_id']
                                      .toString()
                                      : e['varientid']
                                      .toString())
                                      .contains(v['variant']
                                      .isEmpty
                                      ? v['ID'].toString()
                                      : dropdownVarientId
                                      .toString())
                                      ? 'View Cart'
                                      : 'Add to cart',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: Dim().d20,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            ),
                          )),
                    ],
                  ),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(),
                  ],
                ),
              ),
            ),
          ),
        ])
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  // Future<void> _updateItem(
  //     idd, name, brand, image, price, actualPrice, counter) async {
  //   await DatabaseHelper.updateItem(
  //       idd, name, brand, image, price, actualPrice, counter);
  // }

  // void _refreshData() async {
  //   final db = DatabaseHelper.instance;
  //   isExist = await db.isProductExist(int.parse(widget.productID));
  //   var data = await db.queryAllRows();
  //   setState(() {
  //     addToCart = data;
  //   });
  // }

  void getDropDownProductMethod(String variantIdentifier) async {
    for (int i = 0; i < variantData.length; i++) {
      if (variantIdentifier.toString() == variantData[i]['ID']) {
        currentProductWeight = variantData[i]['weight'];
        mainPrice = variantData[i]['final_price'].toString();
        discountPrice = variantData[i]['actual_price'].toString();
        currentProductQuantity = variantData[i]['quantity'].toString();
      }
    }

    setState(() {
      mainPrice = mainPrice;
      discountPrice = discountPrice;
    });
  }

  void getProductDetails() async {
    var dio = Dio();
    var formData = FormData.fromMap({'product_id': widget.productID});
    final response = await dio.post(getProductDetailsUrl(), data: formData);
    var res = json.decode(response.data);
    v = res;
    print(v);
    if (v['variant'].isNotEmpty) {
      varientsellingprice = v['variant'][0]['final_price'].toString();
      // sliderList = result['medicine']['product_images'];-
      varientid = int.parse(v['variant'][0]['ID']);
      varientprice = v['variant'][0]['final_price'].toString();
      dropdownVarientId = v['variant'][0]['ID'].toString();
      dropdownFinalPrice = v['variant'][0]['final_price'].toString();
      v['qty'] = v['variant'][0]['quantity'];
      // if (v['food']['product_variants'][0]['variant']!= null) varientname = v['food']['product_variants'][0]['variant']['variant_name'];
      // varientdiscount = v['food']['product_variants'][0]['discount'].toString();
    }
    setState(() {
      int pos =
      databaseList.indexWhere((e) => e.toString() == res['ID'].toString());
      Map<String, dynamic> map = {
        'dropdown_value':
        v['variant'].isNotEmpty ? v['variant'][0]['weight'] : '',
        'dropdown_price': v['variant'].isNotEmpty
            ? v['variant'][0]['final_price']
            : v['final_price'],
        'dropdown_price1': v['variant'].isNotEmpty
            ? v['variant'][0]['actual_price']
            : v['actual_price'],
        'count': databaseList.contains(v['ID'].toString()) ? countList[pos] : 1,
        'is_exist': databaseList.contains(v['ID'].toString()),
      };
      v.addEntries(map.entries);

      imgList = [];
      for (int i = 0; i < res['images'].length; i++) {
        if (res['images'].length > 0) {
          imgList.add(res['images'][i]['img_product'].toString());
        } else {
          imgList.add("");
        }
      }
      for (int i = 0; i < res['variant'].length; i++) {
        variantDropDownItems.add([
          res['variant'][i]['weight'].toString(),
          res['variant'][i]['ID'].toString(),
          res['variant'][i]['quantity']
        ]);
      }
      if (variantDropDownItems.isNotEmpty) {
        dropdownvalue = res['variant'].length > 0
            ? res['variant'][0]['ID'].toString()
            : "-";

        currentProductWeight = res['variant'].length > 0
            ? res['variant'][0]['weight'].toString()
            : "-";

        currentProductQuantity = res['variant'].length > 0
            ? res['variant'][0]['quantity'].toString()
            : "0";
      }
      variantData = res['variant'];
      mainPrice = res['final_price'].toString();
      discountPrice = res["actual_price"].toString();
      discounts = res['discount'].toString();
      res['qty'] == null ? outOfStock = true : outOfStock = false;
      addEnabled = true;
      imgList = imgList;
      variantDropDownItems = variantDropDownItems;
      dropdownvalue = dropdownvalue;
      addEnabled = addEnabled;
      outOfStock = outOfStock;
    });
  }

  Widget sliderWidget() {
    return CarouselSlider(
      items: imgList
          .map((item) => InkWell(
        onTap: () {},
        child: Container(
          margin: const EdgeInsets.all(5.0),
          child: ClipRRect(
              borderRadius:
              const BorderRadius.all(Radius.circular(5.0)),
              child: Stack(
                children: <Widget>[
                  item.isNotEmpty
                      ? FadeInImage(
                    placeholder: const AssetImage(
                        "assets/img/logo (6).png"),
                    image: NetworkImage(item),
                    imageErrorBuilder:
                        (context, exception, stackTrace) {
                      return const Text(
                          "Failed to load the image");
                    },
                  )
                      : Image.asset("assets/img/logo (4).png"),
                  Positioned(
                    bottom: 0.0,
                    left: 0.0,
                    right: 0.0,
                    child: Container(
                      // decoration: BoxDecoration(
                      //   gradient: LinearGradient(
                      //     colors: [
                      //       Color.fromARGB(0, 0, 0, 0),
                      //       Color.fromARGB(0, 0, 0, 0)
                      //     ],
                      //     begin: Alignment.bottomCenter,
                      //     end: Alignment.topCenter,
                      //   ),
                      // ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10.0),
                      child: const Text(
                        '',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              )),
        ),
      ))
          .toList(),
      carouselController: _controller,
      options: CarouselOptions(
          autoPlay: false,
          enlargeCenterPage: false,
          // aspectRatio: 1.2,
          viewportFraction: 1.0,
          onPageChanged: (index, reason) {
            setState(() {
              selected = index;
            });
          }),
    );
  }

  Widget dots() {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
        horizontal: 12,
      ),
      child: Wrap(
        children: imgList.asMap().entries.map((entry) {
          return Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.symmetric(
              horizontal: 2,
            ),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected == entry.key
                  ? const Color(0xff065197)
                  : Colors.white,
              border: Border.all(width: 2, color: const Color(0xff065197)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget gramDropDown() {
    return (variantDropDownItems.isNotEmpty)
        ? DropdownButtonHideUnderline(
      child: DropdownButton(
        icon: const Padding(
          padding: EdgeInsets.only(right: 6.0),
          child: Icon(Icons.keyboard_arrow_down),
        ),
        iconSize: 20,
        iconEnabledColor: const Color(0xff065197),
        isExpanded: true,
        items: variantDropDownItems.map((items) {
          return DropdownMenuItem(
            value: items[1].toString(),
            child: Padding(
              padding: const EdgeInsets.only(left: 6.0),
              child: Text(items[0],
                  style: const TextStyle(color: Color(0xff065197))),
            ),
          );
        }).toList(),
        value: dropdownvalue,
        onChanged: (newValue) {
          getDropDownProductMethod(newValue.toString());
          setState(() {
            dropdownvalue = newValue.toString();
          });
        },
      ),
    )
        : const Center(child: Text("No variants"));
  }

  Widget alignedGramDropDown() {
    return variantData.isNotEmpty
        ? Container(
        margin: const EdgeInsets.all(15),
        child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              alignment: Alignment.centerLeft,
              width: 150,
              height: 40,
              decoration: BoxDecoration(
                  border: Border.all(
                      width: 0.5, color: const Color(0xff065197)),
                  borderRadius:
                  const BorderRadius.all(Radius.circular(35))),
              child: SizedBox(
                width: 150,
                height: 50,
                child: gramDropDown(),
              ),
            )))
        : const Text("");
  }

  Widget priceWidget(String amount) {
    return Text(
      "₹$amount",
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: Clr().textSecondaryColor,
      ),
    );
  }

  Widget priceStrikeWidget(String amount) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
      child: Text(
        "₹$amount",
        style: const TextStyle(
          decoration: TextDecoration.lineThrough,
          fontSize: 16,
          color: Color(0xff90ABC3),
        ),
      ),
    );
  }

  Widget priceAndGramDropDown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        (dropdownvalue != "No Data") ? alignedGramDropDown() : const Text(""),
      ],
    );
  }

  Widget productDetails(String details, String info) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          details.toString(),
          textAlign: TextAlign.left,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 10,
        ),
        HtmlWidget(info.toString(),
            textStyle: TextStyle(
                color: Clr().textSecondaryColor, fontFamily: 'Opensans')),
        // Text(
        //   info.toString(),
        //   textAlign: TextAlign.left,
        // )
      ],
    );
  }

  Widget topContent(v) {
    int positionOfCart = v['variant'].isEmpty
        ? addToCart.indexWhere((element) =>
    element['medicine_id'].toString() == widget.productID.toString())
        : addToCart.indexWhere((element) =>
    element['varientid'].toString() == dropdownVarientId.toString());

    return Stack(
      children: [
        Image.asset('assets/img/productimg.png'),
        Column(
          children: [
            const SizedBox(
              height: 100,
            ),
            Container(
              child: imgList.isNotEmpty
                  ? sliderWidget()
                  : Image.asset("assets/img/logo (6).png"),
            ),
            dots(),
          ],
        ),
        Positioned(
          top: 360,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
                color: Clr().white,
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20))),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Text(v['name'].toString()),
                  Container(
                    margin: const EdgeInsets.all(18),
                    alignment: Alignment.centerLeft,
                    child: Text(v['name'].toString(),
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Clr().textPrimaryColor)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      (v['variant'].isNotEmpty)
                          ? Container(
                        margin:
                        const EdgeInsets.only(left: 12, right: 12),
                        width: 150,
                        height: 40,
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 0.5,
                                color: const Color(0xff065197)),
                            borderRadius: const BorderRadius.all(
                                Radius.circular(35))),
                        padding:
                        const EdgeInsets.only(right: 10, left: 10),
                        // decoration: BoxDecoration(
                        //     color: Colors.white,
                        //     borderRadius: BorderRadius.circular(5),
                        //     border: Border.all(
                        //         color: const Color(0xff5AA6EC)
                        //             .withOpacity(0.5))),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<dynamic>(
                            onTap: () {
                              FocusManager.instance.primaryFocus!
                                  .unfocus();
                            },
                            hint: Text(
                              v['dropdown_value'],
                              style: Sty().mediumText.copyWith(
                                color: Clr().lightGrey,
                              ),
                            ),
                            value: v['dropdown_value'],
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            style: Sty().mediumText,
                            onChanged: (value) {
                              setState(() {
                                // varientid = int.parse(v['ID']);
                                // varientsellingprice = v['final_price'].toString();
                                // varientprice = v['actual_price'].toString();
                                // varientname = v['variant_id'];

                                // varientid = int.parse(v['ID']);
                                // varientsellingprice = v['final_price'].toString();
                                // varientprice = v['actual_price'].toString();

                                // varientname = v['variant_id'];
                                // varientdiscount = v['discount'].toString();
                                v['dropdown_value'] = value!;
                                int position = v['variant'].indexWhere(
                                        (e) =>
                                    e['weight'].toString() ==
                                        value.toString());
                                v['dropdown_price'] =
                                v['variant'][position]['final_price'];
                                v['dropdown_price1'] = v['variant']
                                [position]['actual_price'];
                                v['qty'] =
                                v['variant'][position]['quantity'];
                                dropdownVarientId =
                                v['variant'][position]['ID'];
                                dropdownFinalPrice = v['variant']
                                [position]['final_price']
                                    .toString();
                                print(dropdownVarientId);
                                print(dropdownFinalPrice);
                              });
                            },
                            items: v['variant']
                                .map<DropdownMenuItem<dynamic>>((value) {
                              return DropdownMenuItem<dynamic>(
                                value: value['weight'],
                                child: Text(
                                  value['weight'],
                                  style: Sty().mediumText.copyWith(
                                    color: Color(0xff244D73),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      )
                          : Container(),
                      addToCart
                          .map((e) => v['variant'].isEmpty
                          ? e['medicine_id'].toString()
                          : e['varientid'].toString())
                          .contains(v['variant'].isEmpty
                          ? v['ID'].toString()
                          : dropdownVarientId.toString())
                          ? Container(
                        margin:
                        EdgeInsets.symmetric(horizontal: Dim().d20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dim().d8),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomLeft,
                            colors: <Color>[
                              Color(0xff1964aa),
                              Color(0xff5AA6EC),
                            ],
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                                onPressed: () {
                                  removeItem(positionOfCart);
                                },
                                icon: Icon(
                                  Icons.remove,
                                  size: Dim().d20,
                                ),
                                color: Clr().white),
                            Text(
                                '${addToCart[positionOfCart]['counter']}',
                                style: Sty()
                                    .smallText
                                    .copyWith(color: Clr().white)),
                            IconButton(
                                onPressed: () {
                                  addItem(positionOfCart, v);
                                },
                                icon: Icon(
                                  Icons.add,
                                  size: Dim().d20,
                                ),
                                color: Clr().white),
                          ],
                        ),
                      )
                          : Container()
                    ],
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     (v['variant'].isNotEmpty)?
                  //       Container(
                  //         margin: const EdgeInsets.only(left: 12, right: 12),
                  //         width: 150,
                  //         height: 40,
                  //         decoration: BoxDecoration(
                  //             border: Border.all(
                  //                 width: 0.5, color: const Color(0xff065197)),
                  //             borderRadius:
                  //             const BorderRadius.all(Radius.circular(35))),
                  //         padding: const EdgeInsets.only(right: 10, left: 10),
                  //         // decoration: BoxDecoration(
                  //         //     color: Colors.white,
                  //         //     borderRadius: BorderRadius.circular(5),
                  //         //     border: Border.all(
                  //         //         color: const Color(0xff5AA6EC)
                  //         //             .withOpacity(0.5))),
                  //         child: DropdownButtonHideUnderline(
                  //           child: DropdownButton<dynamic>(
                  //             onTap: () {
                  //               FocusManager.instance.primaryFocus!.unfocus();
                  //             },
                  //             hint: Text(
                  //               v['dropdown_value'],
                  //               style: Sty().mediumText.copyWith(
                  //                     color: Clr().lightGrey,
                  //                   ),
                  //             ),
                  //             value: v['dropdown_value'],
                  //             isExpanded: true,
                  //             icon: const Icon(Icons.keyboard_arrow_down),
                  //             style: Sty().mediumText,
                  //             onChanged: v['is_exist']
                  //                 ? null
                  //                 : (value) {
                  //                     setState(() {
                  //                       // varientid = int.parse(v['ID']);
                  //                       // varientsellingprice = v['final_price'].toString();
                  //                       // varientprice = v['actual_price'].toString();
                  //                       // varientname = v['variant_id'];
                  //
                  //                        // varientid = int.parse(v['ID']);
                  //                       // varientsellingprice = v['final_price'].toString();
                  //                       // varientprice = v['actual_price'].toString();
                  //                       // varientname = v['variant_id'];
                  //                       // varientdiscount = v['discount'].toString();
                  //
                  //                       v['dropdown_value'] = value!;
                  //                       int position = v['variant'].indexWhere((e) => e['weight'].toString() == value.toString());
                  //                       v['dropdown_price'] = v['variant'][position]['final_price'];
                  //                         v['dropdown_price1'] = v['variant'][position]['actual_price'];
                  //                       v['qty'] = v['variant'][position]['quantity'];
                  //                     });
                  //                   },
                  //             items: v['variant']
                  //                 .map<DropdownMenuItem<dynamic>>((value) {
                  //               return DropdownMenuItem<dynamic>(
                  //                 value: value['weight'],
                  //                 child: Text(
                  //                   value['weight'],
                  //                   style: Sty().mediumText.copyWith(
                  //                         color: Color(0xff244D73),
                  //                         fontSize: 14,
                  //                         fontWeight: FontWeight.w400,
                  //                       ),
                  //                 ),
                  //               );
                  //             }).toList(),
                  //           ),
                  //         ),
                  //       ):Container(),
                  //
                  //     // if (addToCart.map((e) => e['varientid'] != 0 ? e['varientid'] : e['medicine_id']).contains( varientid != null ? varientid: v['id'] ))
                  //     // if (v['is_exist'])
                  //     addToCart.map((e) => e['varientid']).contains(varientid) ?
                  //       Padding(
                  //         padding: const EdgeInsets.only(right: 20),
                  //         child: Row(
                  //           children: [
                  //             SizedBox(
                  //               width: 30,
                  //               child: TextButton(
                  //                   style: ButtonStyle(
                  //                     foregroundColor:
                  //                         MaterialStateProperty.all<Color>(
                  //                             primary()),
                  //                   ),
                  //                   // onPressed: () async {
                  //                   //   if (v['count'] <= 1) {
                  //                   //     showDialog(
                  //                   //         context: context,
                  //                   //         builder: (context) {
                  //                   //           return AlertDialog(
                  //                   //             title: const Text("Error",
                  //                   //                 style: TextStyle(
                  //                   //                     color: Colors.red)),
                  //                   //             content: const Text(
                  //                   //                 "You must have at least one of these items in the cart"),
                  //                   //             actions: [
                  //                   //               TextButton(
                  //                   //                 child: const Text("OK"),
                  //                   //                 onPressed: () =>
                  //                   //                     Navigator.of(context)
                  //                   //                         .pop(),
                  //                   //               )
                  //                   //             ],
                  //                   //           );
                  //                   //         });
                  //                   //   } else {
                  //                   //     int i = v['variant'].indexWhere((e) =>
                  //                   //         e['weight'] == v['dropdown_value']);
                  //                   //     setState(() {
                  //                   //       v['count']--;
                  //                   //     });
                  //                   //     int sPrice = v['variant'].isNotEmpty
                  //                   //         ? v['variant'][i]['final_price']
                  //                   //         : v['final_price'];
                  //                   //     int total = v['count'] * sPrice;
                  //                   //     Map<String, dynamic> row = {
                  //                   //       DatabaseHelper.columnQuantity:
                  //                   //           v['count'],
                  //                   //       DatabaseHelper.columnProductUniqueId:
                  //                   //           int.parse(v['ID']),
                  //                   //       DatabaseHelper.columnVariantArray:
                  //                   //           v['variant'].toString(),
                  //                   //       DatabaseHelper.columnTotalAmount:
                  //                   //           total.toString()
                  //                   //     };
                  //                   //     await helper.update(row);
                  //                   //   }
                  //                   // },
                  //                   onPressed: (){
                  //                     removeItem(position);
                  //                   },
                  //                   child: Text(
                  //                     "-",
                  //                     style: TextStyle(
                  //                         fontSize: 22,
                  //                         color: Clr().textSecondaryColor),
                  //                   )),
                  //             ),
                  //             Container(
                  //               decoration: BoxDecoration(
                  //                   border: Border.all(
                  //                       width: 1,
                  //                       color: Clr().textSecondaryColor),
                  //                   borderRadius: BorderRadius.circular(55.0)),
                  //               padding: const EdgeInsets.all(10),
                  //               height: 35,
                  //               child: Text(
                  //                 '${addToCart[position]['counter'].toString()}',
                  //                 style: const TextStyle(fontSize: 12),
                  //               ),
                  //             ),
                  //             SizedBox(
                  //               width: 20,
                  //               child: TextButton(
                  //                   style: ButtonStyle(
                  //                     foregroundColor:
                  //                         MaterialStateProperty.all<Color>(
                  //                             primary()),
                  //                   ),
                  //                   // onPressed: () async {
                  //                   //   int i = v['variant'].indexWhere((e) =>
                  //                   //       e['weight'] == v['dropdown_value']);
                  //                   //   var productQty = v['variant'].isNotEmpty
                  //                   //       ? v['variant'][i]['quantity']
                  //                   //       : v['qty'];
                  //                   //   if (int.parse(productQty) > v['count']) {
                  //                   //     setState(() {
                  //                   //       v['count']++;
                  //                   //     });
                  //                   //     int sPrice = v['variant'].isNotEmpty
                  //                   //         ? v['variant'][i]['final_price']
                  //                   //         : v['final_price'];
                  //                   //     int total = v['count'] * sPrice;
                  //                   //     Map<String, dynamic> row = {
                  //                   //       DatabaseHelper.columnQuantity:
                  //                   //           v['count'],
                  //                   //       DatabaseHelper.columnProductUniqueId:
                  //                   //           int.parse(v['ID']),
                  //                   //       DatabaseHelper.columnVariantArray:
                  //                   //           v['variant'].toString(),
                  //                   //       DatabaseHelper.columnTotalAmount:
                  //                   //           total.toString()
                  //                   //     };
                  //                   //     await helper.update(row);
                  //                   //   } else {
                  //                   //     showDialog(
                  //                   //         context: context,
                  //                   //         builder: (context) {
                  //                   //           return AlertDialog(
                  //                   //             title: const Text(
                  //                   //               "Error",
                  //                   //               style: TextStyle(
                  //                   //                 color: Colors.red,
                  //                   //               ),
                  //                   //             ),
                  //                   //             content: Text(
                  //                   //                 "Maximum available quantity reached for " +
                  //                   //                     v['name']),
                  //                   //             actions: [
                  //                   //               TextButton(
                  //                   //                 child: const Text("OK"),
                  //                   //                 onPressed: () =>
                  //                   //                     Navigator.of(context)
                  //                   //                         .pop(),
                  //                   //               )
                  //                   //             ],
                  //                   //           );
                  //                   //         });
                  //                   //   }
                  //                   // },
                  //                   onPressed: (){
                  //                     addItem(position);
                  //                   },
                  //                   child: Text(
                  //                     "+",
                  //                     style: TextStyle(
                  //                         fontSize: 22,
                  //                         color: Clr().textSecondaryColor),
                  //                   )),
                  //             ),
                  //           ],
                  //         ),
                  //       ) : Text('Add To Cart'),
                  //   ],
                  // ),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.all(15),
                          child: productDetails(
                              "Product details", v['description']))),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // remove item
  removeItem(index) {
    int counter = addToCart[index]['counter'];
    var acutal;
    try {
      acutal = int.parse(addToCart[index]['actualPrice'].toString());
    } catch (_) {
      acutal = double.parse(addToCart[index]['actualPrice'].toString());
    }
    ;
    var price;
    try {
      price = int.parse(addToCart[index]['price'].toString());
    } catch (_) {
      price = double.parse(addToCart[index]['price'].toString());
    }
    ;
    counter == 1
        ? Store.deleteItem(
      addToCart[index]['medicine_id'],
      addToCart[index]['varientid'],
    )
        : counter--;
    var newPrice = price - acutal;
    if (counter > 0) {
      _updateItem(
          addToCart[index]['medicine_id'],
          addToCart[index]['varientid'],
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
  addItem(index, v) {
    print(v);
    int counter = addToCart[index]['counter'];
    var acutal;
    try {
      acutal = int.parse(addToCart[index]['actualPrice'].toString().replaceAll(new RegExp(r"\D"), ""));
    } catch (_) {
      acutal = double.parse(addToCart[index]['actualPrice'].toString());
    }
    ;
    var price;
    try {
      price = int.parse(addToCart[index]['price'].toString().replaceAll(new RegExp(r"\D"), ""));
    } catch (_) {
      price = double.parse(addToCart[index]['price'].toString());
    }
    ;
    if (v['variant'].isNotEmpty) {
      counter == int.parse(v['qty'])
          ? STM().displayToast('This product quantity is ${v['qty']}')
          : counter++;
    } else {
      counter == int.parse(v['qty'])
          ? STM().displayToast('This product quantity is ${v['qty']}')
          : counter++;
    }

    var newPrice = price + acutal;
    if (counter > 0) {
      _updateItem(
          addToCart[index]['medicine_id'],
          addToCart[index]['varientid'],
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

// void check() async {
//   final db = DatabaseHelper.instance;
//   var b = await db.isProductExist(int.parse(widget.productID.toString()));
//   if (b) {
//     qtyno =
//         int.parse(await db.getQty(int.parse(widget.productID.toString())));
//   }
// }
}
