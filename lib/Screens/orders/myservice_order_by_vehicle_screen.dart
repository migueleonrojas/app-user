import 'package:auto_size_text/auto_size_text.dart';
import 'package:oilapp/Model/vehicle_model.dart';
import 'package:oilapp/Screens/home_screen.dart';
import 'package:oilapp/Screens/orders/myservice_order_details_by_vehicle_screen.dart';
import 'package:oilapp/config/config.dart';
import 'package:oilapp/widgets/emptycardmessage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oilapp/widgets/loading_widget.dart';
import 'package:timeago/timeago.dart' as timeago;



class MyServiceOrderByVehicleScreen extends StatefulWidget {

  final VehicleModel? vehicleModel;

  const MyServiceOrderByVehicleScreen({super.key, this.vehicleModel});
  

  @override
  _MyServiceOrderByVehicleScreenState createState() => _MyServiceOrderByVehicleScreenState();
}

class _MyServiceOrderByVehicleScreenState extends State<MyServiceOrderByVehicleScreen> {
  final f = DateFormat('dd-MM-yyyy');
  final ScrollController scrollController = ScrollController();
  QuerySnapshot<Map<String, dynamic>>? _docSnapStream;
  int lengthCollection = 0;
  bool isLoading =  false;
  List listDocument = [];
  QuerySnapshot? collectionState;


  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Route route = MaterialPageRoute(
                builder: (_) => HomeScreen(),
              );
              Navigator.push(context, route);
            }, 
            icon: const Icon(Icons.home))
        ],
        title: AutoSizeText(
          "Mis ordenes de servicio",
          style: TextStyle(
            fontSize: size.height * 0.025,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
            fontFamily: "Brand-Regular",
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: gerServiceOrders(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }

          if(snapshot.data!.isEmpty) {
            return const EmptyCardMessage(
              listTitle: 'No tiene servicios para este vehiculo',
              message: 'Solicite un servicio desde Global Oil',
            );
          }

          return OrderBody(
            itemCount: snapshot.data!.length,
            data: snapshot.data!,
            vehicleModel: widget.vehicleModel!,
            scrollController: scrollController,
          );


        },
      ),
      /* body: OrderBody(
        itemCount: listDocument.length,
        data: listDocument,
        vehicleModel: widget.vehicleModel!,
        scrollController: scrollController,
      ), */
      
    );
  }

    Future<List<Map<String,dynamic>>> gerServiceOrders() async {

      List <Map<String,dynamic>> listServiceOrders = [];

      QuerySnapshot<Map<String, dynamic>> serviceOrders = await AutoParts.firestore!
        .collection(AutoParts.collectionUser)
        .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
        .collection(AutoParts.vehicles)
        .doc(widget.vehicleModel!.vehicleId ?? "")
        .collection('serviceOrder')
        .orderBy("orderTime", descending: true)
        .get();

      for(final serviceOrder in serviceOrders.docs) {

        listServiceOrders.add(serviceOrder.data());

      }

      return listServiceOrders;

    }

}

class OrderBody extends StatelessWidget {
  const OrderBody({
    required this.vehicleModel,
    required this.itemCount,
    required this.data,
    required this.scrollController,
    Key? key,
  }) : super(key: key);
  final int itemCount;
  final List data;
  final VehicleModel vehicleModel;
  final ScrollController scrollController;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        controller: scrollController,
        shrinkWrap: true,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          DateTime myDateTime = (data[index]['orderTime']).toDate();
          return Column(
            children: [

              Padding(
                padding: EdgeInsets.all(size.height * 0.010),
                child: Container(
                  child: Column(
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            
                            TextSpan(
                              text: "Número: ",
                              style: TextStyle(
                                fontSize: size.height * 0.022,
                                fontWeight: FontWeight.w600,
                                color: Colors.deepOrangeAccent,
                              ),
                            ),
                            TextSpan(
                              text: (index + 1 ).toString(),
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: size.height * 0.022,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            
                            TextSpan(
                              text: "ID de la Orden: ",
                              style: TextStyle(
                                fontSize: size.height * 0.022,
                                fontWeight: FontWeight.w600,
                                color: Colors.deepOrangeAccent,
                              ),
                            ),
                            TextSpan(
                              text: data[index]['orderId'],
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: size.height * 0.022,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // AutoSizeText(
                      //   "(" +
                      //       (data[index].data()[AutoParts.productID].length - 1)
                      //           .toString() +
                      //       " items)",
                      //   style: TextStyle(
                      //     color: Colors.grey,
                      //     fontSize: 16,
                      //   ),
                      // ),
                      AutoSizeText(
                        "Vehiculo: ${vehicleModel.brand}, ${vehicleModel.model} ",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: size.height * 0.022,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      AutoSizeText(
                        "Servicio: ${data[index]['serviceName']}",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: size.height * 0.022,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      AutoSizeText(
                        "Precio Total: ${data[index]['totalPrice']}\$.",                        
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: size.height * 0.022,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      AutoSizeText(DateFormat.yMMMd().add_jm().format(myDateTime)),
                      AutoSizeText(timeago
                          .format(DateTime.tryParse(data[index]
                              ['orderTime']
                              .toDate()
                              .toString())!)
                          .toString()),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 3, 3, 247),
                          shape: const StadiumBorder()
                        ),
                        
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MyServiceOrderDetailsByVehicleScreen(
                                orderId: data[index]['orderId'],
                                addressId: data[index]['addressID'],
                                vehicleModel: vehicleModel,
                                idOrderPaymentDetails: data[index]['idOrderPaymentDetails'],
                              ),
                            ),
                          );
                        },
                        /* color: Colors.deepOrangeAccent[200], */
                        child: const AutoSizeText(
                          "Detalle de la orden",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: size.height * 0.014,
                width: double.infinity,
                color: Colors.blueGrey[50],
              ),
            ],
          );
        },
      ),
    );
  }
}
