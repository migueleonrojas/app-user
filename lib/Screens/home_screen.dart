/* import 'package:firebase_messaging/firebase_messaging.dart'; */
import 'dart:async';
import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:oil_app/Helper/home_helper.dart';
import 'package:oil_app/Helper/login_helper.dart';
import 'package:oil_app/Screens/Vehicles/time_line_car.dart';
import 'package:oil_app/Screens/Vehicles/timelines_vehicles.dart';
import 'package:oil_app/Screens/Vehicles/vehicles.dart';
import 'package:oil_app/Screens/cart_screen.dart';
import 'package:oil_app/Screens/orders/timeline_service_order.dart';
import 'package:oil_app/Screens/products/product_search.dart';
import 'package:oil_app/Screens/products/time_line_products.dart';
import 'package:oil_app/config/config.dart';
import 'package:oil_app/services/notification_services.dart';
import 'package:oil_app/widgets/mycustom_appbar.dart';
import 'package:oil_app/widgets/mycustomdrawer.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/whatsapp.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
  

  
}

class _HomeScreenState extends State<HomeScreen>  {

  List<Color> colorButton = [
    Color.fromRGBO(156, 141, 7, 1),
    Color.fromRGBO(107, 106, 116, 1),
    Color.fromRGBO(56, 48, 175, 1),
  ];
  int indexColor = 0;
  Color  _buttonColor = Color.fromRGBO(156, 141, 7, 1);
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (timer) {

      if(indexColor > 2) indexColor = 0;
      /* Random().nextint(max - min) + min; */
      /* int codeColorRandom = Random().nextInt(999999999 - 1) + 1; */
      /* _buttonColor = Color(codeColorRandom); */
      _buttonColor = colorButton[indexColor];
      indexColor++;
      setState(() {
        
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer!.cancel();
  }



  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        backgroundColor: Colors.white,
        title:  AutoSizeText(
          "MetaOil",
          style: TextStyle(
            color: Colors.black,
            fontSize: size.height * 0.028,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
            fontFamily: "Brand-Regular",
          ),
        ),
        centerTitle: true,
        actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.black,
              ),
              onPressed: () {
                Route route = MaterialPageRoute(builder: (_) => CartScreen());
                Navigator.push(context, route);
              },
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(AutoParts.collectionUser)
                  .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
                  .collection('carts')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Container();
                return Positioned(
                  top: size.height * 0.005,
                  left: size.height * 0.005,
                  child: Stack(
                    children: [
                      Container(
                        height: size.height * 0.025,
                        width: size.height * 0.025,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(size.height * 0.025,),
                            color: Colors.red,
                            border: Border.all(color: Colors.orangeAccent)),
                      ),
                      (snapshot.data!.docs.length < 10)
                          ? Positioned(
                              top: size.height * 0.005,
                              bottom: size.height * 0.005,
                              left: size.height * 0.0080,
                              child: AutoSizeText(
                                snapshot.data!.docs.length.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          : Positioned(
                              top: size.height * 0.005,
                              bottom: size.height * 0.005,
                              left: size.height * 0.0080,
                              child: AutoSizeText(
                                snapshot.data!.docs.length.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: size.height * 0.016,
                                ),
                              ),
                            ),
                    ],
                  ),
                );
              },
            ),
            // Positioned(
            //   top: 3,
            //   left: 3,
            //   child: Stack(
            //     children: [
            //       Container(
            //         height: 20,
            //         width: 20,
            //         decoration: BoxDecoration(
            //             borderRadius: BorderRadius.circular(20),
            //             color: Colors.red,
            //             border: Border.all(color: Colors.orangeAccent)),
            //       ),
            //       ((AutoParts.sharedPreferences
            //                       .getStringList(AutoParts.userCartList)
            //                       .length -
            //                   1) <
            //               10)
            //           ? Positioned(
            //               top: 2,
            //               bottom: 4,
            //               left: 6,
            //               child: Consumer<CartItemCounter>(
            //                 builder: (context, counter, _) {
            //                   return AutoSizeText(
            //                     (AutoParts.sharedPreferences
            //                                 .getStringList(
            //                                     AutoParts.userCartList)
            //                                 .length -
            //                             1)
            //                         .toString(),
            //                     style: TextStyle(
            //                       color: Colors.white,
            //                       fontWeight: FontWeight.w500,
            //                     ),
            //                   );
            //                 },
            //               ),
            //             )
            //           : Positioned(
            //               top: 3,
            //               bottom: 2,
            //               left: 3,
            //               child: Consumer<CartItemCounter>(
            //                 builder: (context, counter, _) {
            //                   return AutoSizeText(
            //                     (AutoParts.sharedPreferences
            //                                 .getStringList(
            //                                     AutoParts.userCartList)
            //                                 .length -
            //                             1)
            //                         .toString(),
            //                     style: TextStyle(
            //                       color: Colors.white,
            //                       fontSize: 12.0,
            //                     ),
            //                   );
            //                 },
            //               ),
            //             ),
            //     ],
            //   ),
            // ),
          ],
        ),
        
      ],
      
      )
      
      ,
      drawer: MyCustomDrawer(),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment:MainAxisAlignment.spaceBetween,
          
          children: [
            SizedBox(height: size.height * 0.025,),
            HomeHelper().buttonCreateVehicle(_buttonColor, context),
            SizedBox(height: size.height * 0.025,),
            /* LoginHelper().loginLog(context), */
            HomeHelper().mainButtons(context),
            SizedBox(height: size.height * 0.025,),
            const TimelinesVehicles()
            /* const TimeLineCars(), */
            /* HomeHelper().homeCarousel(context),
            HomeHelper().categoriesCard(context),
            HomeHelper().uptoFiftyPercentOFFCard(),
            HomeHelper().newArrivalCard(),
            HomeHelper().vacuumsCard(),
            HomeHelper().helmetCard(),
            HomeHelper().airfresnersCard(), */
          ],
        ),
      ),
    );
  }
  
  

  Future<bool> _onBackPressed() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Estas seguro?'),
            content: Container(
              height: MediaQuery.of(context).size.height * 0.04,
              width: MediaQuery.of(context).size.width * 0.3,
              child: const Text('De que quieres salir!')
            ),
            actions: <Widget>[
              GestureDetector(
                onTap: () { 
                  if(!mounted) return;
                  Navigator.of(context).pop(false);
                },
                child: const Text("NO"),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  await AutoParts.auth!.signOut();
                  if(!mounted) return;
                  Navigator.of(context).pop(true);
                },
                child: const Text("YES"),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ) ??
        false;
  }
  


}
