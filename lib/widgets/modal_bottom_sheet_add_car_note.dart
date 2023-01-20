import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:oilapp/Model/vehicle_model.dart';
import 'package:oilapp/Screens/Vehicles/add_car_notes.dart';
import 'package:oilapp/config/config.dart';
import 'package:oilapp/widgets/emptycardmessage.dart';
import 'package:oilapp/widgets/loading_widget.dart';
class ModalBottomSheetAddCarNote {

  Future <void> showModalBottomSheetByAddCarNotes({
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
              height: 500,
              child: Column(
                children: [
                  Column(
                    children: [
                      Divider(
                        color: Colors.black45,
                        height: 15,
                        thickness: 3,
                        indent: size.width * 0.45,
                        endIndent: size.width * 0.45,
                      ),
                      const SizedBox(height: 5,),
                      const Text(
                        'Seleccionar un servicio',                    
                        style: TextStyle(
                          fontSize: 20
                        ),
                      ),
                      const SizedBox(height: 20,),
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
                            width: 20,
                            fit:BoxFit.contain
                          ),
                          title: Text((snapshot.data as dynamic)[index]["name"]),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (c) =>  AddCarNote(noteCar: (snapshot.data as dynamic)[index], vehicleModel: vehicle,)
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
