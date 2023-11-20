// Crearte category based interface...
import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qf/appbar_gradientlook.dart';
import 'package:qf/cart_page_old.dart';
import 'package:qf/colors.dart';
import 'package:qf/globalurls.dart';

import 'package:qf/sqliteop.dart';
import 'package:qf/sub_product_category_screen.dart';
import 'package:qf/values/colors.dart';
import 'package:qf/values/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bottom_navigation/bottom_navigation.dart';

class CategoriesScreen extends StatefulWidget {

  const CategoriesScreen({Key? key,}) : super(key: key);


  @override
  State<CategoriesScreen> createState() => CategoriesScreenState();
}

class CategoriesScreenState extends State<CategoriesScreen> {
  late BuildContext ctx;
  List<Widget> leftCategories = [];
  List<Widget> rightSubCategories = [];
  List<bool> categoriesSelectedBoolean = [];
  bool isloaded = false;
  // String sPincode;


  Widget priceWidget(String amount) {
    return Text("₹" + amount.toString(),
        style: TextStyle(fontSize: 14, color: primary()));
  }

  Widget priceStrikeWidget(String amount) {
    return Container(
        margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
        child: Text("₹" + amount.toString(),
            style: TextStyle(
                decoration: TextDecoration.lineThrough,
                fontSize: 14,
                color: Colors.grey)));
  }



  Widget miniProductCard(String imagePath, String title, String categoryID, String subCategoryID, int selectedIndex, String categoryTitle) {
    return InkWell(
      splashColor: Color.fromARGB(255, 255, 220, 187),
      onTap: () {
        print("CATEGORY ID: " + categoryID + " SUBCATEGORY ID: " + subCategoryID + " SELECTED INDEX: " + selectedIndex.toString());
        Navigator.push(context, MaterialPageRoute(builder: (context) => SubProductCategoriesScreen(sCategory: categoryID, sSubCategory: subCategoryID, selectedIndex: selectedIndex, sTitle : categoryTitle, spincode: '',  ))).then((_) { print("Cart update called");});
      },
      child: Stack(children: [
        // Container
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Clr().borderColor.withOpacity(0.5),
                    spreadRadius: 0.1,
                    blurRadius: 8,
                    offset: Offset(0, 0), // changes position of shadow
                  ),
                ],
              ),
              child: Card(
                elevation: 0,
                margin: EdgeInsets.only(right:2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Clr().borderColor,width: 0.2)),
                child: Column(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top:8,right: 8,left: 8),
                          child: Container(
                              padding: EdgeInsets.only(top: 10, bottom: 10),
                              // padding: const EdgeInsets.only(top: 25, bottom: 25),
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
                                    imageUrl: imagePath,
                                    placeholder: (context, url) =>
                                        Image.asset("assets/img/logo (6).png"),
                                    errorWidget: (context, url, error) =>
                                        Image.asset("assets/img/logo (6).png"),
                                    width: 110,
                                    height: 80,
                                  ),
                                ],
                              )

                              // Image.network(
                              //   // "https://www.seekpng.com/png/full/62-623622_bag-of-chips-png-lays-potato-chips.png",
                              //   imagePath,
                              //   width: 100,
                              //   height: 80,
                              // )
                              ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Html(data: title, style: {
                      "*" : Style(
                      textAlign: TextAlign.left,
                        textOverflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        fontSize: FontSize(14),
                        color: Clr().primaryColor,fontWeight:FontWeight.w600 ,
                        fontFamily: 'Opensans'
                      )
                    },)

                        // Text(
                        //   title,
                        //   textAlign: TextAlign.left,
                        // ),
                      ),
                      // Row(
                      //   children: [
                      //     Text("500g - 600g", style: TextStyle(color: Colors.grey))
                      //   ],
                      // ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [Row(
                      //     children: [
                      //       priceWidget("100"),
                      //       priceStrikeWidget("100"),
                      //     ],
                      //   ),
                      //   InkWell(onTap: (){}, child: Container(child: Text("Add", style: TextStyle(color: Colors.white),), padding: EdgeInsets.only(left: 13, right: 13, top: 5, bottom: 5), decoration: BoxDecoration(color: primary(), borderRadius: BorderRadius.circular(3)),)),

                      //   ]
                      // ),
                    ]),
              )),
        ),
        // Tag SVG
      ]),
    );
  }

  //   Widget stackedProductInCategory(String imagePath, String title){
  //   return Stack(children: [
  //                 Container(
  //                     child: Center(child: miniProductCard(imagePath, title)),
  //                     decoration: BoxDecoration(
  //                         border: Border.all(width: 0.5, color: primary()))),
  //                 Positioned(
  //                     top: 10,
  //                     right: -52,
  //                     child: Transform(
  //                       transform: Matrix4.rotationY(3.14),
  //                       child: SvgPicture.asset(
  //                         "assets/img/lable.svg",
  //                         width: 25,
  //                         height: 25,
  //                         color: primary(),
  //                       ),
  //                     )),
  //                 Positioned(
  //                     top: 18,
  //                     right: 2,
  //                     child: Text(
  //                       "Discount",
  //                       style: TextStyle(fontSize: 10, color: Colors.white),
  //                     ))
  //               ]);
  // }

  Widget stackedProductInCategory(String imagePath, String title, String categoryID, String subCategoryID, int selectedIndex, String categoryTitle) {
    return Stack(children: [
      Container(
          child: Center(child: miniProductCard(imagePath, title, categoryID, subCategoryID, selectedIndex, categoryTitle)),
          // decoration: BoxDecoration(border:Border(left: BorderSide(width: 1, color: primary())))
      ),
      // Positioned(
      //     top: 10,
      //     right: -52,
      //     child: Transform(
      //       transform: Matrix4.rotationY(3.14),
      //       child: SvgPicture.asset(
      //         "assets/img/lable.svg",
      //         width: 25,
      //         height: 25,
      //         color: primary(),
      //       ),
      //     )),
      // Positioned(
      //     top: 18,
      //     right: 2,
      //     child: Text(
      //       "Discount",
      //       style: TextStyle(fontSize: 10, color: Colors.white),
      //     ))
    ]);
  }

  Widget miniProductCardViewCategory(
      String imagePath, String categoryTitle, List subCategories, String mainCategoryID, int index) {
    return InkWell(
      onTap: () {
        print("building right sub categories...");
        rightSubCategories = [];
        for (int i = 0; i < subCategories.length; i++) {
          rightSubCategories.add(stackedProductInCategory(
              subCategories[i]['image_path'], subCategories[i]['name'], mainCategoryID.toString(), subCategories[i]['ID'].toString(), i, categoryTitle));
        }
        setState(() {
          rightSubCategories = rightSubCategories;
          print("Trigger left rebuild index: $index");
          rebuildLeftCategories(index);
        });
      },
      child: Container(
        decoration: BoxDecoration(
          // color: Colors.blueAccent,
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
                  margin: EdgeInsets.only(top: 5, bottom: 3),
                  child: Column(children: [
                    Center(
                        child: Container(
                            padding: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(width: 0, color: Color(0xfffdb17a)),
                              borderRadius: BorderRadius.circular(45),
                              color: categoriesSelectedBoolean[index]?  Color(0xffF16624):Color(0xfffff8f3),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10000.0),
                              child: CachedNetworkImage(
                                imageUrl: imagePath.toString(),
                                placeholder: (context, url) =>
                                    Image.asset("assets/img/logo (6).png"),
                                errorWidget: (context, url, error) =>
                                    Image.asset("assets/img/logo (6).png"),
                                width: 60,
                                height: 60,
                              ),
                            )

                            //  Image.network(
                            //   imagePath.toString(),
                            //   width: 88,
                            //   height: 88,
                            // ),
                            )),
                    Container(
                      height: 49,
                      width: 80,
                      child: Html(data:'${categoryTitle.toString()}', style: {
                        "*" : Style(
                            textAlign: TextAlign.center,
                            textOverflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            fontSize: FontSize(12),
                            fontWeight:  categoriesSelectedBoolean[index]
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: const Color(0xffF16624),
                            fontFamily: 'Opensans'
                        )
                      },),


                    ),
                    // Container(
                    //   height: 43,
                    //     width: 80,
                    //     child: Padding(
                    //       padding: const EdgeInsets.only(top:4),
                    //       child: Text('${categoryTitle.toString()}',maxLines: 2,textAlign: TextAlign.center,overflow: TextOverflow.ellipsis,style: Sty().mediumText.copyWith( fontWeight: categoriesSelectedBoolean[index]?FontWeight.w700:FontWeight.w500,fontSize: 12, color: Color(0xffF16624),),),
                    //     ))
                  //   Container(
                  //     width: 84,
                  //     child: Html(data: categoryTitle.toString(),shrinkWrap: true, style: {
                  //   "*" : Style(
                  //     textAlign: TextAlign.left,
                  //     maxLines: 2,textOverflow:TextOverflow.ellipsis,
                  //     color: Color(0xffF16624),
                  //     fontWeight: FontWeight.w500,
                  //     padding: EdgeInsets.all(0),
                  //     // margin: EdgeInsets.all(0)
                  //   // maxLines: 1,
                  //   // textOverflow: TextOverflow.ellipsis,
                  //   )
                  // },),
                  //     margin: EdgeInsets.only(top: 5),
                  //
                  //     // Text(
                  //     //   categoryTitle.toString(),
                  //     //   maxLines: 1,
                  //     //   overflow: TextOverflow.ellipsis,
                  //     // ),
                  //     // margin: EdgeInsets.only(top: 5),
                  //   )
                  ])),
              Container(
                decoration: BoxDecoration(
                    color: categoriesSelectedBoolean[index]
                        ? primary()
                        : Color(0),
                    borderRadius: BorderRadius.circular(10)),
                height: 100,
                width: categoriesSelectedBoolean[index] ? 3 : 5,
                margin: EdgeInsets.only(left: 5),
              ),
              // Container( decoration: BoxDecoration(border: selected ? Border(right: BorderSide(width: 5, color: primary())) :Border(right: BorderSide(width: 0, color: primary()))),),

              // selected ? 5 : 0
            ]),
      ),
    );
  }

  var rBuildMainCategories;
  void rebuildLeftCategories(int boolindex) {
    print('building left categories...');
    for (int i = 0; i < rBuildMainCategories.length; i++) {
      categoriesSelectedBoolean[i] = false;
    }

    categoriesSelectedBoolean[boolindex] = true;

    leftCategories = [];

    for (int i = 0; i < rBuildMainCategories.length; i++) {
      leftCategories.add(miniProductCardViewCategory(
          rBuildMainCategories[i]['image_path'].toString(),
          rBuildMainCategories[i]['name'].toString(),
          rBuildMainCategories[i]['sub_categories'],
          rBuildMainCategories[i]['ID'],
          i));
    }

    setState(() {
      leftCategories = leftCategories;
      categoriesSelectedBoolean = categoriesSelectedBoolean;
    });
  }

  void getCategories() async {
    var dio = Dio();
    setState(() {
      isloaded = false;
    });
    var formData = FormData.fromMap({});
    final response = await dio.post(getMainCategoriesUrl(), data: formData);
    var res = json.decode(response.data);

    // print(res);
    rBuildMainCategories = res['main_categories'];

    for (int i = 0; i < res['main_categories'].length; i++) {
      categoriesSelectedBoolean.add(false);
    }
    categoriesSelectedBoolean[0] = true;

    for (int i = 0; i < res['main_categories'].length; i++) {
      leftCategories.add(miniProductCardViewCategory(
          res['main_categories'][i]['image_path'].toString(),
          res['main_categories'][i]['name'].toString(),
          res['main_categories'][i]['sub_categories'],
          res['main_categories'][i]['ID'],
          i));
    }

    // print(categoriesSelectedBoolean);

    // Set right subcategories on initialize...
    rightSubCategories = [];
    for (int i = 0;
        i < res['main_categories'][0]['sub_categories'].length;
        i++) {
      rightSubCategories.add(stackedProductInCategory(
          res['main_categories'][0]['sub_categories'][i]['image_path'],
          res['main_categories'][0]['sub_categories'][i]['name'],
          res['main_categories'][0]['ID'],
          res['main_categories'][0]['sub_categories'][i]['ID'],
          i,
          res['main_categories'][0]['name']
          ));
    }

    setState(() {
      leftCategories = leftCategories;
      categoriesSelectedBoolean = categoriesSelectedBoolean;
      rightSubCategories = rightSubCategories;
      rebuildLeftCategories(0);
      isloaded = true;
    });
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


  @override
  void initState() {
    getCategories();
    getSession();
    // updateBadgeCount();
    super.initState();
  }

  getSession() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      // sPincode = sp.getString('pincode') ?? "";
      // print(sPincode);
    });
  }

  //   void _onItemTapped(int index) {
  //   print(index);
  //   // setState(() {
  //   //   _selectedIndex = index;
  //   // });
  //   switch (index){
  //     case 0:
  //       Navigator.of(context).push(MaterialPageRoute(builder: ((context) => HomeScreen()))).then((_) { updateBadgeCount();  print("Cart update called");});
  //       break;
  //     case 1:
  //       Navigator.of(context).push(MaterialPageRoute(builder: ((context) => CategoriesScreen()))).then((_) { updateBadgeCount(); print("Cart update called"); print(_); });
  //       break;
  //     case 2:
  //       Navigator.of(context).push(MaterialPageRoute(builder: ((context) => OfferScreen()))).then((_) { updateBadgeCount();  print("Cart update called");});
  //       break;
  //     case 3:
  //       Navigator.of(context).push(MaterialPageRoute(builder: ((context) => MyProfileScreen()))).then((_) { updateBadgeCount(); print("Cart update called"); });
  //       break;
  //     case 4:
  //       Navigator.of(context).push(MaterialPageRoute(builder: ((context) => CartScreen()))).then((_) { updateBadgeCount(); print("Cart update called"); });
  //       break;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    ctx = context;
    leftCategories = leftCategories;
    rightSubCategories = rightSubCategories;
    categoriesSelectedBoolean = categoriesSelectedBoolean;
    return Scaffold(
      bottomNavigationBar: bottomBarLayout(ctx, 1),
      // bottomNavigationBar: BottomNavigationBar(
      //     type: BottomNavigationBarType.fixed,
      //     items: <BottomNavigationBarItem>[
      //       BottomNavigationBarItem(
      //         icon: SvgPicture.asset("assets/img/Home.svg",),
      //         label: 'Home',
      //       ),
      //       BottomNavigationBarItem(
      //         icon: SvgPicture.asset("assets/img/Categories.svg",),
      //         label: 'Categories',
      //       ),
      //       BottomNavigationBarItem(
      //         icon: SvgPicture.asset("assets/img/Offers.svg",),
      //         label: 'Offers',
      //       ),
      //       BottomNavigationBarItem(
      //         icon: SvgPicture.asset("assets/img/My Profile.svg",),
      //         label: 'My Profile',
      //       ),
      //       // BottomNavigationBarItem(
      //       //   icon: contentInCart > 0 ? Badge(child: SvgPicture.asset("assets/img/Cart.svg",), badgeColor: primary(), badgeContent: Text(contentInCart.toString(), style: TextStyle(color: Colors.white),),) : SvgPicture.asset("assets/img/Cart.svg",),
      //       //   // icon: SvgPicture.asset("assets/img/Cart.svg"),
      //       //   label: 'Cart',
      //       // ),
      //     ],
      //     currentIndex: 0,
      //     showSelectedLabels: true,
      //     showUnselectedLabels: true,
      //     selectedItemColor: greyLite(),
      //     unselectedItemColor: greyLite(),
      //     selectedIconTheme: IconThemeData(size: 25.0, color: primary()),
      //     selectedLabelStyle: TextStyle(fontSize: 15.0, color: primary()),
      //     unselectedIconTheme: IconThemeData(size: 25.0, color:secondary()),
      //     unselectedLabelStyle: TextStyle(fontSize: 15.0, color:secondary()),
      //     onTap: _onItemTapped,
      //   ),
      // bottomNavigationBar: ClipRRect(
      //   borderRadius: const BorderRadius.only(
      //       topRight: Radius.circular(15),
      //       topLeft: Radius.circular(15)),
      //   child: BottomNavigationBar(
      //
      //     backgroundColor: Color(0xffF16624),
      //     type: BottomNavigationBarType.fixed,
      //     items: <BottomNavigationBarItem>[
      //       BottomNavigationBarItem(
      //         icon: SvgPicture.asset(
      //           "assets/img/bn_homebttn.svg",
      //         ),
      //         label: 'Home',
      //       ),
      //       BottomNavigationBarItem(
      //         icon: SvgPicture.asset(
      //           "assets/img/bn_categhome.svg",
      //           color: _onItemTapped == 0 ? Clr().primaryColor : Clr().white,
      //         ),
      //         label: 'Categories',
      //       ),
      //       BottomNavigationBarItem(
      //         icon: SvgPicture.asset(
      //           "assets/img/bn_search.svg",
      //         ),
      //         label: 'Offers',
      //       ),
      //       BottomNavigationBarItem(
      //         icon: SvgPicture.asset(
      //           "assets/img/bn_profile.svg",
      //         ),
      //         label: 'My Profile',
      //       ),
      //       // BottomNavigationBarItem(
      //       //   icon: contentInCart > 0
      //       //       ? Badge(
      //       //           child: SvgPicture.asset(
      //       //             "assets/img/Cart.svg",
      //       //           ),
      //       //           badgeColor: primary(),
      //       //           badgeContent: Text(
      //       //             contentInCart.toString(),
      //       //             style: const TextStyle(color: Colors.white),
      //       //           ),
      //       //         )
      //       //       : SvgPicture.asset(
      //       //           "assets/img/Cart.svg",
      //       //         ),
      //       //   // icon: SvgPicture.asset("assets/img/Cart.svg"),
      //       //   label: 'Cart',
      //       // ),
      //     ],
      //     currentIndex: 0,
      //     showSelectedLabels: false,
      //     selectedFontSize: 0,
      //     showUnselectedLabels: false,
      //     selectedItemColor: Clr().red,
      //     unselectedItemColor: Clr().white,
      //     selectedIconTheme: IconThemeData(size: 25.0, color: primary()),
      //     selectedLabelStyle: TextStyle(fontSize: 15.0, color: primary()),
      //     unselectedIconTheme: IconThemeData(size: 25.0, color: secondary()),
      //     unselectedLabelStyle: TextStyle(fontSize: 15.0, color: secondary()),
      //     onTap: _onItemTapped,
      //   ),
      // ),
      appBar: AppBar(
        backgroundColor:Colors.white,
        elevation: 0,
        leading: BackButton(
          color: Color(0xff244D73)
        ),
        centerTitle: true,
        title: Text("Quality Foods",style: TextStyle(color: Color(0xff00182E),fontWeight: FontWeight.w500,fontSize: 18)),
        flexibleSpace: barGredient(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child:IconButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: ((context) {
                    return const CartScreen(type: 'categoryscreen',);
                  }))).then((_) {
                    // updateBadgeCount();
                    print("Cart update called");
                  });
                },
                icon: Stack(
                  // clipBehavior: Clip.none,
                  fit: StackFit.loose,
                  children: [
                    Container(
                        height: 32,
                        width: 36,
                        decoration:  BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          gradient: LinearGradient(
                            // begin: Alignment.topCenter,
                            // end: Alignment.bottomCenter,
                              colors: <Color>[ Clr().appbarColor.withOpacity(0.9), Clr().appbarColor1.withOpacity(0.9),]),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(7.0),
                          child: SvgPicture.asset('assets/img/cartimg.svg',color: Color(0xffFFEEE5),),
                        )),
                    contentInCart == 0
                        ? Positioned(
                        bottom: 2, right: -8, child: Container())
                        : Positioned(
                        bottom: 18,
                        right: 4,
                        child: Container(
                          child: Center(
                              child: Text(
                                // '${contentInCart}',
                                '',
                                style: Sty()
                                    .smallText
                                    .copyWith(color: Clr().white,fontSize:8,),
                              )),
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xffFF7534),width: 0.5),
                            shape: BoxShape.circle,
                            color: contentInCart == 0
                                ? Clr().transparent
                                : Color(0xff50D112),
                          ),
                          width:8,
                          height:8,
                        )),
                  ],
                )),
          ),

        ],
      ),
      body: isloaded ? Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(offset: Offset(2, 20), spreadRadius: 2, blurRadius: 1, color: Color(0xffFFEEE5).withOpacity(0.5))]),
              child: SizedBox(
                // width: MediaQuery.of(context).size.width - 300,
                child: ListView(
                  children: leftCategories,
                ),
              ),
            ),
          ),
         rightSubCategories.length > 0 ? Expanded(
            flex: 3,
            child: Container(
              // width: MediaQuery.of(context).size.width - 115,
              child:GridView.count(
                // shrinkWrap: true,
                childAspectRatio: 0.70,
                // childAspectRatio: 0.77,
                // MediaQuery.of(context).size.width /
                //     (MediaQuery.of(context).size.height) *
                //     1.2
                // mainAxisSpacing: 1,
                // crossAxisSpacing: 1,
                addRepaintBoundaries: true,
                crossAxisCount: 2,
                children: rightSubCategories,
              ),
            ),
          ) 
          :
          Expanded(
            flex: 3,
            child: Center(child: Text("No Data Found", style:TextStyle(color: primary(), fontSize: 25)),)
          )

        ],
      ) : Center(child: CircularProgressIndicator()),
    );
  }
}
