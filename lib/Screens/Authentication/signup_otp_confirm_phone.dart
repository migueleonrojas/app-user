import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:oilapp/Helper/login_helper.dart';
import 'package:oilapp/Screens/Authentication/login_screen.dart';
import 'package:oilapp/Screens/Authentication/signup_screen.dart';
import 'dart:convert';

import 'package:oilapp/config/config.dart';
import 'package:oilapp/widgets/progressdialog.dart';

class SignUpOtpConfirmPhoneScreen extends StatefulWidget {

  final int codeEmail;
  final int codeNumber;
  final String phoneUser; 
  final String emailUser;
  final String nameUser;

  const SignUpOtpConfirmPhoneScreen({super.key, required this.codeEmail, required this.codeNumber, required this.phoneUser, required this.emailUser, required this.nameUser});

  @override
  State<SignUpOtpConfirmPhoneScreen> createState() => _SignUpOtpConfirmPhoneScreenState();
}

class _SignUpOtpConfirmPhoneScreenState extends State<SignUpOtpConfirmPhoneScreen> {

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
          Route route = MaterialPageRoute(builder: (_) => SignUpScreen());
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
                  SizedBox(height: MediaQuery.of(context).size.height.toDouble() * 0.015),
                  LoginHelper().loginLog(context),
                  SizedBox(height: MediaQuery.of(context).size.height.toDouble() * 0.015),
                  LoginHelper().subtitleText(
                    msg: "Introduzca el código de confirmación enviada a",
                    size: MediaQuery.of(context).size.height.toDouble() * 0.040,
                    color: Colors.black
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height.toDouble() * 0.010),
                  LoginHelper().subtitleText(
                    msg: '+58${widget.phoneUser}'.replaceFirst('0', ''),
                    size: MediaQuery.of(context).size.height.toDouble() * 0.022,
                    color: Colors.grey
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height.toDouble() * 0.030),
                  OtpTextField(
                    fieldWidth: MediaQuery.of(context).size.height.toDouble() * 0.060,
                    numberOfFields: 4,
                    borderColor: const Color.fromARGB(255, 32, 190, 190),
                    showFieldAsBox: true, 
                    
                    onSubmit: (String verificationCode){
                      codeOtpTextField = verificationCode;
                      setState(() {});
                    }
                  ),
                  
                  SizedBox(height: MediaQuery.of(context).size.height.toDouble() * 0.080),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height.toDouble() * 0.030, horizontal: MediaQuery.of(context).size.width * 0.35),
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
                        showSnackBar(title: 'El código ingresado es exitoso.', seconds: 2);

                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (BuildContext context) => const ProgressDialog(
                            status: "Creando Usuario, Por favor espere....",
                          ),
                        );
                        await createUser();
                        if(!mounted) return;
                        Navigator.pop(context);
                        showSnackBar(title: 'El usuario fue creado con exito.');
                        Route route = MaterialPageRoute(builder: (_) => LoginScreen());
                        Navigator.pushAndRemoveUntil(context, route, (route) => false);
                        
                      }
      
                      
                    }
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height.toDouble() * 0.050),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height.toDouble() * 0.030, horizontal: MediaQuery.of(context).size.width * 0.15),
                      backgroundColor: Color.fromARGB(255, 3, 3, 247),
                      shape: const StadiumBorder()
                    ),
                    child: const Text("Enviar nuevo código"),
                    onPressed: () async {
                      int codeEmail = Random().nextInt(9999 - 1000 + 1) + 1000;
                      bool confirmSend= await sendCodeByPhone(
                        int.parse('58${widget.phoneUser}'.replaceFirst('0', '')),
                        codeEmail.toString()
                      );
                      if(!confirmSend){
                        showSnackBar(title: 'El codigo no se pudo enviar, intente de nuevo.');
                        return;
                      }
                      showSnackBar(title: 'El codigo se envio de nuevo a +58${widget.phoneUser.replaceFirst("0","")}');
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

  createUser() async {
    String userId = DateTime.now().microsecondsSinceEpoch.toString();

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    
    String phoneUser = '58${widget.phoneUser}'.replaceFirst('0', '');
    final String? tokenFirebaseMsg = await messaging.getToken();

    FirebaseFirestore.instance.collection("users").doc(userId).set({
      "uid": userId,
      "email": widget.emailUser,
      "name": widget.nameUser,
      "phone": phoneUser,
      "address": "Venezuela",
      "url": "https://firebasestorage.googleapis.com/v0/b/oildatabase-781a4.appspot.com/o/no-image-user.png?alt=media&token=012134ea-3488-4061-ab18-a9f4196b202c",
      "logged": false,
      AutoParts.userCartList: ["garbageValue"],
    });
    await AutoParts.sharedPreferences!.setString("uid", userId);
    await AutoParts.sharedPreferences!.setString(AutoParts.userEmail, widget.emailUser);
    await AutoParts.sharedPreferences!.setString(AutoParts.tokenFirebaseMsg, tokenFirebaseMsg!);
    await AutoParts.sharedPreferences!.setString(AutoParts.userName, widget.nameUser);
    await AutoParts.sharedPreferences!.setString(AutoParts.userPhone, phoneUser);
    await AutoParts.sharedPreferences!.setString(AutoParts.userAddress, 'Venezuela');
    await AutoParts.sharedPreferences!.setString(AutoParts.userAvatarUrl, "https://firebasestorage.googleapis.com/v0/b/oildatabase-781a4.appspot.com/o/no-image-user.png?alt=media&token=03a744f0-5f12-42a2-b709-e68dc0c66128");
    await AutoParts.sharedPreferences!.setStringList(AutoParts.userCartList, ["garbageValue"]);

  }

  void showSnackBar({required String title, int seconds = 4}) {
    final snackbar = SnackBar(
      content: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: MediaQuery.of(context).size.height.toDouble() * 0.020),
      ),
      duration: Duration(seconds: seconds),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }
}