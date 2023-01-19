import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:oilapp/Model/vehicle_model.dart';
import 'package:oilapp/Screens/Vehicles/create_vehicle.dart';
import 'package:oilapp/Screens/Vehicles/edit_vehicle.dart';
import 'package:oilapp/Screens/Vehicles/view_cars_notes.dart';
import 'package:oilapp/Screens/home_screen.dart';
import 'package:oilapp/Screens/orders/myservice_order_by_vehicle_screen.dart';
import 'package:oilapp/Screens/orders/myservice_order_screen.dart';
import 'package:oilapp/Screens/ourservice/our_service_screen.dart';
import 'package:oilapp/config/config.dart';

import 'package:oilapp/widgets/loading_widget.dart';
import 'package:oilapp/widgets/modal_bottom_sheet_add_car_note.dart';
import 'package:oilapp/widgets/simpleAppbar.dart';

class Vehicles extends StatefulWidget {
  const Vehicles({super.key});

  @override
  State<Vehicles> createState() => _VehiclesState();
}

class _VehiclesState extends State<Vehicles> {

  final ScrollController scrollController = ScrollController();
  QuerySnapshot<Map<String, dynamic>>? _docSnapStream;
  int lengthCollection = 0;
  bool isLoading =  false;
  List listDocument = [];
  QuerySnapshot? collectionState;

  ModalBottomSheetAddCarNote carNotes =  ModalBottomSheetAddCarNote();
  @override
  void initState() {
    super.initState();
    getDocuments();
    

    scrollController.addListener(() {
      if(scrollController.position.pixels + 500 > scrollController.position.maxScrollExtent){
        getDocumentsNext();
      }
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(  
      appBar: AppBar(
        
        title: const Text(
          "Mi Garage",
          style: TextStyle(
            fontSize: 20,
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
                  MaterialPageRoute(builder: (_) => CreateVehicleScreen()));
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
      body: 
      
      (listDocument.isNotEmpty)
        ? ListView.builder(
          physics: const BouncingScrollPhysics(),
          controller: scrollController,
          itemCount: listDocument.length,
          itemBuilder: (context, index)  {

            VehicleModel vehicleModel = VehicleModel.fromJson(listDocument[index]);
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
                        Text(vehicleModel.brand!),
                        Text(" - "),
                        Text(vehicleModel.model!)
                      ],
                    ),
                    const SizedBox(height: 10,),
                    Container(
                      color: Color(vehicleModel.color!),
                      child: const SizedBox(width: 40,height: 20,),
                    ),
                    const SizedBox(height: 10,),
                    Text(vehicleModel.year.toString()),
                    const SizedBox(height: 10,),
                    TextButton(                      
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.all(10),
                        backgroundColor: Colors.blue,
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
                          child:  Text(
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
                        padding: const EdgeInsets.all(10),
                        backgroundColor: Colors.blue,
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
                          child:  Text(
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
                        padding: const EdgeInsets.all(10),
                        backgroundColor: Colors.blue,
                      ),
                      onPressed: () async {
                        List <Map<String, dynamic>> list = [];

                        QuerySnapshot<Map<String, dynamic>> servicesNotes =  await FirebaseFirestore.instance.collection("servicesNotes").get();
                        for(final serviceNote in servicesNotes.docs){
                          list.add(serviceNote.data());
                          
                        }

                        await carNotes.showModalBottomSheetByAddCarNotes(context: context, items: list, vehicle: vehicleModel );
                        
                      },
                      child: Container(
                        width: 200,
                        child: const Center(
                          child: Text(
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
                        padding: const EdgeInsets.all(10),
                        backgroundColor: Colors.blue,
                      ),
                      onPressed: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) => ViewCarNotes(vehicleModel: vehicleModel, goToHome: false,)
                          ),
                        );
                      },
                      child:  Container(
                        width: 200,
                        child: const Center(
                          child: Text(
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
        )
        :(listDocument.isNotEmpty)
        ? Center(
          child: circularProgress(),
        )
        : Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height - AppBar().preferredSize.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Route route = MaterialPageRoute(builder: (_) => CreateVehicleScreen());
                  Navigator.push(context, route);
                },
                child: Container(
                  color: Colors.blueGrey.shade300,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: const Center(
                    child: Text(
                      'No hay vehiculos, toque aqui para agregar uno', 
                      style:TextStyle(color: Colors.white, fontSize: 18, fontFamily: "Brand-Bold",),),
                  ),
                ),
              )
            ],
          )
        ) 
    );
  }

  
  Future<void> getDocuments() async {

    int limit = 1;

    _docSnapStream = await AutoParts.firestore!
      .collection(AutoParts.collectionUser)
      .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
      .collection(AutoParts.vehicles).get();


    lengthCollection = _docSnapStream!.docs.length;

    if(lengthCollection == 0) {
      return;
    }
    if(lengthCollection <= 3) {
      limit = lengthCollection;
    }
    
    else if(lengthCollection > 3){
      limit = 4;
    }


    
    final collection =  AutoParts.firestore!
      .collection(AutoParts.collectionUser)
      .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
      .collection(AutoParts.vehicles)
      .orderBy("registrationDate", descending: true)
      .limit(limit);

      fetchDocuments(collection);
  }
  fetchDocuments(Query collection){
    collection.get().then((values) {
      collectionState = values; 
      for(final value in values.docs){
        
        listDocument.add(value.data());
      }
      
      setState((){});
      
    
    });
  }
  Future<void> getDocumentsNext() async {
  
    if (isLoading) return;
    isLoading = true;
    await Future.delayed(const Duration(seconds: 1));

    int limit = 1;
    
    if(lengthCollection == listDocument.length){
      return;
    }
    if((lengthCollection - listDocument.length ) % 3 == 0){
      limit = 3;
    }
    else if((lengthCollection - listDocument.length ) % 3 != 0 && (lengthCollection - listDocument.length ) <= 3){
      limit = lengthCollection - listDocument.length;
    }

    // Get the last visible document
    final lastVisible = collectionState!.docs[collectionState!.docs.length-1];
    final collection = AutoParts.firestore!
      .collection(AutoParts.collectionUser)
      .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
      .collection(AutoParts.vehicles)
      .orderBy("registrationDate", descending: true)
      .startAfterDocument(lastVisible)
      .limit(limit);

    fetchDocuments(collection);
    

    isLoading = false;
    if(scrollController.position.pixels + 100 <= scrollController.position.maxScrollExtent) return;
    scrollController.animateTo(
      scrollController.position.pixels + 120, 
      duration: const Duration(milliseconds: 300), 
      curve: Curves.fastOutSlowIn
    );

  }

}