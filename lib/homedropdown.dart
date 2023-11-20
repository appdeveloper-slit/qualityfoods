import 'package:flutter/material.dart';
import 'package:qf/localstore.dart';
import 'package:qf/manage/static_method.dart';
import 'package:qf/values/colors.dart';
import 'package:qf/values/dimens.dart';
import 'package:qf/values/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class homeDropdown extends StatefulWidget {
  final data;

  const homeDropdown({super.key, this.data});

  @override
  State<homeDropdown> createState() => _homeDropdownState();
}

class _homeDropdownState extends State<homeDropdown> {
  List<dynamic> addToCart = [];

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

  Map v = {};

  getSessionData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    //
    STM().checkInternet(context, widget).then((value) {
      if (value) {
        _refreshData();
      }
    });
  }

  Future<void> _addItem(medicine_id, varientid, name, image, price, actualPrice,
      description, counter) async {
    await Store.createItem(medicine_id, varientid, name, image, price,
        actualPrice, description, counter);
  }

  @override
  void initState() {
    // TODO: implement initState\
    getSessionData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    v = widget.data;
    int position = addToCart.indexWhere(
        (element) => element['medicine_id'].toString() == v['ID'].toString());
    return addToCart
            .map((e) => e['medicine_id'].toString())
            .contains(v['ID'].toString())
        ? Container(
            height: Dim().d36,
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
              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                            ? Store.deleteItem(int.parse(v['ID'].toString()), 0)
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
                  style: TextStyle(fontSize: 14.0, color: Clr().white),
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
                        counter == int.parse(v['qty'])
                            ? STM().displayToast(
                                'This product quantity is ${v['qty']}')
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
                _addItem(
                        int.parse(v['ID'].toString()),
                        0,
                        '${v['name']}',
                        v['images'].isNotEmpty
                            ? v['images'][0]['img_product']
                            : '',
                        v['final_price'].toString(),
                        v['final_price'].toString(),
                        '',
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
    return const Placeholder();
  }
}
