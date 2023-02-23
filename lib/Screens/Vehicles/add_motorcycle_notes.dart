import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:oilapp/Model/vehicle_model.dart';
import 'package:oilapp/Screens/Vehicles/view_cars_notes.dart';
import 'package:oilapp/Screens/Vehicles/view_image.dart';
import 'package:oilapp/Screens/home_screen.dart';
import 'package:oilapp/Screens/ourservice/backend_carnoteservice.dart';
import 'package:oilapp/config/config.dart';
import 'package:oilapp/service/vehicle_service.dart';
import 'package:oilapp/widgets/customTextField.dart';
import 'package:file_picker/file_picker.dart';
import 'package:oilapp/widgets/progressdialog.dart';
class AddMotorCycleNote extends StatefulWidget {

  final Map<String,dynamic> noteCar;
  final VehicleModel vehicleModel;
  const AddMotorCycleNote({super.key, required this.noteCar, required this.vehicleModel});
  
  @override
  State<AddMotorCycleNote> createState() => _AddMotorCycleNoteState();
}

class _AddMotorCycleNoteState extends State<AddMotorCycleNote> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final _serviceNameTextEditingController = TextEditingController();
  final _mileageTextEditingController = TextEditingController();
  final _dateTextEditingController = TextEditingController();
  final _commentsTextEditingController = TextEditingController();
  final VehicleService vehicleService = VehicleService();

  List attachments = [];
  List selectedAttachments = [];
  bool selectingAttachments = false;
  @override
  void initState() {
    super.initState();
    _serviceNameTextEditingController.text = widget.noteCar["name"];
  }
  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    
    return Scaffold(
      
      appBar: AppBar(
        title:  AutoSizeText(
          (!selectingAttachments)?"Agregar Servicio":"Selecionado: ${selectedAttachments.length}",
          style: TextStyle(
            fontSize: size.height * 0.024,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
            fontFamily: "Brand-Regular",
          ),
        ),
        
        centerTitle: true,
        leading: (selectingAttachments)
          ? IconButton(
              icon: const Icon(Icons.disabled_by_default_outlined),
              onPressed: () {
                selectingAttachments = false;
                selectedAttachments = [];
                setState(() {});
              },
          )
          :null,
          actions:(selectingAttachments)? <Widget>[
            IconButton(
              icon: const Icon(Icons.list_sharp),
              onPressed: () {
              
                
                for(final attachment in attachments){
                  if(!selectedAttachments.contains(attachment)){
                    selectedAttachments.add(attachment);
                  }
                  
                }
                setState(() {});
              },  
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {

                bool confirm =  await _onBackPressed("De que quieres eliminar los adjuntos seleccionados");

                if(!confirm) return;

                for(final selectedAttachment in selectedAttachments){
                  
                  if(attachments.contains(selectedAttachment)){
                    attachments.remove(selectedAttachment);
                  }
                  
                }
                selectedAttachments = [];
                selectingAttachments = false;
                setState(() {});
              },  
            ),

          ]:<Widget>[
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () async {
                /* DateTime lastTimeDeliverdTime = DateTime.now();
                
                QuerySnapshot<Map<String, dynamic>> serviceOrders = await FirebaseFirestore.instance
                    .collection('serviceOrder')
                    .where('categoryName', isEqualTo: 'Cambio de Aceite')
                    .where('vehicleId',isEqualTo: widget.vehicleModel.vehicleId)
                    .orderBy('deliverdTime',descending: false)                    
                    .get();
                  
                

                for(final serviceOrder in serviceOrders.docs){
      
                  lastTimeDeliverdTime = serviceOrder.data()['deliverdTime'].toDate();
                  
                } */


                if(_serviceNameTextEditingController.text.isEmpty ||
                  _mileageTextEditingController.text.isEmpty ||
                  _dateTextEditingController.text.isEmpty
                ){
                  await Fluttertoast.showToast(
                    msg: 'Debe ingresar todos los datos del formulario',
                    toastLength: Toast.LENGTH_LONG
                  );
                  return;
                }
                if(int.parse(_mileageTextEditingController.text) <  widget.vehicleModel.mileage! ){
                  await Fluttertoast.showToast(
                    msg: 'No puede indicar un kilometraje menor al actual',
                    toastLength: Toast.LENGTH_LONG
                  );
                  return;
                }
                
                FocusScope.of(context).requestFocus(FocusNode());
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext context) => const ProgressDialog(
                        status: "Creando la nota de servicio y subiendo los adjuntos... Por favor, espere.",
                      ),
                    );
                
                final DateTime date = DateTime.parse(_dateTextEditingController.text.split('/').reversed.join('-'));

                await BackEndCarNotesService().addCarNoteService(
                  vehicleId: widget.vehicleModel.vehicleId!, 
                  serviceName: _serviceNameTextEditingController.text.trim(),
                  serviceImage: widget.noteCar["image"],
                  date: date, 
                  mileage: int.parse(_mileageTextEditingController.text.trim()),
                  comments: _commentsTextEditingController.text.trim(), 
                  attachments: attachments,
                  vehicleModel: widget.vehicleModel
                );

                if(widget.noteCar['name'] == 'Aceite con filtro'){

                  DateTime? lastTimeDeliverdTime;

                  QuerySnapshot<Map<String, dynamic>> serviceOrders = await FirebaseFirestore.instance
                    .collection('serviceOrder')
                    .where('categoryName', isEqualTo: 'Cambio de Aceite')
                    .where('vehicleId',isEqualTo: widget.vehicleModel.vehicleId)
                    .orderBy('deliverdTime',descending: false)                    
                    .get();

                  for(final serviceOrder in serviceOrders.docs){
        
                    lastTimeDeliverdTime = serviceOrder.data()['deliverdTime'].toDate();
                    
                  }

                  if(lastTimeDeliverdTime == null){

                    if(date.compareTo(widget.vehicleModel.updateDate!) > 0){
                      await vehicleService.updateFromCarNotes(
                        widget.vehicleModel.vehicleId!, 
                        widget.vehicleModel.brand!, 
                        widget.vehicleModel.model!, 
                        int.parse(_mileageTextEditingController.text.trim()), 
                        widget.vehicleModel.year!, 
                        widget.vehicleModel.color!, 
                        widget.vehicleModel.tuition!, 
                        widget.vehicleModel.name!, 
                        widget.vehicleModel.logo!, 
                        widget.vehicleModel.registrationDate!, 
                        date,
                        "motorcycle"
                      );
                    }

                  }
                  else {
                    if(date.compareTo(lastTimeDeliverdTime) > 0){
                      await vehicleService.updateFromCarNotes(
                        widget.vehicleModel.vehicleId!, 
                        widget.vehicleModel.brand!, 
                        widget.vehicleModel.model!, 
                        int.parse(_mileageTextEditingController.text.trim()), 
                        widget.vehicleModel.year!, 
                        widget.vehicleModel.color!, 
                        widget.vehicleModel.tuition!, 
                        widget.vehicleModel.name!, 
                        widget.vehicleModel.logo!, 
                        widget.vehicleModel.registrationDate!, 
                        date,
                        'motorcycle'
                      );
                    }
                  }
                  
                }

                Navigator.pop(context);
              
                Route route = MaterialPageRoute(builder: (_) => ViewCarNotes( goToHome: true));
                Navigator.pushAndRemoveUntil(context, route, (route) => false);
                
              },
            )
          ],
        
      ),

      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(size.height * 0.026),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  padding: EdgeInsets.all(size.height * 0.035),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black)
                  ),
                  child: FadeInImage(
                    placeholder: const AssetImage('assets/no-image/no-image.jpg'),
                      image: NetworkImage(widget.noteCar["image"]),
                        width: size.width * 0.22,
                        fit:BoxFit.contain
                    ),
                ),
              ),
              SizedBox(height: size.height * 0.028),
              AutoSizeText('Kilometraje Actual: ${widget.vehicleModel.mileage} km.'),
              SizedBox(height: size.height * 0.028),
              Form(
                key: _formkey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _serviceNameTextEditingController,
                      textInputType: TextInputType.text,
                      data: Icons.miscellaneous_services,
                      hintText: "Nombre del Servicio",
                      labelText: "Nombre del Servicio",
                      isObsecure: false,
                    ),
                    SizedBox(height: size.height * 0.015),
                    CustomTextField(
                      controller: _mileageTextEditingController,
                      textInputType: TextInputType.number,
                      data: Icons.add_road_sharp,
                      hintText: "Kilometraje",
                      labelText: "Kilometraje",
                      isObsecure: false,
                    ),
                    SizedBox(height: size.height * 0.015),
                    CustomTextField(
                      controller: _dateTextEditingController,
                      textInputType: TextInputType.none,
                      data: Icons.calendar_month,
                      hintText: "Fecha",
                      labelText: "Fecha",
                      isObsecure: false,
                      showCursor: false,
                      function: () async {
                        final initialDate = DateTime.now();
                        final newDate = await showDatePicker(                          
                          context: context,
                          initialDate: initialDate,
                          firstDate: DateTime(DateTime.now().year - 5),
                          lastDate: DateTime.now(),
                        );
                        if (newDate == null) return;

                        DateTime newDateSpecific = newDate.
                          add(Duration(hours: DateTime.now().hour)).
                          add(Duration(minutes:DateTime.now().minute)).
                          add(Duration(seconds: DateTime.now().second));
                        _dateTextEditingController.text = DateFormat('dd/MM/yyyy').format(newDateSpecific);
                      },
                    ),
                    SizedBox(height: size.height * 0.015),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal:16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextFormField(
                        controller: _commentsTextEditingController,
                        keyboardType: TextInputType.text,
                        maxLines: 8,
                        decoration: InputDecoration(
                          labelText: "Comentarios (Opcional)",
                          hintText: "Comentarios (Opcional)",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(size.height * 0.016),
                          ),
                          prefixIcon: Icon(
                            Icons.comment,
                            color: Theme.of(context).primaryColor,
                          )
                        ),
                        
                        
                      ),
                    ),
                    /* CustomTextField(
                      controller: _commentsTextEditingController,
                      textInputType: TextInputType.text,
                      data: Icons.comment,
                      hintText: "Comentarios (Opcional)",
                      labelText: "Comentarios (Opcional)",
                      isObsecure: false,
                      
                    ), */
                    SizedBox(height: size.height * 0.024),
                    
                    ElevatedButton(

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 3, 3, 247),
                        shape: const StadiumBorder()
                      ),
                      onPressed: () async {

                        await showModalBottomSheet(
                          context: context, 
                          builder: (context) {
                             return Wrap(
                              children:  [
                                Divider(
                                  color: Colors.black45,
                                  height: size.height * 0.021,
                                  thickness: 3,
                                  indent: MediaQuery.of(context).size.width * 0.45,
                                  endIndent: MediaQuery.of(context).size.width * 0.45,
                                ),
                                SizedBox(height: size.height * 0.008,),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.055, vertical: size.height * 0.014),
                                  child:  AutoSizeText(
                                    'Adjuntar',                    
                                    style: TextStyle(
                                      fontSize: size.height * 0.022,
                                      
                                    ),
                                  ),
                                ),
                                ListTile(
                                  leading: const Icon(Icons.camera_alt_outlined),
                                  title: const AutoSizeText('Tomar foto'),
                                  onTap: capturePhotoWithCamera,
                                ),
                                ListTile(
                                  leading: const Icon(Icons.image),
                                  title: const AutoSizeText('Seleccionar imagen'),
                                  onTap: pickPhotoFromGallery,
                                ),
                                ListTile(
                                  leading: const Icon(Icons.file_copy),
                                  title: const AutoSizeText('Seleccionar archivo'),
                                  onTap: pickPhotoFromFile
                                ),
                              ]
                             );
                          }
                        );

                      }, 
                      child: const AutoSizeText('Adjuntar Archivo')
                    ),
                    SizedBox(height: size.height * 0.024),
                    (attachments.isNotEmpty)  
                    ? 
                    Container(
                      width: size.width * 0.9,
                      height: size.height * 0.200,
                      child: Column(
                        children: [
                          AutoSizeText(
                            'Adjunto',
                            style: TextStyle(fontSize: size.height * 0.024),
                          ),
                          SizedBox(height: size.height * 0.014),
                          Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: attachments.length,
                              itemBuilder: ( _, int index) {
                                
                                return Center(
                                  
                                  child: GestureDetector(
                                    onLongPress: () {
                                      selectingAttachments = true;
                                      selectedAttachments.add(attachments[index]);
                                      setState(() {});
                                    },
                                    onTap: () async {
                                      if(selectingAttachments){
                                        if(selectedAttachments.contains(attachments[index])){
                                          selectedAttachments.remove(attachments[index]);
                                          setState(() {});
                                          return;
                                        }
                                        selectedAttachments.add(attachments[index]);
                                        setState(() {});
                                      }
                                      else{
                                        final attachmentsDeleted = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (c) =>  ViewImage(
                                              pathImage: attachments[index]
                                            )
                                          ),
                                        );

                                        if(attachmentsDeleted == null) return;

                                        attachments.remove(attachmentsDeleted);
                                        setState(() {});

                                      }
                                    },
                                    child: Container(
                                      width:(selectedAttachments.contains(attachments[index]))? size.width * 0.23:size.width * 0.28,
                                      height:(selectedAttachments.contains(attachments[index]))? size.height * 0.135:size.height * 0.145,
                                      margin:  EdgeInsets.symmetric(horizontal: size.height * 0.019),
                                      decoration: BoxDecoration(
                                        image:DecorationImage(
                                          image: FileImage(File(attachments[index].path)),
                                          fit: BoxFit.cover,
                                        )
                                      ),
                                      child:(selectedAttachments.contains(attachments[index]))
                                        ? IconButton(
                                          alignment: AlignmentDirectional.topEnd,
                                          padding: EdgeInsets.symmetric(vertical: 0),
                                          icon: Icon(
                                            Icons.cancel,
                                            color: Colors.blue,
                                            size: size.height * 0.035
                                          ),
                                          onPressed: null,
                                        ): null
                                      
                                    ),
                                    
                                  ),
                                );        
                              },
                            ),
                          )
                        ]
                      )
                    )
                    
                    :Container()
                    
                  ]
                ),
              )
              
            ],
          ),
        ),
      ),
    );

     
  }

  capturePhotoWithCamera() async {
      Navigator.pop(context);
      final imageFile = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxHeight: MediaQuery.of(context).size.height * 0.70/* 680 */,
        maxWidth: MediaQuery.of(context).size.width * 0.25/* 970 */,
      );
      if (imageFile == null) return;
      if(attachments.isNotEmpty) attachments = [];
      attachments.add(imageFile);
      setState(() {});
    }
    pickPhotoFromGallery() async {
      Navigator.pop(context);

      final imageFile = await ImagePicker().pickImage(
        source:ImageSource.gallery,
        maxHeight: MediaQuery.of(context).size.height * 0.70/* 680 */,
        maxWidth: MediaQuery.of(context).size.width * 0.25/* 970 */,
      );
      if(imageFile == null) return;
      if(attachments.isNotEmpty) attachments = [];
      attachments.add(imageFile);
      setState(() {});

      /* final imagesFiles = await ImagePicker().pickMultiImage(
        
        maxHeight: 680,
        maxWidth: 970,
      );
      if (imagesFiles.isEmpty) return;
      
      for(final imageFile in imagesFiles) {
        attachments.add(imageFile);
      }
      
      setState(() {}); */
    }

    pickPhotoFromFile() async {
      Navigator.pop(context);
      

      final imageFile = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.image
      );
      if(imageFile == null) return;
      if(attachments.isNotEmpty) attachments = [];
      
      
      
      attachments.add(imageFile.files.single);
      setState(() {});


      
      /* final imagesFiles = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,

      );
      if (imagesFiles == null) return;
      
      for(final imageFile in imagesFiles.files){
        attachments.add(imageFile);
      }
      setState(() {}); */
    }



    Future<bool> _onBackPressed(String msg) async {
    return await showDialog(
          context: context,
          builder: (context) =>  AlertDialog(
            title:  Text('Estas seguro?'),
            content:  Container(
              height: MediaQuery.of(context).size.height * 0.04,
              width: MediaQuery.of(context).size.width * 0.3,
              child: Text(msg)
            ),
            actions: <Widget>[
               GestureDetector(
                onTap: () => Navigator.of(context).pop(true),
                child: Padding(
                  padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.010),
                  child: Text("YES"),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.019),
               GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
                child: Padding(
                  padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.010),
                  child: Text("NO"),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.019),
            ],
          ),
        ) ??
        false;
  }

}