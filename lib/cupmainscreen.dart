// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:qf/bottomnav.dart';
// import 'package:qf/cart_page_old.dart';
// import 'package:qf/category_screen.dart';
// import 'package:qf/colors.dart';
// import 'package:qf/home_page.dart';
// import 'package:qf/myprofile.dart';
// import 'package:qf/searchpage.dart';
//
//
// class CupHomeScreen extends StatefulWidget{
//   CupHomeScreen({Key? key}) : super (key: key);
//   @override
//   State<CupHomeScreen> createState() => CupHomeScreenState();
// }
//
// class CupHomeScreenState extends State<CupHomeScreen> {
//   final GlobalKey<NavigatorState> firstTabNavKey = GlobalKey<NavigatorState>();
//   final GlobalKey<NavigatorState> secondTabNavKey = GlobalKey<NavigatorState>();
//   final GlobalKey<NavigatorState> thirdTabNavKey = GlobalKey<NavigatorState>();
//   final GlobalKey<NavigatorState> fourthTabNavKey = GlobalKey<NavigatorState>();
//   final GlobalKey<NavigatorState> fifthTabNavKey = GlobalKey<NavigatorState>();
//   CupertinoTabController? tabController;
//
//   void initState(){
//     tabController = CupertinoTabController(initialIndex: 0);
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     final listOfKeys = [firstTabNavKey, secondTabNavKey, thirdTabNavKey, fourthTabNavKey, fifthTabNavKey];
//     List homeScreenList = [
//       CupertinoTabView(builder: (context) => CupertinoPageScaffold(child: HomeScreen(),)),
//       CupertinoTabView(builder: (context) => CupertinoPageScaffold(child: CategoriesScreen(),)),
//       CupertinoTabView(builder: (context) => CupertinoPageScaffold(child: SearchScreen(),)),
//       CupertinoTabView(builder: (context) => CupertinoPageScaffold(child: MyProfileScreen(),)),
//       CupertinoTabView(builder: (context) => CupertinoPageScaffold(child: CartScreen(),))
//     ];
//
//
//
//     return WillPopScope(
//       onWillPop: () async {
//         return !await listOfKeys[tabController!.index].currentState!.maybePop();
//       },
//       child: CupertinoTabScaffold(
//         controller: tabController,
//         tabBar: CupertinoTabBar(
//           border: Border(top: BorderSide(color: primary(), width: 0.0)),
//           iconSize: 35,
//           height: 60,
//           activeColor: primary(),
//           inactiveColor: secondary(),
//           items: [
//             BottomNavigationBarItem(
//               icon: SvgPicture.asset(
//               "assets/img/Home.svg",
//               semanticsLabel: 'Home'
//             ),
//               label: 'Home',
//             ),
//             BottomNavigationBarItem(
//               icon: SvgPicture.asset(
//               "assets/img/Categories.svg",
//               semanticsLabel: 'Home'
//             ),
//               label: 'Categories',
//             ),
//             BottomNavigationBarItem(
//               icon: SvgPicture.asset(
//               "assets/img/Offers.svg",
//               semanticsLabel: 'Home'
//             ),
//               label: 'Offers',
//             ),
//             BottomNavigationBarItem(
//               icon: SvgPicture.asset(
//               "assets/img/My Profile.svg",
//               semanticsLabel: 'Home'
//             ),
//               label: 'My Profile',
//             ),
//             BottomNavigationBarItem(
//               icon: SvgPicture.asset(
//               "assets/img/Cart.svg",
//               semanticsLabel: 'Home'
//             ),
//               label: 'Cart',
//             ),
//           ],
//         ),
//         tabBuilder: (context, index) {
//           return CupertinoTabView(
//             navigatorKey: listOfKeys[index], //set navigatorKey here which was initialized before
//             builder: (context) {
//               return homeScreenList[index];
//             });
//
//
//           // if (index == 0) {
//           //   return CupertinoTabView(builder: (context) => CupertinoPageScaffold(child: HomeScreen(),));
//           // }
//           // else if(index == 1){
//           //    return CupertinoTabView(builder: (context) => CupertinoPageScaffold(child: CategoriesScreen(),));
//           // }
//           // else if(index == 2){
//           //    return CupertinoTabView(builder: (context) => CupertinoPageScaffold(child: OfferScreen(),));
//           // }
//           // else if(index == 3){
//           //   return CupertinoTabView(builder: (context) => CupertinoPageScaffold(child: MyProfileScreen(),));
//           // }
//           // else if(index == 4){
//           //   return CupertinoTabView(builder: (context) => CupertinoPageScaffold(child: CartScreen(),));
//           // }
//           // else{
//           //   return Scaffold(body: Center(child: Text("Failed to start"),));
//           // }
//         },
//       ),
//     );
//   }
// }
