import 'dart:async';
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:oilapp/Model/service_order_model.dart';
import 'package:oilapp/Model/service_order_with_vehicle.dart';
import 'package:oilapp/Model/vehicle_model.dart';
import 'package:oilapp/Model/vehicle_model_notification.dart';
import 'package:oilapp/Screens/ourservice/backend_orderservice.dart';
import 'package:oilapp/Screens/ourservice/backend_vehicles.dart';
import 'package:oilapp/config/config.dart';
import 'package:oilapp/widgets/emptycardmessage.dart';
import 'package:oilapp/widgets/loading_widget.dart';
import 'package:timelines/timelines.dart';
import 'package:intl/intl.dart';

class TimeLineVehicles extends StatefulWidget {



  const TimeLineVehicles({super.key});

  @override
  State<TimeLineVehicles> createState() => _TimeLineVehiclesState();
}

class _TimeLineVehiclesState extends State<TimeLineVehicles> {

  final backEndVehiclesService = BackEndVehiclesService();
  final ScrollController scrollController = ScrollController();
  Map<String, dynamic> notification = {};
  
  @override
  void initState() {
    super.initState();
    backEndVehiclesService.getVehiclesWithNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Próximos servicios de Cambio de Aceite',
          style:  TextStyle(
            fontSize: 20 
          ),
        ),
        const SizedBox(height: 15,),
        Container(
          height: MediaQuery.of(context).size.height * 0.20,
          child: SingleChildScrollView(
            
            physics: const BouncingScrollPhysics(),
            controller: scrollController,
            scrollDirection: Axis.vertical,
            child: StreamBuilder(
              stream: backEndVehiclesService.suggestionStream,
              /* stream: FirebaseFirestore.instance
                .collection(AutoParts.collectionUser)
                .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
                .collection(AutoParts.vehicles)
                .orderBy("updateDate", descending: true)
                .snapshots(), */
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return circularProgress();
                }

                if (snapshot.data!.isEmpty) {
                  return const EmptyCardMessage(
                    listTitle: 'No tiene ordenes de productos',
                    message: 'Compre desde Global Oil',
                  );
                }
                
                return ListView.builder(
                   physics: const NeverScrollableScrollPhysics(),
                   shrinkWrap: true,
                   itemCount: snapshot.data!.length,
                   itemBuilder:(context, index) {
                     if (snapshot.data == null) return Center(
                        child: Column(
                          children: [
                            SizedBox(height: 20,),
                            Container(
                              child: const CircularProgressIndicator(),
                            ),
                          ],
                        ),
                      );
                      VehicleWithNotificationsModel vehicleWithNotificationsModel = VehicleWithNotificationsModel.fromJson(
                        snapshot.data![index]
                      );
                     
                      int daysActual = (DateTime.now().microsecondsSinceEpoch / 1000000 / 60 / 60 / 24).round();
                      int daysUserVehicle = (vehicleWithNotificationsModel.updateDate!.microsecondsSinceEpoch / 1000000 / 60 / 60 / 24).round(); 
                      int daysPassed = (daysActual - daysUserVehicle);
                      int daysOfTheNextService = vehicleWithNotificationsModel.days! - daysPassed;
                      int microsecondsNextService = vehicleWithNotificationsModel.updateDate!.microsecondsSinceEpoch.round() + (1000000 * 60 * 60 * 24 * vehicleWithNotificationsModel.days!).round();
                      DateTime dateFromNextService = DateTime.fromMicrosecondsSinceEpoch(microsecondsNextService);

                      String dateFromNextFormat = DateFormat('yyyy/MM/dd hh:mm a').format(dateFromNextService);

                      return TimelineTile(

                        node:  TimelineNode(
                          indicator: DotIndicator(
                            color: Color(vehicleWithNotificationsModel.color!),
                          ),
                          startConnector: SolidLineConnector(
                            color: Color(vehicleWithNotificationsModel.color!),
                          ),
                          endConnector: SolidLineConnector(
                            color: Color(vehicleWithNotificationsModel.color!),
                          ),
                        ),
                        oppositeContents: Card(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.50,
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              
                              children: [
                                Text('Marca: ${vehicleWithNotificationsModel.brand}'),
                                Text('Modelo: ${vehicleWithNotificationsModel.model}'),
                                Text('Año: ${vehicleWithNotificationsModel.year}'),
                                messageDayRest(daysOfTheNextService),
                                messageDate(daysOfTheNextService, dateFromNextFormat),
                                
                              ],
                            ),
                          ),
                        ),
                        
                      );
                   }
                );

                
              },
            )
          ),
        ),
      ],
    );
  }

  Future <Map<String, dynamic>> getNotificationMessage () async {

    

    QuerySnapshot<Map<String, dynamic>> notificationMessages = await AutoParts.firestore!
        .collection('notificationMessage')
        .where('message', isEqualTo: "cambio de aceite")
        .get();

   
    return notificationMessages.docs[0].data();


  }

  Widget messageDayRest(int daysOfTheNextService) {

    Widget text = Text('');

    if(daysOfTheNextService <= 0) {
      text =  Text(
        'Ya se le paso la fecha del cambio de aceite',
        style: const TextStyle(color: Colors.red),
      );
    }

    if(daysOfTheNextService > 0 && daysOfTheNextService <= 7) {
      text =  Text(
        'Le quedan solo ${daysOfTheNextService} dias para hacer el cambio de aceite.',
        style: const TextStyle(color: Colors.orange),
      );
    }

    if(daysOfTheNextService > 7){
      text = Text('Su próximo cambio de aceite es en: ${daysOfTheNextService} dias');
    }

    

    return text;

  }

  Widget messageDate(int daysOfTheNextService,  String dateFromNextFormat) {

    Widget text = Text('');

    if(daysOfTheNextService <= 0) {
      text =  Text(
        'Fecha del ultimo cambio de aceite realizado: ${dateFromNextFormat}',
        style: const TextStyle(color: Colors.red),
      );
    }

    else{
      text =  Text(
        'Fecha del próximo cambio de aceite: ${dateFromNextFormat}',
       
      );
    }

    

    return text;

  }

}