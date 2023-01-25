import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:oilapp/config/config.dart';

class BackEndVehiclesService {

  final StreamController <List<Map<String,dynamic>>> _suggestionStreamControler = StreamController.broadcast();
  Stream<List<Map<String,dynamic>>> get suggestionStream => _suggestionStreamControler.stream;

  getVehiclesWithNotification() async {
    List<Map<String,dynamic>> vehiclesWithNotification = [];

    QuerySnapshot<Map<String, dynamic>> querySnapshotNotificationMessage = await FirebaseFirestore.instance
      .collection('notificationMessage')
      .where('categoryNotification',isEqualTo: 'Cambio de Aceite')
      .get();

    QuerySnapshot<Map<String, dynamic>> querySnapshotUsersVehicles = await FirebaseFirestore.instance
      .collection('usersVehicles')
      .where('userId', isEqualTo: AutoParts.sharedPreferences!.getString(AutoParts.userUID))
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
      String dateFromNextFormat = DateFormat('yyyy/MM/dd hh:mm a').format(dateFromNextService);

      vehiclesWithNotification.add({
        "brand":                  (documentsUsersVehicle.data() as dynamic )['brand'],
        "color":                  (documentsUsersVehicle.data() as dynamic )['color'],
        "logo":                   (documentsUsersVehicle.data() as dynamic )['logo'],
        "mileage":                (documentsUsersVehicle.data() as dynamic )['mileage'],
        "model":                  (documentsUsersVehicle.data() as dynamic )['model'],
        "name":                   (documentsUsersVehicle.data() as dynamic )['name'],
        "phoneUser":              (documentsUsersVehicle.data() as dynamic )['phoneUser'],
        "registrationDate":       (documentsUsersVehicle.data() as dynamic )['registrationDate'],
        "tuition":                (documentsUsersVehicle.data() as dynamic )['tuition'],
        "updateDate":             (documentsUsersVehicle.data() as dynamic )['updateDate'],
        "userId":                 (documentsUsersVehicle.data() as dynamic )['userId'],
        "vehicleId":              (documentsUsersVehicle.data() as dynamic )['vehicleId'],
        "year":                   (documentsUsersVehicle.data() as dynamic )['year'],
        "categoryNotification":   (querySnapshotNotificationMessage.docs[0].data() as dynamic)["categoryNotification"],
        "days":                   (querySnapshotNotificationMessage.docs[0].data() as dynamic)["days"],
        "message":                (querySnapshotNotificationMessage.docs[0].data() as dynamic)["message"],
        "minutes":                (querySnapshotNotificationMessage.docs[0].data() as dynamic)["minutes"],
        "daysOfTheNextService":   daysOfTheNextService,
        "dateFromNextFormat":     dateFromNextFormat
      });
    }

    
    vehiclesWithNotification.sort((a, b) => (a['daysOfTheNextService']).compareTo(b['daysOfTheNextService']));

    _suggestionStreamControler.add(vehiclesWithNotification);
  }

}