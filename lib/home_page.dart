import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:qf/about_us.dart';
import 'package:qf/cart_page_old.dart';
import 'package:qf/colors.dart';
import 'package:qf/commonaddtocart.dart';
import 'package:qf/contact_us.dart';
import 'package:qf/myaddress.dart';
import 'package:qf/myorders.dart';
import 'package:qf/notifications.dart';
import 'package:qf/sqliteop.dart';
import 'package:qf/sub_product_category_screen.dart';
import 'package:qf/values/colors.dart';
import 'package:qf/values/dimens.dart';
import 'package:qf/values/styles.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';

import './appbar_gradientlook.dart';
import './single_product_view.dart';
import 'bottom_navigation/bottom_navigation.dart';
import 'commondropdown.dart';
import 'globalurls.dart';
import 'localstore.dart';
import 'location.dart';
import 'login.dart';
import 'manage/static_method.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

int QfPosition = -1;
int cartPosition = -1;
List imgList = [];
List bannerImageList = [];
List<Widget> homeProductCatgories = [];
bool searchVisibility = true;
int position = 0;
List<Widget> searchResultList = [];
List<dynamic> addToCart = [];
var Gmapkey;
var homeBanner;
bool isExist = false;

bool isDropdownOpen = false;

List<Widget> bannerImageSlider = bannerImageList
    .map((item) => Container(
          // margin: const EdgeInsets.all(5.0),
          child: Stack(
            children: <Widget>[
              CachedNetworkImage(imageUrl: item, fit: BoxFit.fill),
              Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(0, 0, 0, 0),
                        Color.fromARGB(0, 0, 0, 0)
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
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
          ),
        ))
    .toList();

List<Widget> imageSliders = imgList
    .map((item) => Container(
          margin: const EdgeInsets.all(5.0),
          child: Stack(
            children: <Widget>[
              ClipRRect(
                borderRadius: const BorderRadius.all(
                  Radius.circular(0),
                ),
                child: CachedNetworkImage(
                    imageUrl: item, fit: BoxFit.cover, width: 1500),
              ),
              Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(0, 0, 0, 0),
                        Color.fromARGB(0, 0, 0, 0)
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
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
          ),
        ))
    .toList();

class HomeScreenState extends State<HomeScreen> {
  late BuildContext ctx;
  int count = 0;
  var check;

  // List<dynamic> resultList = [];
  List<dynamic> categorylist = [];
  List<dynamic> bannerlist = [];
  List<String> databaseList = [];
  List<int> countList = [];

  // DatabaseHelper helper = DatabaseHelper.instance;
  int? selected;
  bool homeloaded = false;
  final CarouselController _controller = CarouselController();
  final CarouselController _bannerController = CarouselController();
  DateTime? currentBackPressTime;
  GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();
  List<dynamic> dropdownValue = [];
  List<dynamic> ActualPri = [];
  List<dynamic> finalPre = [];

  String? sID, sUUID;
  var city;
  var Pincode;

//new data base
  var qualityname,
      varientprice,
      varientsellingprice,
      varientQty,
      varientdiscount,
      mainId,
      varientId;
  var dropdownVarientId, dropdownVarientWeight, dropdownFinalPrice;
  List<dynamic> addToCart = [];
  bool? isLoading;
  String? sUserid;
  var varientid;
  var price;
  String sTotalPrice = "0";
  int? positionOfCart;

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

  String? usertoken;

  getSessionData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    //
    STM().checkInternet(context, widget).then((value) {
      if (value) {
        _refreshData();
      }
    });
  }

  Future<void> _addItem(medicine_id, varientid, name, image, price, actualPrice,
      description, counter) async {
    await Store.createItem(medicine_id, varientid, name, image, price,
        actualPrice, description, counter);
  }

  @override
  void initState() {
    // print(sID);
    // print(sUUID);
    // Future.delayed(Duration.zero,() {
    //   setState(() {
    //     print('${Pincode}'+'Pincode');
    //     print('${city}'+'city');
    //     // _modalBottomSheetMenu();
    //   });
    // });\
    cleanArray();
    getSessionData();
    getLocation();
    checkConnectivity();
    // getDatabase();
    print(sUUID);
    print(sID);
    print(Gmapkey);
    checklogin();
    Store.getCounterId();
    // updateBadgeCount();
    // _refreshData();
    super.initState();
  }

  @override
  void dispose() {
    // updateBadgeCount();
    super.dispose();
  }

  cleanArray() async {
    commonAryy = await [];
  }

  // void getDatabase() async {
  //   // var rows = await helper.queryAllRows();
  //   databaseList = rows.map((e) => e['product_id'].toString()).toList();
  //   for (int i = 0; i < rows.length; i++) {
  //     countList.add(rows[i]['quantity']);
  //   }
  // }
  Widget sliderwidget() {
    return CarouselSlider(
      items: imageSliders,
      carouselController: _controller,
      options: CarouselOptions(
          autoPlay: false,
          scrollPhysics: NeverScrollableScrollPhysics(),
          enlargeCenterPage: false,
          // aspectRatio: 3.0,
          viewportFraction: 1.0,
          height: 180,
          // height: 110,
          onPageChanged: (index, reason) {
            setState(() {
              selected = index;
            });
          }),
    );
  }

  Widget sliderbannerwidget() {
    return CarouselSlider(
      items: bannerImageSlider,
      carouselController: _bannerController,
      options: CarouselOptions(
          autoPlay: false,
          scrollPhysics: NeverScrollableScrollPhysics(),
          enlargeCenterPage: false,
          // aspectRatio: 3.0,
          viewportFraction: 1.0,
          height: 180,
          // height: 180,
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
            width: 12,
            height: 12,
            margin: const EdgeInsets.symmetric(
              horizontal: 2,
            ),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected == entry.key ? primary() : white(),
              border: Border.all(width: 2, color: primary()),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget miniProductCardViewCategory(String productCategoryImagePath,
      String productCategoryTitle, String category_id) {
    return InkWell(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(
                builder: (context) => SubProductCategoriesScreen(
                    sCategory: category_id,
                    sSubCategory: '',
                    selectedIndex: 0,
                    sTitle: productCategoryTitle,
                    spincode: Pincode.toString())))
            .then((_) {
          // updateBadgeCount();
          print("Cart update called");
        });
      },
      child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/img/homecategbg.png')),
          ),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                    child: Html(
                  data: productCategoryTitle,
                  style: {
                    "body": Style(
                      maxLines: 2,
                      color: Color(0xff065197),
                      fontSize: FontSize(16),
                      fontWeight: FontWeight.w500,
                      textOverflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    )
                  },
                )),
                FittedBox(
                  fit: BoxFit.cover,
                  child: CachedNetworkImage(
                    // fit: Box,
                    imageUrl: productCategoryImagePath,
                    placeholder: (context, url) => Center(
                        child: Container(
                      child: const CircularProgressIndicator(),
                      width: 20,
                      height: 20,
                    )),
                    // Image.asset("assets/img/logo (6).png"),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                    width: 80,
                    height: 50,
                    // height: 60,
                  ),
                )
              ])),
    );
  }

  Widget discountStripLabel(String discountLabel) {
    return Positioned(
        top: 83,
        left: 6,
        child: Text(
          discountLabel,
          style: const TextStyle(fontSize: 10, color: Colors.white),
        ));
  }

  Widget discountStrip(String discountLabel) {
    return Positioned(
        top: 75,
        left: 0,
        child: SvgPicture.asset(
          "assets/img/lable.svg",
          width: 25,
          height: 25,
          color: primary(),
        ));
  }

  Widget priceWidget(String amount) {
    return Text("₹" + amount.toString(),
        // textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14, color: primary()));
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

  void getHomePageData({pincode}) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    // final status = await OneSignal.shared.getDeviceState();
    if (!mounted) return;
    sUUID = OneSignal.User.pushSubscription.id;
    sID = sp.getString("user_id");
    setState(() {
      homeloaded = false;
      searchVisibility = true;
    });

    var dio = Dio();
    var formData = FormData.fromMap({
      "player_id": sUUID ?? "",
      "user_id": sID ?? "",
      "pincode": '$pincode'
    });
    // {"player_id": sUUID ?? "", "user_id": sID ?? "", "pincode":'123456'});
    debugPrint(formData.fields.toString());
    final response = await dio.post(homePageDataUrl(), data: formData);
    var res = json.decode(response.data);
    var success = res['error'];
    var message = res['message'];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Gmapkey = res['google_map_key'];
    homeBanner = res['home_banner'];
    // prefs.setString('mapkey', res["google_map_key"].toString());
    if (success) {
      setState(() {
        STM().displayToast(message);
        STM().redirect2page(context, LocationNotFound());
      });
    } else {
      categorylist = res['deals_array'];
      bannerlist = res['banner_array'];
      print(categorylist);
      for (var e in categorylist) {
        for (var v in e['products']) {
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
      }
      imgList = [];
      for (int i = 0; i < res['slider_array'].length; i++) {
        imgList.add([
          "" + res['slider_array'][i]["image_path"].toString() + "",
          res['slider_array'][i]['maincat_id'].toString(),
          res['slider_array'][i]['maincat_name'],
          res['slider_array'][i]['product_id']
        ]);
      }
      // get banner images for banner slider
      bannerImageList = [];
      for (int i = 0; i < res['banner_array'].length; i++) {
        bannerImageList.add([
          "" + res['banner_array'][i]["image_path"].toString() + "",
          res['banner_array'][i]['maincat_id'].toString(),
          res['banner_array'][i]['maincat_name'],
          res['banner_array'][i]['product_id']
        ]);
      }
      // get home page product categories
      homeProductCatgories = [];
      for (int i = 0; i < res['main_categories'].length; i++) {
        homeProductCatgories.add(miniProductCardViewCategory(
            res['main_categories'][i]['image_path'],
            res['main_categories'][i]['name'],
            res['main_categories'][i]['ID']));
      }
      // get product swiper (deals array)

      homeloaded = true;

      // Final Set State for all
      setState(() {
        imgList = imgList;
        homeProductCatgories = homeProductCatgories;
        bannerImageList = bannerImageList;
        homeloaded = homeloaded;
        imageSliders = imgList
            .map((item) => Container(
                  margin: const EdgeInsets.all(5.0),
                  child: Stack(
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          // imagepath, cat_id, cat_name, product_id
                          // [0,        1,      2,        3]
                          print(item[1]);
                          print(item[2]);
                          print(item[3]);
                          if ((item[1].isNotEmpty && item[1] != null) &&
                              item[2].isNotEmpty) {
                            Navigator.of(context)
                                .push(MaterialPageRoute(
                                    builder: (context) =>
                                        SubProductCategoriesScreen(
                                            sCategory: item[1].toString(),
                                            sSubCategory: '',
                                            selectedIndex: 0,
                                            sTitle: item[2].toString(),
                                            spincode: Pincode.toString())))
                                .then((_) {
                              // updateBadgeCount();
                              print("Cart update called");
                            });
                          }

                          if (item[3].isNotEmpty && item[3] != null) {
                            Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ProductDetail(
                                            productID: item[3].toString())))
                                .then((_) {
                              // updateBadgeCount();
                              print("Cart update called");
                            });
                          }
                          print("Image Tapped");
                        },
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(25)),
                          child: CachedNetworkImage(
                            imageUrl: item[0].toString(),
                            fit: BoxFit.cover,
                            width: 1500.0,
                            placeholder: (context, url) => Center(
                                child: Container(
                              child: const CircularProgressIndicator(),
                              width: 20,
                              height: 20,
                            )),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0.0,
                        left: 0.0,
                        right: 0.0,
                        child: Container(
                          decoration: const BoxDecoration(
                              // gradient: LinearGradient(
                              //   colors: [
                              //     Color.fromARGB(100, 0, 0, 0),
                              //     Color.fromARGB(0, 0, 0, 0)
                              //   ],
                              //   begin: Alignment.bottomCenter,
                              //   end: Alignment.topCenter,
                              // ),
                              ),
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
                  ),
                ))
            .toList();

        bannerImageSlider = bannerImageList
            .map((item) => Container(
                  child: Container(
                    margin: const EdgeInsets.all(5.0),
                    child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(0)),
                        child: Stack(
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                print(item[1]);
                                print(item[2]);
                                print(item[3]);
                                if ((item[1].isNotEmpty && item[1] != null) &&
                                    item[2].isNotEmpty) {
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (context) =>
                                              SubProductCategoriesScreen(
                                                  sCategory: item[1].toString(),
                                                  sSubCategory: '',
                                                  selectedIndex: 0,
                                                  sTitle: item[2].toString(),
                                                  spincode:
                                                      Pincode.toString())))
                                      .then((_) {
                                    // updateBadgeCount();
                                    print("Cart update called");
                                  });
                                }

                                if (item[3].isNotEmpty && item[3] != null) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ProductDetail(
                                              productID: item[3]
                                                  .toString()))).then((_) {
                                    // updateBadgeCount();
                                    print("Cart update called");
                                  });
                                }
                                print("Banner Image Tapped");
                              },
                              child: CachedNetworkImage(
                                imageUrl: item[0].toString(),
                                fit: BoxFit.cover,
                                width: 1500.0,
                                placeholder: (context, url) =>
                                    Image.asset("assets/img/logo (6).png"),
                              ),
                            ),
                            Positioned(
                              bottom: 0.0,
                              left: 0.0,
                              right: 0.0,
                              child: Container(
                                decoration: const BoxDecoration(
                                    // gradient: LinearGradient(
                                    //   colors: [
                                    //     Color.fromARGB(0, 0, 0, 0),
                                    //     Color.fromARGB(0, 0, 0, 0)
                                    //   ],
                                    //   begin: Alignment.bottomCenter,
                                    //   end: Alignment.topCenter,
                                    // ),
                                    ),
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
            .toList();
      });
      if (!res['is_active']) {
        sp.clear();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => LoginScreen(),
          ),
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  bool personloggedin = false;

  void checklogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('isLoggedIn') == true) {
      setState(() {
        personloggedin = true;
      });
    }
  }

  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', false);
    prefs.setString('name', '');
    prefs.setString('mobile', '');
    prefs.setString('email', '');
    prefs.setString('user_id', '');
  }

  void checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    print(connectivityResult);
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      // Do nothing
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.wifi_off,
                size: 100,
                color: primary(),
              ),
              const SizedBox(
                height: 15,
              ),
              const Align(
                  alignment: Alignment.center,
                  child: Text("No internet connection!",
                      style: TextStyle(fontSize: 24))),
              Container(
                margin: const EdgeInsets.all(10),
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HomeScreen()))
                          .then((_) {
                        // updateBadgeCount();
                        print("Cart update called");
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.refresh),
                        const Text("Retry"),
                      ],
                    )),
              )
            ],
          );
        },
      );

      //  children: [
      //   Icon(Icons.wifi_off),
      //   Text("No internet connection!"),
      // ]);
    }
  }

  int contentInCart = 0;

  // void updateBadgeCount() async {
  //   // final db = DatabaseHelper.instance;
  //   final allRows = await db.queryAllRows();
  //   setState(() {
  //     contentInCart = allRows.length;
  //     contentInCart = contentInCart;
  //   });
  // }

  Future<void> pullDownRefresh() async {
    print("Refresh Started!");
    await Timer(const Duration(milliseconds: 100), () {
      setState(() {
        getHomePageData(pincode: Pincode);
      });
      print("Working refresh...");
    });
    print("Refresh Ended!");
  }

  @override
  Widget build(BuildContext context) {
    ctx = context;
    return WillPopScope(
      onWillPop: () async {
        DateTime now = DateTime.now();
        if (currentBackPressTime == null ||
            now.difference(currentBackPressTime!) >
                const Duration(seconds: 2)) {
          currentBackPressTime = now;
          SnackBar sn = const SnackBar(
            content: Text("Press back again to exit"),
            duration: Duration(milliseconds: 500),
          );
          ScaffoldMessenger.of(context).showSnackBar(sn);
          return Future.value(false);
        } else {
          SystemNavigator.pop();
        }

        return false;
      },
      child: Scaffold(
        key: scaffoldState,
        bottomNavigationBar: bottomBarLayout(ctx, 0),
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: InkWell(
            onTap: () {
              scaffoldState.currentState?.openDrawer();
            },
            child: Padding(
              padding: EdgeInsets.only(top: 18, bottom: 18),
              child: SvgPicture.asset('assets/img/menuiconbar.svg'),
            ),
          ),
          title: InkWell(
            onTap: () async {
              // getHomePageData();
              SharedPreferences sp = await SharedPreferences.getInstance();
              // sp.containsKey('pincode') ? sp.clear() : null;
              STM().redirect2page(
                  context,
                  MyLocation(
                    Gmapkey: Gmapkey,
                  ));
            },
            child: SizedBox(
              child: Row(children: [
                SvgPicture.asset('assets/img/Loactionimg.svg'),
                SizedBox(
                  width: 6,
                ),
                Text(
                  '$city',
                  style: TextStyle(color: Color(0xff787882), fontSize: 14),
                ),
                SizedBox(
                  width: 8,
                ),
                SvgPicture.asset('assets/img/dropdown.svg'),
              ]),
            ),
          ),
          flexibleSpace: barGredient(),
          actions: [
            Padding(
              padding: const EdgeInsets.all(0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                              ? Positioned(
                                  bottom: 2, right: -8, child: Container())
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
                  IconButton(
                      onPressed: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: ((context) {
                          return const NotificationScreen();
                        }))).then((_) {
                          // updateBadgeCount();
                          print("Cart update called");
                        });
                      },
                      icon: Icon(
                        Icons.notifications,
                        color: Clr().themePrimary,
                      ))
                ],
              ),
            ),
          ],
        ),
        drawer: Container(
          width: MediaQuery.of(context).size.width * 0.75,
          child: Drawer(
              child: ListView(
            children: [
              Container(
                child: Image.asset("assets/img/sidebarbanner.png",
                    fit: BoxFit.fill),
                // width: 150,
                height: 180,
              ),
              SizedBox(
                height: 10,
              ),
              ListTile(
                leading: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      color: Clr().textSecondary1Color, shape: BoxShape.circle),
                  child: Center(
                    child: SvgPicture.asset(
                      "assets/img/locatondrawer.svg",
                      height: 20,
                      width: 20,
                    ),
                  ),
                ),
                title: Text(
                  "My Address",
                  style: TextStyle(color: Clr().bgDrawer, fontSize: 15),
                ),
                trailing: Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: SvgPicture.asset(
                    "assets/img/nextdrawer.svg",
                    height: 12,
                    width: 10,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MyAddressScreen()))
                      .then((_) {
                    // updateBadgeCount();
                    print("Cart update called");
                  });
                },
              ),
              ListTile(
                leading: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      color: Clr().textSecondary1Color, shape: BoxShape.circle),
                  child: Center(
                    child: SvgPicture.asset(
                      "assets/img/orderdrawer.svg",
                      height: 20,
                      width: 20,
                    ),
                  ),
                ),
                trailing: Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: SvgPicture.asset(
                    "assets/img/nextdrawer.svg",
                    height: 12,
                    width: 10,
                  ),
                ),
                title: Text(
                  "My Order",
                  style: TextStyle(color: Clr().bgDrawer, fontSize: 15),
                ),
                onTap: () {
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MyOrdersScreen()))
                      .then((_) {
                    // updateBadgeCount();
                    print("Cart update called");
                  });
                },
              ),
              ListTile(
                leading: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      color: Clr().textSecondary1Color, shape: BoxShape.circle),
                  child: Center(
                    child: SvgPicture.asset(
                      "assets/img/privacydrawer.svg",
                      height: 20,
                      width: 20,
                    ),
                  ),
                ),
                title: Text(
                  "Privacy Policy",
                  style: TextStyle(color: Clr().bgDrawer, fontSize: 15),
                ),
                trailing: Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: SvgPicture.asset(
                    "assets/img/nextdrawer.svg",
                    height: 12,
                    width: 10,
                  ),
                ),
                onTap: () {
                  STM().openWeb('https://qualityfoods.info/privacy_policy.php');
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => MyAddressScreen()));
                },
              ),
              ListTile(
                leading: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      color: Clr().textSecondary1Color, shape: BoxShape.circle),
                  child: Center(
                    child: SvgPicture.asset(
                      "assets/img/Shippingdrawer.svg",
                      height: 20,
                      width: 20,
                    ),
                  ),
                ),
                // enabled: false,
                title: Text(
                  "Shipping Policy",
                  style: TextStyle(color: Clr().bgDrawer, fontSize: 15),
                ),
                trailing: Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: SvgPicture.asset(
                    "assets/img/nextdrawer.svg",
                    height: 12,
                    width: 10,
                  ),
                ),
                onTap: () {
                  STM()
                      .openWeb('https://qualityfoods.info/Shipping_policy.php');
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => ContactUsScreen()));
                },
              ),
              ListTile(
                leading: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      color: Clr().textSecondary1Color, shape: BoxShape.circle),
                  child: Center(
                    child: SvgPicture.asset(
                      "assets/img/refundrawer.svg",
                      height: 20,
                      width: 20,
                    ),
                  ),
                ),

                // enabled: false,
                title: Text(
                  "Refund Policy",
                  style: TextStyle(color: Clr().bgDrawer, fontSize: 15),
                ),
                trailing: Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: SvgPicture.asset(
                    "assets/img/nextdrawer.svg",
                    height: 12,
                    width: 10,
                  ),
                ),
                onTap: () {
                  STM().openWeb('https://qualityfoods.info/refund.php');
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => ContactUsScreen()));
                },
              ),
              ListTile(
                leading: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      color: Clr().textSecondary1Color, shape: BoxShape.circle),
                  child: Center(
                    child: SvgPicture.asset(
                      "assets/img/aboutdrawer.svg",
                      height: 20,
                      width: 20,
                    ),
                  ),
                ),

                // enabled: false,
                title: Text(
                  "About Us",
                  style: TextStyle(color: Clr().bgDrawer, fontSize: 15),
                ),
                trailing: Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: SvgPicture.asset(
                    "assets/img/nextdrawer.svg",
                    height: 12,
                    width: 10,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AboutUsScreen()))
                      .then((_) {
                    // updateBadgeCount();
                    print("Cart update called");
                  });
                },
              ),
              // ListTile(
              //   leading: Container(
              //     height: 35,
              //      width: 35,
              //      decoration: BoxDecoration(
              //       color: Clr().textSecondary1Color,
              //        shape: BoxShape.circle
              //      ),
              //     child: Center(
              //       child: SvgPicture.asset("assets/img/My Offers.svg", height: 20, width: 20,),
              //     ),
              //   ),
              //   title: Text(
              //     "My Offers",
              //     style: TextStyle(color: Clr().bgDrawer,fontSize: 15),
              //   ),
              //   trailing: Padding(
              //     padding:  EdgeInsets.only(right:12),
              //     child: SvgPicture.asset("assets/img/nextdrawer.svg", height: 12, width: 10,),
              //   ),
              //   onTap: () {
              //     Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //             builder: (context) => const OfferScreen())).then((_) {
              //       updateBadgeCount();
              //       print("Cart update called");
              //     });
              //   },
              // ),
              ListTile(
                leading: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      color: Clr().textSecondary1Color, shape: BoxShape.circle),
                  child: Center(
                    child: SvgPicture.asset(
                      "assets/img/contactusdrawer.svg",
                      height: 20,
                      width: 20,
                    ),
                  ),
                ),
                // enabled: false,
                title: Text(
                  "Contact Us",
                  style: TextStyle(color: Clr().bgDrawer, fontSize: 15),
                ),
                trailing: Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: SvgPicture.asset(
                    "assets/img/nextdrawer.svg",
                    height: 12,
                    width: 10,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ContactUsScreen()))
                      .then((_) {
                    // updateBadgeCount();
                    print("Cart update called");
                  });
                },
              ),
              ListTile(
                leading: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      color: Clr().textSecondary1Color, shape: BoxShape.circle),
                  child: Center(
                    child: SvgPicture.asset(
                      "assets/img/sharedrawer.svg",
                      height: 20,
                      width: 20,
                    ),
                  ),
                ),
                // enabled: false,
                title: Text(
                  "Share",
                  style: TextStyle(color: Clr().bgDrawer, fontSize: 15),
                ),
                trailing: Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: SvgPicture.asset(
                    "assets/img/nextdrawer.svg",
                    height: 12,
                    width: 10,
                  ),
                ),
                onTap: () {
                  Share.share(
                      'Download The Quality Foods App \n\nhttps://play.google.com/store/apps/details?id=com.qualityfoods.app&hl=en');
                },
              ),

              // ListTile(
              //   leading: const Icon(
              //     Icons.star_rate_outlined,
              //     size: 25,
              //     color: Colors.black,
              //   ),
              //   // enabled: false,
              //   title: Text(
              //     "Rate Us",
              //     style: TextStyle(color: Clr().bgDrawer),
              //   ),
              //   onTap: () async {
              //     try {
              //       if (!await launchUrlString(
              //           "market://details?id=com.qualityfoods.app"))
              //         throw 'Could not launch';
              //     } catch (err) {
              //       if (!await launchUrlString(
              //           "https://play.google.com/stdetails?id=com.qualityfoods.app"))
              //         throw 'Could not launch';
              //     }
              //   },
              // ),
              SizedBox(
                height: 30,
              ),
              personloggedin
                  ? Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: InkWell(
                        onTap: () async {
                          logout();
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HomeScreen()),
                              (route) => false).then((_) {
                            // updateBadgeCount();
                            print("Cart update called");
                          });
                          // SystemNavigator.pop();
                        },
                        child: Container(
                          // padding: EdgeInsets.only(top: 5, bottom: 5),
                          decoration: BoxDecoration(
                            border:
                                Border.all(width: 1, color: Color(0xfffdb17a)),
                            borderRadius: BorderRadius.circular(35),
                            color: Color(0xfffff8f3),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    "assets/img/logoutdrawer.svg",
                                    height: 20,
                                    width: 20,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "Log Out",
                                    style: TextStyle(color: primary()),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Text(""),
              if (personloggedin)
                InkWell(
                  onTap: () {},
                  child: Column(
                    children: [
                      Text(
                        'Delete My Account',
                        style: Sty().mediumBoldText.copyWith(
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                            color: Colors.red,
                            height: 0),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        '-----------------------------',
                        style: Sty().mediumBoldText.copyWith(
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                            color: Colors.red,
                            height: -0.1),
                      ),
                    ],
                  ),
                ),
            ],
          )),
        ),
        body: homeloaded
            ? UpgradeAlert(
                upgrader: Upgrader(dialogStyle: UpgradeDialogStyle.material),
                child: RefreshIndicator(
                  onRefresh: pullDownRefresh,
                  child: SingleChildScrollView(
                    child: Column(children: [
                      const SizedBox(height: 12),
                      // Image.network('${homeBanner}',),,
                      if (homeBanner != null)
                        CachedNetworkImage(
                          imageUrl: bannerlist.length > 0
                              ? '${bannerlist[0]['image_path'].toString()}'
                              : '${homeBanner}'.toString(),
                          fit: BoxFit.fill,
                          height: 170,
                          width: double.infinity,
                          // width: 1500.0,
                          placeholder: (context, url) =>
                              Image.asset("assets/img/logo (6).png"),
                        ),
                      Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                            child: GridView.count(
                                padding: EdgeInsets.only(left: 4, right: 4),
                                childAspectRatio: 0.9,
                                mainAxisSpacing: 14,
                                crossAxisSpacing: 14,
                                addRepaintBoundaries: true,
                                physics: const ScrollPhysics(),
                                shrinkWrap: true,
                                crossAxisCount: 3,
                                children: homeProductCatgories
                                // for (int i = 0; i < 12; i++) miniProductCardViewCategory(),
                                ),
                          ),
                          if (bannerImageSlider.isEmpty)
                            Container(
                              margin: const EdgeInsets.only(
                                  top: 0, right: 8, left: 8, bottom: 20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: sliderbannerwidget(),
                              ),
                            ),
                          bannerlist.length > 1
                              ? CachedNetworkImage(
                                  imageUrl:
                                      '${bannerlist[1]['image_path'].toString()}',
                                  fit: BoxFit.fill,
                                  height: 170,
                                  width: double.infinity,
                                  // width: 1500.0,
                                  placeholder: (context, url) =>
                                      Image.asset("assets/img/logo (6).png"),
                                )
                              : Container(),
                          SizedBox(
                            height: 8,
                          ),
                          ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: categorylist.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          15, 4, 8, 4),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                                child: Html(
                                              data:
                                                  '${categorylist[index]['main_cat_name'].toString()}',
                                              style: {
                                                "*": Style(
                                                    fontSize: FontSize(18),
                                                    color: Color(0xff00182E),
                                                    fontWeight: FontWeight.w500)
                                              },
                                            )),
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .push(MaterialPageRoute(
                                                          builder: ((context) =>
                                                              SubProductCategoriesScreen(
                                                                sCategory: categorylist[index]['main_cat_id'].toString(),
                                                                sSubCategory:
                                                                    "",
                                                                selectedIndex:
                                                                    0,
                                                                sTitle: categorylist[
                                                                            index]
                                                                        [
                                                                        'main_cat_name']
                                                                    .toString(),
                                                                spincode: Pincode
                                                                    .toString(),
                                                              ))))
                                                      .then((_) {
                                                    // updateBadgeCount();
                                                    print("Cart update called");
                                                  });
                                                },
                                                child: Row(
                                                  children: [
                                                    const Text(
                                                      "View All",
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xff244D73),
                                                      ),
                                                    ),
                                                    SizedBox(width: 6),
                                                    SvgPicture.asset(
                                                      "assets/img/nextdrawer.svg",
                                                      height: 12,
                                                      width: 10,
                                                    ),
                                                  ],
                                                )),
                                          ]),
                                    ),
                                    subCatLayout(index),
                                    SizedBox(
                                      height: Dim().d2,
                                    ),
                                  ],
                                );
                              }),
                          SizedBox(
                            height: 8,
                          ),
                          bannerlist.length > 2
                              ? Container(
                                  child: Image.network(
                                      '${bannerlist[2]['image_path'].toString()}'),
                                )
                              : Container(),
                          if (imageSliders.isEmpty)
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: sliderwidget(),
                            ),
                          SizedBox(
                            height: 8,
                          )
                        ],
                      ),
                    ]),
                  ),
                ),
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  // void _refreshData() async {
  //   // final db = DatabaseHelper.instance;
  //   dynamic data = await db.queryAllRows();
  //   setState(() {
  //     addToCart = data;
  //   });
  //   print('ktg${addToCart}');
  // }

  getLocation() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sID = sp.getString("user_id");
    if (sp.getString('lat') == null) {
      STM().redirect2page(context, const MyLocation());
    }
    double lat = double.parse(sp.getString('lat').toString());
    double lng = double.parse(sp.getString('lng').toString());
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
    setState(() {
      Placemark placeMark = placemarks[0];
      city = placeMark.subLocality;
      Pincode = placeMark.postalCode;
      sp.setString('pincode', Pincode.toString());
      getHomePageData(pincode: Pincode);
      print(city);
      print(Pincode);
    });
  }

  void _modalBottomSheetMenu() {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.6,
            color: Colors.transparent, //could change this to Color(0xFF737373),
            //so you don't have to change MaterialApp canvasColor
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(10.0),
                      topRight: const Radius.circular(10.0))),
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    SvgPicture.asset(
                      height: 200,
                      'assets/img/location2.svg',
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Text(
                      'Enable Location',
                      style: Sty().largeText.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            color: Color(0xff065197),
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 16),
                    //   child: Text(
                    //     "We'll need your location to give you the best possible eye contact matching experience",
                    //     textAlign: TextAlign.center,
                    //     style: Sty().smallText.copyWith(
                    //         height: 1.5, fontSize: 14, fontWeight: FontWeight.w400),
                    //   ),
                    // ),
                    const SizedBox(
                      height: 20,
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
                            // permissionHandle();
                          },
                          child: Center(
                            child: Text(
                              'Get Current Location',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                        )),
                    // SizedBox(
                    //   height: 65,
                    //   width: 370,
                    //   child: ElevatedButton(
                    //       onPressed: () {
                    //         permissionHandle();
                    //       },
                    //       style: ElevatedButton.styleFrom(
                    //           backgroundColor: Clr().primaryColor,
                    //           shape: RoundedRectangleBorder(
                    //               borderRadius: BorderRadius.circular(15))),
                    //       child: Text(
                    //         'Get Current Location',
                    //         style: Sty().largeText.copyWith(
                    //             color: Clr().white,
                    //             fontWeight: FontWeight.w600,
                    //             fontSize: 16),
                    //       )),
                    // ),
                    SizedBox(
                      height: Dim().d28,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 45,
                      child: ElevatedButton(
                          onPressed: () {
                            // STM().redirect2page(ctx, CustomSearchScaffold(widget.Gmapkey, 'home'));
                          },
                          style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Clr().white,
                              shape: RoundedRectangleBorder(
                                  side: BorderSide(color: Clr().primaryColor),
                                  borderRadius: BorderRadius.circular(45))),
                          child: Text(
                            'Enter Location Manually',
                            style: Sty().largeText.copyWith(
                                color: Clr().black,
                                fontWeight: FontWeight.w600,
                                fontSize: 16),
                          )),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

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
  addItem(index) async {
    var data = await Store.getItems();
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
    counter++;
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
        setState(() {
          addToCart = data;
        });
      });
    }
  }

  showoutOfStock(bool bool, bool bool2, isEmpty) {
    return bool && isEmpty
        ? Flex(direction: Axis.horizontal, children: [
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  // padding: EdgeInsets.only(left:80, right:80),
                  width: double.infinity,
                  height: 20,
                  color: primary(),
                  child: const Center(
                      child: Text(
                    "Out of Stock",
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  )),
                ),
              ),
            ),
          ])
        : Container();
  }

  // Widget itemLayout(v, BuildContext context, list) {
  //   int position =
  //       addToCart.indexWhere((element) => element['medicine_id'] == v['ID']);
  //   if (v['variant'].isNotEmpty) {
  //     qualityname = v['variant'][0]['weight'].toString();
  //     // finalPre = v
  //     // ['variant'][0]
  //     // ['final_price']
  //     //     .toString();
  //     // ActualPri = v
  //     // ['variant'][0]
  //     // ['actual_price']
  //     //     .toString();
  //     // dropdownValue = v
  //     // ['variant'][0]['weight']
  //     //     .toString();
  //     varientid = v['variant'][0]['ID'].toString();
  //     varientQty = v['variant'][0]['quantity'].toString();
  //   } else {
  //     finalPre = v['final_price'].toString();
  //     ActualPri = v['actual_price'].toString();
  //     mainId = v['ID'].toString();
  //   }
  //   return StatefulBuilder(builder: (context, setState) {
  //     return Container(
  //       margin: EdgeInsets.all(
  //         Dim().d4,
  //       ),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.spaceAround,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           if (v['discount'] != '0')
  //             Container(
  //               height: Dim().d32,
  //               width: Dim().d72,
  //               decoration: BoxDecoration(
  //                   borderRadius: BorderRadius.only(
  //                       topLeft: Radius.circular(Dim().d12),
  //                       bottomRight: Radius.circular(Dim().d20)),
  //                   color: Color(0xffFF7534)),
  //               child: Center(
  //                 child: Text(
  //                   v['discount'] + "% off",
  //                   style: const TextStyle(color: Colors.white),
  //                 ),
  //               ),
  //             ),
  //           Center(
  //             child: Container(
  //               padding: const EdgeInsets.only(
  //                 top: 10,
  //                 bottom: 10,
  //               ),
  //               decoration: BoxDecoration(
  //                 border: Border.all(width: 1, color: const Color(0xffE5F3FF)),
  //                 borderRadius: BorderRadius.circular(10),
  //                 color: const Color(0xffE5F3FF),
  //               ),
  //               child: Stack(
  //                 fit: StackFit.loose,
  //                 children: [
  //                   CachedNetworkImage(
  //                     imageUrl: v['images'].isNotEmpty
  //                         ? v['images'][0]['img_product']
  //                         : '',
  //                     placeholder: (context, url) =>
  //                         Image.asset("assets/img/logo (6).png"),
  //                     errorWidget: (context, url, error) =>
  //                         Image.asset("assets/img/logo (6).png"),
  //                     width: 110,
  //                     height: 60,
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //           Html(
  //             data: '${v['name']} ${qualityname == null ? '' : qualityname}',
  //             style: {
  //               "*": Style(
  //                 maxLines: 2,
  //                 textOverflow: TextOverflow.ellipsis,
  //                 textAlign: TextAlign.left,
  //                 fontSize: FontSize(14),
  //                 color: Clr().primaryColor,
  //                 fontWeight: FontWeight.w600,
  //                 fontFamily: 'Opensans',
  //               )
  //             },
  //           ),
  //           if (v['variant'].isNotEmpty)
  //             DropdownButtonHideUnderline(
  //                 child: DropdownButtonFormField<dynamic>(
  //               padding: EdgeInsets.symmetric(horizontal: Dim().d12),
  //               decoration: Sty().TextFormFieldOutlineDarkStyle.copyWith(
  //                     hintText: dropdownValue[index1].toString() ?? 'Grams',
  //                     hintStyle: Sty().mediumText.copyWith(
  //                           color: dropdownValue == null
  //                               ? Clr().hintColor
  //                               : Clr().black.withOpacity(0.7),
  //                         ),
  //                   ),
  //               value: dropdownValue,
  //               items: v['variant'].map<DropdownMenuItem<dynamic>>((value) {
  //                 return DropdownMenuItem<dynamic>(
  //                   value: value['weight'],
  //                   child: Text(
  //                     value['weight'],
  //                     style: Sty().mediumText.copyWith(
  //                           color: Color(0xff244D73),
  //                           fontSize: 13,
  //                           fontWeight: FontWeight.w400,
  //                         ),
  //                   ),
  //                 );
  //               }).toList(),
  //               onChanged: (Object? value) {
  //                 setState(() {
  //                   dropdownValue = value.toString();
  //                   position = v['variant'].indexWhere(
  //                       (e) => e['weight'].toString() == value.toString());
  //                   varientid = v['variant'][position]['ID'].toString();
  //                   qualityname = v['variant'][position]['weight'];
  //                   finalPre = v['variant'][position]['final_price'].toString();
  //                   print(finalPre);
  //                   ActualPri =
  //                       v['variant'][position]['actual_price'].toString();
  //                   varientQty = v['variant'][position]['quantity'].toString();
  //                   // positionOfCart = addToCart.indexWhere((element) =>
  //                   //     element['varientid'].toString() ==
  //                   //     v['variant'][position]['ID'].toString());
  //                 });
  //               },
  //             )),
  //           Padding(
  //             padding: const EdgeInsets.only(left: 8.0),
  //             child: priceStrikeWidget('${ActualPri ?? v['actual_price']}'),
  //           ),
  //           // if(v['qty'] == 0)
  //           //   Padding(
  //           //     padding:  EdgeInsets.only(left: 16.0,bottom: 4),
  //           //     child: Text('Out of Stock',style: TextStyle(color: Colors.red),),
  //           //   ),
  //           Padding(
  //             padding: const EdgeInsets.symmetric(horizontal: 8),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Text(
  //                   '₹ ${finalPre ?? v['final_price']}',
  //                   style: TextStyle(
  //                     fontSize: Dim().d16,
  //                     color: Clr().textSecondaryColor,
  //                     fontWeight: FontWeight.w500,
  //                   ),
  //                 ),
  //                 // v['is_exist']
  //                 // addToCartLayout(v, v['ID'], varientid, list, dropdownValue,position),
  //                 addToCart
  //                         .map((e) => e['varientid'] == 0
  //                             ? e['medicine_id'].toString()
  //                             : e['varientid'].toString())
  //                         .contains(varientid == null
  //                             ? v.toString()
  //                             : varientid.toString())
  //                     ? Container(
  //                         height: Dim().d32,
  //                         decoration: BoxDecoration(
  //                           borderRadius: BorderRadius.circular(Dim().d8),
  //                           gradient: LinearGradient(
  //                             begin: Alignment.topLeft,
  //                             end: Alignment.bottomLeft,
  //                             colors: <Color>[
  //                               Color(0xff1964aa),
  //                               Color(0xff5AA6EC),
  //                             ],
  //                           ),
  //                         ),
  //                         child: Row(
  //                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                           children: [
  //                             SizedBox(
  //                               width: Dim().d8,
  //                             ),
  //                             InkWell(
  //                               onTap: () async {
  //                                 // positionOfCart = v['variant'].isEmpty ?  addToCart.indexWhere((element) =>
  //                                 // element['medicine_id'].toString() ==
  //                                 //     v['ID'].toString()) :  addToCart.indexWhere((element) =>
  //                                 // element['varientid'].toString() ==
  //                                 //     v['variant'][position]['ID'].toString());
  //                                 var data = await Store.getItems();
  //                                 int counter = addToCart[position]['counter'];
  //                                 var acutal;
  //                                 try {
  //                                   acutal = double.parse(addToCart[position]
  //                                           ['actualPrice']
  //                                       .toString());
  //                                 } catch (_) {
  //                                   acutal = int.parse(addToCart[position]
  //                                           ['actualPrice']
  //                                       .toString());
  //                                 }
  //                                 ;
  //                                 var price;
  //                                 try {
  //                                   price = double.parse(addToCart[position]
  //                                           ['price']
  //                                       .toString());
  //                                 } catch (_) {
  //                                   price = int.parse(addToCart[position]
  //                                           ['price']
  //                                       .toString());
  //                                 }
  //                                 ;
  //                                 counter == 1
  //                                     ? Store.deleteItem(
  //                                         addToCart[position]['medicine_id'],
  //                                         addToCart[position]['varientid'],
  //                                       )
  //                                     : counter = 0;
  //                                 var newPrice = price - acutal;
  //                                 if (counter > 0) {
  //                                   _updateItem(
  //                                           addToCart[position]['medicine_id'],
  //                                           addToCart[position]['varientid'],
  //                                           addToCart[position]['name']
  //                                               .toString(),
  //                                           addToCart[position]['image']
  //                                               .toString(),
  //                                           newPrice.toString(),
  //                                           addToCart[position]['actualPrice']
  //                                               .toString(),
  //                                           addToCart[position]['description']
  //                                               .toString(),
  //                                           counter)
  //                                       .then((value) {
  //                                     newPrice = 0;
  //                                     counter = 0;
  //                                     setState(() {
  //                                       addToCart = data;
  //                                     });
  //                                   });
  //                                 }
  //                               },
  //                               child: Icon(Icons.remove, color: Clr().white),
  //                             ),
  //                             SizedBox(
  //                               width: Dim().d8,
  //                             ),
  //                             Text(
  //                                 '${position == -1 ? '' : addToCart[position]['counter']}',
  //                                 style: Sty()
  //                                     .smallText
  //                                     .copyWith(color: Clr().white)),
  //                             SizedBox(
  //                               width: Dim().d8,
  //                             ),
  //                             InkWell(
  //                               onTap: () async {
  //                                 // positionOfCart = v['variant'].isEmpty ?  addToCart.indexWhere((element) =>
  //                                 // element['medicine_id'].toString() ==
  //                                 //     v['ID'].toString()) :  addToCart.indexWhere((element) =>
  //                                 //     element['varientid'].toString() ==
  //                                 //     v['variant'][position]['ID'].toString());
  //
  //                                 var data = await Store.getItems();
  //                                 int counter = addToCart[position]['counter'];
  //                                 var acutal;
  //                                 try {
  //                                   acutal = double.parse(addToCart[position]
  //                                           ['actualPrice']
  //                                       .toString());
  //                                 } catch (_) {
  //                                   acutal = int.parse(addToCart[position]
  //                                           ['actualPrice']
  //                                       .toString());
  //                                 }
  //                                 ;
  //                                 var price;
  //                                 try {
  //                                   price = double.parse(addToCart[position]
  //                                           ['price']
  //                                       .toString());
  //                                 } catch (_) {
  //                                   price = int.parse(addToCart[position]
  //                                           ['price']
  //                                       .toString());
  //                                 }
  //                                 ;
  //                                 counter++;
  //                                 var newPrice = price + acutal;
  //                                 if (counter > 0) {
  //                                   _updateItem(
  //                                           addToCart[position]['medicine_id'],
  //                                           addToCart[position]['varientid'],
  //                                           addToCart[position]['name']
  //                                               .toString(),
  //                                           addToCart[position]['image']
  //                                               .toString(),
  //                                           newPrice.toString(),
  //                                           addToCart[position]['actualPrice']
  //                                               .toString(),
  //                                           addToCart[position]['description']
  //                                               .toString(),
  //                                           counter)
  //                                       .then((value) {
  //                                     newPrice = 0;
  //                                     counter = 0;
  //                                     setState(() {
  //                                       addToCart = data;
  //                                     });
  //                                   });
  //                                 }
  //                               },
  //                               child: Icon(Icons.add, color: Clr().white),
  //                             ),
  //                             SizedBox(
  //                               width: Dim().d8,
  //                             ),
  //                           ],
  //                         ),
  //                       )
  //                     : InkWell(
  //                         onTap: () {
  //                           // QfPosition = dropdownValue == null ? int.parse(v['ID']) : int.parse(varientid.toString());
  //                           // for(int a = 0; a < list.length; a++){
  //                           //   if(int.parse(list[a]['ID'].toString()) == QfPosition){
  //                           //     cartPosition = int.parse(list[a]['ID'].toString());
  //                           //     break;
  //                           //   }
  //                           // }
  //                           setState(() {
  //                             _refreshData();
  //                             v['qty'] == "0"
  //                                 ? STM().displayToast(v['qty'].toString())
  //                                 : _addItem(
  //                                         int.parse(v['ID'].toString()),
  //                                         varientid == null
  //                                             ? 0
  //                                             : int.parse(varientid.toString()),
  //                                         '${v['name']} ${qualityname ?? ''}',
  //                                         v['images'][0]['img_product'],
  //                                         finalPre ??
  //                                             v['final_price'].toString(),
  //                                         finalPre ??
  //                                             v['final_price'].toString(),
  //                                         dropdownValue ?? '',
  //                                         1)
  //                                     .then((value) async {
  //                                     setState(() {
  //                                       _refreshData();
  //                                       print(addToCart);
  //                                     });
  //                                   });
  //                           });
  //                         },
  //                         child: Container(
  //                           decoration: BoxDecoration(
  //                             borderRadius: BorderRadius.circular(Dim().d8),
  //                             gradient: LinearGradient(
  //                               begin: Alignment.topLeft,
  //                               end: Alignment.bottomLeft,
  //                               colors: <Color>[
  //                                 Color(0xff1964aa),
  //                                 Color(0xff5AA6EC),
  //                               ],
  //                             ),
  //                           ),
  //                           child: Padding(
  //                             padding: EdgeInsets.symmetric(
  //                                 horizontal: Dim().d20, vertical: Dim().d8),
  //                             child: Center(
  //                                 child: Text('+',
  //                                     style: Sty().smallText.copyWith(
  //                                         fontSize: Dim().d20,
  //                                         color: Clr().white))),
  //                           ),
  //                         ),
  //                       )
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //       // InkWell(
  //       //   onTap: () {
  //       //     Navigator.of(context).push(
  //       //       MaterialPageRoute(
  //       //         builder: (context) => ProductDetail(
  //       //           productID: v['ID'].toString(),
  //       //         ),
  //       //       ),
  //       //     );
  //       //     // .then((_) => updateBadgeCount());
  //       //   },
  //       //   child: Stack(
  //       //     clipBehavior: Clip.none,
  //       //     children: [
  //       //       Opacity(
  //       //         opacity: v['qty'] == 0 ? 0.5 : 1,
  //       //         child: Container(
  //       //           decoration: BoxDecoration(
  //       //             boxShadow: [
  //       //               BoxShadow(
  //       //                 color: Clr().borderColor.withOpacity(0.5),
  //       //                 spreadRadius: 0.1,
  //       //                 blurRadius: 8,
  //       //                 offset: const Offset(0, 0),
  //       //               ),
  //       //             ],
  //       //           ),
  //       //           child: Card(
  //       //             elevation: 0,
  //       //             margin: const EdgeInsets.only(right: 2),
  //       //             shape: RoundedRectangleBorder(
  //       //               borderRadius: BorderRadius.circular(10),
  //       //               side: BorderSide(
  //       //                 color: Clr().borderColor,
  //       //                 width: 0.2,
  //       //               ),
  //       //             ),
  //       //             child: Column(
  //       //               mainAxisAlignment: MainAxisAlignment.spaceAround,
  //       //               crossAxisAlignment: CrossAxisAlignment.start,
  //       //               children: [
  //       //                 if (v['discount'] != '0')
  //       //                   Container(
  //       //                     height: Dim().d32,
  //       //                     width: Dim().d72,
  //       //                     decoration: BoxDecoration(
  //       //                         borderRadius: BorderRadius.only(
  //       //                             topLeft: Radius.circular(Dim().d12),
  //       //                             bottomRight: Radius.circular(Dim().d20)),
  //       //                         color: Color(0xffFF7534)),
  //       //                     child: Center(
  //       //                       child: Text(
  //       //                         v['discount'] + "% off",
  //       //                         style: const TextStyle(color: Colors.white),
  //       //                       ),
  //       //                     ),
  //       //                   ),
  //       //                 Center(
  //       //                   child: Container(
  //       //                     padding: const EdgeInsets.only(
  //       //                       top: 10,
  //       //                       bottom: 10,
  //       //                     ),
  //       //                     decoration: BoxDecoration(
  //       //                       border: Border.all(
  //       //                           width: 1, color: const Color(0xffE5F3FF)),
  //       //                       borderRadius: BorderRadius.circular(10),
  //       //                       color: const Color(0xffE5F3FF),
  //       //                     ),
  //       //                     child: Stack(
  //       //                       fit: StackFit.loose,
  //       //                       children: [
  //       //                         CachedNetworkImage(
  //       //                           imageUrl: v['images'].isNotEmpty
  //       //                               ? v['images'][0]['img_product']
  //       //                               : '',
  //       //                           placeholder: (context, url) =>
  //       //                               Image.asset("assets/img/logo (6).png"),
  //       //                           errorWidget: (context, url, error) =>
  //       //                               Image.asset("assets/img/logo (6).png"),
  //       //                           width: 110,
  //       //                           height: 60,
  //       //                         ),
  //       //                       ],
  //       //                     ),
  //       //                   ),
  //       //                 ),
  //       //                 Html(
  //       //                   data:
  //       //                   '${v['name']} ${qualityname == null ? '' : qualityname}',
  //       //                   style: {
  //       //                     "*": Style(
  //       //                       maxLines: 2,
  //       //                       textOverflow: TextOverflow.ellipsis,
  //       //                       textAlign: TextAlign.left,
  //       //                       fontSize: FontSize(14),
  //       //                       color: Clr().primaryColor,
  //       //                       fontWeight: FontWeight.w600,
  //       //                       fontFamily: 'Opensans',
  //       //                     )
  //       //                   },
  //       //                 ),
  //       //                 if (v['variant'].isNotEmpty)
  //       //                   Container(
  //       //                     margin: const EdgeInsets.only(left: 12, right: 12),
  //       //                     height: 30,
  //       //                     width: 110,
  //       //                     padding: const EdgeInsets.only(right: 10, left: 10),
  //       //                     decoration: BoxDecoration(
  //       //                         color: Colors.white,
  //       //                         borderRadius: BorderRadius.circular(5),
  //       //                         border: Border.all(
  //       //                             color: const Color(0xff5AA6EC)
  //       //                                 .withOpacity(0.5))),
  //       //                     child: DropdownButtonHideUnderline(
  //       //                       child: DropdownButton<dynamic>(
  //       //                         hint: Text(
  //       //                           dropdownValue ?? 'grams',
  //       //                           style: Sty().mediumText.copyWith(
  //       //                             color: Clr().black,
  //       //                           ),
  //       //                         ),
  //       //                         isExpanded: true,
  //       //                         icon: const Icon(Icons.keyboard_arrow_down),
  //       //                         style: Sty().mediumText,
  //       //                         onChanged: (value) {
  //       //                           setState(() {
  //       //                             dropdownValue = value.toString();
  //       //                             position = v['variant'].indexWhere((e) =>
  //       //                             e['weight'].toString() ==
  //       //                                 value.toString());
  //       //                             varientid =
  //       //                                 v['variant'][position]['ID'].toString();
  //       //                             qualityname =
  //       //                             v['variant'][position]['weight'];
  //       //                             finalPre = v['variant'][position]
  //       //                             ['final_price']
  //       //                                 .toString();
  //       //                             ActualPri = v['variant'][position]
  //       //                             ['actual_price']
  //       //                                 .toString();
  //       //                             varientQty = v['variant'][position]
  //       //                             ['quantity']
  //       //                                 .toString();
  //       //                             positionOfCart = addToCart.indexWhere(
  //       //                                     (element) =>
  //       //                                 element['varientid'].toString() ==
  //       //                                     v['variant'][position]['ID']
  //       //                                         .toString());
  //       //                           });
  //       //                         },
  //       //                         items: v['variant']
  //       //                             .map<DropdownMenuItem<dynamic>>((value) {
  //       //                           return DropdownMenuItem<dynamic>(
  //       //                             value: value['weight'],
  //       //                             child: Text(
  //       //                               value['weight'],
  //       //                               style: Sty().mediumText.copyWith(
  //       //                                 color: Color(0xff244D73),
  //       //                                 fontSize: 13,
  //       //                                 fontWeight: FontWeight.w400,
  //       //                               ),
  //       //                             ),
  //       //                           );
  //       //                         }).toList(),
  //       //                       ),
  //       //                     ),
  //       //                   ),
  //       //                 // check == 0
  //       //                 //     ? Padding(
  //       //                 //         padding: EdgeInsets.only(left: 16.0),
  //       //                 //         child: Text(
  //       //                 //           'Out of Stock',
  //       //                 //           style: TextStyle(color: Colors.red),
  //       //                 //         ),
  //       //                 //       )
  //       //                 //     : Container(),
  //       //                 // if (v['variant'].isEmpty)
  //       //                 //   SizedBox(
  //       //                 //     height: 30,
  //       //                 //   ),
  //       //
  //       //                 // // if (v['discount'].toString() == "0")
  //       //                 //   SizedBox(
  //       //                 //     height: Dim().d8,
  //       //                 //   ),
  //       //                 // if (v['discount'].toString() != "0")
  //       //                 Padding(
  //       //                   padding: const EdgeInsets.only(left: 8.0),
  //       //                   child: priceStrikeWidget('${ActualPri}'),
  //       //                 ),
  //       //                 // if(v['qty'] == 0)
  //       //                 //   Padding(
  //       //                 //     padding:  EdgeInsets.only(left: 16.0,bottom: 4),
  //       //                 //     child: Text('Out of Stock',style: TextStyle(color: Colors.red),),
  //       //                 //   ),
  //       //
  //       //                 Padding(
  //       //                   padding: const EdgeInsets.symmetric(horizontal: 8),
  //       //                   child: Row(
  //       //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       //                     children: [
  //       //                       Text(
  //       //                         '₹ ${finalPre}',
  //       //                         style: TextStyle(
  //       //                           fontSize: Dim().d16,
  //       //                           color: Clr().textSecondaryColor,
  //       //                           fontWeight: FontWeight.w500,
  //       //                         ),
  //       //                       ),
  //       //                       // v['is_exist']
  //       //                       addToCart
  //       //                           .map((e) => e['varientid'] == 0
  //       //                           ? e['medicine_id'].toString()
  //       //                           : e['varientid'].toString())
  //       //                           .contains(v['variant'].isEmpty
  //       //                           ? v['ID'].toString()
  //       //                           : varientid.toString())
  //       //                           ? Container(
  //       //                         height: Dim().d32,
  //       //                         decoration: BoxDecoration(
  //       //                           borderRadius:
  //       //                           BorderRadius.circular(Dim().d8),
  //       //                           gradient: LinearGradient(
  //       //                             begin: Alignment.topLeft,
  //       //                             end: Alignment.bottomLeft,
  //       //                             colors: <Color>[
  //       //                               Color(0xff1964aa),
  //       //                               Color(0xff5AA6EC),
  //       //                             ],
  //       //                           ),
  //       //                         ),
  //       //                         child: Row(
  //       //                           mainAxisAlignment:
  //       //                           MainAxisAlignment.spaceEvenly,
  //       //                           children: [
  //       //                             SizedBox(
  //       //                               width: Dim().d8,
  //       //                             ),
  //       //                             InkWell(
  //       //                               onTap: () {
  //       //                                 removeItem(positionOfCart);
  //       //                               },
  //       //                               child: Icon(Icons.remove,
  //       //                                   color: Clr().white),
  //       //                             ),
  //       //                             SizedBox(
  //       //                               width: Dim().d8,
  //       //                             ),
  //       //                             Text(
  //       //                                 '${addToCart[positionOfCart!]['counter']}',
  //       //                                 style: Sty().smallText.copyWith(
  //       //                                     color: Clr().white)),
  //       //                             SizedBox(
  //       //                               width: Dim().d8,
  //       //                             ),
  //       //                             InkWell(
  //       //                               onTap: () {
  //       //                                 addItem(positionOfCart);
  //       //                               },
  //       //                               child: Icon(Icons.add,
  //       //                                   color: Clr().white),
  //       //                             ),
  //       //                             SizedBox(
  //       //                               width: Dim().d8,
  //       //                             ),
  //       //                           ],
  //       //                         ),
  //       //                       )
  //       //                           : InkWell(
  //       //                         onTap: () {
  //       //                           setState(() {
  //       //                             v['qty'] == 0 && v['variant'].isEmpty
  //       //                                 ? null
  //       //                                 : _addItem(
  //       //                                 int.parse(
  //       //                                     v['ID'].toString()),
  //       //                                 v['variant'].isEmpty
  //       //                                     ? 0
  //       //                                     : int.parse(varientid
  //       //                                     .toString()),
  //       //                                 '${v['name']} ${qualityname == null ? '' : qualityname}',
  //       //                                 v['images'][0]
  //       //                                 ['img_product'],
  //       //                                 finalPre,
  //       //                                 finalPre,
  //       //                                 v['variant'].isEmpty
  //       //                                     ? ''
  //       //                                     : dropdownValue,
  //       //                                 1)
  //       //                                 .then((value) {
  //       //                               _refreshData();
  //       //                             });
  //       //                           });
  //       //                         },
  //       //                         child: Container(
  //       //                           decoration: BoxDecoration(
  //       //                             borderRadius:
  //       //                             BorderRadius.circular(Dim().d8),
  //       //                             gradient: LinearGradient(
  //       //                               begin: Alignment.topLeft,
  //       //                               end: Alignment.bottomLeft,
  //       //                               colors: <Color>[
  //       //                                 Color(0xff1964aa),
  //       //                                 Color(0xff5AA6EC),
  //       //                               ],
  //       //                             ),
  //       //                           ),
  //       //                           child: Padding(
  //       //                             padding: EdgeInsets.symmetric(
  //       //                                 horizontal: Dim().d20,
  //       //                                 vertical: Dim().d8),
  //       //                             child: Center(
  //       //                                 child: Text('+',
  //       //                                     style: Sty()
  //       //                                         .smallText
  //       //                                         .copyWith(
  //       //                                         fontSize: Dim().d20,
  //       //                                         color: Clr().white))),
  //       //                           ),
  //       //                         ),
  //       //                       ),
  //       //                     ],
  //       //                   ),
  //       //                 ),
  //       //               ],
  //       //             ),
  //       //           ),
  //       //         ),
  //       //       ),
  //       //       // if (v['qty'] != 0 && v['discount'].toString() != 0)
  //       //       //   Positioned(
  //       //       //       top: 10,
  //       //       //       right: 11,
  //       //       //       child: Transform.scale(
  //       //       //         scaleX: -1.5,
  //       //       //         child: SvgPicture.asset(
  //       //       //           "assets/img/lable.svg",
  //       //       //           width: 25,
  //       //       //           height: 25,
  //       //       //           color: primary(),
  //       //       //         ),
  //       //       //       )),
  //       //       showoutOfStock(
  //       //           v['qty'] == 0, varientQty == 0, v['variant'].isEmpty),
  //       //     ],
  //       //   ),
  //       // ),
  //     );
  //   });
  // }

  Widget addToCartLayout(v, id, varientid, List list, dropdownvalue, position) {
    print('${id}addtocartLayout');
    return addToCart
            .map((e) => e['varientid'] == 0
                ? e['medicine_id'].toString()
                : e['varientid'].toString())
            .contains(varientid == null ? v.toString() : varientid.toString())
        ? Container(
            height: Dim().d32,
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: Dim().d8,
                ),
                InkWell(
                  onTap: () async {
                    // positionOfCart = v['variant'].isEmpty ?  addToCart.indexWhere((element) =>
                    // element['medicine_id'].toString() ==
                    //     v['ID'].toString()) :  addToCart.indexWhere((element) =>
                    // element['varientid'].toString() ==
                    //     v['variant'][position]['ID'].toString());
                    var data = await Store.getItems();
                    int counter = addToCart[position]['counter'];
                    var acutal;
                    try {
                      acutal = double.parse(
                          addToCart[position]['actualPrice'].toString());
                    } catch (_) {
                      acutal = int.parse(
                          addToCart[position]['actualPrice'].toString());
                    }
                    ;
                    var price;
                    try {
                      price =
                          double.parse(addToCart[position]['price'].toString());
                    } catch (_) {
                      price =
                          int.parse(addToCart[position]['price'].toString());
                    }
                    ;
                    counter == 1
                        ? Store.deleteItem(
                            addToCart[position]['medicine_id'],
                            addToCart[position]['varientid'],
                          )
                        : counter = 0;
                    var newPrice = price - acutal;
                    if (counter > 0) {
                      _updateItem(
                              addToCart[position]['medicine_id'],
                              addToCart[position]['varientid'],
                              addToCart[position]['name'].toString(),
                              addToCart[position]['image'].toString(),
                              newPrice.toString(),
                              addToCart[position]['actualPrice'].toString(),
                              addToCart[position]['description'].toString(),
                              counter)
                          .then((value) {
                        newPrice = 0;
                        counter = 0;
                        setState(() {
                          addToCart = data;
                        });
                      });
                    }
                  },
                  child: Icon(Icons.remove, color: Clr().white),
                ),
                SizedBox(
                  width: Dim().d8,
                ),
                Text('${position == -1 ? '' : addToCart[position]['counter']}',
                    style: Sty().smallText.copyWith(color: Clr().white)),
                SizedBox(
                  width: Dim().d8,
                ),
                InkWell(
                  onTap: () async {
                    // positionOfCart = v['variant'].isEmpty ?  addToCart.indexWhere((element) =>
                    // element['medicine_id'].toString() ==
                    //     v['ID'].toString()) :  addToCart.indexWhere((element) =>
                    //     element['varientid'].toString() ==
                    //     v['variant'][position]['ID'].toString());

                    var data = await Store.getItems();
                    int counter = addToCart[position]['counter'];
                    var acutal;
                    try {
                      acutal = double.parse(
                          addToCart[position]['actualPrice'].toString());
                    } catch (_) {
                      acutal = int.parse(
                          addToCart[position]['actualPrice'].toString());
                    }
                    ;
                    var price;
                    try {
                      price =
                          double.parse(addToCart[position]['price'].toString());
                    } catch (_) {
                      price =
                          int.parse(addToCart[position]['price'].toString());
                    }
                    ;
                    counter++;
                    var newPrice = price + acutal;
                    if (counter > 0) {
                      _updateItem(
                              addToCart[position]['medicine_id'],
                              addToCart[position]['varientid'],
                              addToCart[position]['name'].toString(),
                              addToCart[position]['image'].toString(),
                              newPrice.toString(),
                              addToCart[position]['actualPrice'].toString(),
                              addToCart[position]['description'].toString(),
                              counter)
                          .then((value) {
                        newPrice = 0;
                        counter = 0;
                        setState(() {
                          addToCart = data;
                        });
                      });
                    }
                  },
                  child: Icon(Icons.add, color: Clr().white),
                ),
                SizedBox(
                  width: Dim().d8,
                ),
              ],
            ),
          )
        : InkWell(
            onTap: () {
              // QfPosition = dropdownValue == null ? int.parse(v['ID']) : int.parse(varientid.toString());
              // for(int a = 0; a < list.length; a++){
              //   if(int.parse(list[a]['ID'].toString()) == QfPosition){
              //     cartPosition = int.parse(list[a]['ID'].toString());
              //     break;
              //   }
              // }
              setState(() {
                _refreshData();
                v['qty'] == null
                    ? STM().displayToast(v['qty'].toString())
                    : _addItem(
                            int.parse(v['ID'].toString()),
                            varientid == null
                                ? 0
                                : int.parse(varientid.toString()),
                            '${v['name']} ${qualityname ?? ''}',
                            v['images'][0]['img_product'],
                            finalPre ?? v['final_price'].toString(),
                            finalPre ?? v['final_price'].toString(),
                            dropdownValue ?? '',
                            1)
                        .then((value) async {
                        setState(() {
                          _refreshData();
                          print(addToCart);
                        });
                      });
              });
            },
            child: Container(
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
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: Dim().d20, vertical: Dim().d8),
                child: Center(
                    child: Text('+',
                        style: Sty().smallText.copyWith(
                            fontSize: Dim().d20, color: Clr().white))),
              ),
            ),
          );
  }

  Widget subCatLayout(int index) {
    return SizedBox(
      height: MediaQuery.of(ctx).size.height / 3.6,
      child: ListView.builder(
        shrinkWrap: true,
        itemExtent: 160.0,
        padding: EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categorylist[index]['products'].length,
        itemBuilder: (context, index1) {
          var v = categorylist[index]['products'][index1];
          return Container(
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
                                    InkWell(
                                      onTap: () {
                                        if (v['qty'] != null)
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ProductDetail(
                                                productID: v['ID'].toString(),
                                                type: v['variant'].isEmpty
                                                    ? 'No'
                                                    : 'Yes',
                                              ),
                                            ),
                                          );
                                      },
                                      child: CachedNetworkImage(
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
                          commonDropdown(v: v, type: 'Home'),
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
                                          '₹ ${v['final_price']}',
                                          style: TextStyle(
                                            fontSize: Dim().d12,
                                            color: Clr().textSecondaryColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                     Expanded(flex: 2,child:  addtoCartLayout(v:v),),
                                    ],
                                  ),
                                ),
                        SizedBox(height: Dim().d2),
                      ],
                    ),
                  ),
                ),
                if (v['qty'] != null)
                  v['discount'].toString() != '0'
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
          );
        },
      ),
    );
  }

  dropdownLayout(v, index) {
    for (int a = 0; a < v['variant'].length; a++) {
      dropdownValue.add('');
    }
    return Container(
      margin: const EdgeInsets.only(left: 12, right: 12),
      height: 30,
      width: 110,
      padding: const EdgeInsets.only(right: 10, left: 10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: const Color(0xff5AA6EC).withOpacity(0.5))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<dynamic>(
          hint: Text(
            dropdownValue[index] ?? 'grams',
            style: Sty().mediumText.copyWith(
                  color: Clr().black,
                ),
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          style: Sty().mediumText,
          onChanged: (value) {
            setState(() {
              dropdownValue[index] = value;
              int position1 = v['variant'].indexWhere(
                  (e) => e['weight'].toString() == value.toString());
              varientid = v['variant'][position1]['ID'].toString();
              print(varientid);
              print(addToCart
                  .map((e) => e['varientid'] != 0
                      ? e['varientid'].toString()
                      : e['medicine_id'].toString())
                  .contains(varientid));
              qualityname = v['variant'][position1]['weight'];
              finalPre[index] =
                  v['variant'][position1]['final_price'].toString();
              ActualPri[index] =
                  v['variant'][position1]['actual_price'].toString();
              varientQty = v['variant'][position1]['quantity'].toString();
            });
          },
          items: v['variant'].map<DropdownMenuItem<dynamic>>((value) {
            return DropdownMenuItem<dynamic>(
              value: value['weight'],
              child: Text(
                value['weight'],
                style: Sty().mediumText.copyWith(
                      color: Color(0xff244D73),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }


}

class dropDownLayout extends StatefulWidget {
  final v;
  final List list;
  final index, varientQty, qualityname, varientid;

  const dropDownLayout({
    super.key,
    this.v,
    required this.list,
    this.index,
    this.varientid,
    this.qualityname,
    this.varientQty,
  });

  @override
  State<dropDownLayout> createState() => _dropDownLayoutState();
}

class _dropDownLayoutState extends State<dropDownLayout> {
  @override
  Widget build(BuildContext context) {
    var v = widget.v;
    int index = widget.index;
    return Container(
      margin: const EdgeInsets.only(left: 12, right: 12),
      height: 30,
      width: 110,
      padding: const EdgeInsets.only(right: 10, left: 10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: const Color(0xff5AA6EC).withOpacity(0.5))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<dynamic>(
          hint: Text(
            widget.list[index] ?? 'grams',
            style: Sty().mediumText.copyWith(
                  color: Clr().black,
                ),
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          style: Sty().mediumText,
          onChanged: (value) {
            setState(() {
              widget.list[index] = value;
              // int position1 = v['variant'].indexWhere((e) =>
              // e['weight'].toString() == value.toString());
              // widget.varientid =
              //     v['variant'][position1]['ID'].toString();
              // print(widget.varientid);
              // print(addToCart
              //     .map((e) => e['varientid'] != 0
              //     ? e['varientid'].toString()
              //     : e['medicine_id'].toString())
              //     .contains(widget.varientid));
              // widget.qualityname = v['variant'][position1]['weight'];
              // widget.finalPre[index] = v['variant'][position1]['final_price']
              //     .toString();
              // widget.ActualPri[index] = v['variant'][position1]
              // ['actual_price']
              //     .toString();
              // widget.varientQty = v['variant'][position1]['quantity']
              //     .toString();
            });
          },
          items: v['variant'].map<DropdownMenuItem<dynamic>>((value) {
            return DropdownMenuItem<dynamic>(
              value: value['weight'],
              child: Text(
                value['weight'],
                style: Sty().mediumText.copyWith(
                      color: Color(0xff244D73),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
