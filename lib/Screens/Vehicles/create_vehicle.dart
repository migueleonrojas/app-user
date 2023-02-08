import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:oilapp/Screens/Vehicles/add_brand.dart';
import 'package:oilapp/Screens/Vehicles/add_color.dart';
import 'package:oilapp/Screens/Vehicles/add_model.dart';
import 'package:oilapp/Screens/Vehicles/add_year.dart';
import 'package:oilapp/Screens/Vehicles/vehicles.dart';
import 'package:oilapp/config/config.dart';
import 'package:oilapp/service/vehicle_service.dart';

import '../../widgets/erroralertdialog.dart';
enum DateOfLastOilChangeService { OneMonth, TwoMonth, ThreeMonth, MoreThreeMonth }
class CreateVehicleScreen extends StatefulWidget {
  const CreateVehicleScreen({super.key});

  @override
  State<CreateVehicleScreen> createState() => _CreateVehicleScreenState();
}

class _CreateVehicleScreenState extends State<CreateVehicleScreen> {

  void changeIndex(int index) {
   setState(() => selectedIndex = index);
  }
  
  DateOfLastOilChangeService? dateOfLastOilChangeService;
  
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
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        
        title: AutoSizeText(
          "Agregar Vehiculo",
          style: TextStyle(
            fontSize: size.height * 0.024,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
            fontFamily: "Brand-Regular",
            
          ),
        ),
        centerTitle: true,
        
      ),
      bottomNavigationBar: Container(
        width: MediaQuery.of(context).size.width,
        height: size.height * 0.058,
        child: ElevatedButton(
          onPressed: () async {
            FocusScope.of(context).requestFocus(FocusNode());
            if(brandController.text.isNotEmpty && modelController.text.isNotEmpty &&
               yearController.text.isNotEmpty && colorController.text.isNotEmpty &&
              mileageController.text.isNotEmpty && dateOfLastOilChangeService != null
            ){
              VehicleService vehicleService = VehicleService();
                    
              DateTime date = generateUpdateDateValue(dateOfLastOilChangeService!);
                  
              vehicleService.addVehicle(
                brandController.text, 
                modelController.text, 
                int.parse(mileageController.text), 
                int.parse(yearController.text), 
                int.parse(colorController.text), 
                tuitionController.text,
                nameOwnerController.text,
                logoBrand,
                date
              );

              Fluttertoast.showToast(msg: 'Vehiculo agregado exitosamente');
                    
              setState(() {
                selectedIndex = 0;
                idBrand = null;
                logoBrand = null;
                indexBrandController = null;
                indexModelController = null;
                indexYearController = null;
                indexColorController = null;
                brandController.text = '';
                modelController.text = '';
                yearController.text = '';
                colorController.text = '';
                tuitionController.text = '';
                nameOwnerController.text = '';
                mileageController.text = '';
              });

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
          child: const AutoSizeText('Agregar vehiculo')
        ),
      ),
      body: SingleChildScrollView(

        child: Column(
          children: [
            Container(
              child: Form(
                key: _vehicleformkey,
                child: Padding(
                  padding: EdgeInsets.only(left: size.width * 0.06, top: 30, right: size.width * 0.06),
                  child: Column(
                    children: [
                      Padding(
                        padding:  EdgeInsets.all(size.height * 0.010),
                        child: GestureDetector(
                          onTap:addBrand,
                          child: Row(
                            children: [
                              const AutoSizeText('* Marca'),
                              const Expanded(child: SizedBox(width: double.infinity,)),
                              AutoSizeText((brandController.text.isEmpty? 'Seleccione la Marca': brandController.text))
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.010),
                      Padding(
                        padding: EdgeInsets.all(size.height * 0.010),
                        child: GestureDetector(
                          onTap:addModel,
                          child: Row(
                            children: [
                              const AutoSizeText('* Modelo'),
                              const Expanded(child: SizedBox(width: double.infinity,)),
                              AutoSizeText((modelController.text.isEmpty? 'Seleccione el Modelo': modelController.text))
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.010),
                      Padding(
                        padding: EdgeInsets.all(size.height * 0.010),
                        child: GestureDetector(
                          onTap:addYear,
                          child: Row(
                            children: [
                              const AutoSizeText('* Año'),
                              const Expanded(child: SizedBox(width: double.infinity,)),
                              AutoSizeText((yearController.text.isEmpty? 'Seleccion el año': yearController.text))
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.010),
                      Padding(
                        padding: EdgeInsets.all(size.height * 0.010),
                        child: GestureDetector(
                          onTap: addColor,
                          child: Row(
                            children: [
                              const AutoSizeText('* Color'),
                              const Expanded(child: SizedBox(width: double.infinity,)),
                              (colorController.text.isEmpty) 
                                ? const AutoSizeText('Seleccione el color')
                                : Container(height: size.height * 0.027,width: size.width * 0.15,color:Color(int.parse(colorController.text)))
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.010),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        controller: mileageController,
                        decoration: const InputDecoration(
                          hintText: "Agregar Kilometraje",
                        ),
                      ),
                      SizedBox(height: size.height * 0.010),
                      TextFormField(
                        controller: tuitionController,
                        decoration: const InputDecoration(
                          hintText: "Agregar Matricula (Opcional)",
                        ),
                      ),
                      SizedBox(height: size.height * 0.010),
                      TextFormField(
                        controller: nameOwnerController,
                        decoration: const InputDecoration(
                          hintText: "Agregar Nombre (Opcional)",
                        ),
                      ),
                  ]),
                ),
              )
      
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.02, vertical: size.height * 0.025),
              width: MediaQuery.of(context).size.width * 0.90,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AutoSizeText(
                    '¿Cuando fue el ultimo cambio de aceite a tu vehiculo${brandController.text.isEmpty?'': ' '+ brandController.text}${modelController.text.isEmpty?'':' ' + modelController.text}${yearController.text.isEmpty?'':' ' + yearController.text}?',
                    style:  TextStyle(
                      fontSize: size.height * 0.023
                    ),    
                  ),
      
                  ListTile(
                    title: const AutoSizeText('Hace 1 mes'),
                    leading: Radio(
                      groupValue: dateOfLastOilChangeService,
                      value: DateOfLastOilChangeService.OneMonth,
                      onChanged: (DateOfLastOilChangeService? value) {
                        dateOfLastOilChangeService = value!;
                        setState(() {});
                      },
                    )
                  ),
                  ListTile(
                    title: const AutoSizeText('Hace 2 meses'),
                    leading: Radio(
                      groupValue: dateOfLastOilChangeService,
                      value: DateOfLastOilChangeService.TwoMonth,
                      onChanged: (DateOfLastOilChangeService? value) {
                        dateOfLastOilChangeService = value!;
                        setState(() {});
                      },
                    )
                  ),
                  ListTile(
                    title: const AutoSizeText('Hace 3 meses'),
                    leading: Radio(
                      groupValue: dateOfLastOilChangeService,
                      value: DateOfLastOilChangeService.ThreeMonth,
                      onChanged: (DateOfLastOilChangeService? value) {
                        dateOfLastOilChangeService = value!;
                        setState(() {});
                      },
                    )
                  ),
                  ListTile(
                    title: const AutoSizeText('No lo recuerdo'),
                    leading: Radio(
                      groupValue: dateOfLastOilChangeService,
                      value: DateOfLastOilChangeService.MoreThreeMonth,
                      onChanged: (DateOfLastOilChangeService? value) {
                        dateOfLastOilChangeService = value!;
                        setState(() {});
                      },
                    )
                  ),
                ],
              ),
            ),
            /* const Expanded(child: SizedBox(height: double.infinity,)), */
            /* Boton de agregar */
            /* Container(
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  if(brandController.text.isNotEmpty && modelController.text.isNotEmpty &&
                     yearController.text.isNotEmpty && colorController.text.isNotEmpty &&
                     mileageController.text.isNotEmpty && dateOfLastOilChangeService != null
                  ){
                    VehicleService vehicleService = VehicleService();

                    

                    DateTime date = generateUpdateDateValue(dateOfLastOilChangeService!);
                  
                    vehicleService.addVehicle(
                      brandController.text, 
                      modelController.text, 
                      int.parse(mileageController.text), 
                      int.parse(yearController.text), 
                      int.parse(colorController.text), 
                      tuitionController.text,
                      nameOwnerController.text,
                      logoBrand,
                      date
                    );
                    Fluttertoast.showToast(msg: 'Vehiculo agregado exitosamente');
                    
                    setState(() {
                      selectedIndex = 0;
                      idBrand = null;
                      logoBrand = null;
                      indexBrandController = null;
                      indexModelController = null;
                      indexYearController = null;
                      indexColorController = null;
                      brandController.text = '';
                      modelController.text = '';
                      yearController.text = '';
                      colorController.text = '';
                      tuitionController.text = '';
                      nameOwnerController.text = '';
                      mileageController.text = '';
                    });
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
                child: const AutoSizeText('Agregar vehiculo')
              ),
            ) */
          ],
        ),
      ),
    );
  }

  void addBrand() async {
    final alert = (indexBrandController == null && brandController.text == '' && idBrand == null && logoBrand == null) ? AddBrand():AddBrand(selectedIndex:indexBrandController, brandName: brandController.text, brandId: idBrand, logoBrand:logoBrand);
    
    final returnDataBrand = await showDialog(context: context, barrierDismissible: false, builder: (_) => alert);
    final indexBrand = (returnDataBrand[0] == '')? '' : returnDataBrand[0];
    final brandName = (returnDataBrand[1] == null)? '' : returnDataBrand[1];
    final idBrandReturned = (returnDataBrand[2] == null)? '' : returnDataBrand[2];
    final logoBrandReturned = (returnDataBrand[3] == null)? '' : returnDataBrand[3];
    final confirmChanges = returnDataBrand[4];
    if(indexBrand != '' && brandName != '' && idBrandReturned != ''){
      indexBrandController = indexBrand;
      brandController.text = brandName;
      idBrand = idBrandReturned;
      logoBrand = logoBrandReturned;
      if(confirmChanges) modelController.text = '';
      indexModelController = null;
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
      modelController.text = ModelName.toString();
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

  DateTime generateUpdateDateValue(DateOfLastOilChangeService dateOfLastOilChangeService){

    DateTime date = DateTime.now();
    int microsecondsSinceEpochLastService = 0;

    if(dateOfLastOilChangeService == DateOfLastOilChangeService.OneMonth){
      microsecondsSinceEpochLastService = 1000000 * 60 * 60 * 24 * 30;

      int microsecondsDateLastService = date.microsecondsSinceEpoch - microsecondsSinceEpochLastService;

      DateTime dateLastService = DateTime.fromMicrosecondsSinceEpoch(microsecondsDateLastService);
     
      date = dateLastService;

    }
    else if(dateOfLastOilChangeService == DateOfLastOilChangeService.TwoMonth){
      microsecondsSinceEpochLastService = 1000000 * 60 * 60 * 24 * 60;

      int microsecondsDateLastService = date.microsecondsSinceEpoch - microsecondsSinceEpochLastService;

      DateTime dateLastService = DateTime.fromMicrosecondsSinceEpoch(microsecondsDateLastService);
     
      date = dateLastService;

    }

    else if(dateOfLastOilChangeService == DateOfLastOilChangeService.ThreeMonth){
      microsecondsSinceEpochLastService = 1000000 * 60 * 60 * 24 * 90;

      int microsecondsDateLastService = date.microsecondsSinceEpoch - microsecondsSinceEpochLastService;

      DateTime dateLastService = DateTime.fromMicrosecondsSinceEpoch(microsecondsDateLastService);
     
      date = dateLastService;

    }

    else if(dateOfLastOilChangeService == DateOfLastOilChangeService.MoreThreeMonth){
      microsecondsSinceEpochLastService = 1000000 * 60 * 60 * 24 * 83;

      int microsecondsDateLastService = date.microsecondsSinceEpoch - microsecondsSinceEpochLastService;

      DateTime dateLastService = DateTime.fromMicrosecondsSinceEpoch(microsecondsDateLastService);
     
      date = dateLastService;

    }

    

    return date;

  }

}