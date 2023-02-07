import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:oilapp/Model/vehicle_model.dart';
import 'package:oilapp/Screens/Vehicles/add_brand.dart';
import 'package:oilapp/Screens/Vehicles/add_color.dart';
import 'package:oilapp/Screens/Vehicles/add_model.dart';
import 'package:oilapp/Screens/Vehicles/add_year.dart';
import 'package:oilapp/Screens/Vehicles/vehicles.dart';
import 'package:oilapp/config/config.dart';
import 'package:oilapp/service/vehicle_service.dart';
import 'package:oilapp/widgets/loading_widget.dart';

import '../../widgets/erroralertdialog.dart';

class EditVehicleScreen extends StatefulWidget {

  final VehicleModel? vehicleModel;

  const EditVehicleScreen({super.key, this.vehicleModel});

  @override
  State<EditVehicleScreen> createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends State<EditVehicleScreen> {

 

  void changeIndex(int index) {
   setState(() => selectedIndex = index);
  }
  
  final VehicleService vehicleService = VehicleService();
  GlobalKey<FormState> _vehicleformkey = GlobalKey<FormState>();

  TextEditingController brandController = TextEditingController();
  TextEditingController modelController = TextEditingController();
  TextEditingController yearController = TextEditingController();
  TextEditingController colorController = TextEditingController();
  TextEditingController mileageController = TextEditingController();
  TextEditingController tuitionController = TextEditingController();
  TextEditingController nameOwnerController = TextEditingController();

  TextEditingController registrationDateController = TextEditingController();
  int selectedIndex = 0;
  int? idBrand;
  String? logoBrand;
  int? indexBrandController;
  int? indexModelController;
  int? indexYearController;
  int? indexColorController;

   @override
  void initState() {

    super.initState();
    brandController.text = widget.vehicleModel!.brand!;
    modelController.text = widget.vehicleModel!.model!;
    yearController.text = widget.vehicleModel!.year.toString();
    colorController.text = widget.vehicleModel!.color.toString();
    mileageController.text = widget.vehicleModel!.mileage.toString();
    tuitionController.text = widget.vehicleModel!.tuition!;
    nameOwnerController.text = widget.vehicleModel!.name!;
    logoBrand = widget.vehicleModel!.logo;
    
    Future.delayed(Duration.zero, () async {
      
      await getIndexBrand();
      await getIndexModel();
      await getIndexYear();
      setState((){});
      
    },);
    
    
    
  }
  
  
  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        
        title:  Text(
          "Editar Vehiculo",
          style: TextStyle(
            fontSize: size.height * 0.024,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
            fontFamily: "Brand-Regular",
          ),
        ),
        centerTitle: true,
      ),
      body: 
      
      (indexBrandController == null && indexModelController == null && indexYearController == null)
      ? circularProgress()
      : SingleChildScrollView(
        child: Column(
          children: [
            Container(
              child: Form(
                key: _vehicleformkey,
                child: Padding(
                  padding: EdgeInsets.only(left: size.width * 0.1, top: size.height * 0.035, right: size.width * 0.1),
                  child: Column(
                    children: [
                      Image.network(
                        logoBrand!, 
                        height: size.height * 0.124,
                        width: double.infinity,
                        fit: BoxFit.scaleDown,
                      ),
                      SizedBox(height: size.height * 0.016),
                      Padding(
                        padding: EdgeInsets.all(size.height * 0.016),
                        child: GestureDetector(
                          onTap: () {
                            if(indexBrandController != null){
                              addBrand();
                            }
                          },
                          child: Row(
                            children: [
                              const Text('* Marca'),
                              const Expanded(child: SizedBox(width: double.infinity,)),
                              Text((brandController.text.isEmpty? 'Seleccione la Marca': brandController.text))
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.016),
                      Padding(
                        padding: EdgeInsets.all(size.height * 0.016),
                        child: GestureDetector(
                          onTap: () {
                            /* if(indexModelController != null) { */
                              addModel();
                            /* } */
                          },
                          child: Row(
                            children: [
                              const Text('* Modelo'),
                              const Expanded(child: SizedBox(width: double.infinity,)),
                              Text((modelController.text.isEmpty? 'Seleccione el Modelo': modelController.text))
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.016),
                      Padding(
                        padding: EdgeInsets.all(size.height * 0.016),
                        child: GestureDetector(
                          onTap: () {
                            if(indexYearController != null) {
                              addYear();
                            }
                          },
                          child: Row(
                            children: [
                              const Text('* Año'),
                              const Expanded(child: SizedBox(width: double.infinity,)),
                              Text((yearController.text.isEmpty? 'Selecciona el año': yearController.text))
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.016),
                      Padding(
                        padding: EdgeInsets.all(size.height * 0.016),
                        child: GestureDetector(
                          onTap: addColor,
                          child: Row(
                            children: [
                              const Text('* Color'),
                              const Expanded(child: SizedBox(width: double.infinity,)),
                              (colorController.text.isEmpty) 
                                ? const Text('Seleccione el color')
                                : Container(height: size.height * 0.024,width: size.width * 0.15,color:Color(int.parse(colorController.text)))
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.016),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: mileageController,
                          decoration: const InputDecoration(
                            hintText: "Editar Kilometraje",
                            labelText: "Kilometraje:"
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.016),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: TextFormField(
                          controller: tuitionController,
                          decoration: const InputDecoration(
                            hintText: "Editar Matricula (Opcional)",
                            labelText: "Matricula:"
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.016),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: TextFormField(
                          controller: nameOwnerController,
                          decoration: const InputDecoration(
                            hintText: "Editar Nombre (Opcional)",
                            labelText: "Nombre del vehiculo:"
                          ),
                        ),
                      ),
                  ]),
                ),
              )
      
            ),
            /* const Expanded(child: SizedBox(height: double.infinity,)), */
            SizedBox(height: size.height * 0.056,),
            Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: size.height * 0.036,
              child: ElevatedButton(
                onPressed: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  if(brandController.text.isNotEmpty && modelController.text.isNotEmpty &&
                     yearController.text.isNotEmpty && colorController.text.isNotEmpty &&
                     mileageController.text.isNotEmpty
                  ){
                    bool confirm = await _confirm('De que quiere actualizar el vehiculo');

                    if(!confirm) return;

                    bool canUpdate = await vehicleService.updateVehicle(
                      widget.vehicleModel!.vehicleId!, 
                      brandController.text, 
                      modelController.text, 
                      int.parse(mileageController.text), 
                      int.parse(yearController.text), 
                      int.parse(colorController.text), 
                      tuitionController.text, 
                      nameOwnerController.text, 
                      logoBrand, 
                      widget.vehicleModel!.registrationDate!,
                      widget.vehicleModel!.updateDate!
                    );
                    if(!canUpdate) return;

                    Fluttertoast.showToast(msg: 'Vehiculo editado exitosamente');
                    if(!mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context, 
                      MaterialPageRoute(
                        builder: (c) => const Vehicles(),
                      ), 
                      (route) => false
                    );
                    
      
                  }
      
                  else {
                    showDialog(
                    context: context,
                    builder: (c) {
                      return const ErrorAlertDialog(
                        message: "Por favor ingrese toda la información solicitada.",
                      );
                    },
                  );
                  }
      
                },
                style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    backgroundColor: Color.fromARGB(255, 3, 3, 247),
                  ),
                child: const Text(
                  'Editar vehiculos',
                  
                )
              ),
            ),
            SizedBox(height: size.height * 0.014,),
            Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: size.height * 0.034,
              child: ElevatedButton(
                onPressed: () async {
                  bool confirm = await _confirm('De que quiere eliminar el vehiculo');

                  if(!confirm) return;
                  bool canDelete = await vehicleService.deleteVehicle(widget.vehicleModel!.vehicleId!);

                  if(!canDelete) return;
                    
      
                  Fluttertoast.showToast(msg: 'Vehiculo eliminado exitosamente');
                  if(!mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context, 
                    MaterialPageRoute(
                      builder: (c) => const Vehicles(),
                    ), 
                    (route) => false
                  );
                },
                child: const Text('Eliminar vehiculo'),
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  backgroundColor: Color.fromARGB(255, 3, 3, 247),
                ),
              )
            ),
            SizedBox(height: size.height * 0.014,),
          ],
        ),
      ),
    );
  }

  void addBrand() async {
    final alert = (indexBrandController == null && brandController.text == '' && idBrand == null && logoBrand == null) ? AddBrand():AddBrand(selectedIndex:indexBrandController, brandName: brandController.text, brandId: idBrand, logoBrand:logoBrand,);
    
    final returnDataBrand = await showDialog(context: context, barrierDismissible: false, builder: (_) => alert);
    final indexBrand = (returnDataBrand[0] == '')? '' : returnDataBrand[0];
    final brandName = (returnDataBrand[1] == null)? '' : returnDataBrand[1];
    final idBrandReturned = (returnDataBrand[2] == null)? '' : returnDataBrand[2];
    final logoBrandReturned = (returnDataBrand[3] == null)? '' : returnDataBrand[3];
    final confirmChanges = returnDataBrand[4];
    if(indexBrand != '' && brandName != '' && idBrandReturned != '' && logoBrandReturned != ''){
      indexBrandController = indexBrand;
      brandController.text = brandName;
      idBrand = idBrandReturned;
      logoBrand = logoBrandReturned;
      if(confirmChanges){ 
        modelController.text = '';
        indexModelController = null;
      }
      
      
      setState(() {});
    }
    
    
    
  }

  void addModel() async {

    
    if(idBrand == null) return;
    final alert = (indexModelController == null && modelController.text == '') ? AddModel(brandId: idBrand):AddModel(selectedIndex:indexModelController, modelName: modelController.text, brandId: idBrand);
    
    final returnDataModel = await showDialog(context: context, barrierDismissible: false, builder: (_) => alert);
    final indexModel = (returnDataModel[0] == '')? '' : returnDataModel[0];
    final ModelName = (returnDataModel[1] == null)? '' : returnDataModel[1];
    if(indexModel != '' && ModelName != ''){
      indexModelController = indexModel;
      modelController.text = ModelName;
      setState(() {});
    }
    
    
  }

  void addYear() async {

    
    final alert = (indexYearController == null && yearController.text == '') ? AddYear():AddYear(selectedIndex:indexYearController, year: int.parse(yearController.text));
    
    final returnDataYear = await showDialog(context: context, barrierDismissible: false, builder: (_) => alert);
    final indexYear = (returnDataYear[0] == '')? '' : returnDataYear[0];
    final year = (returnDataYear[1] == null)? '' : returnDataYear[1];
    if(indexYear != '' && year != ''){
      indexYearController = indexYear;
      yearController.text = year.toString();
      setState(() {});
    }
    
    
  }

  void addColor() async {

    final alert = (colorController.text.isEmpty)?AddColor():AddColor(pickerColor: Color(int.parse(colorController.text)));
    
    final colorCode = await showDialog(context: context, builder: (_) => alert);

    if(colorCode != null) {
      colorController.text = colorCode.toString();

      setState(() {});

    }
  }

  Future<bool> _confirm(String msg) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Estas seguro?'),
            content: Text(msg),
            actions: <Widget>[
              GestureDetector(
                onTap: () => Navigator.of(context).pop(true),
                child: Text("YES"),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.021),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
                child: Text("NO"),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.021),
            ],
          ),
        ) ??
        false;
    }


    getIdBrand() async {
      final modelByName = await AutoParts.firestore!
        .collection('modelsVehicle')
        .where('name', isEqualTo: widget.vehicleModel!.model).get();
      final docModel = modelByName.docs;
      for(final doc in docModel){
        idBrand = doc.data()['id_brand'];
      }
    }

    Future <int> getIndexBrand() async {
      QuerySnapshot<Map<String, dynamic>> brandsVehicles = await AutoParts.firestore!
        .collection(AutoParts.brandsVehicle)
        .get();
      int index = 0;
      for(final brandsVehicle in brandsVehicles.docs){
        
        if(widget.vehicleModel!.brand == brandsVehicle.data()['name']){
          break;
        }
        index++;
      }
      indexBrandController = index;
      setState(() {});
      return index;

    }

    Future <int> getIndexModel() async {

      final brand = await AutoParts.firestore!
        .collection('brandsVehicle')
        .where('name', isEqualTo: widget.vehicleModel!.brand).get();

      QuerySnapshot<Map<String, dynamic>> modelsVehicles = await AutoParts.firestore!
        .collection(AutoParts.modelsVehicle)
        .where('id_brand', isEqualTo: brand.docs[0].data()['id'])
        .get();
      int index = 0;
      idBrand = brand.docs[0].data()['id'];
      
      for(final modelsVehicle in modelsVehicles.docs){
        
        if(widget.vehicleModel!.model == modelsVehicle.data()['name'].toString()){
          
          break;
        }
        index++;
      }
      indexModelController = index;
      setState(() {});
      return index;


    }

    Future <int> getIndexYear() async {

      QuerySnapshot<Map<String, dynamic>> yearsVehicles = await AutoParts.firestore!
        .collection(AutoParts.yearsVehicle)
        .orderBy('year',descending: true)
        .get();
      int index = 0;
      for(final yearsVehicle in yearsVehicles.docs){
        
        if(widget.vehicleModel!.year == yearsVehicle.data()['year']){
          break;
        }
        index++;
      }
      indexYearController = index;
      setState(() {});
      return index;


    }
  

  

}