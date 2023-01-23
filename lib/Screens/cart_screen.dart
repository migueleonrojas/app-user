import 'package:oilapp/Model/cart_model.dart';

import 'package:oilapp/Screens/Address/address.dart';

import 'package:oilapp/config/config.dart';
import 'package:oilapp/counter/cart_item_counter.dart';
import 'package:oilapp/counter/total_money.dart';
import 'package:oilapp/service/cart_service.dart';
import 'package:oilapp/widgets/emptycardmessage.dart';
import 'package:oilapp/widgets/loading_widget.dart';
import 'package:oilapp/widgets/mycustomdrawer.dart';
import 'package:oilapp/widgets/simpleAppbar.dart';
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
    return Scaffold(
      appBar: simpleAppBar(false, "Mi Carro de Compras"),
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
                    label: const Text(
                      "VERIFICAR",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    
                    backgroundColor: Color.fromARGB(255, 3, 3, 247),
                    icon: Icon(Icons.shopping_cart_outlined),
                  );
          }),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Consumer2<TotalAmount, CartItemCounter>(
              builder: (context, amountProvider, cartProvider, c) {
                return Padding(
                  padding: EdgeInsets.all(8),
                  child: Center(
                    child: ((AutoParts.sharedPreferences!
                                    .getStringList(AutoParts.userCartList)!
                                    .length -
                                1) ==
                            0)
                        ? Container()
                        : Text(
                            "Precio Total: \$ ${amountProvider.totalPrice.toString()}",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
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
                                  width: 50,
                                  height: 50,
                                ),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
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
                                          width: 100,
                                          child: OutlinedButton.icon(
                                            style: ButtonStyle(
                                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(5),
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
                                            label: const Text(
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
                                              width: 25,
                                              height: 25,
                                              child: OutlinedButton(
                                                style: ButtonStyle(
                                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                    RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(5),
                                                      side: const BorderSide(color: Colors.red)
                                                    )
                                                  ),
                                                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                                                    EdgeInsets.zero
                                                  )
                                                ),
                                                child: const Icon(Icons.remove,
                                                    size: 18),
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
                                                  const EdgeInsets.symmetric(
                                                horizontal: 6,
                                              ),
                                              child: Text(
                                                '${cartModel.quantity}',
                                                style: TextStyle(
                                                  fontFamily: "Brand-Regular",
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 25,
                                              height: 25,
                                              child: OutlinedButton(
                                                style: ButtonStyle(
                                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                    RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(5),
                                                      side: const BorderSide(color: Colors.red)
                                                    )
                                                  ),
                                                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                                                    EdgeInsets.zero
                                                  )
                                                ),
                                                child:
                                                    Icon(Icons.add, size: 18),
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
                                    Text(
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
