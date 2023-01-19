import 'dart:async';

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:oilapp/Model/vehicle_model.dart';
import 'package:oilapp/config/config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class BackEndCarNotesService{
  DateTime dateActual = DateTime.now();

 Future addCarNoteService({
    required String vehicleId,
    required String serviceName,
    required String serviceImage,
    required DateTime date,
    required int mileage,
    required String comments,
    required List attachments,
    required VehicleModel vehicleModel
  }) async {

    await FirebaseFirestore.instance
      .collection(AutoParts.collectionUser)
      .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
      .collection(AutoParts.vehicles)
      .doc(vehicleId).update({
        "brand": vehicleModel.brand,
        "color": vehicleModel.color,
        "logo":  vehicleModel.logo,
        "mileage": mileage,
        "model": vehicleModel.model,
        "name":vehicleModel.name,
        "registrationDate": vehicleModel.registrationDate,
        "tuition": vehicleModel.tuition,
        "updateDate": vehicleModel.updateDate,
        "userId":vehicleModel.userId,
        "vehicleId":vehicleModel.vehicleId,
        "year":vehicleModel.year
      }).whenComplete(() async {

        await FirebaseFirestore.instance.collection("usersVehicles").doc(vehicleId).update({
          "brand": vehicleModel.brand,
          "color": vehicleModel.color,
          "logo":  vehicleModel.logo,
          "mileage": mileage,
          "model": vehicleModel.model,
          "name":vehicleModel.name,
          "registrationDate": vehicleModel.registrationDate,
          "tuition": vehicleModel.tuition,
          "updateDate": vehicleModel.updateDate,
          "userId":vehicleModel.userId,
          "vehicleId":vehicleModel.vehicleId,
          "year":vehicleModel.year
        });

      });

    String carNoteId = DateTime.now().microsecondsSinceEpoch.toString();
    

    await FirebaseFirestore.instance
      .collection(AutoParts.collectionUser)
      .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
      .collection(AutoParts.vehicles)
      .doc(vehicleId)
      .collection('carNotes')
      .doc(carNoteId)
      .set({
        "carNoteId": carNoteId,
        "vehicleId": vehicleId,
        "serviceName": serviceName,
        "serviceImage":serviceImage,
        "date": date,
        "mileage":mileage,
        "comments":comments,
        "registrationDate": dateActual,
        "tokenFirebaseToken": AutoParts.sharedPreferences!.getString(AutoParts.tokenFirebaseMsg)
      })
      .whenComplete(() async {

        await addCarNoteServiceByAdmin(
          carNoteId:    carNoteId,
          vehicleId:    vehicleId,
          serviceName:  serviceName,
          serviceImage: serviceImage,
          date:         date,
          mileage:      mileage,
          comments:     comments,
        );

        
      })
      .whenComplete(() async {

        await uploadAttachments(
          carNoteId: carNoteId,
          attachments: attachments,
          vehicleId: vehicleId
        );

      });


  }

  addCarNoteServiceByAdmin({
    required String carNoteId,
    required String vehicleId,
    required String serviceName,
    required String serviceImage,
    required DateTime date,
    required int mileage,
    required String comments,
  }) async {

    await FirebaseFirestore.instance.collection('carNotesUserVehicles').doc(carNoteId).set({
          "carNoteId": carNoteId,
          "vehicleId": vehicleId,
          "serviceName": serviceName,
          "serviceImage":serviceImage,
          "date": date,
          "mileage":mileage,
          "comments":comments,
          "registrationDate": dateActual,
          "userId": AutoParts.sharedPreferences!.getString(AutoParts.userUID),
          "tokenFirebaseToken": AutoParts.sharedPreferences!.getString(AutoParts.tokenFirebaseMsg)
        });

  }

  uploadAttachments({
    required String carNoteId,
    required List attachments,
    required String vehicleId
  }) async {

    final Reference reference = FirebaseStorage.instance.ref().child("attachmentCarNote");
    
    int index = 0;
    List urls = [];
    for(final attachment in attachments)  {
        index++;
        UploadTask uploadTask = reference.child("attachmentCarNote$carNoteId$index.jpg").putFile(File(attachment.path));
        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();
        urls.add(downloadUrl);
    }

    for(final url in urls){
      String attachmentId = DateTime.now().microsecondsSinceEpoch.toString();
      await FirebaseFirestore.instance
          .collection(AutoParts.collectionUser)
          .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
          .collection(AutoParts.vehicles)
          .doc(vehicleId)
          .collection('carNotes')
          .doc(carNoteId)
          .collection('attachmentsCarNotes')
          .doc(attachmentId).set({
            "attachmentId":attachmentId,
            "carNoteId":carNoteId,
            "urlImg":url

          }).whenComplete(() async {

            await FirebaseFirestore.instance
              .collection('carNotesUserVehicles')
              .doc(carNoteId)
              .collection("attachmentsCarNotesUsers")
              .doc(attachmentId)
              .set({
                "attachmentId":attachmentId,
                "carNoteId":carNoteId,
                "urlImg":url,
                "userId":AutoParts.sharedPreferences!.getString(AutoParts.userUID)
              });
          });
    }

  }


  deleteCarNoteService(
    String carNoteId, 
    VehicleModel vehicleModel,
    List attachments
    ) async {

    

    await FirebaseFirestore.instance
      .collection(AutoParts.collectionUser)
      .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
      .collection(AutoParts.vehicles)
      .doc(vehicleModel.vehicleId)
      .collection("carNotes")
      .doc(carNoteId)
      .delete()
      .whenComplete(() async{
        QuerySnapshot<Map<String, dynamic>> attachmentsCarNotes = await FirebaseFirestore.instance
          .collection(AutoParts.collectionUser)
          .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
          .collection(AutoParts.vehicles)
          .doc(vehicleModel.vehicleId)
          .collection("carNotes")
          .doc(carNoteId)
          .collection("attachmentsCarNotes").get();

        for(final attachmentsCarNote in attachmentsCarNotes.docs) {
          await attachmentsCarNote.reference.delete();
        }
      })
      .whenComplete(()  async{
        await FirebaseFirestore.instance.collection('carNotesUserVehicles').doc(carNoteId).delete();
      })
      .whenComplete(() async{
        QuerySnapshot<Map<String, dynamic>> attachmentsCarNotes = await FirebaseFirestore.instance.
          collection('carNotesUserVehicles')
          .doc(carNoteId)
          .collection("attachmentsCarNotesUsers").get();
          
        for(final attachmentsCarNote in attachmentsCarNotes.docs) {
          await attachmentsCarNote.reference.delete();
        }
      })
      .whenComplete(() async {

        for(final attachment in attachments) {
          await FirebaseStorage.instance.refFromURL(attachment).delete();
        }
        
      });

  }


}