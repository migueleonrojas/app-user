import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:oilapp/Model/vehicle_model.dart';
import 'package:oilapp/Model/vehicle_model_notification.dart';
import 'package:oilapp/Screens/ourservice/backend_vehicles.dart';
import 'package:oilapp/widgets/emptycardmessage.dart';
import 'package:oilapp/widgets/loading_widget.dart';
import 'package:timelines/timelines.dart';

class TimelineVehiclesCarNotesAndServiceOrder extends StatefulWidget {

  final VehicleWithNotificationsModel? vehicleWithNotificationsModel;
  
  const TimelineVehiclesCarNotesAndServiceOrder({super.key, this.vehicleWithNotificationsModel});

  @override
  State<TimelineVehiclesCarNotesAndServiceOrder> createState() => _TimelineVehiclesCarNotesAndServiceOrderState();
}

class _TimelineVehiclesCarNotesAndServiceOrderState extends State<TimelineVehiclesCarNotesAndServiceOrder> {

  final ScrollController scrollController = ScrollController();
  final backEndVehiclesService = BackEndVehiclesService();

  @override
  void initState() {
    super.initState();
    backEndVehiclesService.getCarNotesAndOrderServiceByVehicle(widget.vehicleWithNotificationsModel!.vehicleId!);
  }

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        
        title: Text(
          "Mis Ordenes de Servicio y Notas de Servicio",
          style: TextStyle(
            fontSize: size.height * 0.024,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
            fontFamily: "Brand-Regular",
          ),
        ),
        centerTitle: true,
        
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Card(
              margin: EdgeInsets.all(size.height * 0.021),
              child: Padding(
                padding: EdgeInsets.all(size.height * 0.008),
                child: messageDayRest(
                  widget.vehicleWithNotificationsModel!.daysOfTheNextService!, 
                  widget.vehicleWithNotificationsModel!.dateFromNextFormat!
                ),
              )
            ),
          ),
          SizedBox(height: size.height * 0.021,),
          Container(
            height: MediaQuery.of(context).size.height * 0.75,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              controller: scrollController,
              scrollDirection: Axis.vertical,
              child: StreamBuilder(
                stream: backEndVehiclesService.suggestionCarNotesAndOrderServiceByVehicle,
                builder: (context, snapshot) {
            
                  if (!snapshot.hasData) {
                    return circularProgress();
                  }
            
                  if (snapshot.data!.isEmpty) {
                    return const EmptyCardMessage(
                      listTitle: 'No tiene ordenes de productos o notas de servicios',
                      message: 'Solicite un servicio Global Oil o cree una nota de servicio',
                    );
                  }
            
                  return ListView.builder(
                     physics: const NeverScrollableScrollPhysics(),
                     shrinkWrap: true,
                     itemCount: snapshot.data!.length,
                     itemBuilder:(context, index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: size.width *0.07),
                          child: carNotesOrOrderServiceByVehicles(snapshot.data![index],size),
                        );
                     }
                  );
            
                  
            
                },
              ),
            )
          )


        ]
      )
      ,
    );
  }

  Widget carNotesOrOrderServiceByVehicles(Map<String,dynamic> data,Size size ){

    return TimelineTile(
      nodeAlign: TimelineNodeAlign.start,
      node: TimelineNode(
        indicator: DotIndicator(
          size: size.height * 0.060,
          child: Padding(
            padding: EdgeInsets.all(size.height * 0.005),
            child: (data['carNoteId'] == null)
              ? const IconButton(onPressed: null, icon: Icon(Icons.miscellaneous_services,color: Colors.white,))
              : const IconButton(onPressed: null, icon: Icon(Icons.note, color: Colors.white,))
          ),                
        ),
        startConnector: const SolidLineConnector(
          color: Colors.blue,
          
        ),
        endConnector: const SolidLineConnector(
          color: Colors.blue,
        ),
      ),
      contents: Card(
        child: Padding(
          padding: EdgeInsets.all(size.height * 0.012),
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                (data['serviceId']!= null) ?Text('Orden de Servicio'):Text('Nota de Servicio'),
                SizedBox(height: size.height * 0.008,),
                Text('${data["serviceName"]}'),
                SizedBox(height: size.height * 0.008,),
                FadeInImage(
                  placeholder: const AssetImage('assets/no-image/no-image.jpg'),
                  image: NetworkImage('${data["serviceImage"]}'),
                  width: size.width * 0.15 ,
                  height: size.height * 0.080,
                  fit:BoxFit.contain
                ),
                (data["mileage"] != null) ?Text('${data["mileage"]} km'):Text('${widget.vehicleWithNotificationsModel!.mileage} km'),
                (data['serviceId']!= null) ?_status(data):const SizedBox()
              ]
            ),
          ),
        ),
      ),
    );
    
  }

  Widget _status(Map<String,dynamic> data) {

    Widget text = Text('');

    if(data["orderRecived"] == "Done") {
      text = const Text('Estatus: Orden recibida.');
    }

    if(data["beingPrePared"] == "Done"){
      text = const Text('Estatus: Persona del servicio preparado.');
    }

    if(data["onTheWay"] == "Done"){
      text = const Text('Estatus: En camino.');
    }

    if(data["deliverd"] == "Done"){
      text = const Text("Estatus: Servicio Completado.");
    }
    if (data["orderCancelled"] =="Done") {
      text = const Text("Estatus: Servicio Cancelado.");
    }

    return text;

  }

  Widget messageDayRest(int daysOfTheNextService,  String dateFromNextFormat) {

    Widget text = Text('');
    if(daysOfTheNextService <= 0) {
      text =  Text(
        'Restan ${0} dias para el proximo cambio de aceite. El ${dateFromNextFormat}',
        style: const TextStyle(color: Colors.red),
      );
    }

    if(daysOfTheNextService > 0 && daysOfTheNextService <= 7) {
      text =  Text(
        'Restan ${daysOfTheNextService} dias para el proximo cambio de aceite.\nEl ${dateFromNextFormat}.',
        style: const TextStyle(color: Colors.orange),
      );
    }

    if(daysOfTheNextService > 7){
      text = Text('Restan ${daysOfTheNextService} dias para el proximo cambio de aceite. \nEl ${dateFromNextFormat}.');
    }

    

    return text;

  }
}