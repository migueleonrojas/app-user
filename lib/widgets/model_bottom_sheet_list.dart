import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:oilapp/Model/vehicle_model.dart';
import 'package:oilapp/Screens/Vehicles/add_car_notes.dart';
import 'package:oilapp/config/config.dart';


class ModalBottomSheetListVehicle{

  final List<VehicleModel> listVehicles = [];

  showModalBottomSheetListVehicle({required context}) async{
    Size size = MediaQuery.of(context).size;
    QuerySnapshot<Map<String, dynamic>> querySnapshotsVehicles = await FirebaseFirestore.instance
    .collection("usersVehicles")
    .where("userId", isEqualTo: AutoParts.sharedPreferences!.getString(AutoParts.userUID)).get();

    for(final querySnapshotsVehicle in querySnapshotsVehicles.docs){
      listVehicles.add(VehicleModel.fromJson(querySnapshotsVehicle.data()));
    }

    return await showModalBottomSheet(
      context: context,
      builder: (context) {
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
        );
      }
    ) ?? false;

  }
}