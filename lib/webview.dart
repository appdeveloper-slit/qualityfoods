import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  final String? key1;
  String? selectedAddressId;
  String? deliveryAmount;
  String? total, tax_charge, coupon_code;

  WebViewPage(
      {this.key1,
        this.selectedAddressId,
        this.deliveryAmount,
        this.total,
        this.tax_charge,
        this.coupon_code});

  @override
  WebViewPageState createState() => WebViewPageState(
      selectedAddressId: selectedAddressId,
      deliveryAmount: deliveryAmount,
      total: total,
      tax_charge: tax_charge,
      coupon_code: coupon_code);
}

class WebViewPageState extends State<WebViewPage> {
  late BuildContext ctx;

  bool isLoading = true, isLoaded = false;
  String? sID;
  String? selectedAddressId;
  String? deliveryAmount;
  String? total, tax_charge, coupon_code;

  WebViewPageState(
      {required this.selectedAddressId,
        required this.deliveryAmount,
        required this.total,
        required this.tax_charge,
        required this.coupon_code});

  @override
  void initState() {
    getSessionData();
    super.initState();
    // if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    ctx = context;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: isLoaded ? WebView(
            javascriptMode: JavascriptMode.unrestricted,
            initialUrl: "https://qualityfoods.info/app_apis/payParameter.php?user_id=$sID&address_id=$selectedAddressId&deliveryamount=$deliveryAmount&tax_charge=$tax_charge&total=$total&coupon_code=$coupon_code",
            onPageFinished: (String url) {
              setState(() {
                isLoading = false;
                if (url.contains("success")) {
                  // StaticMethod.successDialogWithReplace(
                  //     ctx, "Payment successfully", const MySubscription());
                } else if (url.contains("error")) {
                  var separated = url.split("\\?msg=");
                  String message = separated[1];
                  message = message.replaceAll("%20", " ");
                  // StaticMethod.back2Previous(ctx);
                }
              });
            },
          )
              : Container()),
    );
  }

  //Get detail
  getSessionData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      sID = sp.getString("user_id");
      isLoaded = true;
    });
  }
}
