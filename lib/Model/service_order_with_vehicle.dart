import 'package:oilapp/Model/service_order_model.dart';
import 'package:oilapp/Model/vehicle_model.dart';

class SeviceOrderWithVehicleModel {

  Map<String, dynamic>? vehicleModel;
  Map<String, dynamic>? serviceOrderModel;
  
  SeviceOrderWithVehicleModel({
    this.vehicleModel,
    this.serviceOrderModel,
    
  });
  SeviceOrderWithVehicleModel.fromJson(Map<String, dynamic> json) {
    vehicleModel = json['vehicleModel'];
    serviceOrderModel = json['serviceOrderModel'];
    
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['vehicleModel'] = this.vehicleModel;
    data['serviceOrderModel'] = this.serviceOrderModel;
    
    return data;
  }
}
