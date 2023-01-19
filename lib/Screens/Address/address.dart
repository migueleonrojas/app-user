import 'package:fluttertoast/fluttertoast.dart';
import 'package:oilapp/Model/addresss.dart';

import 'package:oilapp/Screens/Address/addAddress.dart';
import 'package:oilapp/Screens/Address/editAddress.dart';
import 'package:oilapp/Screens/orders/paymentpage.dart';
import 'package:oilapp/config/config.dart';
import 'package:oilapp/counter/changeAddress.dart';
import 'package:oilapp/service/address_service.dart';
import 'package:oilapp/widgets/erroralertdialog.dart';
import 'package:oilapp/widgets/loading_widget.dart';
import 'package:oilapp/widgets/widebutton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Address extends StatefulWidget {
  final int totalPrice;

  const Address({
    Key? key,
    required this.totalPrice,
  }) : super(key: key);
  @override
  _AddressState createState() => _AddressState();
}

class _AddressState extends State<Address> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        title: const Text(
          "Global Oil",
          style: TextStyle(
            fontSize: 20,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
            fontFamily: "Brand-Regular",
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location),
            onPressed: () {
              Route route = MaterialPageRoute(builder: (_) => AddAddress());
              Navigator.push(context, route);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Align(
              alignment:   Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  "Seleccionar Dirección",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            Consumer<AddressChange>(builder: (context, address, c) {
              return Flexible(
                child: StreamBuilder<QuerySnapshot>(
                  stream: AutoParts.firestore!
                      .collection(AutoParts.collectionUser)
                      .doc(AutoParts.sharedPreferences!
                          .getString(AutoParts.userUID))
                      .collection(AutoParts.subCollectionAddress)
                      .snapshots(),
                  builder: (context, snapshot) {
                    return !snapshot.hasData
                        ? Center(child: circularProgress())
                        : snapshot.data!.docs.length == 0
                            ? noAddressCard()
                            : ListView.builder(
                                itemCount: snapshot.data!.docs.length,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return AddressCard(
                                    currentIndex: address.count,
                                    value: index,
                                    addressId: snapshot.data!.docs[index].id,
                                    totalPrice: widget.totalPrice,
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

  noAddressCard() {
    return Card(
      color: Colors.blueGrey.withOpacity(0.5),
      child: Container(
        height: 100,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_location, color: Colors.white),
            Text(
              "No se ha guardado ninguna dirección de envío\nPor favor, agregue su dirección de envío para que podamos entregar su producto.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddressCard extends StatefulWidget {
  final AddressModel model;

  final String addressId;
  final int totalPrice;
  final int currentIndex;
  final int value;
  const AddressCard({
    Key? key,
    required this.model,
    required this.addressId,
    required this.totalPrice,
    required this.currentIndex,
    required this.value,
  }) : super(key: key);
  @override
  _AddressCardState createState() => _AddressCardState();
}

class _AddressCardState extends State<AddressCard> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () {
        Provider.of<AddressChange>(context, listen: false)
            .displayResult(widget.value);
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
                  activeColor: Colors.deepOrangeAccent,
                  onChanged: (val) {
                    Provider.of<AddressChange>(context, listen: false)
                        .displayResult(val!);
                  },
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      width: screenWidth * 0.8,
                      child: Table(
                        children: [
                          TableRow(
                            children: [
                              KeyText(msg: "Nombre"),
                              Text(widget.model.customerName!),
                            ],
                          ),
                          TableRow(
                            children: [
                              KeyText(msg: "Teléfono"),
                              Text(widget.model.phoneNumber!),
                            ],
                          ),
                          TableRow(
                            children: [
                              KeyText(msg: "Número de casa y calle"),
                              Text(widget.model.houseandroadno!),
                            ],
                          ),
                          TableRow(
                            children: [
                              KeyText(msg: "Ciudad"),
                              Text(widget.model.city!),
                            ],
                          ),
                          TableRow(
                            children: [
                              KeyText(msg: "Area"),
                              Text(widget.model.area!),
                            ],
                          ),
                          TableRow(
                            children: [
                              KeyText(msg: "Código de Area"),
                              Text(widget.model.areacode!),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            widget.value == Provider.of<AddressChange>(context).count
                ? WideButton(
                    message: "Proceder",
                    onPressed: () {
                      Route route = MaterialPageRoute(
                        builder: (_) => PaymentPage(
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
                    addressModel: widget.model,    
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

                bool isSuccess = await AddressService().deleteAddress(addressId: widget.model.addressId);

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

class KeyText extends StatelessWidget {
  final String msg;

  const KeyText({Key? key, required this.msg}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Text(
      msg,
      style: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
