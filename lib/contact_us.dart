
import 'package:flutter/material.dart';
import 'package:qf/appbar_gradientlook.dart';

import 'package:qf/values/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({Key? key}) : super(key: key);

  @override
  State<ContactUsScreen> createState() => ContactUsScreenState();
}

class ContactUsScreenState extends State<ContactUsScreen> {




  @override
  Widget build(BuildContext context) {
     return Scaffold(

      appBar: AppBar(
        backgroundColor:Colors.white,
        elevation: 0,
        title: Text("Contact Us",style: TextStyle(
          color: Color(0xff00182E),
          fontWeight: FontWeight.w500,
          fontSize: 18)), flexibleSpace: barGredient(),
        leading: BackButton(color: Color(0xff244D73)),
        centerTitle: true,),
      body: Container(
        margin: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Align(child: Image.asset("assets/img/qualityfoodsicon.png",height: 150,width: 150), alignment: Alignment.center,),
            SizedBox(height: 16,),
            InkWell(
                onTap: () async {
                  await launchUrl(
                      Uri.parse('mailto:sushantchaudhary255@gmail.com'));
                },
                child: Text("Email: sushantchaudhary255@gmail.com", style: TextStyle(fontSize: 16,color: Clr().primaryColor))),
            SizedBox(height: 10,),
            Row(
              children: [
                Text("Call: ", style: TextStyle(fontSize: 16,color: Clr().primaryColor)),
                InkWell(
                    onTap: () async {
                      await launchUrl(
                          Uri.parse('tel:7620550436')
                      );
                    },
                    child: Text("7620550436", style: TextStyle(fontSize: 16,color: Clr().primaryColor))),
                Text(" / ", style: TextStyle(fontSize: 16,color: Clr().primaryColor)),
                InkWell(
                    onTap: () async {
                      await launchUrl(
                          Uri.parse('tel:7219196121')
                      );
                    },
                    child: Text("7219196121", style: TextStyle(fontSize: 16,color: Clr().primaryColor))),
              ],
            ),
            // Text("Call: 7620550436 / 7219196121", style: TextStyle(fontSize: 16,color: Clr().primaryColor)),
            SizedBox(height: 10,),
            Text("Address: Shree ganesh tower sector 1 vashi, Navi mumbai pincode 400703", style: TextStyle(fontSize: 16,color: Clr().primaryColor))
          ],
        ),
      ),
    );
  }
}