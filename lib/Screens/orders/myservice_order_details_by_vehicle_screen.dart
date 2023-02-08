import 'package:auto_size_text/auto_size_text.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:oilapp/Model/addresss.dart';
import 'package:oilapp/Model/service_order_payment_details_model.dart';
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
  final String idOrderPaymentDetails;

  const MyServiceOrderDetailsByVehicleScreen({Key? key, required this.orderId, required this.addressId, required this.vehicleModel, required this.idOrderPaymentDetails})
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

    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: simpleAppBar(false, "Detalle de la orden", context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: size.height * 0.008,),
            Center(
              child: AutoSizeText(
                'ID de la orden:${widget.orderId}',
                style: TextStyle(
                  fontSize: size.height * 0.022,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: size.height * 0.008,),
            Container(
              child: Card(
                elevation: 3,
                  child: Column(
                    children: [
                      Center(
                        child: AutoSizeText(
                          'datos del vehiculo'.toUpperCase(),
                          style: TextStyle(
                            fontSize: size.height * 0.026,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        
                      ),
                      SizedBox(height: 5,),
                      AutoSizeText(
                        'Marca: ${widget.vehicleModel.brand}',
                        style: TextStyle(
                          fontSize: size.height * 0.022,
                          fontWeight: FontWeight.w600,
                        )
                      ),
                      AutoSizeText(
                        'Modelo: ${widget.vehicleModel.model}',
                        style: TextStyle(
                          fontSize: size.height * 0.022,
                          fontWeight: FontWeight.w600,
                        )
                      ),
                      AutoSizeText(
                        'Año: ${widget.vehicleModel.year}',
                        style: TextStyle(
                          fontSize: size.height * 0.022,
                          fontWeight: FontWeight.w600,
                        )
                      ),
                      Row(
                        mainAxisAlignment:MainAxisAlignment.center ,
                        children: [
                          AutoSizeText(
                            'Color: ',
                              style: TextStyle(
                                fontSize: size.height * 0.022,
                                fontWeight: FontWeight.w600,
                              )
                          ),
                          Container(color: Color(widget.vehicleModel.color!),child: SizedBox(height: size.height * 0.012, width: size.width *0.07,),)
                        ],
                      ),
                      AutoSizeText(
                        'Kilometraje: ${widget.vehicleModel.mileage}',
                        style: TextStyle(
                          fontSize: size.height * 0.022,
                          fontWeight: FontWeight.w600,
                        )
                      ),
                      SizedBox(height: size.height * 0.008,)
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
                .collection('serviceOrderPaymentDetails')
                .where('idOrderPaymentDetails', isEqualTo: widget.idOrderPaymentDetails)
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

                        ServiceOrderPaymentDetailsModel serviceOrderPaymentDetailsModel = ServiceOrderPaymentDetailsModel
                        .fromJson((snapshot.data!.docs[index] as dynamic).data(),);

                        return Card(
                          elevation: 3,
                          child: Column(
                            children: [
                              Center(
                                child: AutoSizeText(
                                  'detalle del pago'.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: size.height * 0.026,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              ),
                              Padding(
                                padding: EdgeInsets.all(size.height * 0.012),
                                child: Column(
                                  children: [
                                    AutoSizeText(
                                      serviceOrderPaymentDetailsModel.paymentMethod!,
                                      style: TextStyle(
                                        fontSize: size.height * 0.022,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    (serviceOrderPaymentDetailsModel.confirmationNumber != 0)
                                      ? AutoSizeText(
                                        'Número de Confirmación: ${serviceOrderPaymentDetailsModel.confirmationNumber.toString()}',
                                        style: TextStyle(
                                          fontSize: size.height * 0.022,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      )
                                      : Container(),
                                      (serviceOrderPaymentDetailsModel.paymentMethod == "Zelle")
                                      ? AutoSizeText(
                                        'Fecha del Pago: ${DateFormat('dd/MM/yyyy').format(serviceOrderPaymentDetailsModel.paymentDate!)}',
                                        style: TextStyle(
                                          fontSize: size.height * 0.022,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      )
                                      :Container(),
                                    (serviceOrderPaymentDetailsModel.issuerName != "")
                                      ?AutoSizeText(
                                        'Nombre del Emisor: ${serviceOrderPaymentDetailsModel.issuerName.toString()}',
                                        style: TextStyle(
                                          fontSize: size.height * 0.022,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      )
                                      :Container(),
                                    (serviceOrderPaymentDetailsModel.issuerName != "")
                                      ?AutoSizeText(
                                        'Nombre del Titular: ${serviceOrderPaymentDetailsModel.holderName.toString()}',
                                        style: TextStyle(
                                          fontSize: size.height * 0.022,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      )
                                      :Container(),
                                    (serviceOrderPaymentDetailsModel.observations != "")
                                      ?AutoSizeText(                                        
                                        'Observaciones: ${serviceOrderPaymentDetailsModel.observations.toString()}',
                                        maxLines: 3,
                                        style: TextStyle(
                                          fontSize: size.height * 0.022,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      )
                                      :Container(),
                                    

                                  ],
                                )
                              )
                            ],
                          ),
                        );
                      }
                    ),
                  );
                },
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
                              child: AutoSizeText(
                              'detalle del servicio'.toUpperCase(),
                              style: TextStyle(
                                fontSize: size.height * 0.026,
                                fontWeight: FontWeight.w600,
                              ),
                              )
                            ),
                            Padding(
                              padding: EdgeInsets.all(size.height * 0.008),
                              child: ListTile(
                                leading: Image.network(
                                  (snapshot.data!.docs[index] as dynamic).data()['serviceImage'],
                                  width: size.width * 0.22,
                                  height: size.height * 0.096,
                                ),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AutoSizeText(
                                      (snapshot.data!.docs[index] as dynamic)
                                          .data()['serviceName'],
                                      maxLines: 2,
                                      style: TextStyle(
                                        fontSize: size.height * 0.022,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: size.height * 0.008),
                                    AutoSizeText(
                                      "Fecha: " +
                                          (snapshot.data!.docs[index] as dynamic).data()['date'],
                                      maxLines: 2,
                                      style: TextStyle(
                                        fontSize: size.height * 0.022,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: size.height * 0.008),
                                    AutoSizeText(
                                      "\$" +
                                          (snapshot.data!.docs[index] as dynamic)
                                              .data()['newPrice']
                                              .toString(),
                                      style: TextStyle(
                                        fontSize: size.height * 0.022,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepOrangeAccent[200],
                                      ),
                                    ),
                                    AutoSizeText(
                                      'Observaciones: ${(snapshot.data!.docs[index] as dynamic)
                                        .data()['observations']
                                              .toString()}',
                                      maxLines: 5,
                                      style: TextStyle(
                                        
                                        fontSize: size.height * 0.022,
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
                                      size: size.height * 0.022,
                                      color: Colors.deepOrangeAccent[200],
                                    ),
                                    AutoSizeText(
                                      (snapshot.data!.docs[index] as dynamic)
                                          .data()['quantity']
                                          .toString(),
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
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.07, vertical: size.height * 0.025),
                      child: Container(
                        width: double.infinity,
                        child: Column(
                          children: [
                            Center(
                              child: AutoSizeText(
                              'dirección de entrega'.toUpperCase(),
                              style: TextStyle(
                                fontSize: size.height * 0.026,
                                fontWeight: FontWeight.w600,
                              ),
                              )
                            ),
                            SizedBox(height: size.height * 0.008,),
                            Table(
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
                            SizedBox(height: size.height * 0.008,),
                            Center(
                              child: AutoSizeText(
                              'ubicación en el mapa'.toUpperCase(),
                              style: TextStyle(
                                fontSize: size.height * 0.026,
                                fontWeight: FontWeight.w600,
                              ),
                              )
                            ),
                            SizedBox(height: size.height * 0.008,),
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
                            SizedBox(height: size.height * 0.012,),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(255, 3, 3, 247),
                                shape: const StadiumBorder()
                              ),
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
                              child: const AutoSizeText('Editar dirección')
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
                                  height: size.height * 0.096,
                                  width: double.infinity,
                                  child: Column(
                                    children: [
                                      SizedBox(height: size.height * 0.008,),
                                      Center(
                                        child: AutoSizeText(
                                          "Estatus de Orden",
                                          style: TextStyle(
                                            letterSpacing: 1,
                                            color: Colors.deepOrangeAccent[200],
                                            fontSize: size.height * 0.026,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color.fromARGB(255, 3, 3, 247),
                                          shape: const StadiumBorder()
                                        ),
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
                                        child: const AutoSizeText('Cancelar Orden')
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
                                            size
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
                                            size
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
                                            size
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
                                      SizedBox(width: size.width * 0.1),
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
                                            SizedBox(height: size.height * 0.021),
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
                                            SizedBox(height: size.height * 0.021),
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
                                            SizedBox(height: size.height * 0.021),
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
                                            SizedBox(height: size.height * 0.021),
                                            
                                            
                                            
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.028),
                                  AutoSizeText(
                                    ((snapshot.data!.docs[index] as dynamic) 
                                                .data()['deliverd'] ==
                                            'Done')
                                        ? "!!Felicitaciones!!\nEl servicio se completó con éxito."
                                        : "",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.deepOrangeAccent[200],
                                      fontSize: size.height * 0.022,
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
            title:  AutoSizeText('Estas seguro?'),
            content:  AutoSizeText(msg),
            actions: <Widget>[
               GestureDetector(
                onTap: () => Navigator.of(context).pop(true),
                child: Padding(
                  padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.012 ),
                  child: AutoSizeText("YES"),
                ),
              ),
               SizedBox(height: MediaQuery.of(context).size.height * 0.019),
               GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
                child: Padding(
                  padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.012 ),
                  child: AutoSizeText("NO"),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.019),
            ],
          ),
        ) ??
        false;
  }

  Container dividerBetweenDoneIcon(bool isdone, Size size) {

    return (isdone)
        ? Container(height: size.height * 0.065, width: size.width *0.007, color: Colors.deepOrangeAccent[200])
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
    Size size = MediaQuery.of(context).size;
    return (isdone!)
        ? Container(
            height: size.height * 0.038,
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
    Size size = MediaQuery.of(context).size;
    return (isDone!)
        ? Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  title,
                  style: TextStyle(
                    fontSize: size.height * 0.024,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: size.height * 0.013),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Colors.grey,
                    ),
                    SizedBox(width: size.width * 0.02),
                    AutoSizeText(
                      time,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.013),
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
    return AutoSizeText(
      msg,
      style: TextStyle(
        fontSize: size.height * 0.022,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
