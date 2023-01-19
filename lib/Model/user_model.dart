class UserModel {
  String? address;
  String? email;
  String? name;
  String? phone;
  String? uid;
  String? url;

  UserModel({
    this.address,
    this.email,
    this.name,
    this.phone,
    this.uid,
    this.url,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    email = json['email'];
    name = json['name'];
    phone = json['phone'];
    uid = json['uid'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address'] = this.address;
    data['email'] = this.email;
    data['name'] = this.name;
    data['phone'] = this.phone;
    data['uid'] = this.uid;
    data['url'] = this.url;
    return data;
  }
}
