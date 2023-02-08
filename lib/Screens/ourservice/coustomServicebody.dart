import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:oilapp/Model/rating_review_model.dart';
import 'package:oilapp/Model/service_model.dart';
import 'package:oilapp/Model/vehicle_model.dart';
import 'package:oilapp/Screens/ourservice/backend_orderservice.dart';
import 'package:oilapp/Screens/ourservice/orderService_screen.dart';
import 'package:oilapp/Screens/ourservice/service_reviews.dart';
import 'package:oilapp/Screens/ourservice/service_shipping_address.dart';
import 'package:oilapp/config/config.dart';
import 'package:oilapp/service/rating_review_service.dart';
import 'package:oilapp/widgets/confirm_animation_button.dart';
import 'package:oilapp/widgets/emptycardmessage.dart';
import 'package:oilapp/widgets/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:oilapp/widgets/modal.dart';
import 'package:rating_dialog/rating_dialog.dart';

class CoustomServiceBody extends StatefulWidget {
  final dynamic isEqualTo;
  final VehicleModel vehicleModel; 

  const CoustomServiceBody({Key? key, this.isEqualTo, required this.vehicleModel}) : super(key: key);
  @override
  _CoustomServiceBodyState createState() => _CoustomServiceBodyState();
}

class _CoustomServiceBodyState extends State<CoustomServiceBody> {
  TextEditingController quantityController = TextEditingController();
  TextEditingController reviewController = TextEditingController();
  TextEditingController observationsController = TextEditingController();
  double totalrating = 0;
  bool istap = true;
  bool isContinue = false;

  int quantity = 1;
  DateTime? date;
  TimeOfDay? time;
  String getDateText() {
    if (date == null) {
      return DateFormat('MM/dd/yyyy').format(DateTime.now());
    } else {
      return DateFormat('MM/dd/yyyy').format(date!);
    }
  }

  Future pickDate(BuildContext context) async {

    Size size = MediaQuery.of(context).size;

    final initialDate = DateTime.now();
    final newDate = await showDatePicker(
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
      context: context,
      initialDate: date ?? initialDate,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
      builder: (context, child) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.60,
                width: MediaQuery.of(context).size.width * 0.90,
                child: child,
              ),
            ),
          ],
        );
      }
    );

    if (newDate == null) return;

    setState(() => date = newDate);
  }

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Container(
        child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("service")
                .where("categoryName", isEqualTo: widget.isEqualTo)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return circularProgress();
              }

              if(snapshot.data!.docs.isEmpty) {

                return const EmptyCardMessage(
                  listTitle: 'No tiene servicios',
                  message: 'No hay servicios disponibles',
                );

              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  ServiceModel serviceModel = ServiceModel.fromJson(
                    (snapshot.data!.docs[index] as dynamic).data(),
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: size.height * 0.125,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: AutoSizeText(
                                serviceModel.serviceName!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  
                                  letterSpacing: 1.5,
                                  fontFamily: "Brand-Regular",
                                  fontWeight: FontWeight.bold,
                                  fontSize: size.height * 0.025,
                                ),
                              ),
                            ),
                            /* const Center(
                              child:  AutoSizeText(
                                "Empezar desde",
                                style: TextStyle(
                                  letterSpacing: 1,
                                  fontFamily: "Brand-Regular",
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ), */

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AutoSizeText(
                                  'Costo: ${serviceModel.newprice}',
                                  style:  TextStyle(
                                    letterSpacing: 1,
                                    fontFamily: "Brand-Regular",
                                    fontWeight: FontWeight.bold,
                                    fontSize: size.height * 0.025,
                                  ),
                                ),
                                SizedBox(width: size.width * 0.03,),
                                Container(
                                  
                                  /* color: Colors.blue, */
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(size.height * 0.035),
                                    color: Colors.transparent,
                                    border: Border.all(color: Colors.blueAccent),
                                    
                                  ),
                                  child: IconButton(
                                    tooltip: 'Información',
                                    icon: const Icon(  
                                      Icons.question_mark,
                                      color: Colors.blue,
                                      
                                    ),
                                    onPressed: () {
                                
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return  ModalAlertDialog(
                                            title: 'Descripción',
                                            content: serviceModel.aboutInfo!.replaceAll("\\n", "\n"),
                                          );
                                        },
                                      );
                                      
                                    },
                                  ),
                                ),
                              ],
                            )
                            /* RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${serviceModel.newprice} \$',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      letterSpacing: 1,
                                      fontFamily: "Brand-Regular",
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  (serviceModel.offervalue! < 1)
                                  ? TextSpan()
                                  : TextSpan(
                                    text: '(Descuento ${serviceModel.offervalue}%)',
                                    style: const TextStyle(
                                      
                                      letterSpacing: 1,
                                      fontFamily: "Brand-Regular",
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ), */
                          ],
                        ),
                      ),
                      
                      Stack(
                        children: [
                          Container(
                            height: size.height * 0.230,
                            width: double.infinity,
                            child: FadeInImage(
                              placeholder: const AssetImage('assets/no-image/no-image.jpg'),
                              image: NetworkImage(serviceModel.serviceImgUrl!),
                              width: double.infinity,
                              fit:BoxFit.contain
                            ),
                            /* decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(serviceModel.serviceImgUrl!),
                                fit: BoxFit.cover,
                              ),
                            ), */
                          ),
                          /* Container(
                            height: 200,
                            color: Colors.black54,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                  child: AutoSizeText(
                                    serviceModel.serviceName!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      letterSpacing: 1.5,
                                      fontFamily: "Brand-Regular",
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                    ),
                                  ),
                                ),
                                const AutoSizeText(
                                  "Empezar desde",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    letterSpacing: 1,
                                    fontFamily: "Brand-Regular",
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '${serviceModel.newprice} \$',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          letterSpacing: 1,
                                          fontFamily: "Brand-Regular",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      (serviceModel.offervalue! < 1)
                                          ? TextSpan()
                                          : TextSpan(
                                              text:
                                                  ' (Descuento ${serviceModel.offervalue}%)',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                letterSpacing: 1,
                                                fontFamily: "Brand-Regular",
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ), */
                        ],
                      ),

                      //----------------------about title--------------------//
                      /* const Padding(
                        padding: const EdgeInsets.all(10),
                        child: AutoSizeText(
                          "Sobre el servicio",
                          style: TextStyle(
                            letterSpacing: 0.5,
                            fontFamily: "Brand-Regular",
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ), */

//------------------------about text---------------------//
                      /* Padding(
                        padding: const EdgeInsets.all(10),
                        child: AutoSizeText(
                          serviceModel.aboutInfo!.replaceAll("\\n", "\n"),
                          style: const TextStyle(
                            fontFamily: "Brand-Regular",
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          ),
                        ),
                      ), */

                      //----------------expect title-------------------//
                      /* const Padding(
                        padding:  EdgeInsets.all(10),
                        child:  AutoSizeText(
                          "Qué esperar",
                          style: TextStyle(
                            letterSpacing: 0.5,
                            fontFamily: "Brand-Regular",
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ), */
                      //----------------------expectText-----------------//
                      /* Padding(
                        padding: const EdgeInsets.all(10),
                        child: AutoSizeText(
                          serviceModel.expectation!.replaceAll("\\n", "\n"),
                          style: const TextStyle(
                            fontFamily: "Brand-Regular",
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          ),
                        ),
                      ), */

                      /* Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            height: 40,
                            
                            child: TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 0, horizontal: MediaQuery.of(context).size.width * 0.15),
                                backgroundColor: Color.fromARGB(255, 3, 3, 247),
                                shape: const StadiumBorder()
                              ),
                              onPressed: () {
                                setState(() {
                                  istap = true;
                                });
                              },
                              child: const AutoSizeText(
                                "Reservar ahora",

                                
                                style: TextStyle(
                                  
                                  color: Colors.white,
                                  fontFamily: "Brand-Regular",
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ), */

                      (istap)
                          ? Card(
                              elevation: 3,
                              child: Container(
                                  height: size.height * 0.45,
                                  width: double.infinity,
                                  child: Padding(
                                    padding: EdgeInsets.all(size.height * 0.022),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AutoSizeText(
                                          serviceModel.serviceName!,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: size.height * 0.014),
                                        AutoSizeText(
                                          'Va a solicitar $quantity de ${serviceModel.serviceName!}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        /* AutoSizeText(
                                          "Cuántos servicios de" +
                                              "\"${serviceModel.serviceName!}\"" +
                                              " necesita?",
                                          maxLines: 3,
                                        ), */
                                        SizedBox(height: size.height * 0.014),                                        
                                        const AutoSizeText(
                                          "Seleccione su horario para la cita",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: size.height * 0.014),
                                        SizedBox(
                                          width: double.infinity,
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: TextButton.icon(
                                              /* padding: EdgeInsets.zero, */
                                              onPressed: () =>
                                                  pickDate(context),
                                              icon: const Icon(Icons
                                                  .calendar_today_outlined),
                                              label: AutoSizeText(getDateText()),
                                            ),
                                          ),
                                        ),
                                        TextFormField(
                                          maxLines: 3,
                                          controller:
                                          observationsController,
                                          decoration:
                                          InputDecoration(
                                            hintText: "Observaciones",
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(size.height * 0.008),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: size.height * 0.024),
                                        Center(
                                          child: (!isContinue) 
                                            ? AnimatedConfirmButton(

                                                onTap: () async {
                                              
                                              

                                                Timer(const Duration(seconds: 1), () async {
                                                  await BackEndOrderService()
                                                      .addService(
                                                        widget.vehicleModel.vehicleId!,
                                                        serviceModel.serviceId!,
                                                        serviceModel.newprice = serviceModel.newprice! * quantity,
                                                        serviceModel.orginalprice!,
                                                        serviceModel.serviceImgUrl!,
                                                        serviceModel.serviceName!,
                                                        getDateText(),
                                                        quantity,
                                                        observationsController.text,
                                                        serviceModel.categoryName!
                                                      );
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          "El servicio está listo para ser pedido!");
                                                  setState(() {
                                                    isContinue = true;
                                                  });
                                                });

                                                

                                              
                                              
                                            },
                                            
                                            animationDuration: const Duration(
                                                milliseconds: 2000),
                                            initialText: "Solicitar",
                                            finalText: "Listo",
                                            iconData: Icons.check,
                                            iconSize: size.height * 0.036,
                                            
                                            buttonStyle: ConfirmButtonStyle(
                                              primaryColor: const Color.fromARGB(255, 3, 3, 247),
                                              secondaryColor: Colors.white,
                                              elevation: 10.0,
                                              initialTextStyle: TextStyle(
                                                fontSize: size.height * 0.026,
                                                color: Colors.white,
                                              ),
                                              finalTextStyle: TextStyle(
                                                fontSize: size.height * 0.026,
                                                color: const Color.fromARGB(255, 3, 3, 247),
                                              ),
                                              borderRadius: size.height * 0.034,
                                            ),
                                          )
                                          :ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color.fromARGB(255, 3, 3, 247),
                                              shape: const StadiumBorder(),
                                              padding: EdgeInsets.symmetric(vertical: size.height * 0.022, horizontal: size.width * 0.2)                                            ),
                                            child: AutoSizeText('Siguiente'),
                                            onPressed: () {

                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                    ServiceShippingAddress(
                                                      vehicleModel: widget.vehicleModel,
                                                      totalPrice: serviceModel.newprice! * quantity,
                                                    )
                                            
                                                  )
                                                );
                                                

                                            }, 
                                          )
                                        ),
                                      ],
                                    ),
                                  )),
                            )
                          : Container(),
                      SizedBox(height: size.height * 0.014),
                      /* (isContinue)
                          ? Center(
                              child: Container(
                                decoration: const BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blueGrey,
                                      offset: Offset(1, 3),
                                      blurRadius: 6,
                                      spreadRadius: -2,
                                    ),
                                  ],
                                ),
                                child: TextButton.icon(
                                  style: TextButton.styleFrom(
                                    backgroundColor: Color.fromARGB(255, 3, 3, 247),
                                    shape: const StadiumBorder()
                                  ),
                                  /* 
                                  /* style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 0, horizontal: MediaQuery.of(context).size.width * 0.15),
                                backgroundColor: Color.fromARGB(255, 3, 3, 247),
                                shape: const StadiumBorder()
                              ), */
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 9,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  color: Colors.deepOrangeAccent[200], */
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                            ServiceShippingAddress(
                                              vehicleModel: widget.vehicleModel,
                                              totalPrice: serviceModel.newprice! * quantity,
                                            )
                                            /* ServiceShippingAddress(
                                              totalPrice: serviceModel.newprice! * quantity,
                                              vehicleModel: widget.vehicleModel,
                                            ) */
                                        ));
                                    setState(() {
                                      istap = false;
                                      isContinue = false;
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.double_arrow_rounded,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                  label: const AutoSizeText("Continue",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                      )),
                                ),
                              ),
                            )
                          : Container(),
                      const SizedBox(height: 10), */
                      StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection(AutoParts.collectionUser)
                              .doc(AutoParts.sharedPreferences!
                                  .getString(AutoParts.userUID))
                              .collection('ServiceCart')
                              .where("serviceId",
                                  isEqualTo: serviceModel.serviceId)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return Container();
                            return (snapshot.data!.docs.length == 1)
                                ? 
                                ListView.builder(
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    return Center(
                                    child: AnimatedConfirmButton(
                                      onTap: () {
                                        Timer(Duration(seconds: 1), () {
                                          BackEndOrderService().deleteService(
                                            serviceModel.serviceId!,
                                            widget.vehicleModel.vehicleId!,
                                            (snapshot.data!.docs[index] as dynamic).data()['servicecartId'],
                                          );
                                          setState(() {
                                            isContinue = false;
                                            istap = false;
                                          });
                                        });
                                      },
                                      animationDuration:
                                          const Duration(milliseconds: 2000),
                                      initialText: "Eliminar",
                                      finalText: "Eliminar Servicio",
                                      iconData: Icons.check,
                                      iconSize: size.height * 0.036,
                                      buttonStyle: ConfirmButtonStyle(
                                        primaryColor:
                                            Colors.deepOrangeAccent,
                                        secondaryColor: Colors.white,
                                        elevation: 10.0,
                                        initialTextStyle:  TextStyle(
                                          fontSize: size.height * 0.026,
                                          color: Colors.white,
                                        ),
                                        finalTextStyle: TextStyle(
                                          fontSize: size.height * 0.023,
                                          color: Colors.deepOrangeAccent[200],
                                        ),
                                        borderRadius: size.height * 0.014,
                                      ),
                                    ),
                                  );
                                  },
                                )
                                
                                : Container();
                          }),
                      /* Opiniones y criticas de usuarios comentado */
                      /* Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AutoSizeText(
                              "Valoración y comentarios",
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: "Brand-Bold",
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('ratingandreviews')
                                          .where("productId",
                                              isEqualTo: serviceModel.serviceId)
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return Container();
                                        }
                                        double userrating = 0;
                                        for (int i = 0;
                                            i < snapshot.data!.docs.length;
                                            i++) {
                                          userrating = userrating +
                                              (snapshot.data!.docs[i] as dynamic)
                                                  .data()['rating'] as dynamic;
                                        }

                                        return Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                 AutoSizeText(
                                                  (snapshot.data!.docs.length ==
                                                          0)
                                                      ? "0.0"
                                                      : "${(userrating / snapshot.data!.docs.length).toStringAsFixed(1)}",
                                                  style: TextStyle(
                                                    fontSize: 35,
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.star_half,
                                                  size: 25,
                                                  color: Colors
                                                      .deepOrangeAccent[200],
                                                )
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                AutoSizeText(
                                                    '${userrating.toString()}/'),
                                                AutoSizeText(
                                                  "${snapshot.data!.docs.length.toString()} puntajes",
                                                )
                                              ],
                                            ),
                                          ],
                                        );
                                      }),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return RatingDialog(
                                            commentHint: 'díganos sus comentarios',
                                            image: Image.asset(
                                              "assets/authenticaiton/logo.png",
                                              width: 100,
                                              height: 100,
                                            ),
                                            title: const AutoSizeText("Dar su calificación"),
                                            message:const AutoSizeText("Toque una estrella para establecer su calificación. Añade más descripción aquí si quieres."),
                                            onSubmitted: (rating) {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                    ),
                                                    title: const AutoSizeText(
                                                      "Dé su opinión",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    content: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        const AutoSizeText(
                                                          "Escriba su valiosa opinión sobre este servicio. Nos ayudará a mejorar nuestro servicio.",
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                        const SizedBox(height: 4),
                                                        TextFormField(
                                                          maxLines: 3,
                                                          controller:
                                                              reviewController,
                                                          decoration:
                                                              InputDecoration(
                                                            hintText:
                                                                "escribe lo que quieras!",
                                                            border:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                            ),
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () async {
                                                            await RatingAndReviewService()
                                                                .addRatingandReviewForuser(
                                                              AutoParts
                                                                  .sharedPreferences!
                                                                  .getString(
                                                                      AutoParts
                                                                          .userAvatarUrl)!,
                                                              AutoParts
                                                                  .sharedPreferences!
                                                                  .getString(
                                                                      AutoParts
                                                                          .userName)!,
                                                              AutoParts
                                                                  .sharedPreferences!
                                                                  .getString(
                                                                      AutoParts
                                                                          .userUID)!,
                                                              serviceModel
                                                                  .serviceId!,
                                                              serviceModel
                                                                  .serviceName!,
                                                              serviceModel
                                                                  .serviceImgUrl!,
                                                              rating.rating,
                                                              reviewController
                                                                  .text,
                                                            );
                                                            setState(() {
                                                              reviewController
                                                                  .text = "";
                                                            });

                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    "Gracias por darnos su valiosa calificación y reseña");
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: const AutoSizeText(
                                                            "Enviar",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16,
                                                              color: Colors
                                                                  .deepOrangeAccent,
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            submitButtonText: "Opine",
                                            
                                          );
                                        },
                                      );
                                    },
                                    child: Container(
                                      height: 100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          width: 2,
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                      child:const Center(
                                        child:  AutoSizeText(
                                          "Califique y opine...",
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('ratingandreviews')
                                  .where("productId",
                                      isEqualTo: serviceModel.serviceId)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Container();
                                }
                                return (snapshot.data!.docs.length == 0)
                                    ? Container()
                                    : (snapshot.data!.docs.length > 5)
                                        ? Column(
                                            children: [
                                              ListView.builder(
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemCount: 5,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  RatingAndReviewModel
                                                      ratingAndReviewModel =
                                                      RatingAndReviewModel
                                                          .formJson(
                                                    (snapshot.data!.docs[index] as dynamic)
                                                        .data(),
                                                  );
                                                  return ListTile(
                                                    leading: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(50),
                                                          child: (ratingAndReviewModel.userAvatar!.isNotEmpty)
                                                            ? Image.network(ratingAndReviewModel.userAvatar!)
                                                            :  Image.asset('assets/authenticaiton/user_icon.png'),
                                                    ),
                                                    title: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        AutoSizeText(
                                                          ratingAndReviewModel
                                                              .userName!,
                                                          style: const TextStyle(
                                                            fontSize: 18,
                                                            letterSpacing: 0.5,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontFamily:
                                                                "Brand-Regular",
                                                          ),
                                                        ),
                                                        Row(
                                                          children: [
                                                            AutoSizeText(
                                                              '${ratingAndReviewModel.rating} ',
                                                            ),
                                                            for (int i = 0;
                                                                i <
                                                                    ratingAndReviewModel
                                                                        .rating!;
                                                                i++)
                                                              AutoSizeText('⭐'),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    subtitle: AutoSizeText(
                                                        ratingAndReviewModel
                                                            .reviewMessage!),
                                                  );
                                                },
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.bottomRight,
                                                child: TextButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            ServiceReviews(
                                                          serviceId:
                                                              serviceModel
                                                                  .serviceId!,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: AutoSizeText(
                                                    "Más Opiniones....",
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontFamily:
                                                          "Brand-Regular",
                                                      letterSpacing: 0.5,
                                                      color: Colors
                                                              .deepOrangeAccent[
                                                          200],
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          )
                                        : ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            itemCount:
                                                snapshot.data!.docs.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              RatingAndReviewModel
                                                  ratingAndReviewModel =
                                                  RatingAndReviewModel.formJson(
                                                (snapshot.data!.docs[index] as dynamic)
                                                    .data(),
                                              );
                                              return ListTile(
                                                leading: ClipRRect(
                                                  borderRadius: BorderRadius.circular(50),
                                                  child: (ratingAndReviewModel.userAvatar!.isNotEmpty)
                                                    ? Image.network(
                                                        ratingAndReviewModel.userAvatar!,
                                                        fit: BoxFit.cover,
                                                        width: 50,
                                                        height: 50,
                                                      )
                                                    :Image.asset('assets/authenticaiton/user_icon.png')
                      
                                                ),
                                                title: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    AutoSizeText(
                                                      ratingAndReviewModel
                                                          .userName!,
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        letterSpacing: 0.5,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontFamily:
                                                            "Brand-Regular",
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        AutoSizeText(
                                                            '${ratingAndReviewModel.rating}'),
                                                        for (int i = 0;
                                                            i <
                                                                ratingAndReviewModel
                                                                    .rating!;
                                                            i++)
                                                          AutoSizeText('⭐'),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                                subtitle: AutoSizeText(
                                                    ratingAndReviewModel
                                                        .reviewMessage!),
                                              );
                                            },
                                          );
                              },
                            ),
                          ],
                        ),
                      ), */

                      //---------------------Note-------------------//
                      Padding(

                        padding:  EdgeInsets.all(size.height * 0.014),
                        child: Row(
                          children: [
                            AutoSizeText(
                              "Nota:",
                              style: TextStyle(
                                letterSpacing: 0.5,
                                color: Colors.deepOrangeAccent[200],
                                fontStyle: FontStyle.italic,
                                decoration: TextDecoration.underline,
                                fontFamily: "Brand-Regular",
                                fontWeight: FontWeight.w600,
                                fontSize: size.height * 0.016,
                              ),
                            ),
                            SizedBox(width: size.height * 0.014,),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(size.height * 0.036),
                                color: Colors.transparent,
                                border: Border.all(color: Colors.blueAccent),
                                    
                              ),
                              child: IconButton(
                                tooltip: 'Información',
                                icon: const Icon(  
                                  Icons.question_mark,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return  ModalAlertDialog(
                                        title: 'Nota',
                                        content: "Los precios mencionados son cargos de servicio estimados que pueden variar ligeramente dependiendo de: El tipo de vehículo, el modelo y la disponibilidad del servicio.\n\nPolítica de servicio a domicilio: El cargo por servicio a domicilio de un máximo de 5\$ es aplicable si el cliente decide no tomar el servicio después de que el proveedor de servicios visitó el lugar.",
                                      );
                                    },
                                  );
                                      
                                },
                              ),
                            ),
                            
                          ],
                        ),
                      ),
                      /* const Padding(
                        padding:  EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: AutoSizeText(
                          "Los precios mencionados son cargos de servicio estimados que pueden variar ligeramente dependiendo de: El tipo de vehículo, el modelo y la disponibilidad del servicio.",
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontFamily: "Brand-Regular",
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ), */
                      /* const Padding(
                        padding:  EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: AutoSizeText(
                          "Política de servicio a domicilio: El cargo por servicio a domicilio de un máximo de 5\$ es aplicable si el cliente decide no tomar el servicio después de que el proveedor de servicios visitó el lugar.",
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontFamily: "Brand-Regular",
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ), */
                    ],
                  );
                },
              );
            }),
      ),
    );
  }
}
