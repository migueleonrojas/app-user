import 'dart:async';


import 'package:oil_app/Model/service_order_model.dart';
import 'package:oil_app/Model/service_order_with_vehicle.dart';
import 'package:oil_app/Model/vehicle_model.dart';
import 'package:oil_app/config/config.dart';
import 'package:oil_app/counter/service_item_counter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class BackEndOrderService {

  final StreamController <List<SeviceOrderWithVehicleModel>> _suggestionStreamControler = StreamController.broadcast();
  Stream<List<SeviceOrderWithVehicleModel>> get suggestionStream => _suggestionStreamControler.stream;
  QuerySnapshot? collectionState;
  List<SeviceOrderWithVehicleModel> seviceOrderWithVehicleModel = [];
  bool dataFinish = false;

  Future <bool> getServiceOrderWithVehicle({int limit = 5, bool nextDocument = false}) async {

    
    QuerySnapshot<Map<String, dynamic>>? querySnapshotServiceOrder;
    if(!nextDocument){
      final collection = FirebaseFirestore.instance
        .collection('serviceOrder')
        .where('orderBy', isEqualTo: AutoParts.sharedPreferences!.getString(AutoParts.userUID))
        .limit(limit)
        .orderBy("orderTime", descending: true);
      
      collection.get().then((values)  {
        collectionState = values; 
      });

      querySnapshotServiceOrder = await collection.get();

      
    }
    else {
      final lastVisible = collectionState!.docs[collectionState!.docs.length-1];
      

      final collection = FirebaseFirestore.instance
        .collection('serviceOrder')
        .where('orderBy', isEqualTo: AutoParts.sharedPreferences!.getString(AutoParts.userUID))
        .limit(limit)
        .orderBy("orderTime", descending: true)
        .startAfterDocument(lastVisible);

      final collectionGet = await collection.get();

      
      if(collectionGet.size == 0) {
        dataFinish = true;
        return dataFinish;
      }
      
      collection.get().then((values)  {
        collectionState = values; 
      });

      

      querySnapshotServiceOrder = await collection.get();  

      

    }
    
    
    List<QueryDocumentSnapshot<Map<String,dynamic>>> documentsServiceOrders = querySnapshotServiceOrder.docs;
    
    for(final documentsServiceOrder in documentsServiceOrders) {
     
      QuerySnapshot<Map<String, dynamic>> querySnapshotVehicle = await FirebaseFirestore.instance.collection('usersVehicles').where('vehicleId', isEqualTo: (documentsServiceOrder.data() as dynamic)['vehicleId']).get();
      List<QueryDocumentSnapshot<Map<String,dynamic>>> documentsVehicles = querySnapshotVehicle.docs;
      for(final documentsVehicle in  documentsVehicles) {

        
        seviceOrderWithVehicleModel.add(SeviceOrderWithVehicleModel.fromJson({
          "vehicleModel": documentsVehicle.data(),
          "serviceOrderModel":documentsServiceOrder.data()
        }));

      }
    }
  
    _suggestionStreamControler.add(seviceOrderWithVehicleModel);
    return dataFinish;

  }


  checkServiceInCart(
      String serviceId,
      int newPrice,
      int orginalPrice,
      String serviceImage,
      String serviceName,
      String date,
      int quantity,
      BuildContext context) {
    AutoParts.sharedPreferences!
            .getStringList(AutoParts.userServiceList)!
            .contains(serviceId)
        ? Fluttertoast.showToast(msg: "Item is already in Cart.")
        : addServiceToCart(serviceId, newPrice, orginalPrice, serviceImage,
            serviceName, date, quantity, context);
  }

  addServiceToCart(
      String serviceId,
      int newPrice,
      int orginalPrice,
      String serviceImage,
      String serviceName,
      String date,
      int quantity,
      BuildContext context) async {
    List tempServiceList =
        AutoParts.sharedPreferences!.getStringList(AutoParts.userServiceList)!;
    tempServiceList.add(serviceId);

    AutoParts.firestore!
        .collection(AutoParts.collectionUser)
        .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
        .update({AutoParts.userServiceList: tempServiceList}).then((v) {
      Fluttertoast.showToast(msg: "Item Added to Cart Successfully.");

      AutoParts.sharedPreferences!
          .setStringList(AutoParts.userServiceList, tempServiceList as dynamic);
      Provider.of<ServiceItemCounter>(context, listen: false)
          .displayResult()
          .whenComplete(() {
        
      });
    });
  }

  Future addService(
    String vehicleId,
    String serviceId,
    int newPrice,
    int orginalPrice,
    String serviceImage,
    String serviceName,
    String date,
    int quantity,
    String observations,
    String categoryName
  ) async {

    FirebaseFirestore.instance
      .collection(AutoParts.collectionUser)
      .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
      .collection(AutoParts.vehicles)
      .doc(vehicleId)
      .collection('ServiceCart')
      .doc(serviceId)
      .set({
        "servicecartId": serviceId,
        "vehicleId": vehicleId,
        "serviceId": serviceId,
        "newPrice": newPrice,
        "date": date,
        "originalPrice": orginalPrice,
        "serviceImage": serviceImage,
        "serviceName": serviceName,
        "quantity": quantity,
        "observations": observations,
        "categoryName":categoryName
      });
      

  }


  removeServiceFromUserServiceCart(
      String serviceId, int totalPrice, BuildContext context) {
    List tempServiceList =
        AutoParts.sharedPreferences!.getStringList(AutoParts.userServiceList)!;
    tempServiceList.remove(serviceId);
    AutoParts.firestore!
        .collection(AutoParts.collectionUser)
        .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
        .update({
      AutoParts.userServiceList: tempServiceList,
    }).then((v) {
      Fluttertoast.showToast(msg: "Item Removed Successfully.");
      AutoParts.sharedPreferences!
          .setStringList(AutoParts.userServiceList, tempServiceList as dynamic);
      Provider.of<ServiceItemCounter>(context, listen: false)
          .displayResult()
          .whenComplete(() {
        
      });
      totalPrice = 0;
    });
  }

  Future deleteService(String serviceId, String vehicleId, String servicecartId)  async {

    final QuerySnapshot<Map<String, dynamic>>  servicesCart = await FirebaseFirestore.instance
      .collection(AutoParts.collectionUser)
      .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
      .collection(AutoParts.vehicles)
      .doc(vehicleId)
      .collection('ServiceCart')
      .get();

    

    for(final serviceCart in servicesCart.docs){
      

      await serviceCart.reference.delete();
    }
      

  }
  

  addServiceOrderHistory(
      String orderId,
      String serviceId,
      String serviceName,
      String date,
      String serviceImage,
      int orginalPrice,
      int newPrice,
      int quantity,
      BuildContext context) {
    FirebaseFirestore.instance
        .collection(AutoParts.collectionUser)
        .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
        .collection("serviceorderHistory")
        .doc()
        .set({
      "orderHistoyId": orderId,
      "serviceId": serviceId,
      "newPrice": newPrice,
      "date": date,
      "orginalPrice": orginalPrice,
      "serviceImage": serviceImage,
      "serviceName": serviceName,
      "quantity": quantity,
    }).whenComplete(() {
      addServiceOrderHistoryForAdmin(orderId, serviceId, serviceName, date,
          serviceImage, orginalPrice, newPrice, quantity, context);
    }).whenComplete(() {
      
    });
  }

  addServiceOrderHistoryForAdmin(
      String orderId,
      String serviceId,
      String serviceName,
      String date,
      String serviceImage,
      int orginalPrice,
      int newPrice,
      int quantity,
      BuildContext context) {
    AutoParts.firestore!.collection("serviceorderHistory").doc().set({
      "orderHistoyId": orderId,
      "serviceId": serviceId,
      "newPrice": newPrice,
      "date": date,
      "orginalPrice": orginalPrice,
      "serviceImage": serviceImage,
      "serviceName": serviceName,
      "quantity": quantity,
    });
  }

  Future writeServiceOrderPaymentDetailsForUser(
    String vehicleId,
    String idOrderPaymentDetails,
    String paymentMethod,
    int identificationCard,
    int phoneNumber,
    String bank,
    int confirmationNumber,
    DateTime paymentDate,
    String issuerName,
    String holderName,
    String observations
  ) async {

    await AutoParts.firestore!
        .collection(AutoParts.collectionUser)
        .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
        .collection(AutoParts.vehicles)
        .doc(vehicleId)
        .collection("serviceOrderPaymentDetails")
        .doc(idOrderPaymentDetails)
        .set({
          "idOrderPaymentDetails": idOrderPaymentDetails,
          "paymentMethod": paymentMethod,
          "identificationCard": identificationCard,
          "phoneNumber": phoneNumber,
          "bank": bank,
          "confirmationNumber": confirmationNumber,
          "paymentDate": paymentDate,
          "issuerName": issuerName,
          "holderName": holderName,
          "observations": observations
        }).whenComplete(() async {

          await writeServiceOrderPaymentDetailsForAdmin(
            vehicleId,
            idOrderPaymentDetails,
            paymentMethod,
            identificationCard,
            phoneNumber,
            bank,
            confirmationNumber,
            paymentDate,
            issuerName,
            holderName,
            observations
          );

        });


  }


  Future writeServiceOrderPaymentDetailsForAdmin(
    String vehicleId,
    String idOrderPaymentDetails,
    String paymentMethod,
    int identificationCard,
    int phoneNumber,
    String bank,
    int confirmationNumber,
    DateTime paymentDate,
    String issuerName,
    String holderName,
    String observations
  ) async {
    await AutoParts.firestore!
        .collection("serviceOrderPaymentDetails")
        .doc(idOrderPaymentDetails)
        .set({
          "idOrderPaymentDetails": idOrderPaymentDetails,
          "paymentMethod": paymentMethod,
          "identificationCard": identificationCard,
          "phoneNumber": phoneNumber,
          "bank": bank,
          "confirmationNumber": confirmationNumber,
          "paymentDate": paymentDate,
          "issuerName": issuerName,
          "holderName": holderName,
          "observations": observations
        });
  }
  

  Future writeServiceOrderDetailsForUser(
    String servicecartId,
    String vehicleId,
    String orderId,
    String addressId,
    int totalPrice,
    String paymentMethod,
    String serviceId,
    String serviceName,
    String date,
    String serviceImage,
    String categoryName,
    int orginalPrice,
    int newPrice,
    int quantity,
    String observations,
    String idOrderPaymentDetails,
    BuildContext context) async {

      

      await AutoParts.firestore!
        .collection(AutoParts.collectionUser)
        .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
        .collection(AutoParts.vehicles)
        .doc(vehicleId)
        .collection("serviceOrder")
        .doc(orderId)
        .set({
          "vehicleId": vehicleId,
          "orderId": orderId,
          AutoParts.addressID: addressId,
          AutoParts.totalPrice: totalPrice,
          "orderBy": AutoParts.sharedPreferences!.getString(AutoParts.userUID),
          AutoParts.paymentDetails: paymentMethod,
          "orderTime": DateTime.now(),
          AutoParts.isSuccess: true,
          "serviceId": serviceId,
          "newPrice": newPrice,
          "date": date,
          "orginalPrice": orginalPrice,
          "serviceImage": serviceImage,
          "serviceName": serviceName,
          "categoryName":categoryName,
          "quantity": quantity,
          "observations": observations,
          "idOrderPaymentDetails": idOrderPaymentDetails
        })
        .whenComplete(() async {
          await writeServiceOrderDetailsForAdmin(
            vehicleId,
            orderId,
            addressId,
            totalPrice,
            paymentMethod,
            serviceId,
            serviceName,
            date,
            serviceImage,
            categoryName,
            orginalPrice,
            newPrice,
            quantity,
            observations,
            idOrderPaymentDetails,
            context,
          );
        })
        .whenComplete(() async {
          
          await deleteService(serviceId, vehicleId, servicecartId);
        })
        .whenComplete(() async {
          await updateOrderRecived(orderId);
        });
    
  }


  Future writeServiceOrderDetailsForAdmin(
      String vehicleId,
      String orderId,
      String addressId,
      int totalPrice,
      String paymentMethod,
      String serviceId,
      String serviceName,
      String date,
      String serviceImage,
      String categoryName,
      int orginalPrice,
      int newPrice,
      int quantity,
      String observations,
      String idOrderPaymentDetails,
      BuildContext context) async {
    await AutoParts.firestore!.collection("serviceOrder").doc(orderId).set({
      "vehicleId": vehicleId,
      "orderId": orderId,
      AutoParts.addressID: addressId,
      AutoParts.totalPrice: totalPrice,
      "orderBy": AutoParts.sharedPreferences!.getString(AutoParts.userUID),
      // AutoParts.productID:
      //     AutoParts.sharedPreferences.getStringList(AutoParts.userServiceList),
      AutoParts.paymentDetails: paymentMethod,
      "orderTime": DateTime.now(),
      "orderRecived": "UnDone",
      "orderRecivedTime": DateTime.now(),
      "beingPrePared": "UnDone",
      "beingPreParedTime": DateTime.now(),
      "onTheWay": "UnDone",
      "onTheWayTime": DateTime.now(),
      "deliverd": "UnDone",
      "deliverdTime": DateTime.now(),
      "orderCancelled": "UnDone",
      "orderCancelledTime": DateTime.now(),
      AutoParts.isSuccess: true,
      "orderHistoyId": orderId,
      "serviceId": serviceId,
      "newPrice": newPrice,
      "date": date,
      "orginalPrice": orginalPrice,
      "serviceImage": serviceImage,
      "serviceName": serviceName,
      "categoryName":categoryName,
      "quantity": quantity,
      "observations":observations,
      "idOrderPaymentDetails":idOrderPaymentDetails
    });
  }

  Future updateOrderRecived(String orderId) async {
    await FirebaseFirestore.instance.collection("serviceOrder").doc(orderId).update({
      "orderRecived": "Done",
      "orderRecivedTime": DateTime.now(),
    });
  }

  Future cancelledOrder(String orderId) async {
    await FirebaseFirestore.instance.collection("serviceOrder").doc(orderId).update({
      "orderCancelled": "Done",
      "orderCancelledTime": DateTime.now(),
    });
  }
}
