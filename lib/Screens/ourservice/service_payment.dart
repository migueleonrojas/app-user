import 'dart:async';

import 'package:oilapp/Model/vehicle_model.dart';
import 'package:oilapp/Screens/home_screen.dart';
import 'package:oilapp/Screens/orders/myservice_order_by_vehicle_screen.dart';
import 'package:oilapp/Screens/ourservice/backend_orderservice.dart';

import 'package:oilapp/config/config.dart';
import 'package:oilapp/widgets/confirm_animation_button.dart';
import 'package:oilapp/widgets/simpleAppbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ServicePaymentPage extends StatefulWidget {
  final String? addressId;
  final int? totalPrice;
  final VehicleModel vehicleModel;

  const ServicePaymentPage({
    Key? key,
    this.addressId,
    this.totalPrice, 
    required this.vehicleModel,
  }) : super(key: key);
  @override
  _ServicePaymentPageState createState() => _ServicePaymentPageState();
}

class _ServicePaymentPageState extends State<ServicePaymentPage> {
  
  
  bool isTap = false;
  bool goOrders = false;
  bool loading = false;
  @override
  Widget build(BuildContext context) {
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
          title: const Text(
            "Metodo de Pago",
            style: TextStyle(
              fontSize: 20,
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
              const Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    "Elija el método de pago",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                    .collection(AutoParts.collectionUser)
                    .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
                    .collection(AutoParts.vehicles)
                    .doc(widget.vehicleModel.vehicleId)
                    .collection('ServiceCart')
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
                            ? ElevatedButton(
                                onPressed: () async {
                                  loading = true;
                                  setState(() {});
                                  for (int i = 0; i < snapshot.data!.docs.length; i++) {
                                    String orderId = DateTime.now().microsecondsSinceEpoch.toString();
                                    await BackEndOrderService()
                                        .writeServiceOrderDetailsForUser(
                                      (snapshot.data!.docs[i] as dynamic).data()['servicecartId'],
                                      widget.vehicleModel.vehicleId!,
                                      orderId,
                                      widget.addressId!,
                                      widget.totalPrice!,
                                      "Pago en efectivo",
                                      (snapshot.data!.docs[i] as dynamic).data()['serviceId'],
                                      (snapshot.data!.docs[i] as dynamic).data()['serviceName'],
                                      (snapshot.data!.docs[i] as dynamic).data()['date'],
                                      (snapshot.data!.docs[i] as dynamic).data()['serviceImage'],
                                      (snapshot.data!.docs[i] as dynamic).data()['categoryName'],
                                      (snapshot.data!.docs[i] as dynamic).data()['originalPrice'],
                                      (snapshot.data!.docs[i] as dynamic).data()['newPrice'],
                                      (snapshot.data!.docs[i] as dynamic).data()['quantity'],
                                      (snapshot.data!.docs[i] as dynamic).data()['observations'],
                                      context,
                                    );
                                  }

                                  Route route = MaterialPageRoute(builder: (_) => MyServiceOrderByVehicleScreen(vehicleModel: widget.vehicleModel));
                                  Navigator.pushAndRemoveUntil(context, route, (route) => false);
                                    /* Timer(Duration(seconds: 2), () {
                                      /* setState(() {
                                        isTap = false;
                                        goHome = true;
                                      }); */
                                    }); */
                                   
                                    
                                  
                                },
                                child: const Text('Confirmar'),
                              )
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
                                  /* padding: EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  color: Colors.deepOrangeAccent[200], */
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => HomeScreen()));
                                    setState(() {
                                      goOrders = false;
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.home_outlined,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    "Ir a Inicio",
                                    style: TextStyle(
                                      fontSize: 18,
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 3,
          child: ListTile(
            leading: Image.asset(
              leadingImage,
              width: 40,
              height: 40,
            ),
            title: Text(
              title,
              style: TextStyle(
                fontSize: 18,
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
