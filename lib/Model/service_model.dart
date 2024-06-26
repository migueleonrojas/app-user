import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  String? serviceId;
  String? aboutInfo;
  String? serviceName;
  String? categoryName;
  String? brandName;
  Timestamp? publishedDate;
  String? expectation;
  int? newprice;
  int? orginalprice;
  int? offervalue;
  String? status;
  String? serviceImgUrl;

  ServiceModel({
    this.serviceId,
    this.aboutInfo,
    this.serviceName,
    this.categoryName,
    this.brandName,
    this.publishedDate,
    this.expectation,
    this.newprice,
    this.orginalprice,
    this.offervalue,
    this.status,
    this.serviceImgUrl,
  });

  ServiceModel.fromJson(Map<String, dynamic> json) {
    serviceId = json['serviceId'];
    aboutInfo = json['aboutInfo'];
    serviceName = json['serviceName'];
    categoryName = json['categoryName'];
    brandName = json['brandName'];
    publishedDate = json['publishedDate'];
    expectation = json['expectation'];
    newprice = json['newprice'];
    orginalprice = json['orginalprice'];
    offervalue = json['offer'];
    status = json['status'];
    serviceImgUrl = json['serviceImgUrl'];
  }
  ServiceModel.fromSnaphot(DocumentSnapshot snapshot) {
    serviceId = (snapshot.data() as dynamic)['serviceId'];
    aboutInfo = (snapshot.data() as dynamic)['aboutInfo'];
    serviceName = (snapshot.data() as dynamic)['serviceName'];
    categoryName = (snapshot.data() as dynamic)['categoryName'];
    brandName = (snapshot.data() as dynamic)['brandName'];
    publishedDate = (snapshot.data() as dynamic)['publishedDate'];
    expectation = (snapshot.data() as dynamic)['expectation'];
    newprice = (snapshot.data() as dynamic)['newprice'];
    orginalprice = (snapshot.data() as dynamic)['orginalprice'];
    offervalue = (snapshot.data() as dynamic)['offer'];
    status = (snapshot.data() as dynamic)['status'];
    serviceImgUrl = (snapshot.data() as dynamic)['serviceImgUrl'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['serviceId'] = this.serviceId;
    data['aboutInfo'] = this.aboutInfo;
    data['serviceName'] = this.serviceName;
    data['categoryName'] = this.categoryName;
    data['brandName'] = this.brandName;
    data['publishedDate'] = this.publishedDate;
    data['expectation'] = this.expectation;
    data['newprice'] = this.newprice;
    data['orginalprice'] = this.orginalprice;
    data['offer'] = this.offervalue;
    data['status'] = this.status;
    data['serviceImgUrl'] = this.serviceImgUrl;
    return data;
  }
}

class PublishedDate {
  String? date;

  PublishedDate({this.date});

  PublishedDate.fromJson(Map<String, dynamic> json) {
    date = json['$date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['$date'] = this.date;
    return data;
  }
}
