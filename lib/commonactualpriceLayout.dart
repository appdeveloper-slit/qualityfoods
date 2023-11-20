import 'package:flutter/material.dart';

class commonActualLayout extends StatefulWidget {
  final price;
  const commonActualLayout({super.key,this.price});

  @override
  State<commonActualLayout> createState() => _commonActualLayoutState();
}

class _commonActualLayoutState extends State<commonActualLayout> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: priceStrikeWidget('${widget.price}'),
    );
  }
  Widget priceStrikeWidget(String amount) {
    return Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Text("₹" + amount.toString(),
            style: const TextStyle(
                decoration: TextDecoration.lineThrough,
                fontSize: 14,
                color: Colors.grey)));
  }
}
