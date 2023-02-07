import 'package:oilapp/Model/order_history_model.dart';
import 'package:oilapp/config/config.dart';
import 'package:oilapp/widgets/loading_widget.dart';
import 'package:oilapp/widgets/simpleAppbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyOrderDetailsScreen extends StatefulWidget {
  final String orderId;
  final String addressId;

  const MyOrderDetailsScreen({Key? key, required this.orderId, required this.addressId})
      : super(key: key);
  @override
  _MyOrderDetailsScreenState createState() => _MyOrderDetailsScreenState();
}

class _MyOrderDetailsScreenState extends State<MyOrderDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: simpleAppBar(false, "Detalle de la Orden", context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(AutoParts.collectionUser)
                  .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
                  .collection("orderHistory")
                  .where("orderHistoyId", isEqualTo: widget.orderId)
                  .snapshots(),
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
                      OrderHistoyModel orderHistoyModel =
                          OrderHistoyModel.fromJson(
                        (snapshot.data!.docs[index] as dynamic).data(),
                      );
                      return Card(
                        elevation: 3,
                        child: Padding(
                          padding: EdgeInsets.all(size.height * 0.010),
                          child: ListTile(
                            leading: Image.network(
                              orderHistoyModel.pImage!,
                              width: size.width * 0.145,
                              height: size.height * 0.090,
                            ),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  orderHistoyModel.pName!,
                                  maxLines: 2,
                                  style: TextStyle(
                                    fontSize: size.height * 0.020,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: size.height * 0.005),
                                Text(
                                  "\$" + orderHistoyModel.newPrice.toString(),
                                  style: TextStyle(
                                    fontSize: size.height * 0.020,
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
                                  size: size.height * 0.020,
                                  color: Colors.deepOrangeAccent[200],
                                ),
                                Text(
                                  orderHistoyModel.quantity.toString(),
                                  style: TextStyle(
                                    fontSize: size.height * 0.026,
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
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.040, vertical: size.height * 0.020),
                      child: Container(
                        width: double.infinity,
                        child: Table(
                          children: [
                            TableRow(
                              children: [
                                const KeyText(msg: "Nombre del Cliente"),
                                Text(
                                  (snapshot.data!.docs[index] as dynamic)
                                      .data()['customerName'],
                                ),
                              ],
                            ),
                            TableRow(
                              children: [
                                const KeyText(msg: "Teléfono"),
                                Text(
                                  (snapshot.data!.docs[index] as dynamic)
                                      .data()['phoneNumber'],
                                ),
                              ],
                            ),
                            TableRow(
                              children: [
                                const KeyText(msg: "Ciudad"),
                                Text(
                                  (snapshot.data!.docs[index] as dynamic).data()['city'],
                                ),
                              ],
                            ),
                            TableRow(
                              children: [
                                const KeyText(msg: "Area"),
                                Text(
                                  (snapshot.data!.docs[index] as dynamic ).data()['area'],
                                ),
                              ],
                            ),
                            TableRow(
                              children: [
                                const KeyText(msg: "Número de la casa"),
                                Text(
                                  (snapshot.data!.docs[index] as dynamic)
                                      .data()['houseandroadno'],
                                ),
                              ],
                            ),
                            TableRow(
                              children: [
                                const KeyText(msg: "Código de Área"),
                                Text(
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
                  .collection("orders")
                  .where("orderId", isEqualTo: widget.orderId)
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
                                  height: size.height * 0.060,
                                  width: double.infinity,
                                  child: Center(
                                    child: Text(
                                      "Estatus de la Orden",
                                      style: TextStyle(
                                        letterSpacing: 1,
                                        color: Colors.deepOrangeAccent[200],
                                        fontSize: size.height * 0.022,
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
                            height: size.height * 0.7,
                            width: double.infinity,
                            child: Padding(
                              padding: EdgeInsets.all(size.height * 0.018),
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
                                                context
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
                                                context
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
                                                context
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
                                      SizedBox(width: size.width * 0.07),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            OrderStatusCard(
                                              title: "Orden Recibida",
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
                                            SizedBox(height: size.height * 0.020),
                                            OrderStatusCard(
                                              title: "Esta preparado",
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
                                            SizedBox(height: size.height * 0.020),
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
                                            SizedBox(height: size.height * 0.020),
                                            OrderStatusCard(
                                              title: "Entregado",
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
                                  SizedBox(height: size.height * 0.020),
                                  Text(
                                    ((snapshot.data!.docs[index] as dynamic)
                                                .data()['deliverd'] ==
                                            'Done')
                                        ? "¡¡Felicitaciones!!\nEl pedido ha sido entregado con éxito."
                                        : "",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.deepOrangeAccent[200],
                                      fontSize: size.height * 0.020,
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

  Container dividerBetweenDoneIcon(bool isdone, BuildContext context) {

    Size size = MediaQuery.of(context).size;

    return (isdone)
        ? Container(height: size.height * 0.055, width: size.width * 0.008, color: Colors.deepOrangeAccent[200])
        : Container();
  }
}

class IconDoneOrNotDone extends StatelessWidget {
  const IconDoneOrNotDone({
    this.isdone,
    Key ? key,
  }) : super(key: key);
  final bool ? isdone;
  @override
  Widget build(BuildContext context) {

    Size size =  MediaQuery.of(context).size;

    return (isdone!)
        ? Container(
            height: size.height * 0.040,
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
    Size size =  MediaQuery.of(context).size;

    return (isDone!)
        ? Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: size.height * 0.025,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: size.height * 0.012),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Colors.grey,
                    ),
                    SizedBox(width: size.width * 0.04),
                    Text(
                      time,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.012),
                Container(
                  height: size.height * 0.005,
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
    Size size = MediaQuery.of(context).size;
    return Text(
      msg,
      style: TextStyle(
        fontSize: size.height *0.018,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
