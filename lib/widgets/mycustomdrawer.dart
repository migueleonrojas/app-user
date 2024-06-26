import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:oil_app/Helper/drawer_helper.dart';
import 'package:oil_app/Screens/Vehicles/create_vehicle.dart';
import 'package:oil_app/Screens/Vehicles/vehicles.dart';
import 'package:oil_app/Screens/Vehicles/view_cars_notes.dart';
import 'package:oil_app/Screens/about_Screen.dart';
import 'package:oil_app/Screens/cart_screen.dart';
import 'package:oil_app/Screens/home_screen.dart';
import 'package:oil_app/Screens/myaccount_screen.dart';
import 'package:oil_app/Screens/myreview_rating_screen.dart';
import 'package:oil_app/Screens/orders/myOrder_Screen.dart';
import 'package:oil_app/Screens/orders/myservice_order_screen.dart';
import 'package:oil_app/Screens/ourservice/our_service_screen.dart';
import 'package:oil_app/Screens/splash_screen.dart';
import 'package:oil_app/Screens/wishlist_screen.dart';
import 'package:oil_app/config/config.dart';
import 'package:oil_app/widgets/noInternetConnectionAlertDialog.dart';

import 'package:flutter/material.dart';

class MyCustomDrawer extends StatefulWidget {
  @override
  State<MyCustomDrawer> createState() => _MyCustomDrawerState();
}

class _MyCustomDrawerState extends State<MyCustomDrawer> {

  String? urlAvatar;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    urlAvatar = AutoParts.sharedPreferences!.getString(AutoParts.userAvatarUrl);
  }

  @override
  void didUpdateWidget(covariant MyCustomDrawer oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Drawer(
      
      child: SafeArea(
        child: ListView(
          
          children: [
            Container(
              padding:  EdgeInsets.only(top: size.height * 0.020, bottom: size.height * 0.015),
              decoration:  BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey.shade300, Colors.grey.shade200],
                  begin: FractionalOffset(0.0, 0.0),
                  end: FractionalOffset(1.0, 0.0),
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp,
                ),
              ),
              child: Column(
                children: [
                  Material(
                    borderRadius:  BorderRadius.all(Radius.circular(size.height * 0.080)),
                    elevation: 8.0,
                    child: Container(
                      width: size.width * 0.335,
                      height: size.height * 0.15,
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(
                          urlAvatar ?? '',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.015),
                  AutoSizeText(
                    AutoParts.sharedPreferences!.getString(AutoParts.userName) ?? '',
                    style: TextStyle(
                      fontSize: size.height * 0.020,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  AutoSizeText(
                    AutoParts.sharedPreferences!.getString(AutoParts.userEmail) ?? '',
                    style: TextStyle(
                      fontSize: size.height * 0.020,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: Column(
                children: [
                  DrawerItems(
                    leadingIcon: Icons.home_outlined,
                    title: "Inicio",
                    traillingIcon: Icons.keyboard_arrow_right,
                    onPressed: () async {
                      var connectivityResult =
                          await Connectivity().checkConnectivity();
                      if (connectivityResult != ConnectivityResult.mobile &&
                          connectivityResult != ConnectivityResult.wifi) {
                        return showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const NoInternetConnectionAlertDialog();
                          },
                        );
                      }
                      Route route =
                          MaterialPageRoute(builder: (_) => HomeScreen());
                      
                      Navigator.pushReplacement(context, route);
                    },
                  ),
                  DrawerDivider(),
                  DrawerItems(
                    leadingIcon: Icons.person_outline_outlined,
                    title: "Mi Cuenta",
                    traillingIcon: Icons.keyboard_arrow_right,
                    onPressed: () async {
                      var connectivityResult =
                          await Connectivity().checkConnectivity();
                      if (connectivityResult != ConnectivityResult.mobile &&
                          connectivityResult != ConnectivityResult.wifi) {
                        return showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return NoInternetConnectionAlertDialog();
                          },
                        );
                      }


                      Route route =
                          MaterialPageRoute(builder: (_) => MyAccountScreen());
                      if(!mounted)return;
                      final accountUpdate = await Navigator.push(context, route);
                      urlAvatar = accountUpdate;
                      setState(() {
                        
                      });
                    },
                  ),
                  DrawerDivider(),
                  DrawerItems(
                    leadingIcon: Icons.car_repair,
                    title: "Agregar Vehiculo",
                    traillingIcon: Icons.keyboard_arrow_right,
                    onPressed: () async {
                      var connectivityResult =
                          await Connectivity().checkConnectivity();
                      if (connectivityResult != ConnectivityResult.mobile &&
                          connectivityResult != ConnectivityResult.wifi) {
                        return showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return NoInternetConnectionAlertDialog();
                            });
                      }
                      Route route =
                          MaterialPageRoute(builder: (_) => CreateVehicleScreen());
                      Navigator.push(context, route);
                    },
                  ),
                  DrawerDivider(),
                  DrawerItems(
                    leadingIcon: Icons.garage,
                    title: "Mi Garage",
                    traillingIcon: Icons.keyboard_arrow_right,
                    onPressed: () async {
                      var connectivityResult =
                          await Connectivity().checkConnectivity();
                      if (connectivityResult != ConnectivityResult.mobile &&
                          connectivityResult != ConnectivityResult.wifi) {
                        return showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return NoInternetConnectionAlertDialog();
                            });
                      }
                      Route route =
                          MaterialPageRoute(builder: (_) => Vehicles());
                      Navigator.push(context, route);
                    },
                  ),
                  DrawerDivider(),
                  /* DrawerItems(
                    leadingIcon: Icons.shopping_bag_outlined,
                    title: "Mis Ordenes",
                    traillingIcon: Icons.keyboard_arrow_right,
                    onPressed: () async {
                      var connectivityResult =
                          await Connectivity().checkConnectivity();
                      if (connectivityResult != ConnectivityResult.mobile &&
                          connectivityResult != ConnectivityResult.wifi) {
                        return showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return NoInternetConnectionAlertDialog();
                            });
                      }
                      Route route =
                          MaterialPageRoute(builder: (_) => MyOrderScreen());
                      Navigator.push(context, route);
                    },
                  ),
                  DrawerDivider(), */
                  DrawerItems(
                    leadingIcon: Icons.shopping_bag_outlined,
                    title: "Mis Ordenes de Productos",
                    traillingIcon: Icons.keyboard_arrow_right,
                    onPressed: () async {
                      var connectivityResult =
                          await Connectivity().checkConnectivity();
                      if (connectivityResult != ConnectivityResult.mobile &&
                          connectivityResult != ConnectivityResult.wifi) {
                        return showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return NoInternetConnectionAlertDialog();
                            });
                      }
                      Route route =
                          MaterialPageRoute(builder: (_) => MyOrderScreen());
                      Navigator.push(context, route);
                    },
                  ),
                  DrawerDivider(),
                  DrawerItems(
                    leadingIcon: Icons.miscellaneous_services,
                    title: "Mis Ordenes de Servicios",
                    traillingIcon: Icons.keyboard_arrow_right,
                    onPressed: () async {
                      var connectivityResult =
                          await Connectivity().checkConnectivity();
                      if (connectivityResult != ConnectivityResult.mobile &&
                          connectivityResult != ConnectivityResult.wifi) {
                        return showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return NoInternetConnectionAlertDialog();
                            });
                      }
                      Route route =
                          MaterialPageRoute(builder: (_) => MyServiceOrderScreen());
                      Navigator.push(context, route);
                    },
                  ),
                  DrawerDivider(),
                  DrawerItems(
                    leadingIcon: Icons.note,
                    title: "Mis Notas de Servicio",
                    traillingIcon: Icons.keyboard_arrow_right,
                    onPressed: () async {
                      var connectivityResult =
                          await Connectivity().checkConnectivity();
                      if (connectivityResult != ConnectivityResult.mobile &&
                          connectivityResult != ConnectivityResult.wifi) {
                        return showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return NoInternetConnectionAlertDialog();
                            });
                      }

                      

                      Route route = MaterialPageRoute(builder: (_) => const ViewCarNotes(goToHome: false,));
                      Navigator.push(context, route);
                    },
                  ),
                  DrawerDivider(),
                  DrawerItems(
                    leadingIcon: Icons.shopping_cart_outlined,
                    title: "Mi Carrito",
                    traillingIcon: Icons.keyboard_arrow_right,
                    onPressed: () async {
                      var connectivityResult =
                          await Connectivity().checkConnectivity();
                      if (connectivityResult != ConnectivityResult.mobile &&
                          connectivityResult != ConnectivityResult.wifi) {
                        return showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return NoInternetConnectionAlertDialog();
                          },
                        );
                      }
                      Route route =
                          MaterialPageRoute(builder: (_) => CartScreen());
                      Navigator.push(context, route);
                    },
                  ),
                  DrawerDivider(),
                  DrawerItems(
                    leadingIcon: Icons.favorite_border_outlined,
                    title: "Mis favoritos",
                    traillingIcon: Icons.keyboard_arrow_right,
                    onPressed: () async {
                      var connectivityResult =
                          await Connectivity().checkConnectivity();
                      if (connectivityResult != ConnectivityResult.mobile &&
                          connectivityResult != ConnectivityResult.wifi) {
                        return showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return NoInternetConnectionAlertDialog();
                          },
                        );
                      }
                      Route route =
                          MaterialPageRoute(builder: (_) => WishListScreen());
                      Navigator.push(context, route);
                    },
                  ),
                  DrawerDivider(),
                 /*  DrawerItems(
                    leadingIcon: Icons.calendar_today_outlined,
                    title: "Nuestros servicios",
                    traillingIcon: Icons.keyboard_arrow_right,
                    onPressed: () async {
                      var connectivityResult =
                          await Connectivity().checkConnectivity();
                      if (connectivityResult != ConnectivityResult.mobile &&
                          connectivityResult != ConnectivityResult.wifi) {
                        return showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return NoInternetConnectionAlertDialog();
                          },
                        );
                      }
                      Route route =
                          MaterialPageRoute(builder: (_) => OurService());
                      Navigator.push(context, route);
                    },
                  ), */
                  /* DrawerDivider(), */
                  /* DrawerItems(
                    leadingIcon: Icons.message_outlined,
                    title: "Mi calificación y reseñas",
                    traillingIcon: Icons.keyboard_arrow_right,
                    onPressed: () async {
                      var connectivityResult =
                          await Connectivity().checkConnectivity();
                      if (connectivityResult != ConnectivityResult.mobile &&
                          connectivityResult != ConnectivityResult.wifi) {
                        return showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return NoInternetConnectionAlertDialog();
                          },
                        );
                      }
                      Route route = MaterialPageRoute(
                          builder: (_) => MyReviewAndRating());
                      Navigator.push(context, route);
                    },
                  ),
                  DrawerDivider(), */
                  /* DrawerItems(
                    leadingIcon: Icons.settings,
                    title: "Acerca",
                    traillingIcon: Icons.keyboard_arrow_right,
                    onPressed: () async {
                      var connectivityResult =
                          await Connectivity().checkConnectivity();
                      if (connectivityResult != ConnectivityResult.mobile &&
                          connectivityResult != ConnectivityResult.wifi) {
                        return showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return NoInternetConnectionAlertDialog();
                          },
                        );
                      }
                      Route route =
                          MaterialPageRoute(builder: (_) => AboutScreen());
                      Navigator.push(context, route);
                    },
                  ),
                  DrawerDivider(), */
                  DrawerItems(
                    leadingIcon: Icons.exit_to_app,
                    title: "Cerrar sesión",
                    traillingIcon: Icons.keyboard_arrow_right,
                    onPressed: () async {
                      
                      var connectivityResult =
                          await Connectivity().checkConnectivity();
                      if(connectivityResult == ConnectivityResult.none){
                        return showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return NoInternetConnectionAlertDialog();
                          },
                        );
                      }
                      if (connectivityResult != ConnectivityResult.mobile &&
                          connectivityResult != ConnectivityResult.wifi) {
                        return showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return NoInternetConnectionAlertDialog();
                          },
                        );
                      }

                      bool confirm = await _onBackPressed();
                      if(!mounted) return;
                      if(!confirm) return;
                      await FirebaseFirestore.instance
                      .collection('users')
                      .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
                      .update({
                        "logged":false
                      });
                      Route route = MaterialPageRoute(builder: (_) => SplashScreen());
                      Navigator.pushAndRemoveUntil(context, route, (route) => false);
                      /* AutoParts.auth!.signOut().then((c) {
                        Route route = MaterialPageRoute(builder: (_) => SplashScreen());
                        Navigator.pushAndRemoveUntil(context, route, (route) => false);
                      }); */
                    },
                  ),
                  DrawerDivider(),
                ],
              ),
            ),
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
                onTap: () => Navigator.of(context).pop(true),
                child: Text("YES"),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.015 ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
                child: Text("NO"),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.015 ),
            ],
          ),
        ) ??
        false;
  }
}
