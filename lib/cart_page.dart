// import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart';
// import './appbar_gradientlook.dart';

// List<CartItem> cartitems = [];
// // TODO : Call set state in main class...

// class CartScreen extends StatefulWidget {
//   const CartScreen({Key? key}) : super(key: key);

//   @override
//   State<CartScreen> createState() => CartScreenState();
// }

// class CartScreenState extends State<CartScreen> {
//   void globalSetState(){
//     print("GLOBAL SET STATE CALLED!");
//     if(mounted){
//     setState(() {
//       cartitems = cartitems;
//     });
//     }
//   }

//   void addItems(){
//     for (int i = 1; i<5; i++){
//         cartitems.add(CartItem(productTitle: "test", productAmount: "100" + i.toString(), productVariant: "10 KG", productQuantity: "1", setStateSuper: globalSetState));
//     }
//   }

//   @override
//   void initState() {
//     addItems();
//     super.initState();
//   }

  

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("My Cart"),
//         flexibleSpace: barGredient(),
//       ),
//       body: SingleChildScrollView(
//         child: Container(
//           // margin:EdgeInsets.all(25),
      
//           child: Center(
//             child: Scrollbar(
//               child: Column(
//                 children: cartitems,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//   }


// class CartItem extends StatefulWidget {
//   String productTitle;
//   String productAmount;
//   String productVariant;
//   String productQuantity;
//   // int current_index;
//   final Function setStateSuper;

//   CartItem(
//       {required this.productTitle,
//       required this.productAmount,
//       required this.productVariant,
//       required this.productQuantity,
//       // required this.current_index,
//       required this.setStateSuper});
//   CartItemState createState() => new CartItemState(
//       productTitle: this.productTitle,
//       productAmount: this.productAmount,
//       productVariant: this.productVariant,
//       productQuantity: this.productQuantity,
//       // current_index: this.current_index,
//       setStateSuper: this.setStateSuper);
// }

// class CartItemState extends State<CartItem> {
//   String productTitle;
//   String productAmount;
//   String productVariant;
//   String productQuantity;
//   // int current_index;
//   final Function setStateSuper;

//   CartItemState(
//       {required this.productTitle,
//       required this.productAmount,
//       required this.productVariant,
//       required this.productQuantity,
//       // required this.current_index,
//       required this.setStateSuper});
//   var cartamt = 1;
//   Widget build(BuildContext context) {
//     return Container(
//         margin: EdgeInsets.all(10),
//         padding: EdgeInsets.all(5),
//         decoration: BoxDecoration(
//             border: Border.all(width: 1, color: Colors.orange),
//             borderRadius: BorderRadius.circular(10.0)),
//         // width: MediaQuery.of(context).size.width - 100,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Image.network(
//                   "https://5.imimg.com/data5/AL/MM/TB/SELLER-5742893/everest-spices-500x500.jpg",
//                   width: 180,
//                   height: 120,
//                 ),
//                 Container(
//                   margin: EdgeInsets.only(top: 25),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Align(
//                           alignment: Alignment.centerLeft,
//                           child: Container(
//                             width: 190,
//                             child: Text(
//                               productTitle.toString(),
//                               style: TextStyle(
//                                   fontWeight: FontWeight.bold, fontSize: 20),
//                               textAlign: TextAlign.left,
//                             ),
//                           )),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           Text("Amount  :  ",
//                               style: TextStyle(
//                                   fontSize: 18, fontWeight: FontWeight.bold)),
//                           Text(
//                             "₹" + productAmount.toString(),
//                             style: TextStyle(fontSize: 18),
//                           )
//                         ],
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           Text(
//                             "Variant  :  ",
//                             style: TextStyle(
//                                 fontSize: 18, fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             productVariant.toString(),
//                             style: TextStyle(fontSize: 18),
//                           )
//                         ],
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           Text(
//                             "Qty  :  ",
//                             style: TextStyle(
//                                 fontSize: 18, fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             productQuantity.toString(),
//                             style: TextStyle(fontSize: 18),
//                           )
//                         ],
//                       ),
//                     ],
//                   ),
//                 )
//               ],
//             ),
//             SizedBox(
//               width: MediaQuery.of(context).size.width - 100,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       TextButton(
//                           onPressed: () {
//                             print(cartamt);
//                             setState(() {
//                               cartamt++;
//                             });
                              
                              
//                           },
//                           child: Text(
//                             "+",
//                             style: TextStyle(fontSize: 18),
//                           )),
//                       Container(
//                         child: Text(
//                           cartamt.toString(),
//                           style: TextStyle(fontSize: 12),
//                         ),
//                         decoration: BoxDecoration(
//                             border: Border.all(width: 1, color: Colors.orange),
//                             borderRadius: BorderRadius.circular(10.0)),
//                         padding: EdgeInsets.all(10),
//                         height: 35,
//                       ),
//                       TextButton(
//                           onPressed: () {
//                             setState(() {
//                               cartamt--;
//                             });
                              
                              
//                           },
//                           child: Text(
//                             "-",
//                             style: TextStyle(fontSize: 18),
//                           )),
//                     ],
//                   ),
//                   TextButton(
//                       onPressed: () {
//                         // print(cartitems);
//                         print(current_index);
//                           cartitems.removeAt(current_index); 
//                           setStateSuper();
//                       },
//                       child: Icon(Icons.delete))
//                 ],
//               ),
//             ),
//           ],
//         ));
//   }
// }
