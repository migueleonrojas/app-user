import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceOrderPaymentDetailsModel {
  String? bank;
  int? confirmationNumber;
  String? holderName;
  String? idOrderPaymentDetails;
  int? identificationCard;
  String? issuerName;
  String? observations;
  DateTime? paymentDate;
  String? paymentMethod;
  int? phoneNumber;

  ServiceOrderPaymentDetailsModel({
    this.bank,
    this.confirmationNumber,
    this.holderName,
    this.idOrderPaymentDetails,
    this.identificationCard,
    this.issuerName,
    this.observations,
    this.paymentDate,
    this.paymentMethod,
    this.phoneNumber
  });

  ServiceOrderPaymentDetailsModel.fromJson(Map<String, dynamic> json) {
    bank = json['bank'];
    confirmationNumber = json['confirmationNumber'];
    holderName = json['holderName'];
    idOrderPaymentDetails = json['idOrderPaymentDetails'];
    identificationCard = json['identificationCard'];
    issuerName = json['issuerName'];
    observations = json['observations'];
    paymentDate = json['paymentDate'].toDate();
    paymentMethod = json['paymentMethod'];
    phoneNumber = json['phoneNumber'];
  }
  
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['bank'] = this.bank;
    data['confirmationNumber'] = this.confirmationNumber;
    data['holderName'] = this.holderName;
    data['idOrderPaymentDetails'] = this.idOrderPaymentDetails;
    data['identificationCard'] = this.identificationCard;
    data['issuerName'] = this.issuerName;
    data['observations'] = this.observations;
    data['paymentDate'] = this.paymentDate;
    data['paymentMethod'] = this.paymentMethod;
    data['phoneNumber'] = this.phoneNumber;

    return data;
  }
}
