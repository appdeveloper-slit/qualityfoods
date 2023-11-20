import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qf/colors.dart';
import 'package:qf/globalurls.dart';

import './appbar_gradientlook.dart';
import 'bottom_navigation/bottom_navigation.dart';

class OfferScreen extends StatefulWidget {
  const OfferScreen({Key? key}) : super(key: key);

  @override
  State<OfferScreen> createState() => OfferScreenState();
}

class OfferScreenState extends State<OfferScreen> {
  late BuildContext ctx;
  List<Widget> offerItemList = [];
  bool isloaded = false;

  Widget offerItem(String code, String details) {
    return Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: primary()),
            borderRadius: BorderRadius.circular(25)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        decoration: BoxDecoration(
                            border: Border.all(width: 1, color: primary()),
                            borderRadius: BorderRadius.circular(5)),
                        width: MediaQuery.of(context).size.width - 100,
                        child: InkWell(
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: code.toString()));
                            SnackBar sn = SnackBar(
                              content: Text("Copied!"),
                              duration: Duration(seconds: 1),
                            );

                            ScaffoldMessenger.of(context).showSnackBar(sn);
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                  child: Icon(
                                    Icons.copy,
                                    color: primary(),
                                  ),
                                  padding: EdgeInsets.all(5)),
                              Expanded(
                                  child: Align(
                                      alignment: Alignment.center,
                                      child: Container(
                                        child: Text(
                                          code,
                                          textAlign: TextAlign.left,
                                        ),
                                        margin: EdgeInsets.only(right: 30.0),
                                      ))),
                            ],
                          ),
                        )),
                  ],
                )
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    width: MediaQuery.of(context).size.width - 160,
                    margin: EdgeInsets.only(top: 5),
                    child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          child: Text(
                            details,
                            textAlign: TextAlign.center,
                            softWrap: true,
                          ),
                          margin: EdgeInsets.only(left: 20.0),
                        ))),
              ],
            ),
          ],
        ));
  }

  void getOffers() async {
    setState(() {
      isloaded = false;
    });
    var dio = Dio();
    var formData = FormData.fromMap({
      // 'user_id' : '2'
    });
    final response = await dio.post(couponsDataPageUrl(), data: formData);
    var res = json.decode(response.data);
    print(res);

    offerItemList = [];
    for (int i = 0; i < res['result_array'].length; i++) {
      offerItemList.add(offerItem(
          res['result_array'][i]['code'], res['result_array'][i]['detail']));
    }
    // if(offerItemList.length > 0){

    // }
    // else{
    //   SnackBar sn = SnackBar(content: Text(res['message']));
    //   ScaffoldMessenger.of(context).showSnackBar(sn);
    // }
    setState(() {
      offerItemList = offerItemList;
      isloaded = true;
    });
  }

  void initState() {
    getOffers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ctx = context;
    return Scaffold(
      bottomNavigationBar: bottomBarLayout(ctx, 2),
      appBar: AppBar(
        elevation: 0.2,
        leading: BackButton(color: Color.fromARGB(255, 255, 255, 255)),
        title: Text("My Discount"),
        flexibleSpace: barGredient(),
      ),
      body: isloaded
          ? offerItemList.length > 0
              ? Container(
                  child: Center(
                    child: Scrollbar(
                      child: Container(
                        margin: EdgeInsets.all(15),
                        child: ListView(
                          children: offerItemList.length > 0
                              ? offerItemList
                              : [Center(child: Text("No Offers Found"))],
                        ),
                      ),
                    ),
                  ),
                )
              : Center(
                  child: Text(
                  "No Data Found",
                  style: TextStyle(color: primary(), fontSize: 25),
                ))
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
