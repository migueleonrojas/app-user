import 'package:auto_size_text/auto_size_text.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:oilapp/Model/addresss.dart';
import 'package:oilapp/Model/vehicle_model.dart';
import 'package:oilapp/Screens/Address/addAddress.dart';
import 'package:oilapp/Screens/Address/editAddress.dart';
import 'package:oilapp/Screens/ourservice/service_payment.dart';
import 'package:oilapp/config/config.dart';
import 'package:oilapp/counter/changeAddress.dart';
import 'package:oilapp/service/category_data.dart';
import 'package:oilapp/widgets/emptycardmessage.dart';
import 'package:oilapp/widgets/erroralertdialog.dart';
import 'package:oilapp/widgets/loading_widget.dart';
import 'package:oilapp/widgets/widebutton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:oilapp/service/address_service.dart';

class ServiceShippingAddress extends StatefulWidget {
  final int? totalPrice;
  final List<VehicleModel>? vehicleModel;

  const ServiceShippingAddress({
    Key? key,
    this.totalPrice, 
    this.vehicleModel,
  }) : super(key: key);
  @override
  _ServiceShippingAddressState createState() => _ServiceShippingAddressState();
}

class _ServiceShippingAddressState extends State<ServiceShippingAddress> {

  List<AddressModel> addressModel = [];
  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        
        title: AutoSizeText(
          "Mis direcciones",
          style: TextStyle(
            fontSize: size.height * 0.026,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
            fontFamily: "Brand-Regular",
          ),
        ),
        centerTitle: true,
        /* actions: [
          IconButton(
            icon: const Icon(Icons.add_location),
            onPressed: () {
              Route route = MaterialPageRoute(builder: (_) => AddAddress());
              Navigator.push(context, route);
            },
          ),
        ], */
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Column(
                children:  [
                  Padding(
                    padding: EdgeInsets.all(size.height * 0.012),
                    child: AutoSizeText(
                      "Seleccionar Dirección",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: size.height * 0.022,
                      ),
                    ),
                  ),
                  IconButton(
                    iconSize: size.height * 0.070,
                    icon: const Icon(
                      Icons.add_location,
                      color: Color.fromARGB(255, 212, 175, 55),
                    ),
                    onPressed: () {
                      Route route = MaterialPageRoute(builder: (_) => AddAddress());
                      Navigator.push(context, route);
                    },
                  ),
                  Stack(
                    alignment: AlignmentDirectional.centerStart,
                    children:  [
                      Center(
                        child:  AutoSizeText(
                          'Agregar Dirección',
                          style: TextStyle(
                            fontSize: size.height * 0.018,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        
                        children: [
                          IconButton(
                            onPressed: () {
                              if(addressModel.isEmpty) return;
                              int index = Provider.of<AddressChange>(context, listen: false).count;
                              

                              
                              Route route = MaterialPageRoute(
                                builder: (_) => EditAddress(
                                  addressModel: addressModel[index],    
                                ),
                              );
                              Navigator.push(context, route);
                              
                            }, 
                            icon: const Icon(
                              Icons.edit,
                              
                            ),
                          ),

                          IconButton(
                            onPressed: () async {

                              if(addressModel.isEmpty) return;
                              
                              int index = Provider.of<AddressChange>(context, listen: false).count;             

                              bool confirm = await _onBackPressed('De que quiere eliminar la dirección');

                              if(!confirm) return;

                              bool isSuccess = await AddressService().deleteAddress(addressId: addressModel[index].addressId);

                              if(isSuccess){
                                Provider.of<AddressChange>(context, listen: false).displayResult(0);
                                Fluttertoast.showToast(msg:"Se elimino exitosamente la dirección");
                              }
                              else{
                                return showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return const ErrorAlertDialog(
                                      message: "No se puede eliminar una dirección la cual esta asignada a una orden de servico que ya fue recibida",
                                    );
                                  }
                                );
                              }


                            }, 
                            icon: const Icon(
                              Icons.delete,
                              
                            ),
                          ),
                          
                        ],
                      )
                      
                    ],
                  ),
                  SizedBox(height: size.height * 0.016,)                  
                ],
              ),
            ),
            Consumer<AddressChange>(builder: (context, address, c) {
              return Flexible(
                child: StreamBuilder<QuerySnapshot>(
                  stream: AutoParts.firestore!
                      .collection(AutoParts.collectionUser)
                      .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
                      .collection(AutoParts.subCollectionAddress)
                      .snapshots(),
                  builder: (context, snapshot) {

                    addressModel = [];

                    if(!snapshot.hasData) {
                      return Center(child: circularProgress());
                    }

                    if(snapshot.data!.docs.length == 0) {
                      return noAddressCard(size);
                    }
                    
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        addressModel.add(
                          AddressModel.fromJson(
                            (snapshot.data!.docs[index] as dynamic).data())
                        );
                        return AddressCard(
                          vehicleModel: widget.vehicleModel!,
                          currentIndex: address.count,
                          value: index,
                          addressId: snapshot.data!.docs[index].id,
                          totalPrice: widget.totalPrice!,
                          model: AddressModel.fromJson(
                            (snapshot.data!.docs[index] as dynamic).data()),
                        );
                      },
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );

  }

  noAddressCard(Size size) {
    return Card(
      color: Colors.blueGrey.withOpacity(0.5),
      child: Container(
        height: size.height * 0.120,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add_location, color: Colors.white),
            AutoSizeText("No se ha guardado ninguna dirección de envío"),
            AutoSizeText(
              "Por favor, añada su dirección para que podamos prestarle el servicio.",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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

class AddressCard extends StatefulWidget {
  final List<VehicleModel> vehicleModel;
  final AddressModel? model;
  final String? addressId;
  final int? totalPrice;
  final int? currentIndex;
  final int? value;
  const AddressCard({
    Key? key,
    this.model,
    this.addressId,
    this.totalPrice,
    this.currentIndex,
    this.value, 
    required this.vehicleModel,
  }) : super(key: key);
  @override
  _AddressCardState createState() => _AddressCardState();
}

class _AddressCardState extends State<AddressCard> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double screenWidth = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () {
        Provider.of<AddressChange>(context, listen: false)
            .displayResult(widget.value!);
      },
      child: Card(
        color: Colors.white.withOpacity(0.4),
        child: Column(
          children: [
            Row(
              children: [
                
                Radio(
                  value: widget.value,

                  groupValue: widget.currentIndex,
                  activeColor: Color.fromARGB(255, 3, 3, 247),
                  onChanged: (val) {
                    Provider.of<AddressChange>(context, listen: false)
                        .displayResult(val!);
                        
                  },
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(size.height * 0.014),
                      width: screenWidth * 0.8,
                      child: Table(
                        children: [
                          TableRow(
                            children: [
                              KeyText(msg: "Nombre"),
                              AutoSizeText(widget.model!.customerName!),
                            ],
                          ),
                          TableRow(
                            children: [
                              KeyText(msg: "Teléfono"),
                              AutoSizeText(widget.model!.phoneNumber!),
                            ],
                          ),
                          TableRow(
                            children: [
                              KeyText(msg: "Número de Casa y calle"),
                              AutoSizeText(widget.model!.houseandroadno!),
                            ],
                          ),
                          TableRow(
                            children: [
                              KeyText(msg: "Ciudad"),
                              AutoSizeText(widget.model!.city!),
                            ],
                          ),
                          TableRow(
                            children: [
                              KeyText(msg: "Area"),
                              AutoSizeText(widget.model!.area!),
                            ],
                          ),
                          TableRow(
                            children: [
                              KeyText(msg: "Código de Área"),
                              AutoSizeText(widget.model!.areacode!),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                /* Column(
                  children: const [
                     IconButton(
                      icon:  Icon(
                        Icons.add_location,
                        color: Color.fromARGB(255, 212, 175, 55),
                      ),
                      onPressed: null
                    )
                  ],
                ) */
              ],
            ),
            widget.value == Provider.of<AddressChange>(context).count
              ? WideButton(

                    message: "Proceder",
                    onPressed: () {
                      Route route = MaterialPageRoute(
                        builder: (_) => ServicePaymentPage(
                          vehicleModel: widget.vehicleModel,
                          addressId: widget.addressId,
                          totalPrice: widget.totalPrice,
                        ),
                      );
                      Navigator.push(context, route);
                    },
                  )
              : Container(),
            
            /* widget.value == Provider.of<AddressChange>(context).count
                ? WideButton(

                    message: "Proceder",
                    onPressed: () {
                      Route route = MaterialPageRoute(
                        builder: (_) => ServicePaymentPage(
                          vehicleModel: widget.vehicleModel,
                          addressId: widget.addressId,
                          totalPrice: widget.totalPrice,
                        ),
                      );
                      Navigator.push(context, route);
                    },
                  )
                : Container(),
             WideButton(
              message: 'Editar dirección',
              onPressed: () async {
                Route route = MaterialPageRoute(
                  builder: (_) => EditAddress(
                    addressModel: widget.model!,    
                  ),
                );
                Navigator.push(context, route);
              },
             ),
             WideButton(
              message: "Eliminar dirección",
              onPressed: () async {

                bool confirm = await _onBackPressed('De que quiere eliminar la dirección');

                if(!confirm) return;

                bool isSuccess = await AddressService().deleteAddress(addressId: widget.model!.addressId);

                if(isSuccess){
                  Fluttertoast.showToast(msg:"Se elimino exitosamente la dirección");
                }
                else{
                  return showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const ErrorAlertDialog(
                        message: "No se puede eliminar una dirección la cual esta asignada a una orden de servico que ya fue recibida",
                      );
                    }
                  );
                }
                      
              },
            ),
               */
          ],
        ),
      ),
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
              child: Text(msg),
              
            ),
            actions: <Widget>[
               GestureDetector(
                onTap: () => Navigator.of(context).pop(true),
                child: Padding(
                  padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.015),
                  child: Text("YES"),
                ),
              ),
              const SizedBox(height: 16),
               GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
                child: Padding(
                  padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.015),
                  child: Text("NO"),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.021),
            ],
          ),
        ) ??
        false;
  }
}

class KeyText extends StatelessWidget {
  final String? msg;

  const KeyText({Key? key, this.msg}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      msg!,
      style: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
