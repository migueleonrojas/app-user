class VehicleModel {
  String? vehicleId;
  String? userId;
  String? brand;
  String? model;
  int? mileage;
  int? year;
  int? color;
  String? name;
  String? tuition;
  String? logo;
  DateTime? registrationDate;
  DateTime? updateDate;
  int? phoneUser;
  VehicleModel({
    this.vehicleId,
    this.userId,
    this.brand,
    this.model,
    this.mileage,
    this.year,
    this.color,
    this.tuition,
    this.name,
    this.logo,
    this.registrationDate,
    this.updateDate,
    this.phoneUser
  });
  VehicleModel.fromJson(Map<String, dynamic> json) {
    vehicleId = json['vehicleId'];
    userId = json['userId'];
    brand = json['brand'];
    model = json['model'];
    mileage = json['mileage'];
    year = json['year'];
    color = json['color'];
    name = json['name'];
    tuition = json['tuition'];
    logo = json['logo'];
    registrationDate = json['registrationDate'].toDate();
    updateDate = json['updateDate'].toDate();
    phoneUser = json['phoneUser'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['vehicleId'] = this.vehicleId;
    data['userId'] = this.userId;
    data['brand'] = this.brand;
    data['model'] = this.model;
    data['mileage'] = this.mileage;
    data['year'] = this.year;
    data['color'] = this.color;
    data['name'] = this.name;
    data['tuition'] = this.tuition;
    data['logo'] = this.logo;
    data['registrationDate'] = this.registrationDate;
    data['updateDate'] = this.updateDate;
    data['phoneUser'] = this.phoneUser;
    return data;
  }
}
