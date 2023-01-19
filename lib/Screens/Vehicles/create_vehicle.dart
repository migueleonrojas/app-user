import 'dart:math';
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

class CreateVehicleScreen extends StatefulWidget {
  const CreateVehicleScreen({super.key});

  @override
  State<CreateVehicleScreen> createState() => _CreateVehicleScreenState();
}

class _CreateVehicleScreenState extends State<CreateVehicleScreen> {

  void changeIndex(int index) {
   setState(() => selectedIndex = index);
  }
  
  
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
    return Scaffold(
      appBar: AppBar(
        
        title: const Text(
          "Agregar Vehiculo",
          style: TextStyle(
            fontSize: 20,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
            fontFamily: "Brand-Regular",
            
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            child: Form(
              key: _vehicleformkey,
              child: Padding(
                padding: const EdgeInsets.only(left: 30, top: 30, right: 30),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: GestureDetector(
                        onTap:addBrand,
                        child: Row(
                          children: [
                            const Text('* Marca'),
                            const Expanded(child: SizedBox(width: double.infinity,)),
                            Text((brandController.text.isEmpty? 'Seleccione la Marca': brandController.text))
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: GestureDetector(
                        onTap:addModel,
                        child: Row(
                          children: [
                            const Text('* Modelo'),
                            const Expanded(child: SizedBox(width: double.infinity,)),
                            Text((modelController.text.isEmpty? 'Seleccione el Modelo': modelController.text))
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: GestureDetector(
                        onTap:addYear,
                        child: Row(
                          children: [
                            const Text('* Año'),
                            const Expanded(child: SizedBox(width: double.infinity,)),
                            Text((yearController.text.isEmpty? 'Seleccion el año': yearController.text))
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: GestureDetector(
                        onTap: addColor,
                        child: Row(
                          children: [
                            const Text('* Color'),
                            const Expanded(child: SizedBox(width: double.infinity,)),
                            (colorController.text.isEmpty) 
                              ? const Text('Seleccione el color')
                              : Container(height: 20,width: 60,color:Color(int.parse(colorController.text)))
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: mileageController,
                      decoration: const InputDecoration(
                        hintText: "Agregar Kilometraje",
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: tuitionController,
                      decoration: const InputDecoration(
                        hintText: "Agregar Matricula (Opcional)",
                      ),
                    ),
                    const SizedBox(height: 10),
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
          const Expanded(child: SizedBox(height: double.infinity,)),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                FocusScope.of(context).requestFocus(FocusNode());
                if(brandController.text.isNotEmpty && modelController.text.isNotEmpty &&
                   yearController.text.isNotEmpty && colorController.text.isNotEmpty &&
                   mileageController.text.isNotEmpty
                ){
                  VehicleService vehicleService = VehicleService();
                
                  vehicleService.addVehicle(
                    brandController.text, 
                    modelController.text, 
                    int.parse(mileageController.text), 
                    int.parse(yearController.text), 
                    int.parse(colorController.text), 
                    tuitionController.text,
                    nameOwnerController.text,
                    logoBrand,
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
              child: const Text('Agregar vehiculo')
            ),
          )
        ],
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

  /* void addColorSelectedCarrusel() async {

    
    final alert = (indexColorController == null && colorController.text == '') ? AddColor():AddColor(selectedIndex:indexColorController, color: int.parse(colorController.text));
    
    final returnColor = await showDialog(context: context, barrierDismissible: false, builder: (_) => alert);
    final indexColor = (returnColor[0] == '')? '' : returnColor[0];
    final color = (returnColor[1] == null)? '' : returnColor[1];
    if(indexColor != '' && color != ''){
      indexColorController = indexColor;
      colorController.text = color.toString();
      setState(() {});
    }
    
    
  } */

  

}