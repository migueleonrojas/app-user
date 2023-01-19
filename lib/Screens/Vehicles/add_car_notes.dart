import 'dart:io';

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
import 'package:oilapp/widgets/customTextField.dart';
import 'package:file_picker/file_picker.dart';
import 'package:oilapp/widgets/progressdialog.dart';
class AddCarNote extends StatefulWidget {

  final Map<String,dynamic> noteCar;
  final VehicleModel vehicleModel;
  const AddCarNote({super.key, required this.noteCar, required this.vehicleModel});

  @override
  State<AddCarNote> createState() => _AddCarNoteState();
}

class _AddCarNoteState extends State<AddCarNote> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final _serviceNameTextEditingController = TextEditingController();
  final _mileageTextEditingController = TextEditingController();
  final _dateTextEditingController = TextEditingController();
  final _commentsTextEditingController = TextEditingController();


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
    
    return Scaffold(
      
      appBar: AppBar(
        title:  Text(
          (!selectingAttachments)?"Agregar Servicio":"Selecionado: ${selectedAttachments.length}",
          style: const TextStyle(
            fontSize: 20,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
            fontFamily: "Brand-Regular",
          ),
        ),
        
        centerTitle: true,
        leading: (selectingAttachments)
          ? IconButton(
              icon: Icon(Icons.disabled_by_default_outlined),
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

                Navigator.pop(context);
              
                Route route = MaterialPageRoute(builder: (_) => ViewCarNotes( goToHome: true));
                Navigator.pushAndRemoveUntil(context, route, (route) => false);
                
              },
            )
          ],
        
      ),

      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black)
                  ),
                  child: FadeInImage(
                    placeholder: const AssetImage('assets/no-image/no-image.jpg'),
                      image: NetworkImage(widget.noteCar["image"]),
                        width: 70,
                        fit:BoxFit.contain
                    ),
                ),
              ),
              const SizedBox(height: 25),
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
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: _mileageTextEditingController,
                      textInputType: TextInputType.number,
                      data: Icons.add_road_sharp,
                      hintText: "Kilometraje",
                      labelText: "Kilometraje",
                      isObsecure: false,
                    ),
                    const SizedBox(height: 10),
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
                          lastDate: DateTime(DateTime.now().year + 5),
                        );
                        if (newDate == null) return;
                        _dateTextEditingController.text = DateFormat('dd/MM/yyyy').format(newDate);
                      },
                    ),
                    const SizedBox(height: 10),
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
                            borderRadius: BorderRadius.circular(8.0),
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
                    const SizedBox(height: 20),
                    
                    ElevatedButton(
                      onPressed: () async {

                        await showModalBottomSheet(
                          context: context, 
                          builder: (context) {
                             return Wrap(
                              children:  [
                                Divider(
                                  color: Colors.black45,
                                  height: 15,
                                  thickness: 3,
                                  indent: MediaQuery.of(context).size.width * 0.45,
                                  endIndent: MediaQuery.of(context).size.width * 0.45,
                                ),
                                const SizedBox(height: 5,),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  child:  Text(
                                    'Adjuntar',                    
                                    style: TextStyle(
                                      fontSize: 18,
                                      
                                    ),
                                  ),
                                ),
                                ListTile(
                                  leading: const Icon(Icons.camera_alt_outlined),
                                  title: const Text('Tomar foto'),
                                  onTap: capturePhotoWithCamera,
                                ),
                                ListTile(
                                  leading: const Icon(Icons.image),
                                  title: const Text('Seleccionar imagen'),
                                  onTap: pickPhotoFromGallery,
                                ),
                                ListTile(
                                  leading: const Icon(Icons.file_copy),
                                  title: const Text('Seleccionar archivo'),
                                  onTap: pickPhotoFromFile
                                ),
                              ]
                             );
                          }
                        );

                      }, 
                      child: const Text('Adjuntar Archivo')
                    ),
                    const SizedBox(height: 20),
                    (attachments.isNotEmpty)  
                    ? 
                    Container(
                      width: 300,
                      height: 180,
                      child: Column(
                        children: [
                          const Text(
                            'Adjunto',
                            style: TextStyle(fontSize: 20),
                          ),
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
                                      width:(selectedAttachments.contains(attachments[index]))? 80:100,
                                      height:(selectedAttachments.contains(attachments[index]))? 120:140,
                                      margin: const EdgeInsets.symmetric(horizontal: 15),
                                      decoration: BoxDecoration(
                                        image:DecorationImage(
                                          image: FileImage(File(attachments[index].path)),
                                          fit: BoxFit.cover,
                                        )
                                      ),
                                      child:(selectedAttachments.contains(attachments[index]))
                                        ? const IconButton(
                                          alignment: AlignmentDirectional.topEnd,
                                          padding: EdgeInsets.symmetric(vertical: 0),
                                          icon: Icon(
                                            Icons.cancel,
                                            color: Colors.blue,
                                            size: 30
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
        maxHeight: 680,
        maxWidth: 970,
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
        maxHeight: 680,
        maxWidth: 970
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
            content:  Text(msg),
            actions: <Widget>[
               GestureDetector(
                onTap: () => Navigator.of(context).pop(true),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("YES"),
                ),
              ),
              const SizedBox(height: 16),
               GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("NO"),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ) ??
        false;
  }

}