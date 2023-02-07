import 'package:oilapp/Model/service_order_with_vehicle.dart';
import 'package:oilapp/Model/vehicle_model.dart';
import 'package:oilapp/Model/service_order_model.dart';
import 'package:oilapp/Screens/orders/myservice_order_details_by_vehicle_screen.dart';
import 'package:oilapp/Screens/orders/myservice_order_details_screen.dart';
import 'package:oilapp/Screens/ourservice/backend_orderservice.dart';
import 'package:oilapp/config/config.dart';
import 'package:oilapp/widgets/emptycardmessage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oilapp/widgets/loading_widget.dart';
import 'package:timeago/timeago.dart' as timeago;



class MyServiceOrderScreen extends StatefulWidget {


  const MyServiceOrderScreen({super.key});
  

  @override
  _MyServiceOrderScreenState createState() => _MyServiceOrderScreenState();
}

class _MyServiceOrderScreenState extends State<MyServiceOrderScreen> {
  final f =  DateFormat('dd-MM-yyyy');
  final backEndOrderService = BackEndOrderService();
  final ScrollController scrollController = ScrollController();
  int limit = 5;
  bool dataFinish = false;
  bool isLoading =  false;
  @override
  void initState() {
    super.initState();
    backEndOrderService.getServiceOrderWithVehicle(limit: 5);
    scrollController.addListener(() async {

      if(scrollController.position.pixels + 200 > scrollController.position.maxScrollExtent) {
        if(isLoading) return;
        if(dataFinish) return;
        isLoading = true;
        await Future.delayed(const Duration(seconds: 1));
        dataFinish = await backEndOrderService.getServiceOrderWithVehicle(limit: limit, nextDocument: true);
        isLoading = false;
        
        if(scrollController.position.pixels + 200 <= scrollController.position.maxScrollExtent) return;
        scrollController.animateTo(
          scrollController.position.maxScrollExtent + 120, 
          duration: const Duration(milliseconds: 300), 
          curve: Curves.fastOutSlowIn
        );

      }
    
    });
  }
  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Mis ordenes de servicio",
          style: TextStyle(
            fontSize: size.height * 0.024,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
            fontFamily: "Brand-Regular",
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        controller: scrollController,
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            StreamBuilder(
              stream: backEndOrderService.suggestionStream,
              builder: ((context, snapshot) {

                if (!snapshot.hasData) {
                  return circularProgress();
                }

                if (snapshot.data!.isEmpty) {
                  return const EmptyCardMessage(
                    listTitle: 'No tiene servicios',
                    message: 'Solicite un servicio desde Global Oil',
                  );
                }
                

                return ListView.builder(
                  
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount:snapshot.data!.length,
                  itemBuilder:(context, index) {
                    if (snapshot.data == null) return Center(
                      child: Column(
                        children: [
                          SizedBox(height: size.height * 0.024,),
                          Container(
                            child: const CircularProgressIndicator(),
                          ),
                        ],
                      ),
                    );

                    final serviceOrderWithVehicle = snapshot.data!;
                    

                    SeviceOrderWithVehicleModel seviceOrderWithVehicleModel = SeviceOrderWithVehicleModel.fromJson(
                      serviceOrderWithVehicle[index].toJson()
                    );

                    
                    VehicleModel vehicleModel = VehicleModel.fromJson(
                      seviceOrderWithVehicleModel.vehicleModel!
                    );

                    ServiceOrderModel serviceOrderModel = ServiceOrderModel.fromJson(
                      seviceOrderWithVehicleModel.serviceOrderModel!
                    );

                    return OrderBody(
                      itemCount: snapshot.data!.length,
                      data: serviceOrderModel,
                      vehicleModel: vehicleModel,
                      size: size, 
                    );
                  },
                );
                
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderBody extends StatelessWidget {
  const OrderBody({
    required this.itemCount,
    required this.data,
    required this.vehicleModel,
    Key? key, 
    required this.size,
  }) : super(key: key);
  final int itemCount;
  final ServiceOrderModel data;
  final VehicleModel vehicleModel;
  final Size size;
  @override
  Widget build(BuildContext context) {

    DateTime myDateTime = (data.orderTime)!.toDate();

    return Container(
      child: Padding(
        padding: EdgeInsets.all(size.height * 0.014),
        child: Container(
          child: Column(
            children: [
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
                      text: data.orderId,
                      style:  TextStyle(
                        color: Colors.black,
                        fontSize: size.height * 0.022,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    
                  ],
                ),
              ),
              Text(
                "Vehiculo: ${vehicleModel.brand}, ${vehicleModel.model} ",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: size.height * 0.022,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "Servicio: ${data.serviceName}",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: size.height * 0.022,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "Precio Total: " + data.totalPrice.toString() + " \$.",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: size.height * 0.022,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(DateFormat.yMMMd().add_jm().format(myDateTime)),
              Text(timeago.format(DateTime.tryParse(data.orderTime!.toDate().toString())!).toString()),
              ElevatedButton(
                /* shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                ), */
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 3, 3, 247),
                  shape: const StadiumBorder()
                ),
                onPressed: () async {
                 Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MyServiceOrderDetailsByVehicleScreen(
                        orderId: data.orderId!,
                        addressId: data.addressID!,
                        vehicleModel: vehicleModel,
                        idOrderPaymentDetails: data.idOrderPaymentDetails!,
                      ),
                    ),
                  );
                },
                /* color: Colors.deepOrangeAccent[200], */
                child: const Text(
                  "Detalle de la orden",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ]
          ),
        )
      )
    );
  }
}
