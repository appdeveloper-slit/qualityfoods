import 'dart:io';

import 'package:flutter/material.dart';

class MainAppPage extends StatefulWidget {
  const MainAppPage({Key? key}) : super(key: key);

  @override
  State<MainAppPage> createState() => MainAppPageState();
}

int contentInCart = 0;

class MainAppPageState extends State<MainAppPage> {
  @override
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Exit?"),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pop(context, true);
                        exit(0);
                      },
                      child: Text("YES")),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("NO")),
                ],
              );
            });

        return false;
      },
      child: Scaffold(),
    );
  }
}
