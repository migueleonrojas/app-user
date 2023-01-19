class ServiceCartModel {
  String? date;
  int? newPrice;
  int? originalPrice;
  int? quantity;
  String? serviceId;
  String? serviceImage;
  String? serviceName;
  String? servicecartId;
  String? vehicleId;

  ServiceCartModel({
    this.date,
    this.newPrice,
    this.originalPrice,
    this.quantity,
    this.serviceId,
    this.serviceImage,
    this.serviceName,
    this.servicecartId,
    this.vehicleId
  });

  ServiceCartModel.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    newPrice = json['newPrice'];
    originalPrice = json['originalPrice'];
    quantity = json['quantity'];
    serviceId = json['serviceId'];
    serviceImage = json['serviceImage'];
    serviceName = json['serviceName'];
    servicecartId = json['servicecartId'];
    vehicleId = json['vehicleId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = this.date;
    data['newPrice'] = this.newPrice;
    data['originalPrice'] = this.originalPrice;
    data['quantity'] = this.quantity;
    data['serviceId'] = this.serviceId;
    data['serviceImage'] = this.serviceImage;
    data['serviceName'] = this.serviceName;
    data['servicecartId'] = this.servicecartId;
    data['vehicleId'] = this.vehicleId;
    return data;
  }
}
