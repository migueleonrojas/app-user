import 'dart:async';
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:oilapp/Model/payment_method_details_model.dart';
import 'package:oilapp/Model/vehicle_model.dart';
import 'package:oilapp/Screens/home_screen.dart';
import 'package:oilapp/Screens/orders/myservice_order_by_vehicle_screen.dart';
import 'package:oilapp/Screens/ourservice/backend_orderservice.dart';
import 'package:oilapp/config/config.dart';
import 'package:oilapp/widgets/confirm_animation_button.dart';
import 'package:oilapp/widgets/emptycardmessage.dart';
import 'package:oilapp/widgets/loading_widget.dart';
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
  
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final _confirmationNumberTextEditingController = TextEditingController();
  final _paymentDateTextEditingController = TextEditingController();
  final _issuerNameTextEditingController = TextEditingController();
  final _holderNameTextEditingController = TextEditingController();
  final _observationsTextEditingController = TextEditingController();
   
  bool isTapCash = false;
  bool isTapMobilePayment = false;
  bool isTapZelle = false;
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
          title: AutoSizeText(
            "Metodo de Pago",
            style: TextStyle(
              fontSize: size.height * 0.024,
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
                  child: AutoSizeText(
                    "Elija el método de pago",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: size.height * 0.024,
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
                    
                    if (!snapshot.hasData) {
                      return circularProgress();
                    }

                    /* if(snapshot.data!.docs.isEmpty){
                      return const EmptyCardMessage(
                        listTitle: 'No tienes servicios.',
                        message: 'Todavia no tienes servicios solicitados.',
                      );
                    } */
    
                    return Column(
                      children: [
                        PaymentButton(
                          onTap: () async {
                            setState(() {
                              isTapMobilePayment = false;
                              isTapCash = true;
                              isTapZelle = false;
                            });
                          },
                          leadingImage: "assets/icons/cod.png",
                          title: "Pago en efectivo",
                        ),
                        (isTapCash)
                            ? ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color.fromARGB(255, 3, 3, 247),
                                  shape: const StadiumBorder()
                                ),
                                onPressed: () async {
                                  _issuerNameTextEditingController.text = "";
                                  _holderNameTextEditingController.text = ""; 
                                  _observationsTextEditingController.text = "";
                                  loading = true;
                                  setState(() {});
                                  for (int i = 0; i < snapshot.data!.docs.length; i++)  {
                                    String orderId = DateTime.now().microsecondsSinceEpoch.toString();
                                    String idOrderPaymentDetails = DateTime.now().microsecondsSinceEpoch.toString();

                                    
                                    await BackEndOrderService().writeServiceOrderPaymentDetailsForUser(
                                      widget.vehicleModel.vehicleId!, 
                                      idOrderPaymentDetails, 
                                      "Pago en efectivo", 
                                      0, 
                                      0, 
                                      "N/A", 
                                      0, 
                                      DateTime.now(), 
                                      _issuerNameTextEditingController.text, 
                                      _holderNameTextEditingController.text, 
                                      _observationsTextEditingController.text
                                    );

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
                                      idOrderPaymentDetails,
                                      context,
                                    );
                                  }

                                  Route route = MaterialPageRoute(builder: (_) => MyServiceOrderByVehicleScreen(vehicleModel: widget.vehicleModel));
                                  Navigator.pushAndRemoveUntil(context, route, (route) => false);
                                  
                                    
                                  
                                },
                                child: const AutoSizeText('Confirmar'),
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
                                  label: AutoSizeText(
                                    "Ir a Inicio",
                                    style: TextStyle(
                                      fontSize: size.height * 0.022,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            : Container(),

                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                            .collection(AutoParts.paymentMethodDetails)
                            .where('paymentMethod', isEqualTo: 'Pago Movil')
                            .snapshots(),
                          builder: (context, snapshotMobilePayment) {
                            if (!snapshotMobilePayment.hasData) {
                              return circularProgress();
                            }

                            if(snapshotMobilePayment.data!.docs.isEmpty){
                              return const EmptyCardMessage(
                                listTitle: 'No hay pago movil.',
                                message: 'No hay el metodo de pago: Pago Movil..',
                              );
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: snapshotMobilePayment.data!.docs.length,
                              itemBuilder: (BuildContext context, int index) {                          

                                PaymentMethodDetailsModel paymentMethodDetailsModel = PaymentMethodDetailsModel.fromJson(
                                  (snapshotMobilePayment.data!.docs[index] as dynamic).data(),
                                );

                                return Column(
                                  children: [
                                    PaymentButton(
                                      onTap: () {
                                        setState(() {
                                          isTapMobilePayment = true;
                                          isTapCash = false;
                                          isTapZelle = false;
                                        });
                                      },
                                      leadingImage: "assets/icons/online_payment.png",
                                      title: "Pago movil",
                                    ),
                                    (isTapMobilePayment) 
                                    ? Container(
                                        width: MediaQuery.of(context).size.width * 0.80,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            AutoSizeText('Datos del Pago Movil'),
                                            SizedBox(height: size.height * 0.014,),
                                            StreamBuilder<QuerySnapshot>(
                                              stream: FirebaseFirestore.instance
                                                .collection(AutoParts.dollarRate)
                                                .snapshots(),
                                                builder: (context, snapshot) {
                                                  if(!snapshot.hasData) {
                                                    return circularProgress();
                                                  }

                                                  if(snapshot.data!.docs.isEmpty) {

                                                    return const EmptyCardMessage(
                                                      listTitle: 'No hay tasa del Dolar',
                                                      message: 'La tasa del dolar no esta disponible',
                                                    );

                                                  }

                                                  return AutoSizeText('Precio del dolar BCV: ${snapshot.data!.docs[0]['price']} ${snapshot.data!.docs[0]['currency']}');

                                                },
                                            ),

                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              children: [

                                                AutoSizeText('Cédula'),
                                                Row(
                                                  children: [
                                                    AutoSizeText('${paymentMethodDetailsModel.kindOfPerson} - ${paymentMethodDetailsModel.identificationCard.toString()}'),
                                                    IconButton(
                                                      icon: const Icon(Icons.copy),
                                                      onPressed: () async {
                                                        await Clipboard.setData(ClipboardData(text: paymentMethodDetailsModel.identificationCard.toString()));
                                                        Fluttertoast.showToast(msg: 'La cédula se copio exitosamente');
                                                      },
                                                    )

                                                  ],
                                                )
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              children: [
                                                AutoSizeText('Teléfono'),
                                                Row(
                                                  children: [
                                                    AutoSizeText(paymentMethodDetailsModel.numberPhone.toString().replaceFirst('58', '0')),
                                                    IconButton(
                                                      icon: const Icon(Icons.copy),
                                                      onPressed: () async {
                                                        String numberToCopy = paymentMethodDetailsModel.numberPhone.toString().substring(5, paymentMethodDetailsModel.numberPhone.toString().length);
                                                    
                                                        await Clipboard.setData(ClipboardData(text: numberToCopy));
                                                        Fluttertoast.showToast(msg: 'El teléfono se copio exitosamente');
                                                      },
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              children: [
                                                AutoSizeText('Banco'),
                                                Row(
                                                  children: [
                                                    AutoSizeText(paymentMethodDetailsModel.bank!),
                                                    IconButton(
                                                      icon: const Icon(Icons.copy),
                                                      onPressed: () async {                                                    
                                                        await Clipboard.setData(ClipboardData(text: paymentMethodDetailsModel.bank));
                                                        Fluttertoast.showToast(msg: 'El banco se copio exitosamente');
                                                      },
                                                    )

                                                  ],
                                                )
                                              ],
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Color.fromARGB(255, 3, 3, 247),
                                                shape: const StadiumBorder()
                                              ),
                                              child: const AutoSizeText('Confirmar'),
                                              onPressed: () async  {
                                                _issuerNameTextEditingController.text = "";
                                                _holderNameTextEditingController.text = ""; 
                                                _observationsTextEditingController.text = "";
                                                loading = true;
                                                setState(() {});
                                                for (int i = 0; i < snapshotMobilePayment.data!.docs.length; i++) {
                                                  String orderId = DateTime.now().microsecondsSinceEpoch.toString();
                                                  String idOrderPaymentDetails = DateTime.now().microsecondsSinceEpoch.toString();
                                    
                                                  await BackEndOrderService().writeServiceOrderPaymentDetailsForUser(
                                                    widget.vehicleModel.vehicleId!, 
                                                    idOrderPaymentDetails, 
                                                    "Pago movil", 
                                                    paymentMethodDetailsModel.identificationCard!, 
                                                    paymentMethodDetailsModel.numberPhone!, 
                                                    paymentMethodDetailsModel.bank!, 
                                                    0, 
                                                    DateTime.now(), 
                                                    _issuerNameTextEditingController.text, 
                                                    _holderNameTextEditingController.text, 
                                                    _observationsTextEditingController.text
                                                  );

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
                                                    idOrderPaymentDetails,
                                                    context,
                                                  );
                                                }

                                                Route route = MaterialPageRoute(builder: (_) => MyServiceOrderByVehicleScreen(vehicleModel: widget.vehicleModel));
                                                Navigator.pushAndRemoveUntil(context, route, (route) => false);
                                            
                                              },
                                            )

                                          ],
                                        ),
                                      )
                                    :Container(),

                                  ],
                                );

                              }
                            );
                          },
                        ),

                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                            .collection(AutoParts.paymentMethodDetails)
                            .where('paymentMethod', isEqualTo: 'Zelle')
                            .snapshots(),
                          builder: (context, snapshotZelle) {

                            if (!snapshotZelle.hasData) {
                              return circularProgress();
                            }

                            if(snapshotZelle.data!.docs.isEmpty){
                              return const EmptyCardMessage(
                                listTitle: 'No hay zelle.',
                                message: 'No hay el metodo de pago: Zelle..',
                              );
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: snapshotZelle.data!.docs.length,
                              itemBuilder: (BuildContext context, int index) {

                                PaymentMethodDetailsModel paymentMethodDetailsModel = PaymentMethodDetailsModel.fromJson(
                                  (snapshotZelle.data!.docs[index] as dynamic).data(),
                                );

                                return Column(
                                  children: [
                                    PaymentButton(
                                      onTap: () {
                                        setState(() {
                                          isTapMobilePayment = false;
                                          isTapCash = false;
                                          isTapZelle = true;
                                        });
                                      },
                                      leadingImage: "assets/icons/online_payment.png",
                                      title: "Pago en Zelle",
                                    ),
                                    (isTapZelle)
                                      ? Container(
                                        width: MediaQuery.of(context).size.width * 0.80,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              AutoSizeText('Datos del Zelle'),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: [

                                                  AutoSizeText('Correo'),
                                                  Row(
                                                    children: [
                                                      AutoSizeText(paymentMethodDetailsModel.email.toString()),
                                                      IconButton(
                                                        icon: const Icon(Icons.copy),
                                                        onPressed: () async {
                                                          await Clipboard.setData(ClipboardData(text: paymentMethodDetailsModel.email.toString()));
                                                          Fluttertoast.showToast(msg: 'El correo se copio exitosamente');
                                                        },
                                                      )

                                                    ],
                                                  )
                                                ],
                                              ),
                                              SizedBox(height: size.height * 0.015,),
                                              AutoSizeText(
                                                'Registro del Pago',
                                                style: TextStyle(
                                                  fontSize: size.height * 0.024
                                                ),
                                              ),
                                              SizedBox(height: size.height * 0.015,),
                                              Form(
                                                key: _formkey,
                                                child: Column(
                                                  children: [
                                                    SizedBox(
                                                      width: MediaQuery.of(context).size.width * 0.80,
                                                      child: TextFormField(
                                                        controller: _confirmationNumberTextEditingController,
                                                        keyboardType: TextInputType.number,
                                                        decoration: InputDecoration(
                                                          hintText: "Número de Confirmación",
                                                          border: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(30.0),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: size.height * 0.015,),
                                                    SizedBox(
                                                      width: MediaQuery.of(context).size.width * 0.80,
                                                      child: TextFormField(
                                                        controller: _paymentDateTextEditingController,
                                                        keyboardType: TextInputType.none,
                                                        showCursor: false,                                                  
                                                        decoration: InputDecoration(
                                                          hintText: "Fecha del Pago",
                                                          border: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(30.0),
                                                          ),
                                                        ),
                                                        onTap: () async {
                                                          final initialDate = DateTime.now();
                                                          final newDate = await showDatePicker(                          
                                                            context: context,
                                                            initialDate: initialDate,
                                                            firstDate: DateTime(DateTime.now().year - 5),
                                                            lastDate: DateTime.now(),
                                                          );

                                                          if (newDate == null) return;

                                                          _paymentDateTextEditingController.text = DateFormat('dd/MM/yyyy').format(newDate);
                                                        },
                                                      ),
                                                    ),
                                                    SizedBox(height: size.height * 0.015,),
                                                    SizedBox(
                                                      width: MediaQuery.of(context).size.width * 0.80,
                                                      child: TextFormField(
                                                        controller: _issuerNameTextEditingController,
                                                        keyboardType: TextInputType.name,
                                                        decoration: InputDecoration(
                                                          hintText: "Nombre del Emisor",
                                                          border: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(size.height * 0.035),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: size.height * 0.015,),
                                                    SizedBox(
                                                      width: MediaQuery.of(context).size.width * 0.80,
                                                      child: TextFormField(
                                                        controller: _holderNameTextEditingController,
                                                        keyboardType: TextInputType.name,
                                                        decoration: InputDecoration(
                                                          hintText: "Nombre del Titular",
                                                          border: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(size.height * 0.035),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: size.height * 0.015,),
                                                    SizedBox(
                                                      width: MediaQuery.of(context).size.width * 0.80,
                                                      child: TextFormField(
                                                        maxLines: 3,
                                                        controller: _observationsTextEditingController,
                                                        keyboardType: TextInputType.name,
                                                        decoration: InputDecoration(
                                                          hintText: "Observaciones",
                                                          border: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(size.height * 0.035),
                                                          ),
                                                        ),
                                                      ),
                                                    ),

                                                  ],
                                                ),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Color.fromARGB(255, 3, 3, 247),
                                                  shape: const StadiumBorder()
                                                ),
                                                child: const AutoSizeText('Confirmar'),
                                                onPressed: () async {

                                                  if(
                                                    _confirmationNumberTextEditingController.text.isEmpty ||
                                                    _paymentDateTextEditingController.text.isEmpty ||
                                                    _issuerNameTextEditingController.text.isEmpty ||
                                                    _holderNameTextEditingController.text.isEmpty ||
                                                    _holderNameTextEditingController.text.isEmpty ||
                                                    _observationsTextEditingController.text.isEmpty
                                                  )
                                                  {
                                                    Fluttertoast.showToast(msg: 'Ingrese toda la información solicitada');
                                                    return;
                                                  }

                                                  loading = true;
                                                  setState(() {});
                                                  for (int i = 0; i < snapshot.data!.docs.length; i++) {
                                                    String orderId = DateTime.now().microsecondsSinceEpoch.toString();
                                                    String idOrderPaymentDetails = DateTime.now().microsecondsSinceEpoch.toString();
                                                    final DateTime datePayment = DateTime.parse(_paymentDateTextEditingController.text.split('/').reversed.join('-'));
                                          
                                                    await BackEndOrderService().writeServiceOrderPaymentDetailsForUser(
                                                      widget.vehicleModel.vehicleId!, 
                                                      idOrderPaymentDetails, 
                                                      "Zelle", 
                                                      0, 
                                                      0, 
                                                      "N/A", 
                                                      int.parse(_confirmationNumberTextEditingController.text), 
                                                      datePayment, 
                                                      _issuerNameTextEditingController.text, 
                                                      _holderNameTextEditingController.text, 
                                                      _observationsTextEditingController.text
                                                    );

                                                    
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
                                                      idOrderPaymentDetails,
                                                      context,
                                                    );
                                                  }

                                                  Route route = MaterialPageRoute(builder: (_) => MyServiceOrderByVehicleScreen(vehicleModel: widget.vehicleModel));
                                                  Navigator.pushAndRemoveUntil(context, route, (route) => false);
                                                  
                                                },
                                              )
                                            ]
                                          )
                                      )
                                      : Container(),
                                      
                                  ],
                                );

                              }
                            );
                          },
                        )


                      ],
                    );
                  }),

                  


                  /* StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                    .collection(AutoParts.paymentMethodDetails)
                    .where('paymentMethod', isEqualTo: 'Pago Movil')
                    .snapshots(),
                    builder: (context, snapshotMobilePayment) {
                      if (!snapshotMobilePayment.hasData) {
                        return circularProgress();
                      }

                      if(snapshotMobilePayment.data!.docs.isEmpty){
                        return const EmptyCardMessage(
                          listTitle: 'No hay pago movil.',
                          message: 'No hay el metodo de pago: Pago Movil..',
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshotMobilePayment.data!.docs.length,
                        itemBuilder: (BuildContext context, int index) {

                          

                          PaymentMethodDetailsModel paymentMethodDetailsModel = PaymentMethodDetailsModel.fromJson(
                            (snapshotMobilePayment.data!.docs[index] as dynamic).data(),
                          );

                          

                          return Column(
                            children: [
                              PaymentButton(
                                onTap: () {
                                  setState(() {
                                    isTapMobilePayment = true;
                                    isTapCash = false;
                                    isTapZelle = false;
                                  });
                                },
                                leadingImage: "assets/icons/online_payment.png",
                                title: "Pago movil",
                              ),
                              (isTapMobilePayment) 
                                ? Container(
                                    
                                    width: MediaQuery.of(context).size.width * 0.80,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        AutoSizeText('Datos del Pago Movil'),
                                        SizedBox(height: 10,),
                                        StreamBuilder<QuerySnapshot>(
                                          stream: FirebaseFirestore.instance
                                          .collection(AutoParts.dollarRate)
                                          .snapshots(),
                                          builder: (context, snapshot) {
                                            if(!snapshot.hasData) {
                                              return circularProgress();
                                            }

                                            if(snapshot.data!.docs.isEmpty) {

                                              return const EmptyCardMessage(
                                                listTitle: 'No hay tasa del Dolar',
                                                message: 'La tasa del dolar no esta disponible',
                                              );

                                            }

                                            return AutoSizeText('Precio del dolar BCV: ${snapshot.data!.docs[0]['price']} ${snapshot.data!.docs[0]['currency']}');

                                          },
                                        ),

                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [

                                            AutoSizeText('Cédula'),
                                            Row(
                                              children: [
                                                AutoSizeText('${paymentMethodDetailsModel.kindOfPerson} - ${paymentMethodDetailsModel.identificationCard.toString()}'),
                                                IconButton(
                                                  icon: const Icon(Icons.copy),
                                                  onPressed: () async {
                                                    await Clipboard.setData(ClipboardData(text: paymentMethodDetailsModel.identificationCard.toString()));
                                                    Fluttertoast.showToast(msg: 'La cédula se copio exitosamente');
                                                  },
                                                )

                                              ],
                                            )
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [

                                            AutoSizeText('Teléfono'),
                                            Row(
                                              children: [
                                                AutoSizeText(paymentMethodDetailsModel.numberPhone.toString().replaceFirst('58', '0')),
                                                IconButton(
                                                  icon: const Icon(Icons.copy),
                                                  onPressed: () async {
                                                    String numberToCopy = paymentMethodDetailsModel.numberPhone.toString().substring(5, paymentMethodDetailsModel.numberPhone.toString().length);
                                                    
                                                    await Clipboard.setData(ClipboardData(text: numberToCopy));
                                                    Fluttertoast.showToast(msg: 'El teléfono se copio exitosamente');
                                                  },
                                                )

                                              ],
                                            )
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [

                                            AutoSizeText('Banco'),
                                            Row(
                                              children: [
                                                AutoSizeText(paymentMethodDetailsModel.bank!),
                                                IconButton(
                                                  icon: const Icon(Icons.copy),
                                                  onPressed: () async {                                                    
                                                    await Clipboard.setData(ClipboardData(text: paymentMethodDetailsModel.bank));
                                                    Fluttertoast.showToast(msg: 'El banco se copio exitosamente');
                                                  },
                                                )

                                              ],
                                            )
                                          ],
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color.fromARGB(255, 3, 3, 247),
                                            shape: const StadiumBorder()
                                          ),
                                          child: const AutoSizeText('Confirmar'),
                                          onPressed: () async  {
                                            _issuerNameTextEditingController.text = "";
                                            _holderNameTextEditingController.text = ""; 
                                            _observationsTextEditingController.text = "";

                                            loading = true;
                                            setState(() {});
                                            for (int i = 0; i < snapshotMobilePayment.data!.docs.length; i++) {
                                              String orderId = DateTime.now().microsecondsSinceEpoch.toString();
                                              String idOrderPaymentDetails = DateTime.now().microsecondsSinceEpoch.toString();

                                    
                                              await BackEndOrderService().writeServiceOrderPaymentDetailsForUser(
                                                widget.vehicleModel.vehicleId!, 
                                                idOrderPaymentDetails, 
                                                "Pago movil", 
                                                paymentMethodDetailsModel.identificationCard!, 
                                                paymentMethodDetailsModel.numberPhone!, 
                                                paymentMethodDetailsModel.bank!, 
                                                0, 
                                                DateTime.now(), 
                                                _issuerNameTextEditingController.text, 
                                                _holderNameTextEditingController.text, 
                                                _observationsTextEditingController.text
                                              );

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
                                                idOrderPaymentDetails,
                                                context,
                                              );
                                            }

                                            Route route = MaterialPageRoute(builder: (_) => MyServiceOrderByVehicleScreen(vehicleModel: widget.vehicleModel));
                                            Navigator.pushAndRemoveUntil(context, route, (route) => false);
                                            
                                          },
                                        )

                                      ],
                                    ),
                                  )
                              :Container(),

                            ],
                          );

                        }
                      );

                    },

                  ), */
                  /* StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                    .collection(AutoParts.paymentMethodDetails)
                    .where('paymentMethod', isEqualTo: 'Zelle')
                    .snapshots(),
                    builder: (context, snapshot) {

                      if (!snapshot.hasData) {
                        return circularProgress();
                      }

                      if(snapshot.data!.docs.isEmpty){
                        return const EmptyCardMessage(
                          listTitle: 'No hay zelle.',
                          message: 'No hay el metodo de pago: Zelle..',
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (BuildContext context, int index) {

                          PaymentMethodDetailsModel paymentMethodDetailsModel = PaymentMethodDetailsModel.fromJson(
                            (snapshot.data!.docs[index] as dynamic).data(),
                          );

                          return Column(
                            children: [
                              PaymentButton(
                                onTap: () {
                                  setState(() {
                                    isTapMobilePayment = false;
                                    isTapCash = false;
                                    isTapZelle = true;
                                  });
                                },
                                leadingImage: "assets/icons/online_payment.png",
                                title: "Pago en Zelle",
                              ),
                              (isTapZelle)
                                ? Container(
                                  width: MediaQuery.of(context).size.width * 0.80,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        AutoSizeText('Datos del Zelle'),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [

                                            AutoSizeText('Correo'),
                                            Row(
                                              children: [
                                                AutoSizeText(paymentMethodDetailsModel.email.toString()),
                                                IconButton(
                                                  icon: const Icon(Icons.copy),
                                                  onPressed: () async {
                                                    await Clipboard.setData(ClipboardData(text: paymentMethodDetailsModel.email.toString()));
                                                    Fluttertoast.showToast(msg: 'El correo se copio exitosamente');
                                                  },
                                                )

                                              ],
                                            )
                                          ],
                                        ),
                                        SizedBox(height: 10,),
                                        AutoSizeText(
                                          'Registro del Pago',
                                          style: TextStyle(
                                            fontSize: 20
                                          ),
                                        ),
                                        SizedBox(height: 10,),
                                        Form(
                                          key: _formkey,
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                width: MediaQuery.of(context).size.width * 0.80,
                                                child: TextFormField(
                                                  controller: _confirmationNumberTextEditingController,
                                                  keyboardType: TextInputType.number,
                                                  decoration: InputDecoration(
                                                    hintText: "Número de Confirmación",
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(30.0),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 10,),
                                              SizedBox(
                                                width: MediaQuery.of(context).size.width * 0.80,
                                                child: TextFormField(
                                                  controller: _paymentDateTextEditingController,
                                                  keyboardType: TextInputType.none,
                                                  showCursor: false,                                                  
                                                  decoration: InputDecoration(
                                                    hintText: "Fecha del Pago",
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(30.0),
                                                    ),
                                                  ),
                                                  onTap: () async {
                                                    final initialDate = DateTime.now();
                                                    final newDate = await showDatePicker(                          
                                                      context: context,
                                                      initialDate: initialDate,
                                                      firstDate: DateTime(DateTime.now().year - 5),
                                                      lastDate: DateTime.now(),
                                                    );

                                                    if (newDate == null) return;

                                                    _paymentDateTextEditingController.text = DateFormat('dd/MM/yyyy').format(newDate);
                                                  },
                                                ),
                                              ),
                                              SizedBox(height: 10,),
                                              SizedBox(
                                                width: MediaQuery.of(context).size.width * 0.80,
                                                child: TextFormField(
                                                  controller: _issuerNameTextEditingController,
                                                  keyboardType: TextInputType.name,
                                                  decoration: InputDecoration(
                                                    hintText: "Nombre del Emisor",
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(30.0),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 10,),
                                              SizedBox(
                                                width: MediaQuery.of(context).size.width * 0.80,
                                                child: TextFormField(
                                                  controller: _holderNameTextEditingController,
                                                  keyboardType: TextInputType.name,
                                                  decoration: InputDecoration(
                                                    hintText: "Nombre del Titular",
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(30.0),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 10,),
                                              SizedBox(
                                                width: MediaQuery.of(context).size.width * 0.80,
                                                child: TextFormField(
                                                  maxLines: 3,
                                                  controller: _observationsTextEditingController,
                                                  keyboardType: TextInputType.name,
                                                  decoration: InputDecoration(
                                                    hintText: "Observaciones",
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(30.0),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                            ],
                                          ),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color.fromARGB(255, 3, 3, 247),
                                            shape: const StadiumBorder()
                                          ),
                                          child: const AutoSizeText('Confirmar'),
                                          onPressed: () async {

                                            if(
                                              _confirmationNumberTextEditingController.text.isEmpty ||
                                              _paymentDateTextEditingController.text.isEmpty ||
                                              _issuerNameTextEditingController.text.isEmpty ||
                                              _holderNameTextEditingController.text.isEmpty ||
                                              _holderNameTextEditingController.text.isEmpty ||
                                              _observationsTextEditingController.text.isEmpty
                                            )
                                            {
                                              Fluttertoast.showToast(msg: 'Ingrese toda la información solicitada');
                                              return;
                                            }

                                            loading = true;
                                            setState(() {});
                                            for (int i = 0; i < snapshot.data!.docs.length; i++) {
                                              String orderId = DateTime.now().microsecondsSinceEpoch.toString();
                                              String idOrderPaymentDetails = DateTime.now().microsecondsSinceEpoch.toString();
                                               final DateTime datePayment = DateTime.parse(_paymentDateTextEditingController.text.split('/').reversed.join('-'));
                                    
                                              await BackEndOrderService().writeServiceOrderPaymentDetailsForUser(
                                                widget.vehicleModel.vehicleId!, 
                                                idOrderPaymentDetails, 
                                                "Zelle", 
                                                0, 
                                                0, 
                                                "N/A", 
                                                int.parse(_confirmationNumberTextEditingController.text), 
                                                datePayment, 
                                                _issuerNameTextEditingController.text, 
                                                _holderNameTextEditingController.text, 
                                                _observationsTextEditingController.text
                                              );

                                              
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
                                                idOrderPaymentDetails,
                                                context,
                                              );
                                            }

                                            Route route = MaterialPageRoute(builder: (_) => MyServiceOrderByVehicleScreen(vehicleModel: widget.vehicleModel));
                                            Navigator.pushAndRemoveUntil(context, route, (route) => false);
                                            
                                          },
                                        )
                                      ]
                                    )
                                )
                                : Container(),
                                
                            ],
                          );

                        }
                      );
                    },
                  ) */
                  
                  
              
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
      padding: EdgeInsets.all(size.height * 0.012),
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
              width: size.width * 0.11,
              height: size.height * 0.044,
            ),
            title: AutoSizeText(
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
