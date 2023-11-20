import 'package:flutter/material.dart';
import 'package:qf/values/colors.dart';

Widget barGredient(){
  return Image(
    image: AssetImage('assets/img/appbarbg.png'),
    fit: BoxFit.cover,
  );
  // return Container(
  //     decoration:  BoxDecoration(
  //       gradient: LinearGradient(
  //         // begin: Alignment.topCenter,
  //         // end: Alignment.bottomCenter,
  //         colors: <Color>[ Clr().appbarColor.withOpacity(0.9), Clr().appbarColor1.withOpacity(0.9),Clr().appbarColor2.withOpacity(0.9),Clr().appbarColor3.withOpacity(0.9)]),
  //     ),);
}