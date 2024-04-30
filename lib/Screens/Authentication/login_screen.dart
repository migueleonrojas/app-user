import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:oilapp/Helper/login_helper.dart';
import 'package:oilapp/Screens/Authentication/login_otp_confirm_email.dart';
import 'package:oilapp/Screens/Authentication/login_otp_confirm_phone.dart';
import 'package:oilapp/config/config.dart';
import 'package:oilapp/widgets/noInternetConnectionAlertDialog.dart';
import 'package:oilapp/widgets/progressdialog.dart';
import 'dart:convert';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<ScaffoldState> scaffoldkey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final _credentialTextEditingController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    return SafeArea(
      
      child: Scaffold(
        backgroundColor: Colors.white,
        key: scaffoldkey,
        body: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment:CrossAxisAlignment.center ,
              
              children: [
                SizedBox(height: (MediaQuery.of(context).size.height * 0.02).toDouble()),
                LoginHelper().loginLog(context),
                SizedBox(height: (MediaQuery.of(context).size.height * 0.02).toDouble()),
                LoginHelper().subtitleText(
                  msg: "Introduzca su número celular o correo",
                  size: (MediaQuery.of(context).size.height * 0.04).toDouble(),
                  color: Colors.black
                ),
                SizedBox(height: (MediaQuery.of(context).size.height * 0.02).toDouble()),
                LoginHelper().subtitleText(
                  msg: 'Se enviará un código de confirmación a su número o correo para conectarse con la aplicación',
                  size: (MediaQuery.of(context).size.height * 0.022).toDouble(),
                  color: Colors.grey
                ),
                SizedBox(height: (MediaQuery.of(context).size.height * 0.02).toDouble()),
                Form(
                  key: _formkey,
                  child: Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.80,
                        child: TextFormField(
                          controller: _credentialTextEditingController,
                          decoration: InputDecoration(
                            hintText: "correo@dominio.com",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height.toDouble() * 0.040),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: (MediaQuery.of(context).size.height * 0.02).toDouble()),
                LoginHelper().donthaveaccount(context),
                SizedBox(height: (MediaQuery.of(context).size.height * 0.03).toDouble()),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: (MediaQuery.of(context).size.height * 0.030).toDouble(), horizontal: MediaQuery.of(context).size.width * 0.35),
                    backgroundColor: Color.fromARGB(255, 3, 3, 247),
                    shape: const StadiumBorder()
                  ),
                  child: const AutoSizeText(
                    "Continuar",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    

                    FocusScope.of(context).requestFocus(FocusNode());
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext context) => const ProgressDialog(
                        status: "Validando Datos, Por favor espere....",
                      ),
                    );
                    
                    final connectivityResult = await Connectivity().checkConnectivity();
                    
                    if(connectivityResult == ConnectivityResult.none) {
                      showSnackBar(title: "No posee conexion a internet");
                      if(!mounted) return;
                      Navigator.pop(context);
                      return showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return NoInternetConnectionAlertDialog();
                        },
                      );
                      
                    }

                    if(_credentialTextEditingController.text.isEmpty) {
                      if(!mounted) return;
                      Navigator.pop(context);
                      showSnackBar(title: 'Ingrese el campo');
                      return;
                    }
                    final phone = RegExp(r'^(041(2|4|6)|042(4|6))[0-9]{7}$');
                    final email = RegExp(r'^[a-zA-Z0-9.-_]+@[a-zA-Z0-9.-_]+\.[A-Za-z]+(\.[a-z]+)?$');
                    bool isEmail = email.hasMatch(_credentialTextEditingController.text.toLowerCase().trim());
                    bool isPhone =  phone.hasMatch(_credentialTextEditingController.text.toLowerCase().trim());




                    if(isEmail){
                      int codeEmail = Random().nextInt(9999 - 1000 + 1) + 1000;
                      String email = _credentialTextEditingController.text.toLowerCase().trim();
                      QuerySnapshot<Map<String, dynamic>> emailExist = await FirebaseFirestore.instance.collection('users').where('email',isEqualTo: email).get();

                      if(emailExist.size == 0){
                        if(!mounted) return;
                        Navigator.pop(context);
                        showSnackBar(title: 'El correo no esta registrado');                        
                        return;
                      }
                      bool confirmSendEmail = await sendCodeByEmail(codeEmail);
                      if(!confirmSendEmail) {
                        showSnackBar(title: 'No se envio el codigo, intentelo de nuevo');
                        if(!mounted) return;
                        Navigator.pop(context);
                        return;
                      }
                      if(emailExist.docs[0].data()['attempts'] < 3){
                        await emailExist.docs[0].reference.update({
                          "timeForTheNextOtp": DateTime.now().add(Duration(seconds: 90))
                        });
                        /* await FirebaseFirestore.instance
                          .collection(AutoParts.collectionUser)
                          .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
                          .update({
                            "timeForTheNextOtp": DateTime.now().add(Duration(seconds: 90))
                          }); */
                      }
                      if(!mounted) return;
                      Navigator.pop(context);
                      Route route = MaterialPageRoute(builder: (_) => LoginOtpConfirmEmailScreen(
                        codeEmail: codeEmail,
                        emailUser: email ,
                        user: emailExist,

                      ));
                      Navigator.pushAndRemoveUntil(context, route, (route) => false);

                    }
                    if(false/* isPhone */) {
                      
                      int codeNumber = Random().nextInt(9999 - 1000 + 1) + 1000;
                      String phone = '58${_credentialTextEditingController.text.toLowerCase().trim().replaceFirst('0', '')}';
                      QuerySnapshot<Map<String, dynamic>> phoneExist = await FirebaseFirestore.instance.collection('users').where('phone',isEqualTo: phone).get();
                      
                      if(phoneExist.size == 0){
                        if(!mounted) return;
                        Navigator.pop(context);
                        showSnackBar(title: 'El teléfono no esta registrado');                        
                        return;
                      }
                      bool confirmSendPhone = await sendCodeByPhone(int.parse(phone), '$codeNumber');
                      if(!confirmSendPhone) {
                        if(!mounted) return;
                        Navigator.pop(context);
                        showSnackBar(title: 'No se envio el codigo, intentelo de nuevo');                        
                        return;
                      }

                      if(phoneExist.docs[0].data()['attempts'] < 3){
                        await phoneExist.docs[0].reference.update({
                          "timeForTheNextOtp": DateTime.now().add(Duration(seconds: 90))
                        });
                        /* await FirebaseFirestore.instance
                          .collection(AutoParts.collectionUser)
                          .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
                          .update({
                            "timeForTheNextOtp": DateTime.now().add(Duration(seconds: 90))
                          }); */
                      }
                      if(!mounted) return;
                      Navigator.pop(context);
                      Route route = MaterialPageRoute(builder: (_) => LoginOtpConfirmPhoneScreen(
                        codeNumber: codeNumber,
                        phoneUser: phoneExist.docs[0].data()["phone"],
                        user: phoneExist,
                        
                      ));
                      Navigator.pushAndRemoveUntil(context, route, (route) => false);
                      
                    }

                    if(!isEmail /* && !isPhone */) {
                      if(!mounted) return;
                      Navigator.pop(context);
                      showSnackBar(title: 'Debe ingresar un correo valido');
                      return;
                    }
                  }, 

                )

              ],
            ),
          ),
        ),
      )
    );
  }

  void showSnackBar({required String title, int seconds = 4}) {
    final snackbar = SnackBar(
      content: AutoSizeText(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: MediaQuery.of(context).size.height.toDouble() * 0.020),
      ),
      duration: Duration(seconds: seconds),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
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
        "name": "sample_shipping_confirmation",//nombre de la plantilla = mensajederegistrootp
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

  Future <bool> sendCodeByEmail(int code) async{

    String username = 'migueleonrojas@gmail.com';
    String password = 'iguqlscuzmzjyrpy';

    try{
      final smtpServer = gmail(username, password);
      final message = Message()
      ..from = Address(username)
      ..recipients.add(_credentialTextEditingController.text.toLowerCase().trim())
      ..subject = 'Validando Acceso en el app'
      ..text = ''
      ..html = ''' 
        <h2>Validando Acceso en el app</h2>
        <br/>
        <p>Valide su Acceso ingresando el siguiente codigo en el app <b>$code</b></p>
      '''
      ;
       final sendReport = await send(message, smtpServer);
      return true;
    }
    catch(e){
      
      return false;
    }

    
  }
  
}


