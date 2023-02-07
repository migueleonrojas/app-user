import 'dart:async';

import 'package:oilapp/Model/cart_model.dart';
import 'package:oilapp/Screens/home_screen.dart';
import 'package:oilapp/Screens/orders/myOrder_Screen.dart';
import 'package:oilapp/config/config.dart';
import 'package:oilapp/service/order_service.dart';
import 'package:oilapp/widgets/confirm_animation_button.dart';
import 'package:oilapp/widgets/simpleAppbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  final String? addressId;
  final CartModel? cartModel;
  final int? totalPrice;
  const PaymentPage({
    Key? key,
    this.addressId,
    this.totalPrice,
    this.cartModel,
  }) : super(key: key);
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String orderId = DateTime.now().microsecondsSinceEpoch.toString();
  bool isTap = false;
  bool goOrders = false;
  bool loading = false;

  
  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop:(!goOrders && !loading)
        ? () async {
          if(loading) return false;
          Navigator.pop(context);
          return false;
        }
        : () async {
          
          return false;
        }
      ,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Metodo de Pago",
            style: TextStyle(
              fontSize: size.height * 0.020,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
              fontFamily: "Brand-Regular",
            ),
          ),
          centerTitle: true,
          leading:(!goOrders)
            ?IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                  if(loading) return;
                  Navigator.pop(context);
              },
            )
            :Container()
          ,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.all(size.height * 0.008),
                  child:  Text(
                    "Elige el método de pago",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: size.height * 0.020,
                    ),
                  ),
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection(AutoParts.collectionUser)
                      .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
                      .collection('carts')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.data == null) {
                      return Container();
                    }
                    return Column(
                      children: [
                        PaymentButton(
                          onTap: () async {
                            setState(() {
                              isTap = true;
                            });
                          },
                          leadingImage: "assets/icons/cod.png",
                          title: "Pago en efectivo",
                        ),
                        (isTap)
                            ? 
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(255, 3, 3, 247),
                                shape: const StadiumBorder()
                              ),
                              onPressed: () async {
                              
                              loading = true;
                              setState(() {});
                              
                              await OrderService().writeOrderDetailsForUser(
                                orderId,
                                widget.addressId!,
                                widget.totalPrice!,
                                "Pago en efectivo",
                                context
                              );
                              for(int i = 0;  i < snapshot.data!.docs.length; i++) {
                                if(!mounted) return;
                                await OrderService().addOrderHistory(
                                  orderId,
                                  (snapshot.data!.docs[i] as dynamic).data()['productId'],
                                  (snapshot.data!.docs[i] as dynamic).data()['pName'],
                                  (snapshot.data!.docs[i] as dynamic).data()['pImage'],
                                  (snapshot.data!.docs[i] as dynamic).data()['orginalPrice'],
                                  (snapshot.data!.docs[i] as dynamic).data()['newPrice'],
                                  (snapshot.data!.docs[i] as dynamic).data()['quantity'],
                                  context,
                                );
                              }

                              setState(() {
                                isTap = false;
                                goOrders = true;
                                
                              });

                            }, 
                            child: const Text('Confirmar'))
                            /* AnimatedConfirmButton(
                                onTap: () async {
                                  print('objectassaasasasasas');
                                  return;
                                  await OrderService().writeOrderDetailsForUser(
                                    orderId,
                                    widget.addressId!,
                                    widget.totalPrice!,
                                    "Pago en efectivo",
                                    context
                                  );
                                  for (int i = 0;  i < snapshot.data!.docs.length; i++) {
                                    if(!mounted) return;
                                    await OrderService().addOrderHistory(
                                      orderId,
                                      (snapshot.data!.docs[i] as dynamic).data()['productId'],
                                      (snapshot.data!.docs[i] as dynamic).data()['pName'],
                                      (snapshot.data!.docs[i] as dynamic).data()['pImage'],
                                      (snapshot.data!.docs[i] as dynamic).data()['orginalPrice'],
                                      (snapshot.data!.docs[i] as dynamic).data()['newPrice'],
                                      (snapshot.data!.docs[i] as dynamic).data()['quantity'],
                                      context,
                                    );
                                  }
                                  Timer(const Duration(seconds: 2), () {
                                    setState(() {
                                      isTap = false;
                                      goOrders = true;
                                    });
                                  });
                                  
                                  
                                },
                                animationDuration:
                                    const Duration(milliseconds: 0),
                                initialText: "Confirmar",
                                finalText: "Orden realizada",
                                iconData: Icons.check,
                                iconSize: 32.0,
                                buttonStyle: ConfirmButtonStyle(
                                  primaryColor: Colors.green.shade600,
                                  secondaryColor: Colors.white,
                                  elevation: 10.0,
                                  initialTextStyle: const TextStyle(
                                    fontSize: 22.0,
                                    color: Colors.white,
                                  ),
                                  finalTextStyle: TextStyle(
                                    fontSize: 22.0,
                                    color: Colors.green.shade600,
                                  ),
                                  borderRadius: 10.0,
                                ),
                              ) */
                            : Container(),
                        (goOrders)
                            ? Container(
                                decoration: const BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blueGrey,
                                      offset: Offset(1, 3),
                                      blurRadius: 6,
                                      spreadRadius: -3,
                                    ),
                                  ],
                                ),
                                child: ElevatedButton.icon(
                                  
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color.fromARGB(255, 3, 3, 247),
                                    shape: const StadiumBorder()
                                  ),
                                  /* padding: EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  color: Colors.deepOrangeAccent[200], */
                                  onPressed: () {
                                    Route route = MaterialPageRoute(builder: (_) => MyOrderScreen());
                                    Navigator.pushAndRemoveUntil(context, route, (route) => false);
                                  /*   Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => HomeScreen()));
                                    setState(() {
                                      goHome = false;
                                    }); */
                                  },
                                  icon: const Icon(
                                    Icons.shopping_bag,
                                    color: Colors.white,
                                  ),
                                  label:  Text(
                                    "Ver las ordenes de productos",
                                    style: TextStyle(
                                      fontSize: size.height *0.022,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    );
                  }),
              PaymentButton(
                onTap: () {},
                leadingImage: "assets/icons/online_payment.png",
                title: "Pago en línea",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PaymentButton extends StatelessWidget {
  const PaymentButton({
    Key? key,
    required this.onTap,
    required this.leadingImage,
    required this.title,
  }) : super(key: key);
  final VoidCallback onTap;
  final String leadingImage;
  final String title;

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.all(size.height * 0.008),
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(size.height * 0.008),
          ),
          elevation: 3,
          child: ListTile(
            leading: Image.asset(
              leadingImage,
              width: size.width * 0.110,
              height: size.height * 0.050,
            ),
            title: Text(
              title,
              style: TextStyle(
                fontSize: size.height * 0.022,
                letterSpacing: 1,
                fontWeight: FontWeight.w600,
                fontFamily: "Brand-Regular",
              ),
            ),
          ),
        ),
      ),
    );
  }
}
