import 'dart:async';


import 'package:oilapp/Model/service_order_model.dart';
import 'package:oilapp/Model/service_order_with_vehicle.dart';
import 'package:oilapp/Model/vehicle_model.dart';
import 'package:oilapp/config/config.dart';
import 'package:oilapp/counter/service_item_counter.dart';
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
    
    
    List<QueryDocumentSnapshot<Map<String,dynamic>>> documentsServiceOrders = querySnapshotServiceOrder!.docs;
    
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
        /* addService(serviceId, newPrice, orginalPrice, serviceImage, serviceName,
            date, quantity); */
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


  /* Future addService(
    String serviceId,
    int newPrice,
    int orginalPrice,
    String serviceImage,
    String serviceName,
    String date,
    int quantity,
  ) async {
    FirebaseFirestore.instance
        .collection(AutoParts.collectionUser)
        .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
        .collection('ServiceCart')
        .doc(serviceId)
        .set({
      "servicecartId": serviceId,
      "serviceId": serviceId,
      "newPrice": newPrice,
      "date": date,
      "orginalPrice": orginalPrice,
      "serviceImage": serviceImage,
      "serviceName": serviceName,
      "quantity": quantity,
    });
  } */

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
        /* deleteService(serviceId); */
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

    print(servicesCart.docs);

    for(final serviceCart in servicesCart.docs){
      print(serviceCart.data());

      await serviceCart.reference.delete();
    }
      

    /* FirebaseFirestore.instance
      .collection(AutoParts.collectionUser)
      .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
      .collection()
      .doc(vehicleId)
      .collection('ServiceCart')
      .doc(serviceId)
      .set({
        "servicecartId": serviceId,
        "vehicleId": vehicleId,
        "serviceId": serviceId,
        "newPrice": newPrice,
        "date": date,
        "orginalPrice": orginalPrice,
        "serviceImage": serviceImage,
        "serviceName": serviceName,
        "quantity": quantity,
      }); */

  }
  /* deleteService(String serviceId) {
    FirebaseFirestore.instance
        .collection(AutoParts.collectionUser)
        .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
        .collection('ServiceCart')
        .doc(serviceId)
        .delete();
  } */

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
      // for (int i = 0;
      //     i <
      //         AutoParts.sharedPreferences
      //             .getStringList(AutoParts.userServiceList)
      //             .length;
      //     i++) {
      //   deleteServiceCart(
      //     context,
      //     AutoParts.sharedPreferences
      //         .getStringList(AutoParts.userServiceList)[i],
      //   );
      // }
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

  // deleteServiceCart(BuildContext context, String serviceId) {
  //   FirebaseFirestore.instance
  //       .collection(AutoParts.collectionUser)
  //       .doc(AutoParts.sharedPreferences.getString(AutoParts.userUID))
  //       .collection('ServiceCart')
  //       .doc(serviceId)
  //       .delete()
  //       .whenComplete(() {
  //     emptyServicCartNow(context);
  //   });
  // }

  // emptyServicCartNow(BuildContext context) {
  //   AutoParts.sharedPreferences
  //       .setStringList(AutoParts.userServiceList, ["garbageValue"]);
  //   List tempServiceList =
  //       AutoParts.sharedPreferences.getStringList(AutoParts.userServiceList);
  //   FirebaseFirestore.instance
  //       .collection("users")
  //       .doc(AutoParts.sharedPreferences.getString(AutoParts.userUID))
  //       .update({
  //     AutoParts.userServiceList: tempServiceList,
  //   }).then((value) {
  //     AutoParts.sharedPreferences
  //         .setStringList(AutoParts.userServiceList, tempServiceList);
  //     Provider.of<ServiceItemCounter>(context, listen: false).displayResult();
  //   });
  // }

  /* Future writeServiceOrderDetailsForUser(
      String orderId,
      String addressId,
      int totalPrice,
      String paymentMethod,
      String serviceId,
      String serviceName,
      String date,
      String serviceImage,
      int orginalPrice,
      int newPrice,
      int quantity,
      BuildContext context) async {
    await AutoParts.firestore!
        .collection(AutoParts.collectionUser)
        .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
        .collection("serviceOrder")
        .doc(orderId)
        .set({
      "orderId": orderId,
      AutoParts.addressID: addressId,
      AutoParts.totalPrice: totalPrice,
      "orderBy": AutoParts.sharedPreferences!.getString(AutoParts.userUID),
      // AutoParts.productID:
      //     AutoParts.sharedPreferences.getStringList(AutoParts.userServiceList),
      AutoParts.paymentDetails: paymentMethod,
      "orderTime": DateTime.now(),
      AutoParts.isSuccess: true,
      "serviceId": serviceId,
      "newPrice": newPrice,
      "date": date,
      "orginalPrice": orginalPrice,
      "serviceImage": serviceImage,
      "serviceName": serviceName,
      "quantity": quantity,
    }).whenComplete(() {
      writeServiceOrderDetailsForAdmin(
        orderId,
        addressId,
        totalPrice,
        paymentMethod,
        serviceId,
        serviceName,
        date,
        serviceImage,
        orginalPrice,
        newPrice,
        quantity,
        context,
      );
    }).whenComplete(() {
      /* deleteService(serviceId); */
    });
  } */

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
            context,
          );
        })
        .whenComplete(() async {
          
          await deleteService(serviceId, vehicleId, servicecartId);
        })
        .whenComplete(() async {
          await updateOrderRecived(orderId);
        });


      


    /* await AutoParts.firestore!
        .collection(AutoParts.collectionUser)
        .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
        .collection("serviceOrder")
        .doc(orderId)
        .set({
      "orderId": orderId,
      AutoParts.addressID: addressId,
      AutoParts.totalPrice: totalPrice,
      "orderBy": AutoParts.sharedPreferences!.getString(AutoParts.userUID),
      // AutoParts.productID:
      //     AutoParts.sharedPreferences.getStringList(AutoParts.userServiceList),
      AutoParts.paymentDetails: paymentMethod,
      "orderTime": DateTime.now(),
      AutoParts.isSuccess: true,
      "serviceId": serviceId,
      "newPrice": newPrice,
      "date": date,
      "orginalPrice": orginalPrice,
      "serviceImage": serviceImage,
      "serviceName": serviceName,
      "quantity": quantity,
    }).whenComplete(() {
      writeServiceOrderDetailsForAdmin(
        vehicleId,
        orderId,
        addressId,
        totalPrice,
        paymentMethod,
        serviceId,
        serviceName,
        date,
        serviceImage,
        orginalPrice,
        newPrice,
        quantity,
        context,
      );
    }).whenComplete(() {
      /* deleteService(serviceId); */
    }); */
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
      "observations":observations
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
