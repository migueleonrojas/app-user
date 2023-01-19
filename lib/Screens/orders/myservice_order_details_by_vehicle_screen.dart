import 'package:fluttertoast/fluttertoast.dart';
import 'package:oilapp/Model/addresss.dart';
import 'package:oilapp/Model/vehicle_model.dart';
import 'package:oilapp/Screens/Address/editAddress.dart';
import 'package:oilapp/Screens/ourservice/backend_orderservice.dart';
import 'package:oilapp/config/config.dart';
import 'package:oilapp/widgets/loading_widget.dart';
import 'package:oilapp/widgets/simpleAppbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyServiceOrderDetailsByVehicleScreen extends StatefulWidget {
  final VehicleModel vehicleModel;
  final String orderId;
  final String addressId;

  const MyServiceOrderDetailsByVehicleScreen({Key? key, required this.orderId, required this.addressId, required this.vehicleModel})
      : super(key: key);
  @override
  _MyServiceOrderDetailsByVehicleScreenState createState() =>
      _MyServiceOrderDetailsByVehicleScreenState();
}

class _MyServiceOrderDetailsByVehicleScreenState
    extends State<MyServiceOrderDetailsByVehicleScreen> {

  CameraPosition? cameraPosition;

  GoogleMapController? _controller;

  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(false, "Detalle de la orden"),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 5,),
            Center(
              child: Text(
                'ID de la orden:${widget.orderId}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 5,),
            Container(
              child: Card(
                elevation: 3,
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          'datos del vehiculo'.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        
                      ),
                      SizedBox(height: 5,),
                      Text(
                        'Marca: ${widget.vehicleModel.brand}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        )
                      ),
                      Text(
                        'Modelo: ${widget.vehicleModel.model}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        )
                      ),
                      Text(
                        'Año: ${widget.vehicleModel.year}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        )
                      ),
                      Row(
                        mainAxisAlignment:MainAxisAlignment.center ,
                        children: [
                          const Text(
                            'Color: ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              )
                          ),
                          Container(color: Color(widget.vehicleModel.color!),child: const SizedBox(height: 10, width: 30,),)
                        ],
                      ),
                      Text(
                        'Kilometraje: ${widget.vehicleModel.mileage}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        )
                      ),
                      const SizedBox(height: 5,)
                    ],
                  )
                
              )
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                .collection(AutoParts.collectionUser)
                .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
                .collection(AutoParts.vehicles)
                .doc(widget.vehicleModel.vehicleId!)
                .collection("serviceOrder")
                .where("orderId", isEqualTo: widget.orderId)
                .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return circularProgress();
                }
                return Container(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 3,
                        child: Column(
                          children: [
                             Center(
                              child: Text(
                              'detalle del servicio'.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              )
                            ),
                            Padding(
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
                                    Text(
                                      (snapshot.data!.docs[index] as dynamic)
                                          .data()['serviceName'],
                                      maxLines: 2,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      "Fecha: " +
                                          (snapshot.data!.docs[index] as dynamic).data()['date'],
                                      maxLines: 2,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      "\$" +
                                          (snapshot.data!.docs[index] as dynamic)
                                              .data()['newPrice']
                                              .toString(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepOrangeAccent[200],
                                      ),
                                    ),
                                    Text(
                                      'Observaciones: ${(snapshot.data!.docs[index] as dynamic)
                                        .data()['observations']
                                              .toString()}',
                                      maxLines: 5,
                                      style: const TextStyle(
                                        
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        
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
                                    Text(
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
                          ],
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
                    cameraPosition =  CameraPosition(
                      target: LatLng(
                        (snapshot.data!.docs[index].data() as dynamic )['latitude'],
                        (snapshot.data!.docs[index].data() as dynamic )['longitude']
                      ),
                      zoom: 18
                    );
                    _markers.add(
                        Marker(
                          markerId: const MarkerId('pin'),
                          position: cameraPosition!.target,
                          icon: BitmapDescriptor.defaultMarker,
                        )
                    );
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 20),
                      child: Container(
                        width: double.infinity,
                        child: Column(
                          children: [
                            Center(
                              child: Text(
                              'dirección de entrega'.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              )
                            ),
                            SizedBox(height: 5,),
                            Table(
                              children: [
                                TableRow(
                                  children: [
                                    KeyText(msg: "Nombre del Cliente"),
                                    Text(
                                      (snapshot.data!.docs[index] as dynamic)
                                          .data()['customerName'],
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    KeyText(msg: "Teléfono"),
                                    Text(
                                      (snapshot.data!.docs[index] as dynamic)
                                          .data()['phoneNumber'],
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    KeyText(msg: "Ciudad"),
                                    Text(
                                      (snapshot.data!.docs[index] as dynamic).data()['city'],
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    KeyText(msg: "Area"),
                                    Text(
                                      (snapshot.data!.docs[index] as dynamic).data()['area'],
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    KeyText(msg: "Número de la casa"),
                                    Text(
                                      (snapshot.data!.docs[index] as dynamic)
                                          .data()['houseandroadno'],
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    KeyText(msg: "Código de Área"),
                                    Text(
                                      (snapshot.data!.docs[index] as dynamic).data()['areacode'],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 5,),
                            Center(
                              child: Text(
                              'ubicación en el mapa'.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              )
                            ),
                            SizedBox(height: 5,),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.50,
                              child: GoogleMap(
                              initialCameraPosition: cameraPosition!,
                              onMapCreated: ((controller) {
                                _controller = controller;
                                setState(() {});
                              }),
                              markers: _markers,
                              ),
                            ),
                            SizedBox(height: 10,),
                            ElevatedButton(

                              onPressed: () async {
                                AddressModel addressModel = AddressModel.fromJson(
                                  (snapshot.data!.docs[index] as dynamic).data()
                                );
                                Route route = MaterialPageRoute(
                                  builder: (_) => EditAddress(
                                    addressModel: addressModel,
                                  ),
                                );
                                final newCameraPosition = await Navigator.push(context, route);
                                if(newCameraPosition == null) return;
                                cameraPosition =  CameraPosition(
                                  target: LatLng(
                                    newCameraPosition.target.latitude,
                                    newCameraPosition.target.longitude
                                  ),
                                  zoom: 18
                                );
                                await _controller!.animateCamera(
                                  CameraUpdate.newCameraPosition(cameraPosition!),
                                );
                                setState(() {});

                              }, 
                              child: const Text('Editar dirección')
                            )
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
                    DateTime cancelledTime =
                        ((snapshot.data!.docs[index] as dynamic).data()['orderCancelledTime'])
                            .toDate();
                    return Column(
                      children: [
                        ((snapshot.data!.docs[index] as dynamic).data()['orderRecived'] ==
                                'Done')
                            ? Card(
                                elevation: 3,
                                child: Container(
                                  height: 80,
                                  width: double.infinity,
                                  child: Column(
                                    children: [
                                      SizedBox(height: 5,),
                                      Center(
                                        child: Text(
                                          "Estatus de Orden",
                                          style: TextStyle(
                                            letterSpacing: 1,
                                            color: Colors.deepOrangeAccent[200],
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        
                                        onPressed: () async {
                                          bool confirm = await _onBackPressed('De que quieres cancelar la orden');
                                          if(!confirm) return;
                                          if((snapshot.data!.docs[index] as dynamic)
                                                          .data()['deliverd'] =='Done'){
                                            Fluttertoast.showToast(
                                              toastLength: Toast.LENGTH_LONG,
                                              msg: "No puede cancelar una orden que ya ha sido entregado"
                                            );
                                            return;
                                          }
                                          await BackEndOrderService().cancelledOrder(widget.orderId);
                                        }, 
                                        child: const Text('Cancelar Orden')
                                      )
                                    ],
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
                                          /* dividerBetweenDoneIcon(
                                            ((snapshot.data!.docs[index] as dynamic)
                                                        .data()['orderCancelled'] ==
                                                    'Done')
                                                ? true
                                                : false,
                                          ),
                                          IconDoneOrNotDone(
                                            isdone: ((snapshot.data!.docs[index] as dynamic)
                                                        .data()['orderCancelled'] ==
                                                    'Done')
                                                ? true
                                                : false,
                                          ), */

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
                                              title: "Servicio Cancelado",
                                              isDone: (
                                                (snapshot.data!.docs[index] as dynamic).data()['orderCancelled'] =='Done' &&
                                                cancelledTime.compareTo(orderRecivedTime) == 1 && 
                                                orderRecivedTime.compareTo(beingPreParedTime) == 1 
                                              )
                                                  ? true
                                                  : false,
                                              time: DateFormat.yMMMd()
                                                  .add_jm()
                                                  .format(cancelledTime),
                                            ),
                                            
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
                                              title: "Servicio Cancelado",
                                              isDone: (
                                                (snapshot.data!.docs[index] as dynamic).data()['orderCancelled'] =='Done' &&
                                                cancelledTime.compareTo(beingPreParedTime) == 1 && 
                                                beingPreParedTime.compareTo(onTheWayTime) == 1 
                                              )
                                                  ? true
                                                  : false,
                                              time: DateFormat.yMMMd()
                                                  .add_jm()
                                                  .format(cancelledTime),
                                            ),
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
                                              title: "Servicio Cancelado",
                                              isDone: (
                                                (snapshot.data!.docs[index] as dynamic).data()['orderCancelled'] =='Done' &&
                                                cancelledTime.compareTo(onTheWayTime) == 1 && 
                                                onTheWayTime.compareTo(deliverdTime) == 1 
                                              )
                                                  ? true
                                                  : false,
                                              time: DateFormat.yMMMd()
                                                  .add_jm()
                                                  .format(cancelledTime),
                                            ),
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
                                            SizedBox(height: 15),
                                            
                                            
                                            
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  Text(
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

  Future<bool> _onBackPressed(String msg) async {
    return await showDialog(
          context: context,
          builder: (context) =>  AlertDialog(
            title:  Text('Estas seguro?'),
            content:  Text(msg),
            actions: <Widget>[
               GestureDetector(
                onTap: () => Navigator.of(context).pop(true),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("YES"),
                ),
              ),
              const SizedBox(height: 16),
               GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("NO"),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ) ??
        false;
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
                Text(
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
                    Text(
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
    return Text(
      msg,
      style: TextStyle(
        fontSize: 16,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
