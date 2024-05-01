import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:oil_app/Helper/login_helper.dart';
import 'package:oil_app/Screens/Authentication/login_screen.dart';
import 'package:oil_app/Screens/Authentication/signup_screen.dart';
import 'package:oil_app/Screens/home_screen.dart';
import 'package:oil_app/Screens/myaccount_screen.dart';
import 'dart:convert';

import 'package:oil_app/config/config.dart';
import 'package:oil_app/widgets/progressdialog.dart';

class UpdateOtpConfirmPhoneScreen extends StatefulWidget {

  
  final int codeNumber;
  final String phoneUser; 

  final QuerySnapshot<Map<String, dynamic>> user;

  const UpdateOtpConfirmPhoneScreen({super.key, required this.codeNumber, required this.phoneUser, required this.user});

  @override
  State<UpdateOtpConfirmPhoneScreen> createState() => _UpdateOtpConfirmPhoneScreenState();
}

class _UpdateOtpConfirmPhoneScreenState extends State<UpdateOtpConfirmPhoneScreen> {

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
          /* Route route = MaterialPageRoute(builder: (_) => MyAccountScreen());
          Navigator.pushAndRemoveUntil(context, route, (route) => false); */
          Navigator.of(context).pop(false);  
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
                  SizedBox(height: (MediaQuery.of(context).size.height * 0.025).toDouble()),
                  LoginHelper().loginLog(context),
                  SizedBox(height: (MediaQuery.of(context).size.height * 0.025).toDouble()),
                  LoginHelper().subtitleText(
                    msg: "Introduzca el código de confirmación enviada a",
                    size: MediaQuery.of(context).size.height * 0.038,
                    color: Colors.black
                  ),
                  SizedBox(height: (MediaQuery.of(context).size.height * 0.025).toDouble()),
                  LoginHelper().subtitleText(
                    msg: '+${widget.phoneUser}',
                    size: (MediaQuery.of(context).size.height * 0.025).toDouble(),
                    color: Colors.grey
                  ),
                  SizedBox(height: (MediaQuery.of(context).size.height * 0.025).toDouble()),
                  OtpTextField(
                    fieldWidth: (MediaQuery.of(context).size.height * 0.065).toDouble(),
                    numberOfFields: 4,
                    borderColor: const Color.fromARGB(255, 32, 190, 190),
                    showFieldAsBox: true, 
                    
                    onSubmit: (String verificationCode){
                      codeOtpTextField = verificationCode;
                      setState(() {});
                    }
                  ),
                  SizedBox(height: (MediaQuery.of(context).size.height * 0.045).toDouble()),
                  
                  
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: (MediaQuery.of(context).size.height * 0.030).toDouble(), horizontal: MediaQuery.of(context).size.width * 0.35),
                      backgroundColor: Color.fromARGB(255, 3, 3, 247),
                      shape: const StadiumBorder()
                    ),
                    child: const AutoSizeText("Continuar"),
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
                        showSnackBar(title: 'El código ingresado es exitoso.', seconds: 2);

                        
                        
                        if(!mounted) return;
                        Navigator.of(context).pop(true);                        
                      }
      
                      
                    }
                  ),
                  SizedBox(height: (MediaQuery.of(context).size.height * 0.045).toDouble()),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: (MediaQuery.of(context).size.height * 0.030).toDouble(), horizontal: MediaQuery.of(context).size.width * 0.15),
                      backgroundColor: Color.fromARGB(255, 3, 3, 247),
                      shape: const StadiumBorder()
                    ),
                    child: const AutoSizeText("Enviar nuevo código"),
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
                      showSnackBar(title: 'El codigo se envio de nuevo a +${widget.phoneUser}');
                      codePhoneOtp = codeEmail; 
                      setState(() {});
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
      content: AutoSizeText(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 15),
      ),
      duration: Duration(seconds: seconds),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }
}