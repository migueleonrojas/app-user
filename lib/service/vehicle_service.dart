
import 'package:fluttertoast/fluttertoast.dart';
import 'package:oilapp/Model/vehicle_model.dart';
import 'package:oilapp/config/config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class VehicleService {
  String vehicleId = DateTime.now().microsecondsSinceEpoch.toString();
  addVehicle(
    String brandVehicle, 
    String modelVehicle, 
    int mileageVehicle, 
    int yearVehicle, 
    int colorVehicle, 
    String? tuitionVehicle,
    String? nameVehicle,
    String? logoVehicle,
    DateTime? updateDate
  ){
    final model = VehicleModel(
      vehicleId: vehicleId,
      userId: AutoParts.sharedPreferences!.getString(AutoParts.userUID),
      brand: brandVehicle, 
      model: modelVehicle,
      mileage: mileageVehicle,
      year: yearVehicle,
      color: colorVehicle,
      name: nameVehicle ?? "",
      tuition: tuitionVehicle ?? "",
      logo: logoVehicle,
      registrationDate: DateTime.now(),
      updateDate: updateDate,
      phoneUser: int.parse(AutoParts.sharedPreferences!.getString(AutoParts.userPhone)!)
    ).toJson();

    FirebaseFirestore.instance
      .collection(AutoParts.collectionUser)
      .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
      .collection(AutoParts.vehicles)
      .doc(vehicleId)
      .set(model)
      .whenComplete(() { 
        addVehicleForAdmin(brandVehicle, modelVehicle, mileageVehicle, yearVehicle, colorVehicle, tuitionVehicle, nameVehicle, logoVehicle, updateDate);
      })
      .then((value) => {

      });
  }

  addVehicleForAdmin(
    String brandVehicle, 
    String modelVehicle, 
    int mileageVehicle, 
    int yearVehicle, 
    int colorVehicle, 
    String? tuitionVehicle,
    String? nameVehicle,
    String? logoVehicle,
    DateTime? updateDate
  ){
    final model = VehicleModel(
      vehicleId: vehicleId,
      userId: AutoParts.sharedPreferences!.getString(AutoParts.userUID),
      brand: brandVehicle, 
      model: modelVehicle,
      mileage: mileageVehicle,
      year: yearVehicle,
      color: colorVehicle,
      name: nameVehicle ?? "",
      tuition: tuitionVehicle ?? "",
      logo: logoVehicle,
      registrationDate: DateTime.now(),
      updateDate: updateDate,
      phoneUser: int.parse(AutoParts.sharedPreferences!.getString(AutoParts.userPhone)!)
    ).toJson();

    FirebaseFirestore.instance.collection('usersVehicles')
      .doc(vehicleId)
      .set(model);
  }

  updateFromCarNotes(
    String vehicleIdFromDB,
    String brandVehicle, 
    String modelVehicle, 
    int mileageVehicle, 
    int yearVehicle, 
    int colorVehicle, 
    String? tuitionVehicle,
    String? nameVehicle,
    String? logoVehicle,
    DateTime registrationDate,
    DateTime updateDate
  ) async {
    final model = VehicleModel(
      vehicleId: vehicleIdFromDB,
      userId: AutoParts.sharedPreferences!.getString(AutoParts.userUID),
      brand: brandVehicle, 
      model: modelVehicle,
      mileage: mileageVehicle,
      year: yearVehicle,
      color: colorVehicle,
      name: nameVehicle ?? "",
      tuition: tuitionVehicle ?? "",
      logo: logoVehicle,
      registrationDate: registrationDate,
      updateDate: updateDate,
      phoneUser: int.parse(AutoParts.sharedPreferences!.getString(AutoParts.userPhone)!)
    ).toJson();

    await FirebaseFirestore.instance
      .collection(AutoParts.collectionUser)
      .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
      .collection(AutoParts.vehicles)
      .doc(vehicleIdFromDB)
      .update(model)
      .whenComplete(() async { 
        await updateVehicleForAdmin(vehicleIdFromDB, brandVehicle, modelVehicle, mileageVehicle, yearVehicle, colorVehicle, tuitionVehicle, nameVehicle, logoVehicle, registrationDate, updateDate);
      })
      .then((value) => {

      });


  }

  Future <bool> updateVehicle(
    String vehicleIdFromDB,
    String brandVehicle, 
    String modelVehicle, 
    int mileageVehicle, 
    int yearVehicle, 
    int colorVehicle, 
    String? tuitionVehicle,
    String? nameVehicle,
    String? logoVehicle,
    DateTime registrationDate,
    DateTime updateDate
  ) async {

    QuerySnapshot<Map<String, dynamic>> serviceOrder = await FirebaseFirestore.instance
      /* .collection(AutoParts.collectionUser)
      .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
      .collection(AutoParts.vehicles)
      .doc(vehicleIdFromDB) */
      .collection("serviceOrder")
      .where('orderBy', isEqualTo: AutoParts.sharedPreferences!.getString(AutoParts.userUID))
      .where('vehicleId', isEqualTo: vehicleIdFromDB)
      .where('orderCancelled', isEqualTo: 'UnDone')
      .get();
    if(serviceOrder.size > 0) {
      Fluttertoast.showToast(
        msg: 'No se puede actualizar vehiculos que posean ordenes de servicio',
        toastLength: Toast.LENGTH_LONG
      );
      return false;
    }

    final model = VehicleModel(
      vehicleId: vehicleIdFromDB,
      userId: AutoParts.sharedPreferences!.getString(AutoParts.userUID),
      brand: brandVehicle, 
      model: modelVehicle,
      mileage: mileageVehicle,
      year: yearVehicle,
      color: colorVehicle,
      name: nameVehicle ?? "",
      tuition: tuitionVehicle ?? "",
      logo: logoVehicle,
      registrationDate: registrationDate,
      updateDate: updateDate,
      phoneUser: int.parse(AutoParts.sharedPreferences!.getString(AutoParts.userPhone)!)
    ).toJson();

    
      await FirebaseFirestore.instance
      .collection(AutoParts.collectionUser)
      .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
      .collection(AutoParts.vehicles)
      .doc(vehicleIdFromDB)
      .update(model)
      .whenComplete(() async { 
        await updateVehicleForAdmin(vehicleIdFromDB, brandVehicle, modelVehicle, mileageVehicle, yearVehicle, colorVehicle, tuitionVehicle, nameVehicle, logoVehicle, registrationDate, updateDate);
      })
      .then((value) => {

      });

      return true;
  }
  updateVehicleForAdmin(
    String vehicleIdFromDB,
    String brandVehicle, 
    String modelVehicle, 
    int mileageVehicle, 
    int yearVehicle, 
    int colorVehicle, 
    String? tuitionVehicle,
    String? nameVehicle,
    String? logoVehicle,
    DateTime registrationDate,
    DateTime updateDate,
  ){
    final model = VehicleModel(
      vehicleId: vehicleIdFromDB,
      userId: AutoParts.sharedPreferences!.getString(AutoParts.userUID),
      brand: brandVehicle, 
      model: modelVehicle,
      mileage: mileageVehicle,
      year: yearVehicle,
      color: colorVehicle,
      name: nameVehicle ?? "",
      tuition: tuitionVehicle ?? "",
      logo: logoVehicle,
      registrationDate: registrationDate,
      updateDate: updateDate,
      phoneUser: int.parse(AutoParts.sharedPreferences!.getString(AutoParts.userPhone)!)
    ).toJson();

    FirebaseFirestore.instance.collection('usersVehicles')
      .doc(vehicleIdFromDB)
      .update(model);

  }

  Future <bool> deleteVehicle(String vehicleIdFromDB) async {

    QuerySnapshot<Map<String, dynamic>> serviceOrder = await FirebaseFirestore.instance
      /* .collection(AutoParts.collectionUser)
      .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
      .collection(AutoParts.vehicles)
      .doc(vehicleIdFromDB) */
      .collection("serviceOrder")
      .where('orderBy', isEqualTo: AutoParts.sharedPreferences!.getString(AutoParts.userUID))
      .where('vehicleId', isEqualTo: vehicleIdFromDB)
      .where('orderCancelled', isEqualTo: 'UnDone')
      .get();
    if(serviceOrder.size > 0) {
      Fluttertoast.showToast(
        msg: 'No se puede eliminar vehiculos que posean ordenes de servicio',
        toastLength: Toast.LENGTH_LONG
      );
      return false;
    }

    

    FirebaseFirestore.instance
      .collection(AutoParts.collectionUser)
      .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
      .collection(AutoParts.vehicles)
      .doc(vehicleIdFromDB)
      .delete()
      .whenComplete(() { 
        deleteVehicleForAdmin(vehicleIdFromDB);
      })
      .then((value) => {

      });
      return true;
    /* FirebaseFirestore.instance.collection(AutoParts.vehicles).doc(vehicleId).delete(); */

  }

  deleteVehicleForAdmin(String vehicleIdFromDB){
    FirebaseFirestore.instance.collection('usersVehicles')
      .doc(vehicleIdFromDB)
      .delete();

  }

  /* deleteVehicle(String vehicleId){

    FirebaseFirestore.instance.collection(AutoParts.vehicles).doc(vehicleId).delete();

  } */



  /* updateVehicle(
    String vehicleId,
    String brandVehicle, 
    String modelVehicle, 
    int mileageVehicle, 
    int yearVehicle, 
    int colorVehicle, 
    String? tuitionVehicle,
    String? nameVehicle,
    String? logoVehicle,
    DateTime registrationDate
  ){


    final model = VehicleModel(
      vehicleId: vehicleId,
      userId: AutoParts.sharedPreferences!.getString(AutoParts.userUID),
      brand: brandVehicle, 
      model: modelVehicle,
      mileage: mileageVehicle,
      year: yearVehicle,
      color: colorVehicle,
      name: nameVehicle ?? "",
      tuition: tuitionVehicle ?? "",
      logo: logoVehicle,
      registrationDate: registrationDate
    ).toJson();

    FirebaseFirestore.instance.collection(AutoParts.vehicles)
      .doc(vehicleId)
      .update(model);
  } */


  /* addVehicle(
    String brandVehicle, 
    String modelVehicle, 
    int mileageVehicle, 
    int yearVehicle, 
    int colorVehicle, 
    String? tuitionVehicle,
    String? nameVehicle,
    String? logoVehicle,
  ){

    final vehicleId = DateTime.now().microsecondsSinceEpoch.toString();

    final model = VehicleModel(
      vehicleId: vehicleId,
      userId: AutoParts.sharedPreferences!.getString(AutoParts.userUID),
      brand: brandVehicle, 
      model: modelVehicle,
      mileage: mileageVehicle,
      year: yearVehicle,
      color: colorVehicle,
      name: nameVehicle ?? "",
      tuition: tuitionVehicle ?? "",
      logo: logoVehicle,
      registrationDate: DateTime.now()
    ).toJson();

    FirebaseFirestore.instance.collection(AutoParts.vehicles)
      .doc(vehicleId)
      .set(model);
  } */

}