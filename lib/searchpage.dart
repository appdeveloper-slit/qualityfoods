import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qf/colors.dart';
import 'package:qf/commondropdown.dart';
import 'package:qf/globalurls.dart';
import 'package:qf/homedropdown.dart';
import 'package:qf/localstore.dart';
import 'package:qf/single_product_view.dart';
import 'package:qf/values/colors.dart';
import 'package:qf/values/dimens.dart';
import 'package:qf/values/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './appbar_gradientlook.dart';
import 'bottom_navigation/bottom_navigation.dart';
import 'manage/static_method.dart';
// backup page name is searchpage
class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  late BuildContext ctx;
  List<Widget> offerItemList = [];
  bool isloaded = false;
  bool searchVisibility = true;
  List<Widget> searchResultList = [];
  bool searchResultLoaded = false;
  TextEditingController searchBarController = TextEditingController();

  Widget offerItem(String code, String details) {
    return Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: primary()),
            borderRadius: BorderRadius.circular(25)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        decoration: BoxDecoration(
                            border: Border.all(width: 1, color: primary()),
                            borderRadius: BorderRadius.circular(5)),
                        width: MediaQuery.of(context).size.width - 100,
                        child: InkWell(
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: code.toString()));
                            SnackBar sn = SnackBar(
                              content: Text("Copied!"),
                              duration: Duration(seconds: 1),
                            );

                            ScaffoldMessenger.of(context).showSnackBar(sn);
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                  child: Icon(
                                    Icons.copy,
                                    color: primary(),
                                  ),
                                  padding: EdgeInsets.all(5)),
                              Expanded(
                                  child: Align(
                                      alignment: Alignment.center,
                                      child: Container(
                                        child: Text(
                                          code,
                                          textAlign: TextAlign.left,
                                        ),
                                        margin: EdgeInsets.only(right: 30.0),
                                      ))),
                            ],
                          ),
                        )),
                  ],
                )
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    width: MediaQuery.of(context).size.width - 160,
                    margin: EdgeInsets.only(top: 5),
                    child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          child: Text(
                            details,
                            textAlign: TextAlign.center,
                            softWrap: true,
                          ),
                          margin: EdgeInsets.only(left: 20.0),
                        ))),
              ],
            ),
          ],
        ));
  }
  List<dynamic> addToCart = [];
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
    for (int i = 0; i < res['result_array'].length; i++) {
      offerItemList.add(offerItem(
          res['result_array'][i]['code'], res['result_array'][i]['detail']));
    }

    setState(() {
      offerItemList = offerItemList;
      isloaded = true;
    });
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

  Future<void> _addItem(medicine_id, varientid, name, image, price, actualPrice,
      description, counter) async {
    await Store.createItem(medicine_id, varientid, name, image, price,
        actualPrice, description, counter);
  }

  getSessionData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    //
    STM().checkInternet(context, widget).then((value) {
      if (value) {
        _refreshData();
      }
    });
  }

  void initState() {
    getOffers();
    _refreshData();
    getSessionData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ctx = context;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        bottomNavigationBar: bottomBarLayout(ctx, 2),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          // elevation: 0.2,
          leadingWidth: 25,
          leading: BackButton(color: Color(0xff244D73)),
          centerTitle: true,
          title: searchBar(),
          flexibleSpace: barGredient(),
        ),
        body: searchResultLoaded
            ? searchResultList.length != 0
                ? SingleChildScrollView(
                    child: Container(
                      child: Column(
                        children: [
                          Visibility(
                            visible: !searchVisibility,
                            child: searchResultLoaded
                                ? GridView.count(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              childAspectRatio: 0.800,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              children: searchResultList,
                            )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Center(
                                          child: Container(
                                        child:
                                            const CircularProgressIndicator(),
                                        padding: const EdgeInsets.all(25),
                                      ))
                                    ],
                                  ),
                          ),
                        ],
                      ),
                      // child: Center(
                      //   child: Scrollbar(
                      //     child: Container(
                      //       margin: EdgeInsets.all(15),
                      //       child: ListView(
                      //         children: offerItemList.length > 0 ? offerItemList : [Center(child: Text("No Offers Found"))],
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ),
                  )
                : Center(
                    child: SvgPicture.asset(
                      'assets/img/pagenotfound.svg',
                      // width: double.infinity,
                    ),
                  )
            : searchBarController.text.isNotEmpty
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Center(
                    child: Container(
                        child: Align(
                    alignment: Alignment.center,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset('assets/img/searchempty.svg'),
                          Text(
                            "Looking for something new?",
                            style: TextStyle(
                                fontSize: 24,
                                color: Color(0xff244D73),
                                fontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            height: 100,
                          ),
                        ],
                      ),
                    ),
                  ))));
  }

  Widget searchBar() {
    return Container(
        height: 40,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(45),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  // keyboardType: TextInputType.,
                  onChanged: (value) {
                    print(searchBarController.text.toString());
                    getSearchResults();
                    setState(() {
                      // searchBarController.clear();
                      searchVisibility = false;
                    });
                  },
                  controller: searchBarController,
                  // onEditingComplete: () {
                  //   print(searchBarController.text.toString());
                  //   getSearchResults();
                  //   setState(() {
                  //     searchVisibility = false;
                  //   });
                  // },
                  decoration: InputDecoration(
                      counterText: "",
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 12),
                      border: InputBorder.none,
                      hintText: "Search",
                      filled: true,
                      fillColor: Colors.grey[100],
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(
                          bottom: 10,
                          top: 10,
                        ),
                        child: SvgPicture.asset('assets/img/Searchic.svg'),
                      ),
                      prefixIconColor: primary()),
                ),
              ),
              !searchVisibility
                  ? InkWell(
                      child: Container(
                        child: SvgPicture.asset('assets/img/cuticon.svg'),
                        padding: const EdgeInsets.all(12),
                        color: Colors.grey[100],
                      ),
                      onTap: () {
                        // searchBarController.text = '';
                        searchBarController.clear();
                        setState(() {
                          searchVisibility = false;
                        });
                      },
                    )
                  : Container(),
            ],
          ),
        ));
  }

  List<dynamic> categorylist = [];

  void getSearchResults() async {
    // SEARCH API
    SharedPreferences sp = await SharedPreferences.getInstance();
    var dio = Dio();
    setState(() {
      searchResultLoaded = false;
    });
    var formData =
        FormData.fromMap({'keyword': searchBarController.text.toString(),'pincode': sp.getString('pincode')});
    final response = await dio.post(searchProductsUrl(), data: formData);
    var res = json.decode(response.data);
    print(res);
    categorylist = res['result_array'];
    searchResultList = [];
    for (int i = 0; i < res['result_array'].length; i++) {
      searchResultList.add(miniProductSearchCard(
          res['result_array'][i],
          res['result_array'][i]['name'],
          res['result_array'][i]['images'].length > 0
              ? res['result_array'][i]['images'][0]['img_product']
              : "",
          res['result_array'][i]['name'],
          res['result_array'][i]['variant'].length > 0
              ? res['result_array'][i]['variant'][0]['final_price'].toString()
              : res['result_array'][i]['final_price'].toString(),
          res['result_array'][i]['variant'].length > 0
              ? res['result_array'][i]['variant'][0]['actual_price'].toString()
              : res['result_array'][i]['actual_price'].toString(),
          res['result_array'][i]['variant'].length > 0
              ? int.parse(res['result_array'][i]['variant'][0]['discount'])
              : int.parse(res['result_array'][i]['discount']),
          res['result_array'][i]['ID'].toString(),
          res['result_array'][i]['variant'],
          res['result_array'][i]['qty']));
    }
    if (searchResultList.length > 0) {
      // ALL GOOD
    } else {
      searchResultList.add(SvgPicture.asset(
        'assets/img/pagenotfound.svg',
        // width: double.infinity,
      ));
    }
    setState(() {
      searchResultLoaded = true;
      searchResultList = searchResultList;
    });
  }

  Widget miniProductSearchCard(
      Map allList,
      String name,
      String imagePath,
      String productTitle,
      String price,
      String actual_price,
      int discount,
      String productID,
      List variant,
      var qty) {
    return InkWell(
      onTap: () {
        qty == null
            ? null
            : Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ProductDetail(productID: productID))).then((_) {
                print("Cart update called");
              });
      },
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Container(
          width: MediaQuery.of(ctx).size.width,
          margin: EdgeInsets.all(
            Dim().d4,
          ),
          child: Stack(
            children: [
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
              // Opacity(
              //   opacity: v['qty'] == 0 ? 0.5 : 1,
              //   child:
              // ),
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
                      if (variant.isEmpty)
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
                                    width: 1,
                                    color: const Color(0xffE5F3FF)),
                                borderRadius: BorderRadius.circular(10),
                                color: const Color(0xffE5F3FF),
                              ),
                              child: Stack(
                                fit: StackFit.loose,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      if(qty != null)
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ProductDetail(
                                                  productID: productID.toString(),
                                                  type: variant.isEmpty
                                                      ? 'No'
                                                      : 'Yes',
                                                ),
                                          ),
                                        );
                                    },
                                    child: CachedNetworkImage(
                                      imageUrl: imagePath,
                                      placeholder: (context, url) =>
                                          Image.asset(
                                              "assets/img/logo (6).png"),
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                              "assets/img/logo (6).png"),
                                      width: 110,
                                      height: 60,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (variant.isEmpty)
                        Html(
                          data: '${name}',
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
                      if (variant.isNotEmpty)
                        commonDropdown(v: allList, type: 'subProduct'),
                      if (variant.isEmpty)
                        Container(height: Dim().d40),
                      if (variant.isEmpty)
                        qty == null
                            ? Container()
                            : Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: int.parse(price.toString().replaceAll(new RegExp(r"\D"), "")) == int.parse(actual_price.toString().replaceAll(new RegExp(r"\D"), "")) ? Container() : priceStrikeWidget(
                              '${actual_price}'),
                        ),
                      // if(v['variant'].isEmpty || v['qty'] == 0)
                      //   Padding(
                      //     padding:  EdgeInsets.only(left: 16.0,bottom: 4),
                      //     child: Text('Out of Stock',style: TextStyle(color: Colors.red),),
                      //   ),
                      if (variant.isEmpty)
                        qty == null
                            ? Padding(
                          padding: const EdgeInsets.all(8.0),
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
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '₹ ${price}',
                                  style: TextStyle(
                                    fontSize: Dim().d12,
                                    color: Clr().textSecondaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(flex: 2,child: homeDropdown(data: allList),)
                            ],
                          ),
                        )
                    ],
                  ),
                ),
              ),
              if (qty != null)
               discount.toString() != '0' ?
                Positioned(
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
                        "$discount % off",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  // Text(
                  //   v['discount'] + "% off",
                  //   style: const TextStyle(color: Colors.white),
                  // ),
                ) : Container(),
              // if (v['qty'] == 0)
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
              //             "Out of Stock",
              //             style: TextStyle(fontSize: 14, color: Colors.white),
              //           )),
              //         ),
              //       ),
              //     ),
              //   ])
            ],
          ),
        ),
      ),
    );
  }



  Widget priceWidget(String amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text("₹" + amount.toString(),
          // textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 16,
              color: Clr().textSecondaryColor,
              fontWeight: FontWeight.w500)),
    );
  }

  Widget priceStrikeWidget(String amount) {
    return Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Text("₹" + amount.toString(),
            style: const TextStyle(
                decoration: TextDecoration.lineThrough,
                fontSize: 14,
                color: Colors.grey)));
  }
}
