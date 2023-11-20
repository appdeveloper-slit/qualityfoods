import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:qf/manage/static_method.dart';
import 'package:qf/single_product_view.dart';
import 'package:qf/values/colors.dart';
import 'package:qf/values/dimens.dart';
import 'package:qf/values/styles.dart';

import 'commonactualpriceLayout.dart';
import 'localstore.dart';

List commonAryy = [];

class commonDropdown extends StatefulWidget {
  final index, v, type;

  const commonDropdown({super.key, this.v, this.index, this.type});

  @override
  State<commonDropdown> createState() => _commonDropdownState();
}

class _commonDropdownState extends State<commonDropdown> {
  List<dynamic> addToCart = [];
  var dropdownValue, finalPrice, actualprice, varientID, discount;
  String? quantValue;

  Future<void> _addItem(medicine_id, varientid, name, image, price, actualPrice,
      description, counter) async {
    await Store.createItem(medicine_id, varientid, name, image, price,
        actualPrice, description, counter);
  }

  Future<void> _updateItem(medicine_id, varientid, name, image, price,
      actualPrice, description, counter) async {
    await Store.updateItem(medicine_id, varientid, name, image, price,
        actualPrice, description, counter);
  }

  _refreshData() async {
    var data = await Store.getItems();
    setState(() {
      addToCart = data;
    });
    print(addToCart);
  }

  @override
  void initState() {
    // TODO: implement initState
    _refreshData();
    dropdownValue = widget.v['variant'][0]['weight'].toString();
    actualprice = widget.v['variant'][0]['actual_price'].toString();
    finalPrice = widget.v['variant'][0]['final_price'].toString();
    varientID = widget.v['variant'][0]['ID'].toString();
    quantValue = widget.v['variant'][0]['quantity'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: Dim().d200 + 1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 8,
                        right: 8,
                        left: 8,
                      ),
                      child: Container(
                        padding: const EdgeInsets.only(
                          top: 10,
                          bottom: 10,
                        ),
                        decoration: BoxDecoration(
                          border:
                          Border.all(width: 1, color: const Color(0xffE5F3FF)),
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xffE5F3FF),
                        ),
                        child: Stack(
                          fit: StackFit.loose,
                          children: [
                            InkWell(
                              onTap: () {
                                quantValue == null
                                    ? Container()
                                    : Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetail(
                                      productID: widget.v['ID'].toString(),
                                      type: widget.type,
                                    ),
                                  ),
                                );
                              },
                              child: CachedNetworkImage(
                                imageUrl: widget.v['images'].isNotEmpty
                                    ? widget.v['images'][0]['img_product']
                                    : '',
                                placeholder: (context, url) =>
                                    Image.asset("assets/img/logo (6).png"),
                                errorWidget: (context, url, error) =>
                                    Image.asset("assets/img/logo (6).png"),
                                width: 110,
                                height: 60,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Html(
                    data: '${widget.v['name']}',
                    style: {
                      "*": Style(
                        maxLines: 1,
                        textOverflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        fontSize: FontSize(12),
                        color: Clr().primaryColor,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Opensans',
                      )
                    },
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 12, right: 12),
                    height: 28,
                    width: 100,
                    padding: const EdgeInsets.only(right: 10, left: 10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                            color: const Color(0xff5AA6EC).withOpacity(0.5))),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<dynamic>(
                        hint: Text(
                          dropdownValue ?? 'grams',
                          style: Sty().mediumText.copyWith(
                            fontSize: 12.0,
                            color: Clr().black,
                          ),
                        ),
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        style: Sty().mediumText,
                        onChanged: (value) {
                          setState(() {
                            dropdownValue = value;
                            int position1 = widget.v['variant'].indexWhere(
                                    (e) => e['weight'].toString() == value.toString());
                            try {
                              finalPrice = int.parse(widget.v['variant'][position1]
                              ['final_price']
                                  .toString());
                            } catch (_) {
                              finalPrice = double.parse(widget.v['variant'][position1]
                              ['final_price']
                                  .toString());
                            }
                            try {
                              actualprice = int.parse(widget.v['variant'][position1]
                              ['actual_price']
                                  .toString());
                            } catch (_) {
                              actualprice = double.parse(widget.v['variant']
                              [position1]['actual_price']
                                  .toString());
                            }
                            varientID =
                                widget.v['variant'][position1]['ID'].toString();
                            quantValue = widget.v['variant'][position1]['quantity'];
                            print(finalPrice);
                            commonActualLayout(
                              price: int.parse(widget.v['variant'][position1]
                              ['actual_price']
                                  .toString()),
                            );
                            commonAryy.add({
                              'id': widget.v['variant'][position1]['ID'].toString(),
                              'final-price': widget.v['variant'][position1]
                              ['final_price']
                                  .toString(),
                              'actual-price': widget.v['variant'][position1]
                              ['final_price']
                                  .toString(),
                              'weight': value,
                            });
                            print(commonAryy);
                            // print(varientid);
                            // print(addToCart
                            //     .map((e) => e['varientid'] != 0
                            //     ? e['varientid'].toString()
                            //     : e['medicine_id'].toString())
                            //     .contains(varientid));
                            // qualityname = v['variant'][position1]['weight'];
                            // finalPre[index] = v['variant'][position1]['final_price']
                            //     .toString();
                            // ActualPri[index] = v['variant'][position1]
                            // ['actual_price']
                            //     .toString();
                            // varientQty = v['variant'][position1]['quantity']
                            //     .toString();
                          });
                        },
                        items: widget.v['variant']
                            .map<DropdownMenuItem<dynamic>>((value) {
                          return DropdownMenuItem<dynamic>(
                            value: value['weight'],
                            child: Text(
                              value['weight'],
                              style: Sty().mediumText.copyWith(
                                color: Color(0xff244D73),
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  quantValue != null
                      ? int.parse(finalPrice
                      .toString()
                      .toString()
                      .replaceAll(RegExp(r"\D"), "")) ==
                      int.parse(actualprice
                          .toString()
                          .replaceAll(RegExp(r"\D"), ""))
                      ? Container()
                      : Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: priceStrikeWidget('${actualprice}'),
                  )
                      : Container(),
                  quantValue != null
                      ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: Dim().d12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '₹ ${finalPrice}',
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Clr().textSecondaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(flex: 2, child: addtoCartLayout())
                      ],
                    ),
                  )
                      : Container(),
                  quantValue != null
                      ? SizedBox(
                    height: Dim().d6,
                  )
                      : Container(),
                  quantValue == null
                      ? Padding(
                    padding: EdgeInsets.only(
                        left: Dim().d8, right: Dim().d8, top: 24.0),
                    child: Text(
                      'Out Of Stock',
                      style: Sty().mediumText.copyWith(color: Clr().errorRed),
                    ),
                  )
                      : Container(),
                ],
              ),
            ),
          ],
        ));
  }

  Widget priceStrikeWidget(String amount) {
    return Container(
        margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Text("₹" + amount.toString(),
            style: TextStyle(
                decoration: TextDecoration.lineThrough,
                fontSize: 12.0,
                color: Colors.grey)));
  }

  addtoCartLayout() {
    int position = addToCart.indexWhere(
        (element) => element['varientid'].toString() == varientID.toString());
    return addToCart
            .map((e) => e['varientid'].toString())
            .contains(varientID.toString())
        ? Container(
            height: 36.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dim().d8),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomLeft,
                colors: <Color>[
                  Color(0xff1964aa),
                  Color(0xff5AA6EC),
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                    onTap: () {
                      setState(() {
                        int counter = addToCart[position]['counter'];
                        var acutal;
                        try {
                          acutal = int.parse(
                              addToCart[position]['actualPrice'].toString().replaceAll(new RegExp(r"\D"), ""));
                        } catch (_) {
                          acutal = double.parse(
                              addToCart[position]['actualPrice'].toString());
                        }
                        var price;
                        try {
                          price = int.parse(
                              addToCart[position]['price'].toString().replaceAll(new RegExp(r"\D"), ""));
                        } catch (_) {
                          price = double.parse(
                              addToCart[position]['price'].toString());
                        }
                        counter == 1
                            ? Store.deleteItem(
                                0, int.parse(varientID.toString()))
                            : counter--;
                        var newPrice = price - acutal;
                        if (counter > 0) {
                          _updateItem(
                                  addToCart[position]['medicine_id'],
                                  addToCart[position]['varientid'],
                                  addToCart[position]['name'].toString(),
                                  addToCart[position]['image'].toString(),
                                  newPrice.toString(),
                                  addToCart[position]['actualPrice'].toString(),
                                  addToCart[position]['description'].toString(),
                                  counter)
                              .then((value) {
                            newPrice = 0;
                            counter = 0;
                            _refreshData();
                          });
                        }
                      });
                    },
                    child: Icon(
                      Icons.remove,
                      size: 20.0,
                      color: Clr().white,
                    )),
                Text(
                  '${addToCart[position]['counter']}',
                  style: TextStyle(fontSize: 12.0, color: Clr().white),
                ),
                InkWell(
                    onTap: () {
                      setState(() {
                        int counter = addToCart[position]['counter'];
                        var acutal;
                        try {
                          acutal = int.parse(
                              addToCart[position]['actualPrice'].toString().replaceAll(new RegExp(r"\D"), ""));
                        } catch (_) {
                          acutal = double.parse(
                              addToCart[position]['actualPrice'].toString());
                        }
                        var price;
                        try {
                          price = int.parse(
                              addToCart[position]['price'].toString().replaceAll(new RegExp(r"\D"), ""));
                        } catch (_) {
                          price = double.parse(
                              addToCart[position]['price'].toString());
                        }
                        counter == int.parse(quantValue.toString())
                            ? STM().displayToast(
                                'This product quantity is ${quantValue.toString()}')
                            : counter++;
                        var newPrice = price + acutal;
                        _updateItem(
                                addToCart[position]['medicine_id'],
                                addToCart[position]['varientid'],
                                addToCart[position]['name'].toString(),
                                addToCart[position]['image'].toString(),
                                newPrice.toString(),
                                addToCart[position]['actualPrice'].toString(),
                                addToCart[position]['description'].toString(),
                                counter)
                            .then((value) {
                          newPrice = 0;
                          counter = 0;
                          _refreshData();
                        });
                      });
                    },
                    child: Icon(
                      Icons.add,
                      size: 20.0,
                      color: Clr().white,
                    )),
              ],
            ),
          )
        : InkWell(
            onTap: () {
              setState(() {
                _refreshData();
                _addItem(
                        int.parse(widget.v['ID'].toString()),
                        int.parse(varientID.toString()),
                        '${widget.v['name']}',
                        widget.v['images'].isEmpty
                            ? ''
                            : widget.v['images'][0]['img_product'],
                        finalPrice.toString(),
                        finalPrice.toString(),
                        dropdownValue,
                        1)
                    .then((value) {
                  _refreshData();
                });
              });
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dim().d8),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomLeft,
                  colors: <Color>[
                    Color(0xff1964aa),
                    Color(0xff5AA6EC),
                  ],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: Dim().d14, vertical: Dim().d4),
                child: Center(
                    child: Text('+',
                        style: Sty().smallText.copyWith(
                            fontSize: Dim().d20, color: Clr().white))),
              ),
            ),
          );
  }
}
