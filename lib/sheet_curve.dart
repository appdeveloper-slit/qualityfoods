import 'package:flutter/material.dart';
import 'package:qf/colors.dart';

Widget inkCurve(String title, var context){
  return Column(
    children: [
      Container(
    height: 180.0,
    width: MediaQuery.of(context).size.width,
    child: Column(
      children: [
        SizedBox(height: 102),
        Container(child: Center(child: Text(title, style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w500))), margin: EdgeInsets.fromLTRB(0, 10, 0, 0)),
      ],
    ),
    decoration: new BoxDecoration(
      color:Colors.white,
    ),
  ),
 Container(
   color:Colors.white,
   child: Stack(
          children: [
            Container(
      height: 79.0,
      decoration: new BoxDecoration(
        color: primary(),
      ),
    ),
            Container(
      height: 80.0,
      decoration: new BoxDecoration(
        color: Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(
                25.0)),
      ),
    ),
          ],
        ),
 )
    ],
  );
}