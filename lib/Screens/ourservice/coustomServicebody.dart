import 'dart:async';

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
import 'package:oilapp/widgets/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
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
  bool istap = false;
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
    final initialDate = DateTime.now();
    final newDate = await showDatePicker(
      context: context,
      initialDate: date ?? initialDate,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (newDate == null) return;

    setState(() => date = newDate);
  }

  @override
  Widget build(BuildContext context) {
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

              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  ServiceModel serviceModel = ServiceModel.fromJson(
                    (snapshot.data!.docs[index] as dynamic).data(),
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(serviceModel.serviceImgUrl!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Container(
                            height: 200,
                            color: Colors.black54,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                  child: Text(
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
                                const Text(
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
                          ),
                        ],
                      ),

                      //----------------------about title--------------------//
                      const Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          "Sobre el servicio",
                          style: TextStyle(
                            letterSpacing: 0.5,
                            fontFamily: "Brand-Regular",
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),

//------------------------about text---------------------//
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          serviceModel.aboutInfo!.replaceAll("\\n", "\n"),
                          style: const TextStyle(
                            fontFamily: "Brand-Regular",
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          ),
                        ),
                      ),

                      //----------------expect title-------------------//
                      const Padding(
                        padding:  EdgeInsets.all(10),
                        child:  Text(
                          "Qué esperar",
                          style: TextStyle(
                            letterSpacing: 0.5,
                            fontFamily: "Brand-Regular",
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      //----------------------expectText-----------------//
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          serviceModel.expectation!.replaceAll("\\n", "\n"),
                          style: const TextStyle(
                            fontFamily: "Brand-Regular",
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.blueGrey,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  istap = true;
                                });
                              },
                              child: const Text(
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
                      ),

                      (istap)
                          ? Card(
                              elevation: 3,
                              child: Container(
                                  height: 400,
                                  width: double.infinity,
                                  child: Padding(
                                    padding: const EdgeInsets.all(14.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          serviceModel.serviceName!,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          "Cuántos servicios de" +
                                              "\"${serviceModel.serviceName!}\"" +
                                              " necesita?",
                                          maxLines: 3,
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: SizedBox(
                                                width: 55,
                                                child: OutlinedButton(
                                                  child: const Icon(Icons.remove),
                                                  onPressed: () {
                                                    if (quantity > 1) {
                                                      setState(() {
                                                        quantity--;
                                                      });
                                                    }
                                                  },
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 30,
                                              ),
                                              child: Text(
                                                quantity.toString(),
                                                style: const TextStyle(
                                                  fontFamily: "Brand-Regular",
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: SizedBox(
                                                width: 55,
                                                child: OutlinedButton(
                                                  child: const Icon(Icons.add),
                                                  onPressed: () {
                                                    setState(() {
                                                      quantity++;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        const Text(
                                          "Seleccione su horario para la cita",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
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
                                              label: Text(getDateText()),
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
                                              borderRadius: BorderRadius.circular(5),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Center(
                                          child: AnimatedConfirmButton(
                                            onTap: () {
                                              Timer(Duration(seconds: 1), () {
                                                BackEndOrderService()
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
                                            initialText: "Confirmar",
                                            finalText: "Hecho",
                                            iconData: Icons.check,
                                            iconSize: 32.0,
                                            buttonStyle: ConfirmButtonStyle(
                                              primaryColor:
                                                  Colors.green.shade600,
                                              secondaryColor: Colors.white,
                                              elevation: 10.0,
                                              initialTextStyle: const TextStyle(
                                                fontSize: 22.0,
                                                color: Colors.white,
                                              ),
                                              finalTextStyle: TextStyle(
                                                fontSize: 22.0,
                                                color: Colors.green.shade600,
                                              ),
                                              borderRadius: 10.0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            )
                          : Container(),
                      const SizedBox(height: 10),
                      (isContinue)
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
                                  /* padding: EdgeInsets.symmetric(
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
                                  label: const Text("Continue",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                      )),
                                ),
                              ),
                            )
                          : Container(),
                      const SizedBox(height: 10),
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
                                      iconSize: 32.0,
                                      buttonStyle: ConfirmButtonStyle(
                                        primaryColor:
                                            Colors.deepOrangeAccent,
                                        secondaryColor: Colors.white,
                                        elevation: 10.0,
                                        initialTextStyle: const TextStyle(
                                          fontSize: 22.0,
                                          color: Colors.white,
                                        ),
                                        finalTextStyle: TextStyle(
                                          fontSize: 18.0,
                                          color: Colors.deepOrangeAccent[200],
                                        ),
                                        borderRadius: 10.0,
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
                            const Text(
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
                                                 Text(
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
                                                Text(
                                                    '${userrating.toString()}/'),
                                                Text(
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
                                            title: const Text("Dar su calificación"),
                                            message:const Text("Toque una estrella para establecer su calificación. Añade más descripción aquí si quieres."),
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
                                                    title: const Text(
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
                                                        const Text(
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
                                                          child: const Text(
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
                                        child:  Text(
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
                                                        Text(
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
                                                            Text(
                                                              '${ratingAndReviewModel.rating} ',
                                                            ),
                                                            for (int i = 0;
                                                                i <
                                                                    ratingAndReviewModel
                                                                        .rating!;
                                                                i++)
                                                              Text('⭐'),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    subtitle: Text(
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
                                                  child: Text(
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
                                                    Text(
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
                                                        Text(
                                                            '${ratingAndReviewModel.rating}'),
                                                        for (int i = 0;
                                                            i <
                                                                ratingAndReviewModel
                                                                    .rating!;
                                                            i++)
                                                          Text('⭐'),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                                subtitle: Text(
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
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          "Nota:",
                          style: TextStyle(
                            letterSpacing: 0.5,
                            color: Colors.deepOrangeAccent[200],
                            fontStyle: FontStyle.italic,
                            decoration: TextDecoration.underline,
                            fontFamily: "Brand-Regular",
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const Padding(
                        padding:  EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Text(
                          "Los precios mencionados son cargos de servicio estimados que pueden variar ligeramente dependiendo de: El tipo de vehículo, el modelo y la disponibilidad del servicio.",
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontFamily: "Brand-Regular",
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const Padding(
                        padding:  EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Text(
                          "Política de servicio a domicilio: El cargo por servicio a domicilio de un máximo de 5\$ es aplicable si el cliente decide no tomar el servicio después de que el proveedor de servicios visitó el lugar.",
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontFamily: "Brand-Regular",
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            }),
      ),
    );
  }
}
