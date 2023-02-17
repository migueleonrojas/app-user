import 'package:auto_size_text/auto_size_text.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:oilapp/Model/addresss.dart';

import 'package:oilapp/service/address_service.dart';
import 'package:oilapp/widgets/erroralertdialog.dart';
import 'package:oilapp/widgets/mytextFormfield.dart';
import 'package:oilapp/widgets/noInternetConnectionAlertDialog.dart';
import 'package:oilapp/widgets/simpleAppbar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:async';
class EditAddress extends StatefulWidget {

  final AddressModel addressModel;

  const EditAddress({super.key, required this.addressModel});
  

  @override
  State<EditAddress> createState() => _EditAddressState();
}

class _EditAddressState extends State<EditAddress> {

  

  
  PageController _controllerPage = PageController(initialPage: 0, keepPage: true);

  CameraPosition? cameraPosition;

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
  void initState() {
    super.initState();
    cameraPosition =  CameraPosition(
      target: LatLng(
        widget.addressModel.latitude!,
        widget.addressModel.longitude!
      ),
      zoom: 18
    );
    _markers.add(
        Marker(
          markerId: const MarkerId('pin'),
          position: cameraPosition!.target,
          icon: BitmapDescriptor.defaultMarker,
        )
    );
  cName.text = widget.addressModel.customerName!;

  cPhoneNumber.text = widget.addressModel.phoneNumber!;

  cHouseandRoadNumber.text = widget.addressModel.houseandroadno!;

  cCity.text = widget.addressModel.city!;

  cArea.text = widget.addressModel.area!;

  cAreaCode.text = widget.addressModel.areacode!;



  }
  
  @override
  Widget build(BuildContext context) {

    

    return Scaffold(
      
      appBar: simpleAppBar(false, "Editar Dirección",context),
      body: addAddressBody(context),
      
      
    );
  }

   addAddressBody(BuildContext context) {

    Size size = MediaQuery.of(context).size;

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
            SizedBox(height: size.height * 0.031,),
            Center(
              child: AutoSizeText(
                "Marque su ubicación".toUpperCase(),
                style:  TextStyle(
                  color: Colors.black,
                  fontFamily: "Brand-Bold",
                  letterSpacing: 1.5,
                  fontSize: size.height * 0.023,
                ),
              ),
            ),
            SizedBox(height: size.height * 0.031,),
            Container(
              height: MediaQuery.of(context).size.height * 0.55,
              child: GoogleMap(
                initialCameraPosition: cameraPosition!,
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
                    CameraUpdate.newCameraPosition(cameraPosition!),
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
            SizedBox(height: size.height * 0.031,),
            TextButton(
              
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.045, vertical: size.height * 0.017),
                backgroundColor: Color.fromARGB(255, 3, 3, 247),
                foregroundColor: Colors.white,
                shape: const StadiumBorder()
              ),
              onPressed:() {
                getCurrentPosition();
              }, 
              child: const AutoSizeText(
                'Marcar mi ubicación actual',
                
              )
            ),
            SizedBox(height: size.height * 0.024,),
            TextButton(
              /* style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(255, 3, 3, 247),
                                shape: const StadiumBorder()
                              ), */
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.045, vertical: size.height * 0.018),
                backgroundColor: Color.fromARGB(255, 3, 3, 247),
                foregroundColor: Colors.white,
                shape: const StadiumBorder()
              ),
              onPressed:() async {
                await _controllerPage.animateToPage(1, duration: const Duration(seconds: 1), curve: Curves.linear);
              }, 
              child: const AutoSizeText(
                'Ver la descripción de la ubicación',
              )
            ),
            
          ],
        ),
        SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: size.height * 0.014,),
              Center(child: AutoSizeText(
                "descripción de la ubicación".toUpperCase(),
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "Brand-Bold",
                  letterSpacing: 1.5,
                  fontSize: size.height * 0.023,
                ),
              ),),
              Padding(
                padding:  EdgeInsets.only(top: size.height * 0.029),
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
                        hintText: "Ingrese la Urbanización o Sector",
                        labelText: "Código postal",
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
                      SizedBox(height: size.height * 0.014,),
                      SizedBox(
                        height: size.height * 0.064,
                        child:
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 3, 3, 247),
                            shape: const StadiumBorder()
                          ),
                          child: AutoSizeText(
                            "Actualizar Dirección".toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: "Brand-Bold",
                              letterSpacing: 1.5,
                              fontSize: size.height * 0.022,
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
                                
                                cAreaCode.text.isNotEmpty && 
                                _markers.isNotEmpty) {

                              bool confirm  = await _onBackPressed("De que quiere actualizar la dirección");

                              if(!confirm) return;

                              _addressService.updateAddress(
                                cName.text.trim(),
                                cPhoneNumber.text.trim(),
                                cHouseandRoadNumber.text.trim(),
                                cCity.text.trim(),
                                cArea.text.trim(),
                                cAreaCode.text.trim(),
                                cameraPosition!.target.latitude,
                                cameraPosition!.target.longitude,
                                widget.addressModel.addressId!
                              );
                              Navigator.of(context).pop(cameraPosition);
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
                      SizedBox(height: size.height * 0.025,),
                      TextButton(
                        /* style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 3, 3, 247),
                            shape: const StadiumBorder()
                          ), */
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: size.width * 0.045, vertical: size.height * 0.018),
                          backgroundColor: Color.fromARGB(255, 3, 3, 247),
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder()
                        ),
                        onPressed:() async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          await _controllerPage.animateToPage(0, duration: const Duration(seconds: 1), curve: Curves.linear);
                        }, 
                        child: const AutoSizeText(
                          'Ver mapa',
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
                child:  Padding(
                  padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.012),
                  child: Text("YES"),
                ),
              ),
               SizedBox(height: MediaQuery.of(context).size.height * 0.020),
               GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
                child:  Padding(
                  padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.012),
                  child: Text("NO"),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.020),
            ],
          ),
        ) ??
        false;
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
        CameraUpdate.newCameraPosition(cameraPosition!),
      );
      if (_markers.length >= 1){
        _markers.clear();
      }
      _markers.add(
        Marker(
          markerId: const MarkerId('pin'),
          position: cameraPosition!.target,
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
