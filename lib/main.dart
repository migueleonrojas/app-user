
import 'package:fluttertoast/fluttertoast.dart';
import 'package:oilapp/Helper/login_helper.dart';
import 'package:oilapp/Screens/splash_screen.dart';
import 'package:oilapp/config/config.dart';
import 'package:oilapp/counter/changeAddress.dart';
import 'package:oilapp/counter/service_item_counter.dart';
import 'package:oilapp/counter/service_total_money.dart';
import 'package:oilapp/counter/wishlist_item_count.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:oilapp/counter/cart_item_counter.dart';
import 'package:oilapp/counter/total_money.dart';
import 'package:firebase_messaging/firebase_messaging.dart';



initFirebaseMessaging() async {

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: true,
    badge: true,
    carPlay: true,
    criticalAlert: true,
    provisional: false,
    sound: true,

  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessageOpenedApp.listen((event) { 
      Fluttertoast.showToast(
      msg: "Notificacion desde Firebase, se toco la not",
      toastLength: Toast.LENGTH_LONG
    );
  });

  
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
 
    Fluttertoast.showToast(
      msg: "Notificacion desde Firebase",
      toastLength: Toast.LENGTH_LONG
    );
    
    /* print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}'); */

    if (message.notification != null) {
      /* print('Message also contained a notification: ${message.notification}'); */
    }
  });

}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  /* sendMessageWs(
    msg: "Mensaje cuando la app esta cerrada",
    useTemplate: false

  ); */
  /* print("Handling a background message: ${message.messageId}"); */
}



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  
  await Firebase.initializeApp();
  await initFirebaseMessaging();
  
  AutoParts.auth = FirebaseAuth.instance;
  AutoParts.sharedPreferences = await SharedPreferences.getInstance();
  /* AutoParts.firebaseAppCheck = FirebaseAppCheck.instance;
  await AutoParts.firebaseAppCheck!.activate(
     webRecaptchaSiteKey: '92933631-F622-40CC-9DC6-DA96A6491FC2',
     androidProvider: AndroidProvider.playIntegrity
  ); */
  AutoParts.firestore = FirebaseFirestore.instance;
  


  runApp(const MyApp());

 
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (c) => LoginHelper()),
        ChangeNotifierProvider(create: (c) => CartItemCounter()),
        ChangeNotifierProvider(create: (c) => WishListItemCounter()),
        ChangeNotifierProvider(create: (c) => ServiceItemCounter()),
        ChangeNotifierProvider(create: (c) => AddressChange()),
        ChangeNotifierProvider(create: (c) => TotalAmount()),
        ChangeNotifierProvider(create: (c) => ServiceTotalPrice()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MetaOil',
        theme: ThemeData(
          primaryColor: Colors.deepOrange,
          accentColor: Colors.deepOrangeAccent,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
            backgroundColor: Colors.white,
            titleTextStyle: TextStyle(color: Colors.black)
          )
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
