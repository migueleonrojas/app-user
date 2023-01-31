import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentMethodDetailsModel {
  String? bank;
  String? email;
  String? id;
  int? identificationCard;
  String? kindOfPerson;
  int? numberPhone;
  String? paymentMethod;

  PaymentMethodDetailsModel({
    this.bank,
    this.email,
    this.id,
    this.identificationCard,
    this.kindOfPerson,
    this.numberPhone,
    this.paymentMethod,
    
  });

  PaymentMethodDetailsModel.fromJson(Map<String, dynamic> json) {
    bank = json['bank'];
    email = json['email'];
    id = json['id'];
    identificationCard = json['identificationCard'];
    kindOfPerson = json['kindOfPerson'];
    numberPhone = json['numberPhone'];
    paymentMethod = json['paymentMethod'];
  }
  
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['bank'] = this.bank;
    data['email'] = this.email;
    data['id'] = this.id;
    data['identificationCard'] = this.identificationCard;
    data['kindOfPerson'] = this.kindOfPerson;
    data['numberPhone'] = this.numberPhone;
    data['paymentMethod'] = this.paymentMethod;
   
    return data;
  }
}
