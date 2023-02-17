import 'package:auto_size_text/auto_size_text.dart';
import 'package:oilapp/Model/vehicle_model.dart';
import 'package:oilapp/config/config.dart';
import 'package:oilapp/widgets/loading_widget.dart';
import 'package:oilapp/widgets/simpleAppbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyServiceOrderDetailsScreen extends StatefulWidget {
  
  final String orderId;
  final String addressId;

  const MyServiceOrderDetailsScreen({Key? key, required this.orderId, required this.addressId})
      : super(key: key);
  @override
  _MyServiceOrderDetailsScreenState createState() =>
      _MyServiceOrderDetailsScreenState();
}

class _MyServiceOrderDetailsScreenState
    extends State<MyServiceOrderDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(false, "Detalle de la orden", context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("serviceOrder")
                  .where("orderBy", isEqualTo: AutoParts.sharedPreferences!.getString(AutoParts.userUID))
                  .where("orderId", isEqualTo: widget.orderId)
                  .snapshots(),
             /*  stream: FirebaseFirestore.instance
                .collection(AutoParts.collectionUser)
                .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
                .collection(AutoParts.vehicles)
                .doc()
                .collection("serviceOrder")
                .where("orderId", isEqualTo: widget.orderId)
                .snapshots(), */
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return circularProgress();
                }
                return Container(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            leading: Image.network(
                              (snapshot.data!.docs[index] as dynamic).data()['serviceImage'],
                              width: 80,
                              height: 80,
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
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 5),
                                AutoSizeText(
                                  "Fecha: " +
                                      (snapshot.data!.docs[index] as dynamic).data()['date'],
                                  maxLines: 2,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 5),
                                AutoSizeText(
                                  "\$" +
                                      (snapshot.data!.docs[index] as dynamic)
                                          .data()['newPrice']
                                          .toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepOrangeAccent[200],
                                  ),
                                )
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.clear,
                                  size: 17,
                                  color: Colors.deepOrangeAccent[200],
                                ),
                                AutoSizeText(
                                  (snapshot.data!.docs[index] as dynamic)
                                      .data()['quantity']
                                      .toString(),
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            StreamBuilder<QuerySnapshot>(
              stream: AutoParts.firestore!
                  .collection(AutoParts.collectionUser)
                  .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
                  .collection(AutoParts.subCollectionAddress)
                  .where("addressId", isEqualTo: widget.addressId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 20),
                      child: Container(
                        width: double.infinity,
                        child: Table(
                          children: [
                            TableRow(
                              children: [
                                KeyText(msg: "Nombre del Cliente"),
                                AutoSizeText(
                                  (snapshot.data!.docs[index] as dynamic)
                                      .data()['customerName'],
                                ),
                              ],
                            ),
                            TableRow(
                              children: [
                                KeyText(msg: "Teléfono"),
                                AutoSizeText(
                                  (snapshot.data!.docs[index] as dynamic)
                                      .data()['phoneNumber'],
                                ),
                              ],
                            ),
                            TableRow(
                              children: [
                                KeyText(msg: "Ciudad"),
                                AutoSizeText(
                                  (snapshot.data!.docs[index] as dynamic).data()['city'],
                                ),
                              ],
                            ),
                            TableRow(
                              children: [
                                KeyText(msg: "Area"),
                                AutoSizeText(
                                  (snapshot.data!.docs[index] as dynamic).data()['area'],
                                ),
                              ],
                            ),
                            TableRow(
                              children: [
                                KeyText(msg: "Número de la casa"),
                                AutoSizeText(
                                  (snapshot.data!.docs[index] as dynamic)
                                      .data()['houseandroadno'],
                                ),
                              ],
                            ),
                            TableRow(
                              children: [
                                KeyText(msg: "Código de Área"),
                                AutoSizeText(
                                  (snapshot.data!.docs[index] as dynamic).data()['areacode'],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("serviceOrder")
                  .where("orderId", isEqualTo: widget.orderId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container(
                   
                  );
                }
                
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DateTime orderRecivedTime =
                        ((snapshot.data!.docs[index] as dynamic).data()['orderRecivedTime'])
                            .toDate();
                    DateTime beingPreParedTime =
                        
                        ((snapshot.data!.docs[index] as dynamic).data()['beingPreParedTime'])
                            .toDate();
                    DateTime onTheWayTime =
                        ((snapshot.data!.docs[index] as dynamic).data()['onTheWayTime'])
                            .toDate();
                    DateTime deliverdTime =
                        ((snapshot.data!.docs[index] as dynamic).data()['deliverdTime'])
                            .toDate();
                    return Column(
                      children: [
                        ((snapshot.data!.docs[index] as dynamic).data()['orderRecived'] ==
                                'Done')
                            ? Card(
                                elevation: 3,
                                child: Container(
                                  
                                  width: double.infinity,
                                  child: Center(
                                    child: AutoSizeText(
                                      "Estatus de Orden",
                                      style: TextStyle(
                                        letterSpacing: 1,
                                        color: Colors.deepOrangeAccent[200],
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                        Card(
                          elevation: 3,
                          child: Container(
                            height: 500,
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        children: [
                                          IconDoneOrNotDone(
                                            isdone: ((snapshot.data!.docs[index] as dynamic)
                                                            .data()[
                                                        'orderRecived'] ==
                                                    'Done')
                                                ? true
                                                : false,
                                          ),
                                          dividerBetweenDoneIcon(
                                            ((snapshot.data!.docs[index] as dynamic).data()[
                                                        'beingPrePared'] ==
                                                    'Done')
                                                ? true
                                                : false,
                                          ),
                                          IconDoneOrNotDone(
                                            isdone: ((snapshot.data!.docs[index] as dynamic)
                                                            .data()[
                                                        'beingPrePared'] ==
                                                    'Done')
                                                ? true
                                                : false,
                                          ),
                                          dividerBetweenDoneIcon(
                                            ((snapshot.data!.docs[index] as dynamic)
                                                        .data()['onTheWay'] ==
                                                    'Done')
                                                ? true
                                                : false,
                                          ),
                                          IconDoneOrNotDone(
                                            isdone: ((snapshot.data!.docs[index] as dynamic)
                                                        .data()['onTheWay'] ==
                                                    'Done')
                                                ? true
                                                : false,
                                          ),
                                          dividerBetweenDoneIcon(
                                            ((snapshot.data!.docs[index] as dynamic)
                                                        .data()['deliverd'] ==
                                                    'Done')
                                                ? true
                                                : false,
                                          ),
                                          IconDoneOrNotDone(
                                            isdone: ((snapshot.data!.docs[index] as dynamic)
                                                        .data()['deliverd'] ==
                                                    'Done')
                                                ? true
                                                : false,
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: 20),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            OrderStatusCard(
                                              title: "Orden recibida",
                                              isDone: ((snapshot.data!.docs[index] as dynamic)
                                                              .data()[
                                                          'orderRecived'] ==
                                                      "Done")
                                                  ? true
                                                  : false,
                                              time: DateFormat.yMMMd()
                                                  .add_jm()
                                                  .format(orderRecivedTime),
                                            ),
                                            SizedBox(height: 15),
                                            OrderStatusCard(
                                              title: "Persona del servicio preparado",
                                              isDone: ((snapshot.data!.docs[index] as dynamic)
                                                              .data()[
                                                          'beingPrePared'] ==
                                                      'Done')
                                                  ? true
                                                  : false,
                                              time: DateFormat.yMMMd()
                                                  .add_jm()
                                                  .format(beingPreParedTime),
                                            ),
                                            SizedBox(height: 15),
                                            OrderStatusCard(
                                              title: "En camino",
                                              isDone: ((snapshot.data!.docs[index] as dynamic)
                                                          .data()['onTheWay'] ==
                                                      'Done')
                                                  ? true
                                                  : false,
                                              time: DateFormat.yMMMd()
                                                  .add_jm()
                                                  .format(onTheWayTime),
                                            ),
                                            SizedBox(height: 15),
                                            OrderStatusCard(
                                              title: "Servicio Completado",
                                              isDone: ((snapshot.data!.docs[index] as dynamic)
                                                          .data()['deliverd'] ==
                                                      'Done')
                                                  ? true
                                                  : false,
                                              time: DateFormat.yMMMd()
                                                  .add_jm()
                                                  .format(deliverdTime),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  AutoSizeText(
                                    ((snapshot.data!.docs[index] as dynamic) 
                                                .data()['deliverd'] ==
                                            'Done')
                                        ? "!!Felicitaciones!!\nEl servicio se completó con éxito."
                                        : "",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.deepOrangeAccent[200],
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Container dividerBetweenDoneIcon(bool isdone) {
    return (isdone)
        ? Container(height: 55, width: 2, color: Colors.deepOrangeAccent[200])
        : Container();
  }
}

class IconDoneOrNotDone extends StatelessWidget {
  const IconDoneOrNotDone({
    this.isdone,
    Key? key,
  }) : super(key: key);
  final bool ? isdone;
  @override
  Widget build(BuildContext context) {
    return (isdone!)
        ? Container(
            height: 30,
            child: CircleAvatar(
              backgroundColor: Colors.deepOrangeAccent[200],
              child: Icon(
                Icons.done,
                color: Colors.white,
              ),
            ),
          )
        : Container();
  }
}

class OrderStatusCard extends StatelessWidget {
  const OrderStatusCard({
    Key? key,
    required this.title,
    required this.time,
    this.isDone,
  }) : super(key: key);
  final String title;

  final String time;

  final bool? isDone;
  @override
  Widget build(BuildContext context) {
    return (isDone!)
        ? Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 10),
                    AutoSizeText(
                      time,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Container(
                  height: 3,
                  width: double.infinity,
                  color: Colors.blueGrey[50],
                ),
              ],
            ),
          )
        : Container();
  }
}

class KeyText extends StatelessWidget {
  final String msg;

  const KeyText({Key? key, required this.msg}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      msg,
      style: TextStyle(
        fontSize: 16,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
