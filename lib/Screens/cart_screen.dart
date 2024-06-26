import 'package:auto_size_text/auto_size_text.dart';
import 'package:oil_app/Model/cart_model.dart';

import 'package:oil_app/Screens/Address/address.dart';

import 'package:oil_app/config/config.dart';
import 'package:oil_app/counter/cart_item_counter.dart';
import 'package:oil_app/counter/total_money.dart';
import 'package:oil_app/service/cart_service.dart';
import 'package:oil_app/widgets/emptycardmessage.dart';
import 'package:oil_app/widgets/loading_widget.dart';
import 'package:oil_app/widgets/mycustomdrawer.dart';
import 'package:oil_app/widgets/simpleAppbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int? totalPrice;

  @override
  void initState() {
    super.initState();
    totalPrice = 0;
    Provider.of<TotalAmount>(context, listen: false).display(0);
  }

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: simpleAppBar(false, "Mi Carro de Compras", context),
      floatingActionButton: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection(AutoParts.collectionUser)
              .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
              .collection('carts')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }

            return (snapshot.data!.docs.length == 0)
                ? Container()
                : FloatingActionButton.extended(
                    onPressed: () {
                      if (AutoParts.sharedPreferences!
                              .getStringList(AutoParts.userCartList)!
                              .length ==
                          1) {
                        Fluttertoast.showToast(msg: "Tu carro de compras esta vacio.");
                      } else {
                        Route route = MaterialPageRoute(
                            builder: (c) => Address(
                                  totalPrice: totalPrice!,
                                ));
                        Navigator.push(context, route);
                      }
                    },
                    label: AutoSizeText(
                      "VERIFICAR",
                      style: TextStyle(
                        fontSize: size.height * 0.020,
                        fontWeight: FontWeight.w600,
                        color: Colors.white
                      ),
                    ),
                    
                    backgroundColor: Color.fromARGB(255, 3, 3, 247),
                    icon: Icon(Icons.shopping_cart_outlined,color: Colors.white),
                  );
          }),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Consumer2<TotalAmount, CartItemCounter>(
              builder: (context, amountProvider, cartProvider, c) {
                return Padding(
                  padding: EdgeInsets.all(size.height * 0.010),
                  child: Center(
                    child: ((AutoParts.sharedPreferences!
                                    .getStringList(AutoParts.userCartList)!
                                    .length -
                                1) ==
                            0)
                        ? Container()
                        : AutoSizeText(
                            "Precio Total: \$ ${amountProvider.totalPrice.toString()}",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: size.height * 0.025,
                                fontWeight: FontWeight.w500),
                          ),
                  ),
                );
              },
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection(AutoParts.collectionUser)
                  .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
                  .collection('carts')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(
                    child: circularProgress(),
                );
                
                return (snapshot.data!.docs.length == 0)
                    ?  const  EmptyCardMessage(
                        listTitle: "El Carro de compra esta vacio",
                        message: "Comienza a agregar artículos a tu carro de compras",
                      )
                    : Container(
                        height: MediaQuery.of(context).size.height,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (BuildContext context, int index) {
                            CartModel cartModel = CartModel.fromJson(
                                snapshot.data!.docs[index].data());

                            if (index == 0) {
                              totalPrice = 0;
                              totalPrice = cartModel.newPrice! + totalPrice!;
                            } else {
                              totalPrice = cartModel.newPrice! + totalPrice!;
                            }

                            if (snapshot.data!.docs.length - 1 == index) {
                              WidgetsBinding.instance.addPostFrameCallback((t) {
                                Provider.of<TotalAmount>(context, listen: false)
                                    .display(totalPrice!);
                              });
                            }
                            return Card(
                              elevation: 2,
                              child: ListTile(
                                leading: Image.network(
                                  cartModel.pImage!,
                                  width: size.width * 0.14,
                                  height: size.height * 0.060,
                                ),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AutoSizeText(
                                      cartModel.pName!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: size.width * 0.30,
                                          child: OutlinedButton.icon(
                                            style: ButtonStyle(
                                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(size.height * 0.005),
                                                  side: const BorderSide(color: Colors.red)
                                                )
                                              ),
                                              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                                                EdgeInsets.zero
                                              )
                                            ),
                                            icon: const Icon(
                                              Icons.delete_outline_outlined,
                                              color: Colors.deepOrangeAccent,
                                            ),
                                            label: const AutoSizeText(
                                              'Remover',
                                              style: TextStyle(
                                                color: Colors.deepOrangeAccent,
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                CartService()
                                                    .removeItemFromUserCart(
                                                  cartModel.productId!,
                                                  totalPrice!,
                                                  cartModel.quantity.toString(),
                                                  context,
                                                );
                                              });
                                            },
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: size.width * 0.065,
                                              height: size.height * 0.035,
                                              child: OutlinedButton(
                                                style: ButtonStyle(
                                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                    RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(size.height * 0.005),
                                                      side: const BorderSide(color: Colors.red)
                                                    )
                                                  ),
                                                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                                                    EdgeInsets.zero
                                                  )
                                                ),
                                                child: Icon(Icons.remove,
                                                    size: size.height * 0.018),
                                                onPressed: () {
                                                  if (cartModel.quantity! > 1) {
                                                    setState(() {
                                                      cartModel.quantity = cartModel.quantity! - 1;
                                                    });
                                                    CartService().updateCart(
                                                      cartModel.productId!,
                                                      cartModel.pName!,
                                                      cartModel.pImage!,
                                                      cartModel.orginalPrice!,
                                                      cartModel
                                                          .newPrice = cartModel
                                                              .orginalPrice! *
                                                          cartModel.quantity!,
                                                      cartModel.quantity!,
                                                      cartModel.quantity
                                                          .toString(),
                                                      context,
                                                    );
                                                  }
                                                },
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  EdgeInsets.symmetric(
                                                horizontal: size.height * 0.006,
                                              ),
                                              child: AutoSizeText(
                                                '${cartModel.quantity}',
                                                style: TextStyle(
                                                  fontFamily: "Brand-Regular",
                                                  fontSize: size.height * 0.016,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: size.width * 0.065,
                                              height: size.height * 0.035,
                                              child: OutlinedButton(
                                                style: ButtonStyle(
                                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                    RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(size.height * 0.005),
                                                      side: const BorderSide(color: Colors.red)
                                                    )
                                                  ),
                                                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                                                    EdgeInsets.zero
                                                  )
                                                ),
                                                child:
                                                    Icon(Icons.add, size: size.height * 0.018),
                                                onPressed: () {
                                                  setState(() {
                                                    cartModel.quantity = cartModel.quantity! + 1;
                                                  });
                                                  CartService().updateCart(
                                                    cartModel.productId!,
                                                    cartModel.pName!,
                                                    cartModel.pImage!,
                                                    cartModel.orginalPrice!,
                                                    cartModel.newPrice =
                                                        cartModel.orginalPrice! *
                                                            cartModel.quantity!,
                                                    cartModel.quantity!,
                                                    cartModel.quantity
                                                        .toString(),
                                                    context,
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Column(
                                  children: [
                                    AutoSizeText(
                                      '\$${cartModel.newPrice}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepOrangeAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}
