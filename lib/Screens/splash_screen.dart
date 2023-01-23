import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oilapp/Helper/login_helper.dart';
import 'package:oilapp/Screens/home_screen.dart';
import 'package:oilapp/config/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:oilapp/Screens/Authentication/login_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero,() async {
      if(AutoParts.sharedPreferences!.getString(AutoParts.userUID) == null) {
        
        Route route = MaterialPageRoute(builder: (_) => const LoginScreen());
        Navigator.pushReplacement(context, route);
        
        return;
      }

      QuerySnapshot<Map<String, dynamic>> user = await AutoParts.firestore!
        .collection(AutoParts.collectionUser)
        .where("uid",isEqualTo: AutoParts.sharedPreferences!.getString(AutoParts.userUID))
        .get();

      if(user.size != 0  ){

        if(user.docs[0].data()["logged"] == true){
          
          Route route = MaterialPageRoute(builder: (_) => HomeScreen());
          Navigator.pushReplacement(context, route);
          
        }
        else{
          
          Route route = MaterialPageRoute(builder: (_) => LoginScreen());
          Navigator.pushReplacement(context, route);
         
        } 
      }
      else {
        
        Route route = MaterialPageRoute(builder: (_) => LoginScreen());
        Navigator.pushReplacement(context, route);
         
      }
      
    });

    /* Timer(const Duration(seconds: 0), () async {

      if(AutoParts.sharedPreferences!.getString(AutoParts.userUID) == null) {
        
        Route route = MaterialPageRoute(builder: (_) => LoginScreen());
        Navigator.pushReplacement(context, route);
        
        return;
      }
      
      QuerySnapshot<Map<String, dynamic>> user = await AutoParts.firestore!
        .collection(AutoParts.collectionUser)
        .where("uid",isEqualTo: AutoParts.sharedPreferences!.getString(AutoParts.userUID))
        .get();
      
      if(user.size != 0  ){

        if(user.docs[0].data()["logged"] == true){
          
          Route route = MaterialPageRoute(builder: (_) => HomeScreen());
          Navigator.pushReplacement(context, route);
          
        }
        else{
          
          Route route = MaterialPageRoute(builder: (_) => LoginScreen());
          Navigator.pushReplacement(context, route);
         
        } 
      }

      else {
        
        Route route = MaterialPageRoute(builder: (_) => LoginScreen());
        Navigator.pushReplacement(context, route);
         
      }
      
    }); */
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          //-------------------logo & title-----------------------//
          Expanded(
            flex: 2,
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  LoginHelper().loginLog(),
                  const Padding(
                    padding: EdgeInsets.only(top: 10.0),
                  ),
                ],
              ),
            ),
          ),
          //------------------------short msg----------------------------//
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget> [
                SpinKitThreeBounce(
                  color: Colors.deepOrangeAccent,
                  size: 25.0,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20.0),
                ),
                Text(
                  'Ahorre tiempo \nAdministrece con Global Oil',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  
}
