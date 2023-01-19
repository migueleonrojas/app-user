

class AddressModel {
  String? addressId;
  String? customerName;
  String? phoneNumber;
  String? houseandroadno;
  String? city;
  String? area;
  String? areacode;
  double? latitude;
  double? longitude;

  AddressModel({
    this.addressId,
    this.customerName,
    this.phoneNumber,
    this.houseandroadno,
    this.city,
    this.area,
    this.areacode,
    this.latitude,
    this.longitude
  });

  AddressModel.fromJson(Map<String, dynamic> json) {
    addressId = json['addressId'];
    customerName = json['customerName'];
    phoneNumber = json['phoneNumber'];
    houseandroadno = json['houseandroadno'];
    city = json['city'];
    area = json['area'];
    areacode = json['areacode'];
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['addressId'] = this.addressId;
    data['customerName'] = this.customerName;
    data['phoneNumber'] = this.phoneNumber;
    data['houseandroadno'] = this.houseandroadno;
    data['city'] = this.city;
    data['area'] = this.area;
    data['areacode'] = this.areacode;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;

    return data;
  }
}
