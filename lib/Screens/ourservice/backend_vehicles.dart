import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:oil_app/Model/vehicle_model.dart';
import 'package:oil_app/config/config.dart';

class BackEndVehiclesService {

  final StreamController <List<Map<String,dynamic>>> _suggestionStreamUsersVehiclesControler = StreamController.broadcast();
  Stream<List<Map<String,dynamic>>> get suggestionUsersVehiclesStream => _suggestionStreamUsersVehiclesControler.stream;

  final StreamController <List<Map<String,dynamic>>> _suggestionStreamVehicleUserControler = StreamController.broadcast();
  Stream<List<Map<String,dynamic>>> get suggestionVehicleUserStream => _suggestionStreamVehicleUserControler.stream;

  final StreamController <List<Map<String,dynamic>>> _suggestionStreamCarNotesAndOrderServiceByVehicle = StreamController.broadcast();
  Stream<List<Map<String,dynamic>>> get suggestionCarNotesAndOrderServiceByVehicle => _suggestionStreamCarNotesAndOrderServiceByVehicle.stream;

  final StreamController <List<Map<String,dynamic>>> _suggestionStreamServiceCartVehicles = StreamController.broadcast();
  Stream<List<Map<String,dynamic>>> get suggestionServiceCartVehicles => _suggestionStreamServiceCartVehicles.stream;

  getVehiclesWithNotification(String typeOfVehicle) async {
    List<Map<String,dynamic>> vehiclesWithNotifications = [];

    QuerySnapshot<Map<String, dynamic>> querySnapshotNotificationMessage = await FirebaseFirestore.instance
      .collection('notificationMessage')
      .where('categoryNotification',isEqualTo: 'Cambio de Aceite')
      .get();

    QuerySnapshot<Map<String, dynamic>> querySnapshotUsersVehicles = await FirebaseFirestore.instance
      .collection('usersVehicles')
      .where('userId', isEqualTo: AutoParts.sharedPreferences!.getString(AutoParts.userUID))
      .where('typeOfVehicle', isEqualTo: typeOfVehicle)
      .orderBy("updateDate", descending: true)
      .get();

    List<QueryDocumentSnapshot<Map<String,dynamic>>> documentsUsersVehicles = querySnapshotUsersVehicles.docs;
    int daysActual = (DateTime.now().microsecondsSinceEpoch / 1000000 / 60 / 60 / 24).round();

    for(final documentsUsersVehicle in documentsUsersVehicles){
      int daysUserVehicle = ((documentsUsersVehicle.data() as dynamic )['updateDate']!.microsecondsSinceEpoch / 1000000 / 60 / 60 / 24).round();
      int daysPassed = (daysActual - daysUserVehicle);
      int daysOfTheNextService = (querySnapshotNotificationMessage.docs[0].data() as dynamic)["days"] - daysPassed;
      int microsecondsNextService = (documentsUsersVehicle.data() as dynamic )['updateDate']!.microsecondsSinceEpoch.round() + (1000000 * 60 * 60 * 24 * (querySnapshotNotificationMessage.docs[0].data() as dynamic)["days"]).round();
      DateTime dateFromNextService = DateTime.fromMicrosecondsSinceEpoch(microsecondsNextService);
      String dateFromNextFormat = DateFormat('dd/MM/yyyy').format(dateFromNextService);

      vehiclesWithNotifications.add({
        ...documentsUsersVehicle.data(),
        ...querySnapshotNotificationMessage.docs[0].data(),
        "daysOfTheNextService":   daysOfTheNextService,
        "dateFromNextFormat":     dateFromNextFormat


      });
      
    }

    
    vehiclesWithNotifications.sort((a, b) => (a['daysOfTheNextService']).compareTo(b['daysOfTheNextService']));

    _suggestionStreamUsersVehiclesControler.add(vehiclesWithNotifications);
  }


  getUserVehiclesWithNotification(String typeOfVehicle) async{

    List<Map<String,dynamic>> vehiclesUserWithNotifications = [];

    QuerySnapshot<Map<String, dynamic>> querySnapshotNotificationMessage = await FirebaseFirestore.instance
      .collection('notificationMessage')
      .where('categoryNotification',isEqualTo: 'Cambio de Aceite')
      .get();

    QuerySnapshot<Map<String, dynamic>> querySnapshotUsersVehicles =  await AutoParts.firestore!
      .collection(AutoParts.collectionUser)
      .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
      .collection(AutoParts.vehicles)
      .where('typeOfVehicle',isEqualTo: typeOfVehicle)
      .get();

    List<QueryDocumentSnapshot<Map<String,dynamic>>> documentsUsersVehicles = querySnapshotUsersVehicles.docs;
    int daysActual = (DateTime.now().microsecondsSinceEpoch / 1000000 / 60 / 60 / 24).round();

    for(final documentsUsersVehicle in documentsUsersVehicles){
      int daysUserVehicle = ((documentsUsersVehicle.data() as dynamic )['updateDate']!.microsecondsSinceEpoch / 1000000 / 60 / 60 / 24).round();
      int daysPassed = (daysActual - daysUserVehicle);
      int daysOfTheNextService = (querySnapshotNotificationMessage.docs[0].data() as dynamic)["days"] - daysPassed;
      int microsecondsNextService = (documentsUsersVehicle.data() as dynamic )['updateDate']!.microsecondsSinceEpoch.round() + (1000000 * 60 * 60 * 24 * (querySnapshotNotificationMessage.docs[0].data() as dynamic)["days"]).round();
      DateTime dateFromNextService = DateTime.fromMicrosecondsSinceEpoch(microsecondsNextService);
      String dateFromNextFormat = DateFormat('yyyy/MM/dd hh:mm a').format(dateFromNextService);
      vehiclesUserWithNotifications.add({
        ...documentsUsersVehicle.data(),
        ...querySnapshotNotificationMessage.docs[0].data(),
        "daysOfTheNextService":   daysOfTheNextService,
        "dateFromNextFormat":     dateFromNextFormat
      });
      
    }

    vehiclesUserWithNotifications.sort((a, b) => (a['daysOfTheNextService']).compareTo(b['daysOfTheNextService']));

    _suggestionStreamVehicleUserControler.add(vehiclesUserWithNotifications);

  }

  getCarNotesAndOrderServiceByVehicle(String vehicleId) async {

    List<Map<String,dynamic>> carNotesAndOrderServiceByVehicles = [];

    QuerySnapshot<Map<String, dynamic>> querySnapshotServiceOrderByVehicle = await FirebaseFirestore.instance
      .collection("serviceOrder")
      .where("orderBy", isEqualTo: AutoParts.sharedPreferences!.getString(AutoParts.userUID))
      .where("vehicleId", isEqualTo: vehicleId)
      .get();
      
      
    QuerySnapshot<Map<String, dynamic>> querySnapshotcarNotesByVehicle = await FirebaseFirestore.instance
      .collection("carNotesUserVehicles")
      .where('userId', isEqualTo: AutoParts.sharedPreferences!.getString(AutoParts.userUID))
      .where('vehicleId', isEqualTo: vehicleId)
      .get();
      

    
    List<Map<String, dynamic>> spreadQuerySnapshotServiceOrderByVehicles  = querySnapshotServiceOrderByVehicle.docs.map((doc) => doc.data() ).toList();
    List<Map<String, dynamic>> spreadQuerySnapshotcarNotesByVehicles  = querySnapshotcarNotesByVehicle.docs.map((doc) => doc.data() ).toList();
    List<Map<String, dynamic>> spreadQuerySnapshotcarNotesByVehiclesAndServiceOrderByVehicles = [
      ...spreadQuerySnapshotServiceOrderByVehicles,
      ...spreadQuerySnapshotcarNotesByVehicles
    ];
    
    for(final sprdQrySnpshtcarNotByVehiAndServcOrdByVehi in spreadQuerySnapshotcarNotesByVehiclesAndServiceOrderByVehicles){

      
      carNotesAndOrderServiceByVehicles.add({
        ...sprdQrySnpshtcarNotByVehiAndServcOrdByVehi,
        "dateOrdered": sprdQrySnpshtcarNotByVehiAndServcOrdByVehi["deliverdTime"] ?? sprdQrySnpshtcarNotByVehiAndServcOrdByVehi["date"]
      });

      

    }
  
    carNotesAndOrderServiceByVehicles.sort((a, b) => (b['dateOrdered']).compareTo(a['dateOrdered']));
    _suggestionStreamCarNotesAndOrderServiceByVehicle.add(carNotesAndOrderServiceByVehicles);

  }

  getServiceCartVehicles(List<VehicleModel> vehiclesModelsList) async {
    List<Map<String,dynamic>> serviceCartVehicles = [];

    for(final vehiclesModel in vehiclesModelsList) {

      QuerySnapshot<Map<String, dynamic>> queryServiceCart = await FirebaseFirestore.instance
        .collection(AutoParts.collectionUser)
        .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
        .collection(AutoParts.vehicles)
        .doc(vehiclesModel.vehicleId)
        .collection('ServiceCart')
        .get();

      serviceCartVehicles.add(queryServiceCart.docs[0].data());
      
      
    }

    _suggestionStreamServiceCartVehicles.add(serviceCartVehicles);

  }

  
}