import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:qf/colors.dart';
import 'package:qf/globalurls.dart';
import 'package:qf/values/colors.dart';
import 'package:qf/values/dimens.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './appbar_gradientlook.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => NotificationScreenState();
}

class NotificationScreenState extends State<NotificationScreen> {
  List<Widget> notificationItemList = [];
  bool isloaded = false;

  Widget NotificationItem(String title, String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 0.0,
        margin: EdgeInsets.symmetric(horizontal: Dim().d0, vertical: Dim().d8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dim().d12),
          side: BorderSide(color: Color(0xffECECEC)),
        ),
        child: Padding(
          padding:
              const EdgeInsets.only(top: 20, bottom: 12, left: 20, right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                child: Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Clr().primaryColor)),
                alignment: Alignment.centerLeft,
              ),
              SizedBox(
                height: 8,
              ),
              Align(
                child: Text(date,
                    style: TextStyle(
                      color: Clr().textSecondaryColor,
                    )),
                alignment: Alignment.centerRight,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void getOffers() async {
    setState(() {
      isloaded = false;
    });
    SharedPreferences sp = await SharedPreferences.getInstance();
    var dio = Dio();
    var formData =
        FormData.fromMap({'user_id': sp.getString('user_id').toString()});
    final response = await dio.post(getNotificationsUrl(), data: formData);
    var res = json.decode(response.data);
    print(res);

    notificationItemList = [];
    for (int i = 0; i < res['result_array'].length; i++) {
      notificationItemList.add(NotificationItem(
          res['result_array'][i]['message'], res['result_array'][i]['date']));
    }
    // if(notificationItemList.length > 0){

    // }
    // else{
    //   SnackBar sn = SnackBar(content: Text(res['message']));
    //   ScaffoldMessenger.of(context).showSnackBar(sn);
    // }
    setState(() {
      notificationItemList = notificationItemList;
      isloaded = true;
    });
  }

  void oneSignalNotificationSetup() async {
    // Please setup your notification backend here...

    // var notification = OSCreateNotification(
    //     content: "this is a test from OneSignal's Flutter SDK",
    //     heading: "Test Notification",
    //     buttons: [
    //       OSActionButton(text: "test1", id: "id1"),
    //       OSActionButton(text: "test2", id: "id2")
    //     ],
    //     playerIds: [
    //       "test"
    //     ]);

    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        '1', 'test',
        icon: 'mipmap/ic_launcher',
        priority: Priority.max,
        importance: Importance.max,
        enableVibration: true,
        color: const Color.fromARGB(255, 255, 0, 0));
    // var iOSPlatformChannelSpecifics =
    //     new IOSNotificationDetails(sound: "slow_spring_board.aiff");

    final FlutterLocalNotificationsPlugin androidNotification =
        FlutterLocalNotificationsPlugin();
    androidNotification.show(1, "Order", "Notification seen",
        NotificationDetails(android: androidPlatformChannelSpecifics));
  }

  void initState() {
    getOffers();

    // Initial call of the function please remove it when stream is done.
    oneSignalNotificationSetup();
    super.initState();
  }

  //   void _onItemTapped(int index) {
  //   print(index);
  //   // setState(() {
  //   //   _selectedIndex = index;
  //   // });
  //   switch (index){
  //     case 0:
  //       Navigator.of(context).push(MaterialPageRoute(builder: ((context) => HomeScreen()))).then((_) { updateBadgeCount(); print("Cart update called");});
  //       break;
  //     case 1:
  //       Navigator.of(context).push(MaterialPageRoute(builder: ((context) => CategoriesScreen()))).then((_) { updateBadgeCount(); print("Cart update called");});
  //       break;
  //     case 2:
  //       Navigator.of(context).push(MaterialPageRoute(builder: ((context) => OfferScreen()))).then((_) { updateBadgeCount(); print("Cart update called");});
  //       break;
  //     case 3:
  //       Navigator.of(context).push(MaterialPageRoute(builder: ((context) => MyProfileScreen()))).then((_) { updateBadgeCount(); print("Cart update called");});
  //       break;
  //     case 4:
  //       Navigator.of(context).push(MaterialPageRoute(builder: ((context) => CartScreen()))).then((_) { updateBadgeCount(); print("Cart update called");});
  //       break;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Color(0xff244D73)),
        centerTitle: true,
        title: Text("Notifications",
            style: TextStyle(
                color: Color(0xff00182E),
                fontWeight: FontWeight.w500,
                fontSize: 18)),
        flexibleSpace: barGredient(),
      ),
      body: isloaded
          ? notificationItemList.length > 0
              ? Container(
                  child: Center(
                    child: Scrollbar(
                      child: Container(
                        margin: EdgeInsets.all(3),
                        child: ListView(
                          children: notificationItemList,
                        ),
                      ),
                    ),
                  ),
                )
              : Center(
                  child: Text(
                  "No Data Found",
                  style: TextStyle(fontSize: 25, color: primary()),
                ))
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
