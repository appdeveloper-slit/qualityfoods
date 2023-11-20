import 'package:flutter/material.dart';
import '../category_screen.dart';
import '../home_page.dart';
import '../manage/static_method.dart';
import '../myprofile.dart';
import '../searchpage.dart';
import '../values/colors.dart';

Widget bottomBarLayout(ctx, index) {
  return ClipRRect(
    borderRadius: const BorderRadius.only(
        topRight: Radius.circular(15),
        topLeft: Radius.circular(15)),
    child: BottomNavigationBar(
      elevation: 0,
      backgroundColor: Color(0xffF16624),
      // currentIndex: 0,
      showSelectedLabels: false,
      selectedFontSize: 0,
      showUnselectedLabels: false,
      selectedItemColor: Clr().red,
      unselectedItemColor: Clr().white,
      // selectedIconTheme: IconThemeData(size: 25.0, color: primary()),
      // selectedLabelStyle: TextStyle(fontSize: 15.0, color: primary()),
      // unselectedIconTheme: IconThemeData(size: 25.0, color: secondary()),
      // unselectedLabelStyle: TextStyle(fontSize: 15.0, color: secondary()),

      type: BottomNavigationBarType.fixed,
      currentIndex: index,
      onTap: (i) async {
        switch (i) {
          case 0:
              STM().finishAffinity(ctx, HomeScreen());
            break;
          case 1:
            index == 1 ?  STM().replacePage(ctx,CategoriesScreen()) : STM().redirect2page(ctx,CategoriesScreen());
            break;
          case 2:
            index == 2 ?  STM().replacePage(ctx, SearchScreen()) : STM().redirect2page(ctx,SearchScreen());
            break;
          case 3:
            index == 3 ? STM().replacePage(ctx, MyProfileScreen()): STM().redirect2page(ctx,MyProfileScreen());
            break;
        }
      },
      items: STM().getBottomList(index),
    ),
  );
}
