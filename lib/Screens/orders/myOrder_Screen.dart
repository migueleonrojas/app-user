import 'package:auto_size_text/auto_size_text.dart';
import 'package:oil_app/Screens/home_screen.dart';
import 'package:oil_app/Screens/orders/myOrder_details_secreen.dart';
import 'package:oil_app/Screens/orders/myservice_order_screen.dart';
import 'package:oil_app/Screens/products/product_search.dart';

import 'package:oil_app/config/config.dart';
import 'package:oil_app/widgets/emptycardmessage.dart';
import 'package:oil_app/widgets/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class MyOrderScreen extends StatefulWidget {
  @override
  _MyOrderScreenState createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends State<MyOrderScreen> {
  final f = new DateFormat('dd-MM-yyyy');
  final ScrollController scrollController = ScrollController();
  QuerySnapshot<Map<String, dynamic>>? _docSnapStream;
  int lengthCollection = 0;
  bool isLoading =  false;
  List listDocument = [];
  QuerySnapshot? collectionState;

 

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          "Mis Ordenes de productos",
          style: TextStyle(
            fontSize: size.height * 0.022,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
            fontFamily: "Brand-Regular",
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Route route = MaterialPageRoute(
                builder: (_) => HomeScreen(),
              );
              Navigator.push(context, route);
            }, 
            icon: const Icon(Icons.home))
        ],

        /* actions: [
          IconButton(
            icon: Image.asset(
              "assets/icons/service.png",
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) =>  MyServiceOrderScreen()));
            },
          ),
        ], */
      ),
      body: FutureBuilder(
        future: gerOrder(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }

          if(snapshot.data!.isEmpty) {
            return const EmptyCardMessage(
              listTitle: 'No tiene productos',
              message: 'Compre desde el app',
            );
          }

          return OrderBody(
            itemCount: snapshot.data!.length,
            data: snapshot.data!,
            scrollController: scrollController,
          );
        },
      ),
    );
  }


  Future<List<Map<String,dynamic>>> gerOrder() async {

    List <Map<String,dynamic>> listOrders = [];

    QuerySnapshot<Map<String, dynamic>> orders = await AutoParts.firestore!
      .collection(AutoParts.collectionUser)
      .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
      .collection(AutoParts.collectionOrders)
      .orderBy("orderTime", descending: true)
      .get();

    for(final order in orders.docs) {

      listOrders.add(order.data());

    }

    return listOrders;

  }

}

class OrderBody extends StatelessWidget {
  const OrderBody({
    required this.itemCount,
    required this.data,
    required this.scrollController,
    Key? key,
  }) : super(key: key);
  final int itemCount;
  final List data;
  final ScrollController scrollController;
  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;

    return Container(
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        controller: scrollController,
        shrinkWrap: true,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          DateTime myDateTime = (data[index]['orderTime']).toDate();
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.all(size.height * 0.010),
                child: Container(
                  child: Column(
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "ID de la Orden: ",
                              style: TextStyle(
                                fontSize: size.height * 0.022,
                                fontWeight: FontWeight.w600,
                                color: Colors.deepOrangeAccent,
                              ),
                            ),
                            TextSpan(
                              text: data[index]['orderId'],
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: size.height * 0.022,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      (data[index][AutoParts.productID].length  > 1)
                      ?AutoSizeText(
                        "(" +
                            (data[index][AutoParts.productID].length - 1)
                                .toString() +
                            " elemento)",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: size.height * 0.022,
                        ),
                      )
                      :AutoSizeText(
                        "(" +
                            (data[index][AutoParts.productID].length - 1)
                                .toString() +
                            " elementos)",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: size.height * 0.022,
                        ),
                      ),
                      AutoSizeText(
                        "Precio total: " +
                            data[index]['totalPrice'].toString() +
                            " \$.",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: size.height * 0.022,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      AutoSizeText(DateFormat.yMMMd().add_jm().format(myDateTime)),
                      AutoSizeText(timeago
                          .format(DateTime.tryParse(data[index]
                              ['orderTime']
                              .toDate()
                              .toString())!)
                          .toString()),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 3, 3, 247),
                          shape: const StadiumBorder()
                        ),
                        /* shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ), */
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MyOrderDetailsScreen(
                                orderId: data[index]['orderId'],
                                addressId: data[index]['addressID'],
                              ),
                            ),
                          );
                        },
                        /* color: Colors.deepOrangeAccent[200], */
                        child: const AutoSizeText(
                          "Detalle de la Orden",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: size.height * 0.010,
                width: double.infinity,
                color: Colors.blueGrey[50],
              ),
            ],
          );
        },
      ),
    );
  }
}
