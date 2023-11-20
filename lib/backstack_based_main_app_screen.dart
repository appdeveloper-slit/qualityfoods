// import 'dart:io';
//
// import 'package:badges/badges.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:qf/category_screen.dart';
// import 'package:qf/colors.dart';
// import 'package:qf/myprofile.dart';
// import 'package:qf/sqliteop.dart';
// import './signup.dart';
// import './login.dart';
// import './cart_page_old.dart';
// import './home_page.dart';
// import './searchpage.dart';
// import 'package:bottom_nav_layout/bottom_nav_layout.dart';
//
// class MainAppPage extends StatefulWidget {
//   const MainAppPage({Key? key}) : super(key: key);
//
//   @override
//   State<MainAppPage> createState() => MainAppPageState();
// }
//
// int contentInCart = 0;
//
// void updatecountbadge() async {
//   final db = DatabaseHelper.instance;
//   final allRows = await db.queryAllRows();
//   print("Number of items in cart" + allRows.length.toString());
//   contentInCart = allRows.length;
// }
//
// class MainAppPageState extends State<MainAppPage> {
//
//   @override
//   void initState() {
//     updateCartCountBadge();
//     // Navigator.push(context,  MaterialPageRoute(builder: (context) => LoginScreen()));
//
//     super.initState();
//   }
//
//
//   int _selectedIndex = 0;
//
//   static const List<Widget> _widgetOptions = <Widget>[
//     HomeScreen(),
//     CategoriesScreen(),// Center(child: Text("Nothing here for now | Categories")), // Categories
//     SearchScreen(),// Center(child: Text("Nothing here for now | Offers")), // Offers
//     MyProfileScreen(),// Center(child: Text("Nothing here for now | My Profile")), // My Profile
//     CartScreen()
//   ];
//
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
//
//   void updateCartCountBadge() async {
//     final db = DatabaseHelper.instance;
//     final allRows = await db.queryAllRows();
//     print("Number of items in cart" + allRows.length.toString());
//     setState(() {
//       contentInCart = allRows.length;
//     });
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//
//         // showDialog(
//         //   barrierDismissible: false,
//         //   context: context, builder: (context) {
//         //   return AlertDialog(title: Text("Exit?"), actions: [
//         //     TextButton(onPressed: (){
//         //       Navigator.of(context).pop();
//         //        Navigator.pop(context, true);
//         //       exit(0);
//         //     }, child: Text("YES")),
//         //     TextButton(onPressed: (){
//         //       Navigator.of(context).pop();
//         //     }, child: Text("NO")),
//         //   ],);
//         // });
//
//         return true;
//       },
//       child: Center(
//         // type: BottomNavigationBarType.fixed,
//         // selectedFontSize: 16,
//         // unselectedFontSize: 16,
//         // savePageState: false,
//         // // pageStack: ReorderToFrontExceptFirstPageStack(initialPage: 0),
//         //   // The app's top level destinations
//         //   pageBuilders: [
//
//         //    () => HomeScreen(),
//         //    () => CategoriesScreen(), // Center(child: Text("Nothing here for now | Categories")), // Categories
//         //    () => OfferScreen(), // Center(child: Text("Nothing here for now | Offers")), // Offers
//         //    () => MyProfileScreen(),// Center(child: Text("Nothing here for now | My Profile")), // My Profile
//         //    () => CartScreen()
//         //   ],
//         //   items: [
//         //     BottomNavigationBarItem(
//         //         icon: SvgPicture.asset("assets/img/Home.svg",),
//         //         label: 'Home',
//         //       ),
//         //       BottomNavigationBarItem(
//         //         icon: SvgPicture.asset("assets/img/Categories.svg",),
//         //         label: 'Categories',
//         //       ),
//         //       BottomNavigationBarItem(
//         //         icon: SvgPicture.asset("assets/img/Offers.svg",),
//         //         label: 'Offers',
//         //       ),
//         //       BottomNavigationBarItem(
//         //         icon: SvgPicture.asset("assets/img/My Profile.svg",),
//         //         label: 'My Profile',
//         //       ),
//         //       BottomNavigationBarItem(
//         //         // icon: contentInCart > 0 ? Badge(child: SvgPicture.asset("assets/img/Cart.svg",), badgeColor: primary(), badgeContent: Text(contentInCart.toString(), style: TextStyle(color: Colors.white),),) : SvgPicture.asset("assets/img/Cart.svg",),
//         //         icon: SvgPicture.asset("assets/img/Cart.svg"),
//         //         label: 'Cart',
//         //       ),
//         //   ],
//         // ),
//     ));
//   }
// }
