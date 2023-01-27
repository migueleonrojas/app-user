/* import 'package:firebase_messaging/firebase_messaging.dart'; */
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:oilapp/Helper/home_helper.dart';
import 'package:oilapp/Helper/login_helper.dart';
import 'package:oilapp/Screens/Vehicles/time_line_vehicles.dart';
import 'package:oilapp/Screens/Vehicles/vehicles.dart';
import 'package:oilapp/Screens/cart_screen.dart';
import 'package:oilapp/Screens/orders/timeline_service_order.dart';
import 'package:oilapp/Screens/products/product_search.dart';
import 'package:oilapp/Screens/products/time_line_products.dart';
import 'package:oilapp/config/config.dart';
import 'package:oilapp/services/notification_services.dart';
import 'package:oilapp/widgets/mycustom_appbar.dart';
import 'package:oilapp/widgets/mycustomdrawer.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/whatsapp.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
  

  
}

class _HomeScreenState extends State<HomeScreen>  {
  

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "GlobalOil",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
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
                  top: 3,
                  left: 3,
                  child: Stack(
                    children: [
                      Container(
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.red,
                            border: Border.all(color: Colors.orangeAccent)),
                      ),
                      (snapshot.data!.docs.length < 10)
                          ? Positioned(
                              top: 2,
                              bottom: 4,
                              left: 6,
                              child: Text(
                                snapshot.data!.docs.length.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          : Positioned(
                              top: 3,
                              bottom: 2,
                              left: 3,
                              child: Text(
                                snapshot.data!.docs.length.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.0,
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
            //                   return Text(
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
            //                   return Text(
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
            
            LoginHelper().loginLog(),
            
            HomeHelper().mainButtons(context),
            const SizedBox(height: 20,),
            
            const TimeLineVehicles()
            
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
            content: const Text('De que quieres salir!'),
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
