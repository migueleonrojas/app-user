import 'package:oilapp/Screens/home_screen.dart';
import 'package:oilapp/Screens/orders/myOrder_details_secreen.dart';
import 'package:oilapp/Screens/orders/myservice_order_screen.dart';

import 'package:oilapp/config/config.dart';
import 'package:oilapp/widgets/emptycardmessage.dart';
import 'package:oilapp/widgets/loading_widget.dart';
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
  void initState() {
    super.initState();
    getDocuments();
    scrollController.addListener(() {
      if(scrollController.position.pixels + 500 > scrollController.position.maxScrollExtent){
        getDocumentsNext();
      }
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mis Ordenes de productos",
          style: TextStyle(
            fontSize: 15,
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
      body:  (listDocument.isNotEmpty) 
        ? OrderBody(
            itemCount: listDocument.length,
            data: listDocument,
            scrollController: scrollController,
          )
        : (listDocument.isNotEmpty)
          ? circularProgress()
          : const EmptyCardMessage(
              listTitle: "Sin orden!",
              message: "Comience a comprar desde GlobalOil!",
          )
    );
  }
  Future<void> getDocuments() async {
    

    int limit = 1;

    _docSnapStream = await AutoParts.firestore!
      .collection(AutoParts.collectionUser)
      .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
      .collection(AutoParts.collectionOrders)
      .orderBy("orderTime", descending: true)
      .get();

    lengthCollection = _docSnapStream!.docs.length;
    if(lengthCollection == 0) {
      return;
    }

    if(lengthCollection <= 4){
      limit = lengthCollection;
    }
    else if(lengthCollection > 4){
      limit = 5;
    }

    
    final collection =  AutoParts.firestore!
      .collection(AutoParts.collectionUser)
      .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
      .collection(AutoParts.collectionOrders)
      .orderBy("orderTime", descending: true)
      .limit(limit);

      fetchDocuments(collection);
  }
  fetchDocuments(Query collection){
    collection.get().then((values) {
      collectionState = values; 
      for(final value in values.docs){
        
        listDocument.add(value.data());
      }
      
      setState((){});
      
    
    });
  }
  Future<void> getDocumentsNext() async {
  
    if (isLoading) return;
    isLoading = true;
    await Future.delayed(const Duration(seconds: 1));

    int limit = 1;

    if(lengthCollection == listDocument.length){
      return;
    }
    if((lengthCollection - listDocument.length ) % 5 == 0){
      limit = 5;
    }
    else if((lengthCollection - listDocument.length ) % 5 != 0 && (lengthCollection - listDocument.length ) <= 5){
      limit = lengthCollection - listDocument.length;
    }
    
    // Get the last visible document
    final lastVisible = collectionState!.docs[collectionState!.docs.length-1];
    final collection = AutoParts.firestore!
      .collection(AutoParts.collectionUser)
      .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
      .collection(AutoParts.collectionOrders)
      .orderBy("orderTime", descending: true)
      .startAfterDocument(lastVisible)
      .limit(limit);

    fetchDocuments(collection);
    isLoading = false;
    if(scrollController.position.pixels + 100 <= scrollController.position.maxScrollExtent) return;
    scrollController.animateTo(
      scrollController.position.pixels + 120, 
      duration: const Duration(milliseconds: 300), 
      curve: Curves.fastOutSlowIn
    );

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
                padding: const EdgeInsets.all(10),
                child: Container(
                  child: Column(
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: "ID de la Orden: ",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.deepOrangeAccent,
                              ),
                            ),
                            TextSpan(
                              text: data[index]['orderId'],
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      (data[index][AutoParts.productID].length  > 1)
                      ?Text(
                        "(" +
                            (data[index][AutoParts.productID].length - 1)
                                .toString() +
                            " elemento)",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      )
                      :Text(
                        "(" +
                            (data[index][AutoParts.productID].length - 1)
                                .toString() +
                            " elementos)",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "Precio total: " +
                            data[index]['totalPrice'].toString() +
                            " \$.",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(DateFormat.yMMMd().add_jm().format(myDateTime)),
                      Text(timeago
                          .format(DateTime.tryParse(data[index]
                              ['orderTime']
                              .toDate()
                              .toString())!)
                          .toString()),
                      ElevatedButton(
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
                        child: const Text(
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
                height: 10,
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
