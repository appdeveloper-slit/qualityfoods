import 'package:flutter/material.dart';
import 'package:qf/appbar_gradientlook.dart';
import 'package:qf/values/colors.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  State<AboutUsScreen> createState() => AboutUsScreenState();
}

class AboutUsScreenState extends State<AboutUsScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor:Colors.white,
        elevation: 0,
        title: Text("About Us",style: TextStyle(
          color: Color(0xff00182E),
          fontWeight: FontWeight.w500,
          fontSize: 18)), flexibleSpace: barGredient(),
        leading: BackButton(color: Color(0xff244D73)),
        centerTitle: true,),
      body: Container(
        margin: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("assets/img/qualityfoodsicon.png",height: 150,width: 150),
            SizedBox(height: 16,),
            Text("Quality Foods is a platform to buy your daily grocery online. We offer different types of Vegetables and Fruits categories along with a wide range of seasonal products.", style: TextStyle(fontSize: 16,color: Clr().primaryColor),),
            SizedBox(height: 10,),
            Text("The Quality Foods app offers both COD & Online payment options so that you can order your grocery with confidence and ease.", style: TextStyle(fontSize: 16,color: Clr().primaryColor),),
            SizedBox(height: 10,),
            Text("The app also has a section to apply any promo codes to avail discounts on your order.", style: TextStyle(fontSize: 16,color: Clr().primaryColor),)
          ],
        ),
      ),
    );
    
    
  }
}