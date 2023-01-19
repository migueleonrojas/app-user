import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:oilapp/Helper/login_helper.dart';
import 'package:oilapp/Screens/Authentication/login_screen.dart';
import 'package:oilapp/Screens/Authentication/signup_screen.dart';
import 'package:oilapp/Screens/home_screen.dart';
import 'dart:convert';

import 'package:oilapp/config/config.dart';
import 'package:oilapp/widgets/progressdialog.dart';

class LoginOtpConfirmPhoneScreen extends StatefulWidget {

  
  final int codeNumber;
  final String phoneUser; 

  final QuerySnapshot<Map<String, dynamic>> user;

  const LoginOtpConfirmPhoneScreen({super.key, required this.codeNumber, required this.phoneUser, required this.user});

  @override
  State<LoginOtpConfirmPhoneScreen> createState() => _LoginOtpConfirmPhoneScreenState();
}

class _LoginOtpConfirmPhoneScreenState extends State<LoginOtpConfirmPhoneScreen> {

  int codePhoneOtp = 0;
  String codeOtpTextField  = "";

  @override
  void initState() {
    super.initState();
    codePhoneOtp = widget.codeNumber;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          Route route = MaterialPageRoute(builder: (_) => LoginScreen());
          Navigator.pushAndRemoveUntil(context, route, (route) => false);
          return false;
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment:CrossAxisAlignment.center,
                children: [
                   const SizedBox(height: 10),
                  LoginHelper().loginLog(),
                  const SizedBox(height: 10),
                  LoginHelper().subtitleText(
                    msg: "Introduzca el código de confirmación enviada a",
                    size: 32,
                    color: Colors.black
                  ),
                  const SizedBox(height: 5),
                  LoginHelper().subtitleText(
                    msg: '+${widget.phoneUser}',
                    size: 17,
                    color: Colors.grey
                  ),
                  const SizedBox(height: 25),
                  OtpTextField(
                    fieldWidth: 50,
                    numberOfFields: 4,
                    borderColor: const Color.fromARGB(255, 32, 190, 190),
                    showFieldAsBox: true, 
                    
                    onSubmit: (String verificationCode){
                      codeOtpTextField = verificationCode;
                      setState(() {});
                    }
                  ),
                  const SizedBox(height: 45),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 20, horizontal: MediaQuery.of(context).size.width * 0.15),
                      backgroundColor: Color.fromARGB(255, 3, 3, 247),
                      shape: const StadiumBorder()
                    ),
                    child: const Text("Enviar nuevo código"),
                    onPressed: () async {
                      int codeEmail = Random().nextInt(9999 - 1000 + 1) + 1000;
                      bool confirmSend= await sendCodeByPhone(
                        int.parse('${widget.phoneUser}'),
                        codeEmail.toString()
                      );
                      if(!confirmSend){
                        showSnackBar(title: 'El codigo no se pudo enviar, intente de nuevo.');
                        return;
                      }
                      codePhoneOtp = codeEmail; 
                      setState(() {});
                    }
                  ),
                  const SizedBox(height: 45),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 20, horizontal: MediaQuery.of(context).size.width * 0.35),
                      backgroundColor: Color.fromARGB(255, 3, 3, 247),
                      shape: const StadiumBorder()
                    ),
                    child: const Text("Continuar"),
                    onPressed: () async {
                      
      
                      if(codeOtpTextField.length != 4) {
                        showSnackBar(title: 'Debe ingresar los 4 digitos.');
                        return; 
                      }
                      else if(codeOtpTextField != codePhoneOtp.toString()){
                        showSnackBar(title: 'El código ingresado esta errado.');
                        return; 
                      }
                      else{
                        showSnackBar(title: 'El código ingresado es exitoso.');

                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (BuildContext context) => const ProgressDialog(
                            status: "Ingresando, Por favor espere....",
                          ),
                        );
                        await loginUser();
                        if(!mounted) return;
                        Navigator.pop(context);
                        Route route = MaterialPageRoute(builder: (_) => HomeScreen());
                        Navigator.pushAndRemoveUntil(context, route, (route) => false);
                        
                      }
      
                      
                    }
                  ),
                ]
              )
            )
          )
        ),
      )
    );
  }

  Future <bool>  sendCodeByPhone(int number, String msg) async {
    String accessToken = 'EAAISTvJmRyQBAHzIjVlyfS3q4CG8I2VV00XlAQZBhWXWwfMjV2h4SKWcpiOS7ep2WoT8Ig21RE9RwQ72Pu5TzSJpcmEASp5u4NJJZBViSsTW3ipu4g84kdq1mt5iGHgRArZCljY7rcopueWvKr4tmLCPWTKBHqS5ZBwQjIcZAP7Yt9FgCcZB3D';
    final url = Uri.parse('https://graph.facebook.com/v15.0/115672898059238/messages');
    final headers = {
      "Content-type": "application/json",
      'Authorization': 'Bearer $accessToken', 
    };


    final json = jsonEncode({
      "messaging_product":"whatsapp",
      "to":number.toString(),
      "type": "template",
      "template": {
        "name": "sample_shipping_confirmation",
        "language": {
          "code": "en_US"
        },
        "components":[
          {
				    "type": "body",
				    "parameters": [
        	    {
         		    "type": "text",
         		    "text": msg
         	    }
            ]
			    }	
        ]
      }
    });

    try {

      final response = await http.post(url, headers: headers, body: json);
      return true;
    }
    catch(e) {
      return false;
    }

    
  }

  loginUser() async {

    

    FirebaseMessaging messaging = FirebaseMessaging.instance;
      final String? tokenFirebaseMsg = await messaging.getToken();
  

    await AutoParts.sharedPreferences!.setString("uid", widget.user.docs[0].data()["uid"]);
    await AutoParts.sharedPreferences!.setString(AutoParts.userEmail, widget.user.docs[0].data()["email"]);
    await AutoParts.sharedPreferences!.setString(AutoParts.userName, widget.user.docs[0].data()["name"]);
    await AutoParts.sharedPreferences!.setString(AutoParts.userPhone, widget.user.docs[0].data()["phone"]);
    await AutoParts.sharedPreferences!.setString(AutoParts.tokenFirebaseMsg, tokenFirebaseMsg!);
    await AutoParts.sharedPreferences!.setString(AutoParts.userAvatarUrl, widget.user.docs[0].data()["url"]);
    List<String> cartList = widget.user.docs[0].data()["userCart"].cast<String>();
    await AutoParts.sharedPreferences!.setStringList(AutoParts.userCartList, cartList);
    await widget.user.docs[0].reference.update({
      "logged":true
    });
  }

  void showSnackBar({required String title, int seconds = 4}) {
    final snackbar = SnackBar(
      content: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 15),
      ),
      duration: Duration(seconds: seconds),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }
}