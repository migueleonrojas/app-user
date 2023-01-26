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
              stream: backEndVehiclesService.suggestionUsersVehiclesStream,
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
                     
                      /* int daysActual = (DateTime.now().microsecondsSinceEpoch / 1000000 / 60 / 60 / 24).round();
                      int daysUserVehicle = (vehicleWithNotificationsModel.updateDate!.microsecondsSinceEpoch / 1000000 / 60 / 60 / 24).round(); 
                      int daysPassed = (daysActual - daysUserVehicle);
                      int daysOfTheNextService = vehicleWithNotificationsModel.days! - daysPassed;
                      int microsecondsNextService = vehicleWithNotificationsModel.updateDate!.microsecondsSinceEpoch.round() + (1000000 * 60 * 60 * 24 * vehicleWithNotificationsModel.days!).round();
                      DateTime dateFromNextService = DateTime.fromMicrosecondsSinceEpoch(microsecondsNextService);

                      String dateFromNextFormat = DateFormat('yyyy/MM/dd hh:mm a').format(dateFromNextService); */

                      

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TimelineTile(
                          
                          nodeAlign: TimelineNodeAlign.start,
                          node:  TimelineNode(
                            
                            indicator: DotIndicator(
                              size: 50,
                              color: Color(vehicleWithNotificationsModel.color!),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(
                                  scale: 0.5,
                                  'assets/icons/car_oilchange.png',
                                  width:40 ,
                                  color: Colors.white,
                                  fit: BoxFit.scaleDown,
                                ),
                              ),
                              /* child: Image.asset(
                                'assets/icons/car_oilchange.png',
                                width: 5,
                                height: 5,
                                color: Colors.white,
                                fit: BoxFit.scaleDown,
                              ), */
                              /* child: Image.asset(
                                "assets/icons/car_oilchange.png",
                                color: Colors.white,
                                height: 2,
                                width: 2,
                              ), */
                            ),
                            startConnector: SolidLineConnector(
                              color: Color(vehicleWithNotificationsModel.color!),
                            ),
                            endConnector: SolidLineConnector(
                              color: Color(vehicleWithNotificationsModel.color!),
                            ),
                          ),
                          contents: Card(
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [

                                  Text(
                                    '${vehicleWithNotificationsModel.brand} ${vehicleWithNotificationsModel.model} ${vehicleWithNotificationsModel.year}',
                                    style: TextStyle(
                                      color: Color(vehicleWithNotificationsModel.color!)
                                    ),
                                  ),
                                  const SizedBox(height: 5,),
                                  messageDayRest(
                                    vehicleWithNotificationsModel.daysOfTheNextService!,
                                    vehicleWithNotificationsModel.dateFromNextFormat!
                                  ),
                                  /* messageDate(
                                    vehicleWithNotificationsModel.daysOfTheNextService!,
                                    vehicleWithNotificationsModel.dateFromNextFormat!
                                  ) */
                                  /* messageDayRest(daysOfTheNextService),
                                  messageDate(daysOfTheNextService, dateFromNextFormat), */
                                  
                                ],
                              ),
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

  Widget messageDayRest(int daysOfTheNextService,  String dateFromNextFormat) {

    Widget text = Text('');

    /* Restan 6 dias para el proximo cambio de aceite */

    if(daysOfTheNextService <= 0) {
      text =  Text(
        'Restan ${0} dias para el proximo cambio de aceite. El ${dateFromNextFormat}',
        style: const TextStyle(color: Colors.red),
      );
    }

    if(daysOfTheNextService > 0 && daysOfTheNextService <= 7) {
      text =  Text(
        'Restan ${daysOfTheNextService} dias para el proximo cambio de aceite. El ${dateFromNextFormat}.',
        style: const TextStyle(color: Colors.orange),
      );
    }

    if(daysOfTheNextService > 7){
      text = Text('Restan ${daysOfTheNextService} dias para el proximo cambio de aceite. El ${dateFromNextFormat}.');
    }

    

    return text;

  }

  Widget messageDate(int daysOfTheNextService,  String dateFromNextFormat) {

    Widget text = Text('');

    if(daysOfTheNextService <= 0) {
      text =  Text(
        'El: ${dateFromNextFormat}',
        style: const TextStyle(color: Colors.red),
      );
    }

    else{
      text =  Text(
        'El: ${dateFromNextFormat}',
       
      );
    }

    

    return text;

  }

}