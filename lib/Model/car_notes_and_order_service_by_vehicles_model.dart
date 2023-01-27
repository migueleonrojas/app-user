import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class carNotesAndOrderServiceByVehiclesModel {
  String? addressID;
  String? beingPrePared;
  Timestamp? beingPreParedTime;
  String? deliverd;
  Timestamp? deliverdTime;
  bool? isSuccess;
  int? newPrice;
  String? observations;
  String? onTheWay;
  Timestamp? onTheWayTime;
  String? orderBy;
  String? orderCancelled;
  Timestamp? orderCancelledTime;
  String? orderHistoyId;
  String? orderId;
  String? orderRecived;
  Timestamp? orderRecivedTime;
  Timestamp? orderTime;
  int? orginalPrice;
  String? paymentDetails;
  int? quantity;
  String? serviceId;
  String? serviceImage;
  String? serviceName;
  String? categoryName;
  int? totalPrice;
  Timestamp? dateOrdered;
  String? carNoteId;
  String? comments;
  int? mileage;
  Timestamp? registrationDate;
  
  

  carNotesAndOrderServiceByVehiclesModel({
    this.addressID,
    this.beingPrePared,
    this.beingPreParedTime,
    this.deliverd,
    this.deliverdTime,
    this.isSuccess,
    this.newPrice,
    this.observations,
    this.onTheWay,
    this.onTheWayTime,
    this.orderBy,
    this.orderCancelled,
    this.orderCancelledTime,
    this.orderHistoyId,
    this.orderId,
    this.orderRecived,
    this.orderRecivedTime,
    this.orderTime,
    this.orginalPrice,
    this.paymentDetails,
    this.quantity,
    this.serviceId,
    this.serviceImage,
    this.serviceName,
    this.categoryName,
    this.totalPrice,
    this.dateOrdered,
    this.carNoteId,
    this.comments,
    this.mileage,
    this.registrationDate,
  });

  carNotesAndOrderServiceByVehiclesModel.fromJson(Map<String, dynamic> json) {
    addressID = json['addressID'];
    beingPrePared = json['beingPrePared'];
    beingPreParedTime = json['beingPreParedTime'];
    deliverd = json['deliverd'];
    deliverdTime = json['deliverdTime'];
    isSuccess = json['isSuccess'];
    newPrice = json['newPrice'];
    observations = json['observations'];
    onTheWay = json['onTheWay'];
    onTheWayTime = json['onTheWayTime'];
    orderBy = json['orderBy'];
    orderCancelled = json['orderCancelled'];
    orderCancelledTime = json['orderCancelledTime'];
    orderHistoyId = json['orderHistoyId'];
    orderId = json['orderId'];
    orderRecived =  json['orderRecived'];
    orderRecivedTime = json['orderRecivedTime'];
    orderTime = json['orderTime'];
    orginalPrice = json['orginalPrice'];
    paymentDetails = json['paymentDetails'];
    quantity = json['quantity'];
    serviceId = json['serviceId'];
    serviceImage = json['serviceImage'];
    serviceName = json['serviceName'];
    categoryName = json['categoryName'];
    totalPrice = json['totalPrice'];
    dateOrdered = json['dateOrdered'];
    carNoteId = json['carNoteId'];
    comments = json['comments'];
    mileage = json['mileage'];
    registrationDate = json['registrationDate'];
    
    
  }
  carNotesAndOrderServiceByVehiclesModel.fromSnaphot(DocumentSnapshot snapshot) {
    addressID = (snapshot.data() as dynamic)['addressID'];
    beingPrePared = (snapshot.data() as dynamic)['beingPrePared'];
    beingPreParedTime = (snapshot.data() as dynamic)['beingPreParedTime'];
    deliverd = (snapshot.data() as dynamic)['deliverd'];
    deliverdTime = (snapshot.data() as dynamic)['deliverdTime'];
    isSuccess = (snapshot.data() as dynamic)['isSuccess'];
    newPrice = (snapshot.data() as dynamic)['newPrice'];
    observations = (snapshot.data() as dynamic)['observations'];
    onTheWay = (snapshot.data() as dynamic)['onTheWay'];
    onTheWayTime = (snapshot.data() as dynamic)['onTheWayTime'];
    orderBy = (snapshot.data() as dynamic)['orderBy'];
    orderCancelled = (snapshot.data() as dynamic)['orderCancelled'];
    orderCancelledTime = (snapshot.data() as dynamic)['orderCancelledTime'];
    orderHistoyId = (snapshot.data() as dynamic)['orderHistoyId'];
    orderId = (snapshot.data() as dynamic)['orderId'];
    orderRecived = (snapshot.data() as dynamic)['orderRecived'];
    orderRecivedTime = (snapshot.data() as dynamic)['orderRecivedTime'];
    orderTime = (snapshot.data() as dynamic)['orderTime'];
    orginalPrice = (snapshot.data() as dynamic)['orginalPrice'];
    paymentDetails = (snapshot.data() as dynamic)['paymentDetails'];
    quantity = (snapshot.data() as dynamic)['quantity'];
    serviceId = (snapshot.data() as dynamic)['serviceId'];
    serviceImage = (snapshot.data() as dynamic)['serviceImage'];
    serviceName = (snapshot.data() as dynamic)['serviceName'];
    categoryName = (snapshot.data() as dynamic)['categoryName'];
    totalPrice = (snapshot.data() as dynamic)['totalPrice'];
    dateOrdered = (snapshot.data() as dynamic)['dateOrdered'];
    carNoteId = (snapshot.data() as dynamic)['carNoteId'];
    comments = (snapshot.data() as dynamic)['comments'];
    mileage = (snapshot.data() as dynamic)['mileage'];
    registrationDate = (snapshot.data() as dynamic)['registrationDate'];

     

      
    
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['addressID'] = this.addressID;
    data['beingPrePared'] = this.beingPrePared;
    data['beingPreParedTime'] = this.beingPreParedTime;
    data['deliverd'] = this.deliverd;
    data['deliverdTime'] = this.deliverdTime;
    data['isSuccess'] = this.isSuccess;
    data['newPrice'] = this.newPrice;
    data['observations'] = this.observations;
    data['onTheWay'] = this.onTheWay;
    data['onTheWayTime'] = this.onTheWayTime;
    data['orderBy'] = this.orderBy;
    data['orderCancelled'] = this.orderCancelled;
    data['orderCancelledTime'] = this.orderCancelledTime;
    data['orderHistoyId'] = this.orderHistoyId;
    data['orderId'] = this.orderId;
    data['orderRecived'] = this.orderRecived;
    data['orderRecivedTime'] = this.orderRecivedTime;
    data['orderTime'] = this.orderTime;
    data['orginalPrice'] = this.orginalPrice;
    data['paymentDetails'] = this.paymentDetails;
    data['quantity'] = this.quantity;
    data['serviceId'] = this.serviceId;
    data['serviceImage'] = this.serviceImage;
    data['serviceName'] = this.serviceName;
    data['categoryName'] = this.categoryName;
    data['totalPrice'] = this.totalPrice;
    data['dateOrdered'] = this.dateOrdered;
    data['carNoteId'] = this.carNoteId;
    data['comments'] = this.comments;
    data['mileage'] = this.mileage;
    data['registrationDate'] = this.registrationDate;

    
    
    
    return data;
  }
}


