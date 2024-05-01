import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:oil_app/Model/vehicle_model.dart';
import 'package:oil_app/Screens/Vehicles/add_car_notes.dart';
import 'package:oil_app/Screens/Vehicles/add_motorcycle_notes.dart';
import 'package:oil_app/config/config.dart';
import 'package:oil_app/widgets/emptycardmessage.dart';
import 'package:oil_app/widgets/loading_widget.dart';
class ModalBottomSheetAddMotorcycleNote {

  Future <void> showModalBottomSheetByAddMotorcyclesNotes({
    required context, 
    required VehicleModel vehicle
  }) async {

    Size size = MediaQuery.of(context).size;
    await showModalBottomSheet(      
      context: context, 
      builder: (context) {
        return FutureBuilder(
          future: getServiceNotes(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return circularProgress();
            }

            if(snapshot.data!.isEmpty) {
              return const EmptyCardMessage(
                listTitle: 'No hay notas de servicio',
                message: 'No hay notas disponibles',
              );
            }

            return Container(
              height: size.height * 0.515,
              child: Column(
                children: [
                  Column(
                    children: [
                      Divider(
                        color: Colors.black45,
                        height: size.height * 0.021,
                        thickness: 3,
                        indent: size.width * 0.45,
                        endIndent: size.width * 0.45,
                      ),
                      SizedBox(height: size.height * 0.007,),
                      AutoSizeText(
                        'Seleccionar un servicio',                    
                        style: TextStyle(
                          fontSize: size.height * 0.027
                        ),
                      ),
                      SizedBox(height: size.height * 0.027,),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: snapshot.data!.length,
                      scrollDirection: Axis.vertical,
                      itemBuilder:  (context, index) {
                        
                        return ListTile(
                          leading: FadeInImage(
                            placeholder: const AssetImage('assets/no-image/no-image.jpg'),
                            image: NetworkImage((snapshot.data as dynamic)[index]["image"]),
                            width: size.width * 0.07,
                            fit:BoxFit.contain
                          ),
                          title: AutoSizeText((snapshot.data as dynamic)[index]["name"]),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (c) =>  AddMotorCycleNote(noteCar: (snapshot.data as dynamic)[index], vehicleModel: vehicle,)
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );

          },
        );
      }
    );

      
  }

  Future<List<Map<String,dynamic>>> getServiceNotes() async {
    List<Map<String,dynamic>> itemsOrdered;
    Map<String, dynamic> firstItem = {};
    List <Map<String,dynamic>> listServiceNotes = [];

    QuerySnapshot<Map<String, dynamic>> serviceNotes = await AutoParts.firestore!
      .collection("servicesNotes").get();

    for(final serviceNote in serviceNotes.docs) {

      listServiceNotes.add(serviceNote.data());

    }

    for(final listServiceNote in listServiceNotes) {

      if(listServiceNote["name"] == "Aceite con filtro"){
        firstItem = listServiceNote;
      }

    }

    listServiceNotes.remove(firstItem);
    itemsOrdered = [firstItem, ...listServiceNotes];

    return itemsOrdered;

  }
    
}
