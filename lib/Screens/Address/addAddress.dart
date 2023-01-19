import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

import 'package:oilapp/service/address_service.dart';
import 'package:oilapp/widgets/erroralertdialog.dart';
import 'package:oilapp/widgets/mytextFormfield.dart';
import 'package:oilapp/widgets/noInternetConnectionAlertDialog.dart';
import 'package:oilapp/widgets/simpleAppbar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:async';
class AddAddress extends StatefulWidget {

  @override
  State<AddAddress> createState() => _AddAddressState();
}

class _AddAddressState extends State<AddAddress> {

  AppBar appBar = simpleAppBar(false, "Agregar Dirección");

  
  PageController _controllerPage = PageController(initialPage: 0, keepPage: true);

  CameraPosition cameraPosition = const CameraPosition(
    target: LatLng(10.48,-66.87),
    zoom: 12
  );

  GoogleMapController? _controller;
  
  final Set<Marker> _markers = {};

  final formkey = GlobalKey<FormState>();

  final scaffoldkey = GlobalKey<ScaffoldState>();

  final cName = TextEditingController();

  final cPhoneNumber = TextEditingController();

  final cHouseandRoadNumber = TextEditingController();

  final cCity = TextEditingController();

  final cArea = TextEditingController();

  final cAreaCode = TextEditingController();

  final AddressService _addressService = AddressService();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: addAddressBody(context),
      
    );
  }

   addAddressBody(BuildContext context) {

    return PageView(
      physics: NeverScrollableScrollPhysics(),
      onPageChanged: (value) async {
        if(_markers.isEmpty) {
          if(value == 1) {
            await _controllerPage.animateToPage(0, duration: const Duration(seconds: 1), curve: Curves.linear);
            Fluttertoast.showToast(msg:"Debe marcar su ubicación en el mapa");
          }
          
        }
      },
      controller: _controllerPage,
      scrollDirection: Axis.vertical,
      children: [
        Column(
          children: [
            const SizedBox(height: 25,),
            Center(
              child: Text(
                "Marque su ubicación".toUpperCase(),
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: "Brand-Bold",
                  letterSpacing: 1.5,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 25,),
            Container(
              height: MediaQuery.of(context).size.height * 0.55,
              child: GoogleMap(
                initialCameraPosition: cameraPosition,
                onMapCreated: ((controller) {
                  _controller = controller;
                  setState(() {});
                }),
                markers: _markers,
                onTap: (latlang) async {
                  cameraPosition = CameraPosition(
                    target: LatLng(latlang.latitude, latlang.longitude),
                    zoom: 18
                  );

                  await _controller!.animateCamera(
                    CameraUpdate.newCameraPosition(cameraPosition),
                  );

                  if (_markers.length >= 1){
                    _markers.clear();
                  }
                  _markers.add(
                    Marker(
                      markerId: const MarkerId('pin'),
                      position: latlang,
                      icon: BitmapDescriptor.defaultMarker,
                    )
                  );
                        
                  setState(() {});
                }
              ),
            ),
            const SizedBox(height: 25,),
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 13),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white
              ),
              onPressed:() {
                getCurrentPosition();
              }, 
              child: const Text(
                'Marcar mi ubicación actual',
                
              )
            ),
            const SizedBox(height: 20,),
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 13),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white
              ),
              onPressed:() async {
                await _controllerPage.animateToPage(1, duration: const Duration(seconds: 1), curve: Curves.linear);
              }, 
              child: const Text(
                'Describir la ubicación',
              )
            ),
            
          ],
        ),
        SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10,),
              Center(child: Text(
                "descripción de la ubicación".toUpperCase(),
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: "Brand-Bold",
                  letterSpacing: 1.5,
                  fontSize: 18,
                ),
              ),),
              Padding(
                padding: const EdgeInsets.only(top: 25),
                child: Form(
                  key: formkey,
                  child: Column(
                    children: [
                      MyTextFormField(
                        maxLine: 1,
                        controller: cName,
                        hintText: "Ingrese el nombre completo",
                        labelText: "Nombre Completo",
                      ),
                      MyTextFormField(
                        maxLine: 1,
                        controller: cPhoneNumber,
                        hintText: "Ingrese el Teléfono",
                        labelText: "Teléfono",
                      ),
                      MyTextFormField(
                        maxLine: 1,
                        controller: cCity,
                        hintText: "Ingrese la ciudad",
                        labelText: "Ciudad",
                      ),
                      MyTextFormField(
                        maxLine: 2,
                        controller: cArea,
                        hintText: "Ingrese el Área",
                        labelText: "Area",
                      ),
                      MyTextFormField(
                        maxLine: 3,
                        controller: cHouseandRoadNumber,
                        hintText: "Ingrese Número de casa y calle",
                        labelText: "Número de Casa y calle",
                      ),
                      MyTextFormField(
                        maxLine: 1,
                        controller: cAreaCode,
                        hintText: "Ingrese su Código de Área",
                        labelText: "Código de Área",
                      ),
                      const SizedBox(height: 10,),
                      SizedBox(
                        height: 50,
                        child:
                        ElevatedButton(
                          child: Text(
                            "Agregar Dirección".toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: "Brand-Bold",
                              letterSpacing: 1.5,
                              fontSize: 18,
                            ),
                          ),
                          /* color: Theme.of(context).accentColor, */
                          onPressed: () async {
                            var connectivityResult = await Connectivity().checkConnectivity();
                            if (connectivityResult != ConnectivityResult.mobile &&
                                connectivityResult != ConnectivityResult.wifi) {
                              return showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return NoInternetConnectionAlertDialog();
                                },
                              );
                            }
                            if (cName.text.isNotEmpty &&
                                cPhoneNumber.text.isNotEmpty &&
                                cHouseandRoadNumber.text.isNotEmpty &&
                                cCity.text.isNotEmpty &&
                                cArea.text.isNotEmpty &&
                                cAreaCode.text.isNotEmpty && 
                                _markers.isNotEmpty) {
                              _addressService.addAddress(
                                cName.text.trim(),
                                cPhoneNumber.text.trim(),
                                cHouseandRoadNumber.text.trim(),
                                cCity.text.trim(),
                                cArea.text.trim(),
                                cAreaCode.text.trim(),
                                cameraPosition.target.latitude,
                                cameraPosition.target.longitude
                              );
                              Navigator.pop(context);
                            } else {
                              return showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return const ErrorAlertDialog(
                                    message: "Por favor ingrese toda la información solicitada!",
                                  );
                                });
                            }
                          },
                        ),
                        
                      ),
                      SizedBox(height: 20,),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 13),
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white
                        ),
                        onPressed:() async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          await _controllerPage.animateToPage(0, duration: const Duration(seconds: 1), curve: Curves.linear);
                        }, 
                        child: const Text(
                          'Regresar al mapa',
                        )
                      ),

                    ],
                  ),
                ),
              ),
            ],
          ),
        )
            
      ],
    );
    
  }
  getCurrentPosition() async { 

    try {

      await Geolocator.requestPermission();

      Position currentPosition = await Geolocator.getCurrentPosition();

      cameraPosition = CameraPosition(
        target: LatLng(currentPosition.latitude, currentPosition.longitude),
        zoom: 18
      );
      await _controller!.animateCamera(
        CameraUpdate.newCameraPosition(cameraPosition),
      );
      if (_markers.length >= 1){
        _markers.clear();
      }
      _markers.add(
        Marker(
          markerId: const MarkerId('pin'),
          position: cameraPosition.target,
          icon: BitmapDescriptor.defaultMarker,
        )
      );
      
      
      setState(() {});
    }
    catch(e) {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return const ErrorAlertDialog(
            message: "Acontecio un error, es probable de que no haya activado la ubicación del dispositivo",
          );
        });
    }
    
    
  }
}
