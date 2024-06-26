
import 'package:auto_size_text/auto_size_text.dart';
import 'package:oil_app/Screens/ourservice/backend_orderservice.dart';
import 'package:oil_app/Screens/ourservice/service_shipping_address.dart';
import 'package:oil_app/config/config.dart';
import 'package:oil_app/counter/service_item_counter.dart';
import 'package:oil_app/counter/service_total_money.dart';
import 'package:oil_app/widgets/emptycardmessage.dart';
import 'package:oil_app/widgets/loading_widget.dart';
import 'package:oil_app/widgets/simpleAppbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class OrderServiceScreen extends StatefulWidget {
  const OrderServiceScreen({Key? key}) : super(key: key);
  @override
  _OrderServiceScreenState createState() => _OrderServiceScreenState();
}

class _OrderServiceScreenState extends State<OrderServiceScreen> {
  final Stream stream = FirebaseFirestore.instance
      .collection(AutoParts.collectionUser)
      .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
      .collection('ServiceCart')
      .snapshots();
  int? totalPrice;

  @override
  void initState() {
    super.initState();
    totalPrice = 0;
    Provider.of<ServiceTotalPrice>(context, listen: false).display(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(false, "Order Service",context),
      floatingActionButton: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection(AutoParts.collectionUser)
              .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
              .collection('ServiceCart')
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
                              .getStringList(AutoParts.userServiceList)!
                              .length ==
                          1) {
                        Fluttertoast.showToast(msg: "Your cart is empty.");
                      } else {
                        Route route = MaterialPageRoute(
                            builder: (c) => ServiceShippingAddress(
                                  totalPrice: totalPrice!,
                                ));
                        Navigator.push(context, route);
                      }
                    },
                    label: AutoSizeText(
                      "CHECKOUT",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor: Colors.deepOrangeAccent[200],
                    icon: Icon(Icons.shopping_cart_outlined),
                  );
          }),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Consumer2<ServiceTotalPrice, ServiceItemCounter>(
              builder: (context, amountProvider, serviceProvider, c) {
                return Padding(
                  padding: EdgeInsets.all(8),
                  child: Center(
                    child: ((AutoParts.sharedPreferences!
                                    .getStringList(AutoParts.userServiceList)!
                                    .length -
                                1) ==
                            0)
                        ? Container()
                        : AutoSizeText(
                            "Total Price: \৳ ${amountProvider.totalPrice.toString()}",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w500),
                          ),
                  ),
                );
              },
            ),
            StreamBuilder<QuerySnapshot>(
              stream: stream as dynamic,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return circularProgress();
                return (snapshot.data!.docs.length == 0)
                    ? EmptyCardMessage(
                        listTitle: "Cart is empty",
                        message: "Start adding Service to your Cart",
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            totalPrice = 0;
                            totalPrice =
                                (snapshot.data!.docs[index] as dynamic).data()['newPrice'] +
                                    totalPrice;
                          } else {
                            totalPrice =
                                (snapshot.data!.docs[index] as dynamic).data()['newPrice'] +
                                    totalPrice;
                          }

                          if (snapshot.data!.docs.length - 1 == index) {
                            WidgetsBinding.instance.addPostFrameCallback((t) {
                              Provider.of<ServiceTotalPrice>(context,
                                      listen: false)
                                  .display(totalPrice!);
                            });
                          }
                          return Card(
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                leading: Image.network(
                                  (snapshot.data!.docs[index] as dynamic)
                                      .data()['serviceImage'],
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AutoSizeText(
                                      (snapshot.data!.docs[index] as dynamic)
                                          .data()['serviceName'],
                                      maxLines: 2,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                     /*  color: Colors.blueGrey.withOpacity(0.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ), */
                                      onPressed: () {
                                        BackEndOrderService()
                                            .removeServiceFromUserServiceCart(
                                          (snapshot.data!.docs[index] as dynamic)
                                              .data()['serviceId'],
                                          totalPrice!,
                                          context,
                                        );
                                      },
                                      icon: Icon(
                                        Icons.delete_outline,
                                        color: Colors.white,
                                      ),
                                      label: AutoSizeText(
                                        "Remove",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "✖",
                                            style: TextStyle(
                                              color:
                                                  Colors.deepOrangeAccent[200],
                                            ),
                                          ),
                                          TextSpan(
                                            text: (snapshot.data!.docs[index] as dynamic)
                                                .data()['quantity']
                                                .toString(),
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    AutoSizeText(
                                      "\৳" +
                                          (snapshot.data!.docs[index] as dynamic)
                                              .data()['newPrice']
                                              .toString(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepOrangeAccent[200],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}
