import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oil_app/config/config.dart';

class CarNoteService{

  final StreamController <List<Map<String,dynamic>>> _suggestionStreamControlerCarNotes = StreamController.broadcast();
  Stream<List<Map<String,dynamic>>> get suggestionStreamCarNotes => _suggestionStreamControlerCarNotes.stream;
  List<Map<String,dynamic>> carNotes = [];
  QuerySnapshot? collectionState;
  bool dataFinish = false;

  final StreamController <List<Map<String,dynamic>>> _suggestionStreamControlerCarNotesByUser = StreamController.broadcast();
  Stream<List<Map<String,dynamic>>> get suggestionStreamCarNotesByUser => _suggestionStreamControlerCarNotesByUser.stream;
  List<Map<String,dynamic>> carNotesByUser = [];
  QuerySnapshot? collectionStateByUser;
  bool dataFinishByUser = false;


  Future <bool> getCarNotes({int limit = 5, bool nextDocument = false, String vehicleId = ""}) async {



    QuerySnapshot<Map<String, dynamic>>? querySnapshotCarNotes;
    QuerySnapshot<Map<String, dynamic>>? collectionCarNotes;
    if(!nextDocument){

      if(vehicleId.isEmpty){
        collectionCarNotes = await FirebaseFirestore.instance
        .collection("carNotesUserVehicles")
        .where('userId',isEqualTo: AutoParts.sharedPreferences!.getString(AutoParts.userUID))
        .orderBy("date", descending: true)
        .get();
      }
      else{
        collectionCarNotes = await FirebaseFirestore.instance
        .collection("carNotesUserVehicles")
        .where('userId',isEqualTo: AutoParts.sharedPreferences!.getString(AutoParts.userUID))
        .orderBy("date", descending: true)
        .get();
      }
      

      
      if(collectionCarNotes.size < limit) {
        limit = collectionCarNotes.size;
      }

      if(collectionCarNotes.size == 0){
        _suggestionStreamControlerCarNotes.add(carNotes);
        return true;
      }

      Query<Map<String, dynamic>> collection;
      if(vehicleId.isEmpty){
        collection = FirebaseFirestore.instance
        .collection("carNotesUserVehicles")
        .where('userId',isEqualTo: AutoParts.sharedPreferences!.getString(AutoParts.userUID))
        .limit(limit)
        .orderBy("date", descending: true);
      }
      else{
        collection = FirebaseFirestore.instance
        .collection("carNotesUserVehicles")
        .where('userId',isEqualTo: AutoParts.sharedPreferences!.getString(AutoParts.userUID))
        .limit(limit)
        .orderBy("date", descending: true);
      }
      
      

      collection.get().then((values)  {
        collectionState = values; 
      });

      querySnapshotCarNotes = await collection.get();
    }

    else{
      final lastVisible = collectionState!.docs[collectionState!.docs.length-1];
      Query<Map<String, dynamic>> collection;
      if(vehicleId.isEmpty){
        collection = FirebaseFirestore.instance
        .collection("carNotesUserVehicles")
        .where('userId',isEqualTo: AutoParts.sharedPreferences!.getString(AutoParts.userUID))
        .limit(limit)
        .orderBy("date", descending: true)
        .startAfterDocument(lastVisible);
      }
      else{
        collection = FirebaseFirestore.instance
        .collection("carNotesUserVehicles")
        .where('userId',isEqualTo: AutoParts.sharedPreferences!.getString(AutoParts.userUID))
        .limit(limit)
        .orderBy("date", descending: true)
        .startAfterDocument(lastVisible);
      }
      

      final collectionGet = await collection.get();

      if(collectionGet.size == 0) {
        dataFinish = true;
        return dataFinish;
      }

      collection.get().then((values)  {
        collectionState = values; 
      });

      querySnapshotCarNotes = await collection.get();  


    }

    List<QueryDocumentSnapshot<Map<String,dynamic>>> documentsCarNotes = querySnapshotCarNotes.docs;

    for(final documentsCarNote in documentsCarNotes) {
      carNotes.add(documentsCarNote.data());
    }
     
    _suggestionStreamControlerCarNotes.add(carNotes);
    return dataFinish;
  }

  Future <bool> getCarNotesByUser({int limit = 5, bool nextDocument = false, String vehicleId = ""}) async {


   
    QuerySnapshot<Map<String, dynamic>>? querySnapshotCarNotesByUser;
    QuerySnapshot<Map<String, dynamic>>? collectionCarNotesByUser;
    if(!nextDocument){

        collectionCarNotesByUser = await FirebaseFirestore.instance
        .collection(AutoParts.collectionUser)
        .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
        .collection(AutoParts.vehicles)
        .doc(vehicleId)
        .collection('carNotes')
        .orderBy("date", descending: true)
        .get();
      
      
      
      
      
      if(collectionCarNotesByUser.size < limit) {
        limit = collectionCarNotesByUser.size;
      }

      if(collectionCarNotesByUser.size == 0){
        _suggestionStreamControlerCarNotesByUser.add(carNotesByUser);
        return true;
      }

      
      QuerySnapshot<Map<String, dynamic>> collectionByUser;

      collectionByUser = await FirebaseFirestore.instance
        .collection(AutoParts.collectionUser)
        .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
        .collection(AutoParts.vehicles)
        .doc(vehicleId)
        .collection('carNotes')
        .orderBy("date", descending: true)
        .get();

      
      
      collectionStateByUser = collectionByUser;
      
      
      querySnapshotCarNotesByUser =  collectionByUser;
    }

    else{
      final lastVisible = collectionStateByUser!.docs[collectionStateByUser!.docs.length-1];
      Query<Map<String, dynamic>> collectionByUser;

      collectionByUser =  FirebaseFirestore.instance
        .collection(AutoParts.collectionUser)
        .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
        .collection(AutoParts.vehicles)
        .doc(vehicleId)
        .collection('carNotes')
        .limit(limit)
        .orderBy("date", descending: true)
        .startAfterDocument(lastVisible);
      

      final collectionGet = await collectionByUser.get();

      if(collectionGet.size == 0) {
        dataFinish = true;
        return dataFinish;
      }

      collectionByUser.get().then((values)  {
        collectionState = values; 
      });

      querySnapshotCarNotesByUser = await collectionByUser.get();  


    }

    List<QueryDocumentSnapshot<Map<String,dynamic>>> documentsCarNotesByUsers = querySnapshotCarNotesByUser.docs;

    for(final documentsCarNotesByUser in documentsCarNotesByUsers) {
      carNotesByUser.add(documentsCarNotesByUser.data());
    }
     
    _suggestionStreamControlerCarNotesByUser.add(carNotesByUser);
    return dataFinishByUser;
  }

}