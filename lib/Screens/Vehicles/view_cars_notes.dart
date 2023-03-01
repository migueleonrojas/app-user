import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:oilapp/Model/vehicle_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oilapp/Screens/Vehicles/edit_car_notes.dart';
import 'package:oilapp/Screens/home_screen.dart';
import 'package:oilapp/config/config.dart';
import 'package:oilapp/widgets/emptycardmessage.dart';
import 'package:oilapp/widgets/loading_widget.dart';
import 'package:oilapp/widgets/modal_bottom_sheet_add_car_note.dart';
import 'package:oilapp/widgets/model_bottom_sheet_list.dart';
class ViewCarNotes extends StatefulWidget {

  final VehicleModel? vehicleModel;
  final bool goToHome;

  const ViewCarNotes({super.key, this.vehicleModel, this.goToHome = false});

  @override
  State<ViewCarNotes> createState() => _ViewCarNotesState();
}

class _ViewCarNotesState extends State<ViewCarNotes> {

  List <VehicleModel>? usersVehicles = [];
  List <Map<String,dynamic>> listAttachments = [];
  ModalBottomSheetAddCarNote carNotes =  ModalBottomSheetAddCarNote();

  late Stream<QuerySnapshot<Map<String, dynamic>>> streamCarNotes = (widget.vehicleModel == null) 
    ? FirebaseFirestore.instance
      .collection('carNotesUserVehicles')
      .where('userId', isEqualTo: AutoParts.sharedPreferences!.getString(AutoParts.userUID))
      
      .snapshots()
    : FirebaseFirestore.instance
        .collection(AutoParts.collectionUser)
        .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
        .collection(AutoParts.vehicles)
        .doc(widget.vehicleModel!.vehicleId)
        .collection('carNotes')
        .snapshots();

  @override
  void initState() {
    super.initState();
    if(widget.vehicleModel == null) {

      getUserVehicle();
    
    }
    getListAttachments();
    if(mounted){
      setState(() {});
    }
    
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          "Notas de Servicio",
          style: TextStyle(
            fontSize: size.height * 0.024,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
            fontFamily: "Brand-Regular",
          ),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (BuildContext context) {

            if(widget.goToHome == false && widget.vehicleModel == null){

              return IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              );

            }

            else if(widget.goToHome == false && widget.vehicleModel != null){

              return IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              );

            }
            else {
              return IconButton(
                icon: const Icon(Icons.home),
                onPressed: () {
                  Route route =  MaterialPageRoute(builder: (_) => HomeScreen());
                  Navigator.push(context, route);
                  
                },
              );
            }

          }
        ),
        
        actions: [
          IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
         
                
                final vehicleSelected = await ModalBottomSheetListVehicle().showModalBottomSheetListVehicle(context: context);

                if(vehicleSelected is bool) return;

                
                await carNotes.showModalBottomSheetByAddCarNotes(context: context, vehicle: vehicleSelected );
                
              },
            )
        ],     
      ),
      
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: streamCarNotes,
              builder: (context, snapshot) {
                
                if (snapshot.data == null) {
                  return Center(
                    child: circularProgress(),
                  );
                }

                
                if(snapshot.data!.size == 0) {
                   return const  EmptyCardMessage(
                    listTitle: "No hay notas de servicio",
                    message: "Comienza a agregar notas de servicio",
                  );
                }
                
                  return 
                    /* listAttachments.isEmpty
                    ? circularProgress()
                    :  */ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  reverse: true,
                  scrollDirection: Axis.vertical,
                  itemBuilder:  (context, index) {

                    return ListTile(
                      leading: FadeInImage(
                        placeholder: const AssetImage('assets/no-image/no-image.jpg'),
                        image: NetworkImage((snapshot.data!.docs[index].data() as dynamic)["serviceImage"]),
                        width: size.width * 0.07,
                        fit:BoxFit.contain
                      ),
                      title: AutoSizeText((snapshot.data!.docs[index].data() as dynamic)["serviceName"]),
                      onTap: () async {
                        
                        VehicleModel? userVehicleReturned;
                        List listAttachmentsReturned = [];
                        for(final listAttachment in listAttachments) {
                         if(listAttachment["carNoteId"] == (snapshot.data!.docs[index].data() as dynamic)["carNoteId"] ){
                          listAttachmentsReturned.add(listAttachment["urlImg"]);
                         }
                        }
                        
                        if(widget.vehicleModel == null) {

                          for(final userVehicle in usersVehicles!){
                            if(userVehicle.vehicleId == (snapshot.data!.docs[index].data() as dynamic)["vehicleId"]){
                              userVehicleReturned = userVehicle;
                            }
                          }

                        }

                        if(listAttachments.isEmpty) return;
                        
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) =>  EditCarNote(
                              noteCar: {
                                "image":(snapshot.data!.docs[index].data() as dynamic)["serviceImage"],
                                "name":(snapshot.data!.docs[index].data() as dynamic)["serviceName"],
                                "date":(snapshot.data!.docs[index].data() as dynamic)["date"],
                                "comments":(snapshot.data!.docs[index].data() as dynamic)["comments"],
                                "carNoteId":(snapshot.data!.docs[index].data() as dynamic)["carNoteId"],
                                "mileage":(snapshot.data!.docs[index].data() as dynamic)["mileage"] 
                              }, 
                              vehicleModel:(widget.vehicleModel == null)? userVehicleReturned!:widget.vehicleModel!,
                              attachmentsFromDB: listAttachmentsReturned,
                              
                            )
                          ),
                        );
                      },
                    );
                  });
                
              },
            )
          ],
        ),
      ),
    );
  }

  getUserVehicle() async {

    QuerySnapshot<Map<String, dynamic>> docUsersVehicles = await FirebaseFirestore.instance
      .collection('usersVehicles')
      .where('userId',isEqualTo: AutoParts.sharedPreferences!.getString(AutoParts.userUID))
      .get();

    for(final docUserVehicle in docUsersVehicles.docs) {

      usersVehicles!.add(VehicleModel.fromJson(docUserVehicle.data()));
    }
    
  }

  getListAttachments() async {
    QuerySnapshot<Map<String, dynamic>> carNotesUsers = await FirebaseFirestore.instance
      .collection("carNotesUserVehicles")
      .where('userId',isEqualTo: AutoParts.sharedPreferences!.getString(AutoParts.userUID))
      .get();
    QuerySnapshot<Map<String, dynamic>>? attachmentsDocs;

    

    for(final carNotesUser in carNotesUsers.docs) {

      QuerySnapshot<Map<String, dynamic>> attachmentsDocs = await carNotesUser.reference
        .collection("attachmentsCarNotesUsers")
        .where('userId',isEqualTo: AutoParts.sharedPreferences!.getString(AutoParts.userUID)).get();

      for(final attachmentsDoc in attachmentsDocs.docs){

        listAttachments.add(attachmentsDoc.data());
      }

    }


   
  }

  



}