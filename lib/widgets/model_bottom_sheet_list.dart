import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:oilapp/Model/vehicle_model.dart';
import 'package:oilapp/Screens/Vehicles/add_car_notes.dart';
import 'package:oilapp/config/config.dart';
import 'package:oilapp/widgets/emptycardmessage.dart';
import 'package:oilapp/widgets/loading_widget.dart';


class ModalBottomSheetListVehicle{

  

  showModalBottomSheetListVehicle({required context}) async{
    Size size = MediaQuery.of(context).size;
    

    return await showModalBottomSheet(
      context: context,
      builder: (context) {

        return FutureBuilder(
          future: getVehicles(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return circularProgress();
            }

            if(snapshot.data!.isEmpty) {
              return const EmptyCardMessage(
                listTitle: 'No hay vehiculos',
                message: 'No hay vehiculos agregue uno',
              );
            }

            return Container(
          
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
                        'Selecciona un vehiculo',                    
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
                            image: NetworkImage((snapshot.data as dynamic)[index].logo!),
                            width: 20,
                            fit:BoxFit.contain
                          ),
                          title: Text('Marca: ${(snapshot.data as dynamic)[index].brand}, Modelo: ${(snapshot.data as dynamic)[index].model!}'),
                          onTap: () {
                            Navigator.of(context).pop((snapshot.data as dynamic)[index]);
                          },
                        );
                      },
                    ),
                  ),
                ],
              )
            );

          },
        );
        /* return Container(
          
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
                    'Selecciona un vehiculo',                    
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
                  itemCount: listVehicles.length,
                  scrollDirection: Axis.vertical,
                  itemBuilder:  (context, index) {
                    
                    return ListTile(
                      leading: FadeInImage(
                        placeholder: const AssetImage('assets/no-image/no-image.jpg'),
                        image: NetworkImage(listVehicles[index].logo!),
                        width: 20,
                        fit:BoxFit.contain
                      ),
                      title: Text('Marca: ${listVehicles[index].brand}, Modelo: ${listVehicles[index].model!}'),
                      onTap: () {
                        Navigator.of(context).pop(listVehicles[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          )
        ); */
      }
    ) ?? false;

  }

  Future<List<VehicleModel>> getVehicles() async {

    final List<VehicleModel> listVehicles = [];

    QuerySnapshot<Map<String, dynamic>> querySnapshotsVehicles = await FirebaseFirestore.instance
      .collection("usersVehicles")
      .where("userId", isEqualTo: AutoParts.sharedPreferences!.getString(AutoParts.userUID))
      .get();

    for(final querySnapshotsVehicle in querySnapshotsVehicles.docs){
      listVehicles.add(VehicleModel.fromJson(querySnapshotsVehicle.data()));
    }

    return listVehicles;

  }
}