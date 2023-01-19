import 'package:flutter/material.dart';
import 'package:oilapp/Model/vehicle_model.dart';
import 'package:oilapp/Screens/Vehicles/add_car_notes.dart';
class ModalBottomSheetAddCarNote {

  Future <void> showModalBottomSheetByAddCarNotes({
    required context, 
    required List<Map<String,dynamic>> items,
    required VehicleModel vehicle
  }) async {

    List<Map<String,dynamic>> itemsOrdered;
    Map<String, dynamic> firstItem = {};

    for(final item in items) {

      if(item["name"] == "Aceite con filtro"){
        firstItem = item;
      }

    }
    items.remove(firstItem);

    itemsOrdered = [firstItem, ...items];

    Size size = MediaQuery.of(context).size;
    await showModalBottomSheet(      
      context: context, 
      builder: (context) {
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
                  itemCount: itemsOrdered.length,
                  scrollDirection: Axis.vertical,
                  itemBuilder:  (context, index) {
                    
                    return ListTile(
                      leading: FadeInImage(
                        placeholder: const AssetImage('assets/no-image/no-image.jpg'),
                        image: NetworkImage(itemsOrdered[index]["image"]),
                        width: 20,
                        fit:BoxFit.contain
                      ),
                      title: Text(itemsOrdered[index]["name"]),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) =>  AddCarNote(noteCar: itemsOrdered[index], vehicleModel: vehicle,)
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
      }
    );

      
  }
    
}
