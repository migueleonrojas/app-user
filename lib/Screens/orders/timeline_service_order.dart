import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:oilapp/Model/service_order_model.dart';
import 'package:oilapp/Model/service_order_with_vehicle.dart';
import 'package:oilapp/Model/vehicle_model.dart';
import 'package:oilapp/Screens/ourservice/backend_orderservice.dart';
import 'package:oilapp/config/config.dart';
import 'package:oilapp/widgets/emptycardmessage.dart';
import 'package:oilapp/widgets/loading_widget.dart';
import 'package:timelines/timelines.dart';


class TimeLineServiceOrder extends StatefulWidget {
  const TimeLineServiceOrder({super.key});

  @override
  State<TimeLineServiceOrder> createState() => _TimeLineServiceOrderState();
}

class _TimeLineServiceOrderState extends State<TimeLineServiceOrder> {

  final backEndOrderService = BackEndOrderService();
  final ScrollController scrollController = ScrollController();
  



  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AutoSizeText(
          'Ordenes de Servicio',
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
              stream: FirebaseFirestore.instance
                .collection('serviceOrder')
                .where('orderBy', isEqualTo: AutoParts.sharedPreferences!.getString(AutoParts.userUID))
                .orderBy("orderTime", descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return circularProgress();
                }

                if (snapshot.data!.docs.isEmpty) {
                  return const EmptyCardMessage(
                    listTitle: 'No tiene servicios',
                    message: 'Solicite un servicio desde Global Oil',
                  );
                }
                return ListView.builder(
                   physics: const NeverScrollableScrollPhysics(),
                   shrinkWrap: true,
                   itemCount: snapshot.data!.docs.length,
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

                      ServiceOrderModel serviceOrderModel = ServiceOrderModel.fromJson(
                        snapshot.data!.docs[index].data()
                      );

                      
                      if(serviceOrderModel.categoryName != "Cambio de Aceite") return Container();

                      
                      return TimelineTile(
                        node: const TimelineNode(
                          indicator: DotIndicator(),
                          startConnector: SolidLineConnector(),
                          endConnector: SolidLineConnector(),
                        ),
                        contents: Card(
                          child: Container(
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                AutoSizeText('Servicio: ${serviceOrderModel.categoryName!}'),
                                _status(serviceOrderModel)
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

  Widget _status(ServiceOrderModel serviceOrderModel) {

    Widget text = AutoSizeText('');

    if(serviceOrderModel.orderRecived == "Done") {
      text = const AutoSizeText('Estatus: Orden recibida.');
    }

    if(serviceOrderModel.beingPrePared == "Done"){
      text = const AutoSizeText('Estatus: Persona del servicio preparado.');
    }

    if(serviceOrderModel.onTheWay == "Done"){
      text = const AutoSizeText('Estatus: En camino.');
    }

    if(serviceOrderModel.deliverd == "Done"){
      text = const AutoSizeText("Estatus: Servicio Completado.");
    }
    if (serviceOrderModel.orderCancelled =="Done") {
      text = const AutoSizeText("Estatus: Servicio Cancelado.");
    }

    return text;

  }

}