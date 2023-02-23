import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:oilapp/Model/vehicle_model.dart';
import 'package:oilapp/Model/vehicle_model_notification.dart';
import 'package:oilapp/Screens/Vehicles/create_car.dart';
import 'package:oilapp/Screens/Vehicles/edit_car.dart';

import 'package:oilapp/Screens/Vehicles/time_line_vehicles_car_notes_and_service_order.dart';
import 'package:oilapp/Screens/Vehicles/create_vehicle.dart';

import 'package:oilapp/Screens/Vehicles/view_cars_notes.dart';
import 'package:oilapp/Screens/home_screen.dart';
import 'package:oilapp/Screens/orders/myservice_order_by_vehicle_screen.dart';
import 'package:oilapp/Screens/orders/myservice_order_screen.dart';
import 'package:gauges/gauges.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:oilapp/Screens/ourservice/backend_vehicles.dart';
import 'package:oilapp/Screens/ourservice/our_service_screen.dart';
import 'package:oilapp/config/config.dart';
import 'package:oilapp/widgets/emptycardmessage.dart';
import 'package:oilapp/widgets/loading_widget.dart';
import 'package:oilapp/widgets/modal_bottom_sheet_add_car_note.dart';
import 'package:oilapp/widgets/simpleAppbar.dart';
import 'package:flutter_rounded_progress_bar/flutter_icon_rounded_progress_bar.dart';
import 'package:flutter_rounded_progress_bar/flutter_rounded_progress_bar.dart';
import 'package:flutter_rounded_progress_bar/rounded_progress_bar_style.dart';

class Cars extends StatefulWidget {
  const Cars({super.key});

  @override
  State<Cars> createState() => _CarsState();
}

class _CarsState extends State<Cars> {

  final ScrollController scrollController = ScrollController();
  final backEndVehiclesService = BackEndVehiclesService();
  ModalBottomSheetAddCarNote carNotes =  ModalBottomSheetAddCarNote();

  @override
  void initState() {
    
    super.initState();
    backEndVehiclesService.getUserVehiclesWithNotification('car');
  }
 

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;

    return Scaffold(  
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: AutoSizeText(
          "Carros",
          style: TextStyle(
            fontSize: size.height * 0.026,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
            fontFamily: "Brand-Regular",
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add
            ),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => CreateCarScreen(automaticallyImplyLeading: true,)));
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.home
            ),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => HomeScreen()));
            },
          ),
        ],
      ),

      body: StreamBuilder(
        stream:backEndVehiclesService.suggestionVehicleUserStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }

          if(snapshot.data!.isEmpty) {
            return const EmptyCardMessage(
              listTitle: 'No tiene vehiculos',
              message: 'Agregue un vehiculo',
            );
          }



          return ListView.builder(
          physics: const BouncingScrollPhysics(),
          controller: scrollController,
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index)  {

            VehicleModel vehicleModel = VehicleModel.fromJson((snapshot.data as dynamic )[index]);
            VehicleWithNotificationsModel vehicleWithNotificationsModel = VehicleWithNotificationsModel.fromJson(
              snapshot.data![index]
            );

            double percent = (100 - ( 100 * vehicleWithNotificationsModel.daysOfTheNextService!.toDouble()) / vehicleWithNotificationsModel.days!.toDouble());
            return Card(
              elevation: 2,
              child: ListTile(
                
                onTap: () {
                  //timelines
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => TimelineVehiclesCarNotesAndServiceOrder(
                        vehicleWithNotificationsModel: vehicleWithNotificationsModel,
                      )
                    ),
                  );

                },
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    
                    Stack(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: size.width * 0.2),
                          
                          child: Container(
                        
                            width: size.width * 0.205,
                            height: size.height * 0.110,
                            child: SfRadialGauge(
                              enableLoadingAnimation: true,
                              axes: <RadialAxis> [
                                RadialAxis(
                                  showLabels: false,
                                  showAxisLine: false,
                                  radiusFactor: 1.0,
                                  minimum: 0,
                                  maximum: vehicleWithNotificationsModel.days!.toDouble(),
                                  isInversed: true,
                                  ranges: <GaugeRange> [
                                    GaugeRange(startValue: vehicleWithNotificationsModel.days!.toDouble(), endValue: 30,color: Colors.green),
                                    GaugeRange(startValue: 30, endValue: 8,color: Colors.orange),
                                    GaugeRange(startValue: 8, endValue: 0, color: Colors.red),                                  
                                  ],
                                  pointers: <GaugePointer> [
                                    NeedlePointer(
                                      value: (vehicleWithNotificationsModel.daysOfTheNextService! < 0) 
                                        ? 0
                                        : vehicleWithNotificationsModel.daysOfTheNextService!.toDouble(),
                                      needleStartWidth: 0,
                                      needleEndWidth: 3,
                                      needleLength: 0.85,
                                    )
                                  ],
                                  annotations: <GaugeAnnotation> [
                                    GaugeAnnotation(
                                      widget: Container(
                                        child: AutoSizeText(
                                          (vehicleWithNotificationsModel.daysOfTheNextService! < 0) 
                                            ? 'Restan 0 días para el próximo cambio de aceite.'
                                            :'Restan ${vehicleWithNotificationsModel.daysOfTheNextService} dias para el próximo cambio de aceite.', 
                                        ),
                                        
                                      ),
                                      angle: 90,
                                      positionFactor: 2,
                                    )
                                  ],
                                  
                                )
                              ],
                            ),
                          ),
                        ),
                        
                        Center(
                          child: Image.network(
                            vehicleModel.logo!,
                            width: size.width * 0.25,
                            height: size.height * 0.096,
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (c) => EditCarScreen(
                                      vehicleModel: vehicleModel,
                                    ),
                                  ),
                                );
                              },
                            )
                          ],
                        )
                      ],
                    ),
                    
                    SizedBox(height: size.height * 0.012,),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AutoSizeText(vehicleModel.brand!),
                        /* const AutoSizeText(" "), */
                        AutoSizeText(vehicleModel.model!),
                        /* const AutoSizeText(" "), */
                        AutoSizeText(vehicleModel.year.toString()),
                        
                        
                      ],
                    ),
                    SizedBox(height: size.height * 0.012,),
                    (vehicleModel.name != "") ? AutoSizeText('${vehicleModel.name}'): Container(),
                    SizedBox(height: size.height * 0.012,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const AutoSizeText('Color:'),
                        IconButton(
                          iconSize: size.height * 0.054,
                          icon:  Icon(
                            Icons.car_repair_rounded,
                            color: Color(vehicleModel.color!),
                            ),
                          onPressed: null,
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.012,),
                    TextButton(                      
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 0, horizontal: size.width * 0.075),
                        backgroundColor: Color.fromARGB(255, 3, 3, 247),
                        shape: const StadiumBorder()
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) => OurService(vehicleModel: vehicleModel)
                          ),
                        );
                      },
                      child: Container(
                        width: size.width * 0.55,
                        height: size.height * 0.021,
                        child: Center(                        
                          child:  AutoSizeText(
                            "Solicitar un servicio",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: "Brand-Regular",
                              fontWeight: FontWeight.bold,
                              fontSize: size.height * 0.018,
                            ),
                            
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 0, horizontal: size.width * 0.075),
                        backgroundColor: Color.fromARGB(255, 3, 3, 247),
                        shape: const StadiumBorder()
                      ),
                      
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) => MyServiceOrderByVehicleScreen(vehicleModel: vehicleModel)
                          ),
                        );
                      },
                      child: Container(
                        width: size.width * 0.55,
                        height: size.height * 0.021,
                        child: Center(
                          child:  AutoSizeText(
                            "Mis ordenes de servicio",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: "Brand-Regular",
                              fontWeight: FontWeight.bold,
                              fontSize: size.height * 0.018,
                            ),
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 0, horizontal: size.width * 0.075),
                        backgroundColor: Color.fromARGB(255, 3, 3, 247),
                        shape: const StadiumBorder()
                      ),
                      onPressed: () async {
                        
                        await carNotes.showModalBottomSheetByAddCarNotes(context: context, vehicle: vehicleModel );
                        
                      },
                      child: Container(
                        width: size.width * 0.55,
                        height: size.height * 0.021,
                        child: Center(
                          child: AutoSizeText(
                            "Agregar una nota",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: "Brand-Regular",
                              fontWeight: FontWeight.bold,
                              fontSize: size.height * 0.018,
                            ),
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 0, horizontal: size.width * 0.075),
                        backgroundColor: Color.fromARGB(255, 3, 3, 247),
                        shape: const StadiumBorder()
                      ),
                      onPressed: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) => ViewCarNotes(vehicleModel: vehicleModel, goToHome: false,)
                          ),
                        );
                      },
                      child: Container(
                        width: size.width * 0.55,
                        height: size.height * 0.021,
                        child: Center(
                          child: AutoSizeText(
                            "Ver las notas de servicio",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: "Brand-Regular",
                              fontWeight: FontWeight.bold,
                              fontSize: size.height * 0.018,
                            ),
                          ),
                        ),
                      ),

                    ),
                  ],
                ),
              ),      
            );
          }
        );
        },
      ),
      /* body: FutureBuilder(
        future: gerVehicles(),
        builder: (context, snapshot) {
          
          if (!snapshot.hasData) {
            return circularProgress();
          }

          if(snapshot.data!.isEmpty) {
             return const EmptyCardMessage(
              listTitle: 'No tiene vehiculos',
              message: 'Agregue un vehiculo',
            );
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            controller: scrollController,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index)  {

              VehicleModel vehicleModel = VehicleModel.fromJson((snapshot.data as dynamic )[index]);
              return Card(
                elevation: 2,
                child: ListTile(
                  
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => EditVehicleScreen(
                          vehicleModel: vehicleModel,
                        ),
                      ),
                    );
                  },
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.network(
                        vehicleModel.logo!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.scaleDown,
                      ),
                      const SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AutoSizeText(vehicleModel.brand!),
                          AutoSizeText(" - "),
                          AutoSizeText(vehicleModel.model!)
                        ],
                      ),
                      const SizedBox(height: 10,),
                      Container(
                        color: Color(vehicleModel.color!),
                        child: const SizedBox(width: 40,height: 20,),
                      ),
                      const SizedBox(height: 10,),
                      AutoSizeText(vehicleModel.year.toString()),
                      const SizedBox(height: 10,),
                      TextButton(                      
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 15, horizontal: MediaQuery.of(context).size.width * 0.15),
                          backgroundColor: Color.fromARGB(255, 3, 3, 247),
                          shape: const StadiumBorder()
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (c) => OurService(vehicleModel: vehicleModel)
                            ),
                          );
                        },
                        child: Container(
                          width: 200,
                          child: const Center(                        
                            child:  AutoSizeText(
                              "Solicitar un servicio",
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: "Brand-Regular",
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 15, horizontal: MediaQuery.of(context).size.width * 0.15),
                          backgroundColor: Color.fromARGB(255, 3, 3, 247),
                          shape: const StadiumBorder()
                        ),
                        
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (c) => MyServiceOrderByVehicleScreen(vehicleModel: vehicleModel)
                            ),
                          );
                        },
                        child: Container(
                          width: 200,
                          child: const Center(
                            child:  AutoSizeText(
                              "Mis ordenes de servicio",
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: "Brand-Regular",
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 15, horizontal: MediaQuery.of(context).size.width * 0.15),
                          backgroundColor: Color.fromARGB(255, 3, 3, 247),
                          shape: const StadiumBorder()
                        ),
                        onPressed: () async {
                          
                          await carNotes.showModalBottomSheetByAddCarNotes(context: context, vehicle: vehicleModel );
                          
                        },
                        child: Container(
                          width: 200,
                          child: const Center(
                            child: AutoSizeText(
                              "Agregar una nota",
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: "Brand-Regular",
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 15, horizontal: MediaQuery.of(context).size.width * 0.15),
                          backgroundColor: Color.fromARGB(255, 3, 3, 247),
                          shape: const StadiumBorder()
                        ),
                        onPressed: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (c) => ViewCarNotes(vehicleModel: vehicleModel, goToHome: false,)
                            ),
                          );
                        },
                        child: Container(
                          width: 200,
                          child: const Center(
                            child: AutoSizeText(
                              "Ver las notas de servicio",
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: "Brand-Regular",
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),

                      ),
                    ],
                  ),
                ),      
              );
            }
          );
        },
      ), */ 
    );
  }

  Future<List<Map<String,dynamic>>> gerVehicles() async {

    List <Map<String,dynamic>> listVehicles = [];

    QuerySnapshot<Map<String, dynamic>> vehicles = await AutoParts.firestore!
      .collection(AutoParts.collectionUser)
      .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
      .collection(AutoParts.vehicles)
      .get();

    for(final vehicle in vehicles.docs.reversed) {

      listVehicles.add(vehicle.data());

    }

    return listVehicles;

  }

  Widget progressiveBar(double percent, VehicleWithNotificationsModel vehicleWithNotificationsModel){

    Widget text = AutoSizeText('');

    if(percent >= 100) {

      RoundedProgressBar(
        milliseconds:3000,
        childLeft: AutoSizeText(
          'Próximo cambio de aceite ${vehicleWithNotificationsModel.daysOfTheNextService} dias.',
          style: const TextStyle(
            color: Colors.white,
            fontFamily: "Brand-Regular",
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        percent: percent,
        style: RoundedProgressBarStyle(
          colorProgress:Color.fromARGB(255, 3, 3, 247),
        ),
        borderRadius: BorderRadius.circular(24)
      );

    }

    else {



    }

    /* if(daysOfTheNextService <= 0) {
      text =  AutoSizeText(
        'Ya se le paso la fecha del cambio de aceite',
        style: const TextStyle(color: Colors.red),
      );
    }

    if(daysOfTheNextService > 0 && daysOfTheNextService <= 7) {
      text =  AutoSizeText(
        'Le quedan solo ${daysOfTheNextService} dias para hacer el cambio de aceite.',
        style: const TextStyle(color: Colors.orange),
      );
    }

    if(daysOfTheNextService > 7){
      text = AutoSizeText('Su próximo cambio de aceite es en: ${daysOfTheNextService} dias');
    } */

    

    return text;

  }

}