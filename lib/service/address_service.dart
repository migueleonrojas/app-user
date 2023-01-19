import 'package:oilapp/Model/addresss.dart';
import 'package:oilapp/config/config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddressService {
  String addressId = DateTime.now().microsecondsSinceEpoch.toString();
  addAddress(String cName, String cPhoneNumber, String houseandroadno,
      String city, String area, String areacode, double latitude, double longitude) {
    final model = AddressModel(
      addressId: addressId,
      customerName: cName,
      phoneNumber: cPhoneNumber,
      houseandroadno: houseandroadno,
      city: city,
      area: area,
      areacode: areacode,
      latitude: latitude,
      longitude: longitude
    ).toJson();
    FirebaseFirestore.instance
        .collection(AutoParts.collectionUser)
        .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
        .collection(AutoParts.subCollectionAddress)
        .doc(addressId)
        .set(model)
        .whenComplete(() {
      addAddressForAdmin(
          cName, cPhoneNumber, houseandroadno, city, area, areacode, latitude, longitude);
    }).then((value) {
      Fluttertoast.showToast(msg: "Nueva dirección agregada exitosamente.");
    });
  }

  addAddressForAdmin(String cName, String cPhoneNumber, String houseandroadno,
      String city, String area, String areacode, double latitude, double longitude) {
    final model = AddressModel(
      addressId: addressId,
      customerName: cName,
      phoneNumber: cPhoneNumber,
      houseandroadno: houseandroadno,
      city: city,
      area: area,
      areacode: areacode,
      latitude: latitude,
      longitude: longitude
    ).toJson();
    FirebaseFirestore.instance
        .collection("useraddress")
        .doc(addressId)
        .set(model);
  }

  updateAddressForAdmin(String cName, String cPhoneNumber, String houseandroadno,
      String city, String area, String areacode, double latitude, double longitude, String addressIdFromDB) {
    final model = AddressModel(
      addressId: addressIdFromDB,
      customerName: cName,
      phoneNumber: cPhoneNumber,
      houseandroadno: houseandroadno,
      city: city,
      area: area,
      areacode: areacode,
      latitude: latitude,
      longitude: longitude
    ).toJson();
    FirebaseFirestore.instance
        .collection("useraddress")
        .doc(addressIdFromDB)
        .update(model);
  }


  updateAddress(String cName, String cPhoneNumber, String houseandroadno,
      String city, String area, String areacode, double latitude, double longitude,
      String addressIdFromDB) {
    final model = AddressModel(
      addressId: addressIdFromDB,
      customerName: cName,
      phoneNumber: cPhoneNumber,
      houseandroadno: houseandroadno,
      city: city,
      area: area,
      areacode: areacode,
      latitude: latitude,
      longitude: longitude
    ).toJson();
    FirebaseFirestore.instance
        .collection(AutoParts.collectionUser)
        .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
        .collection(AutoParts.subCollectionAddress)
        .doc(addressIdFromDB)
        .update(model)
        .whenComplete(() {
      updateAddressForAdmin(
          cName, cPhoneNumber, houseandroadno, city, area, areacode, latitude, longitude, addressIdFromDB);
    }).then((value) {
      Fluttertoast.showToast(msg: "Dirección actualizada exitosamente.");
    });
  }


  Future <bool> deleteAddress({String? addressId}) async {

    final QuerySnapshot<Map<String, dynamic>> resultAddress = await FirebaseFirestore.instance.collection('serviceOrder').where('addressID',isEqualTo: addressId).get();

    for(final doc in resultAddress.docs){
      if( 
        (doc.data())['orderRecived'] != "UnDone"  || 
        (doc.data())['beingPrePared'] != "UnDone" ||
        (doc.data())['onTheWay'] != "UnDone"      ||
        (doc.data())['deliverd'] != "UnDone"
      ){
        return false;
      }
    }

    await FirebaseFirestore.instance
      .collection(AutoParts.collectionUser)
      .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
      .collection(AutoParts.subCollectionAddress)
      .doc(addressId).delete();
    
    
    return true;

  }
}
