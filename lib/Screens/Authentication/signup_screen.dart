
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
import 'package:oilapp/Screens/Authentication/login_screen.dart';
import 'package:oilapp/Screens/Authentication/signup_otp_confirm_email.dart';
import 'package:oilapp/widgets/noInternetConnectionAlertDialog.dart';
import 'package:oilapp/widgets/progressdialog.dart';
import 'dart:convert';
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _userPhoneTextEditingController = TextEditingController();
  final _emailTextEditingController = TextEditingController();
  final _nameTextEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment:CrossAxisAlignment.center ,
              children: [
                SizedBox(height: (MediaQuery.of(context).size.height * 0.010).toDouble()),
                LoginHelper().loginLog(context),
                SizedBox(height: (MediaQuery.of(context).size.height * 0.010).toDouble()),
                LoginHelper().subtitleText(
                  msg: "Registro de usuario",
                  size: (MediaQuery.of(context).size.height * 0.040).toDouble(),
                  color: Colors.black
                ),
                SizedBox(height: (MediaQuery.of(context).size.height * 0.010).toDouble()),
                LoginHelper().subtitleText(
                  msg: "Se enviará un código de confirmación a su número y correo para registrarse en la aplicación",
                  size: (MediaQuery.of(context).size.height * 0.023).toDouble(),
                  color: Colors.grey
                ),
                SizedBox(height: (MediaQuery.of(context).size.height * 0.025).toDouble()),
                Form(
                  
                  child: Column(
                    children: [
                      SizedBox(
                        
                        width: MediaQuery.of(context).size.width * 0.80,
                        child: TextFormField(
                          controller: _nameTextEditingController,
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                          
                            hintText: "Nombre",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height.toDouble() * 0.035),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: (MediaQuery.of(context).size.height * 0.015).toDouble()),
                      SizedBox(
                        
                        width: MediaQuery.of(context).size.width * 0.80,
                        child: TextFormField(
                          controller: _userPhoneTextEditingController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                          
                            hintText: "04141234567",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height.toDouble() * 0.035),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: (MediaQuery.of(context).size.height * 0.015).toDouble()),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.80,
                        child: TextFormField(
                          controller: _emailTextEditingController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "correo@dominio.com",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height.toDouble() * 0.035),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: (MediaQuery.of(context).size.height * 0.065).toDouble()),
                
                
                ElevatedButton(
                
                  child: const AutoSizeText("Continuar"),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.030, horizontal: MediaQuery.of(context).size.width * 0.35),
                    backgroundColor: Color.fromARGB(255, 3, 3, 247),
                    shape: const StadiumBorder()

                    
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
                    

                    if(_userPhoneTextEditingController.text.isEmpty && _emailTextEditingController.text.isEmpty && _nameTextEditingController.text.isEmpty) {
                      if(!mounted) return;
                      Navigator.pop(context);
                      showSnackBar(title: 'Ingrese todos los campos');
                      return;
                    }

                    if(_nameTextEditingController.text.length < 3) {
                      if(!mounted) return;
                      Navigator.pop(context);
                      showSnackBar(title: 'Ingrese un nombre valido');
                      return;
                    }

                    if (!_emailTextEditingController.text.contains("@")) {
                      if(!mounted) return;
                      Navigator.pop(context);
                      showSnackBar(title: "Por favor ingrese su dirección de correo electrónico válido");
                      return;
                    }
                    final phoneRegExp = RegExp(r'^(041(2|4|6)|042(4|6))[0-9]{7}$');
                    if(!phoneRegExp.hasMatch(_userPhoneTextEditingController.text.trim())){
                      if(!mounted) return;
                      Navigator.pop(context);
                      showSnackBar(
                        title: "Número con formato incorrecto. Ejemplo: 04125556987",
                        seconds: 7
                      );
                      return;
                    }

                    String phone = '58${_userPhoneTextEditingController.text.replaceFirst('0', '')}';
              
                    QuerySnapshot<Map<String, dynamic>> phoneExist = await FirebaseFirestore.instance.collection('users').where('phone',isEqualTo: phone).get();
                    QuerySnapshot<Map<String, dynamic>> emailExist = await FirebaseFirestore.instance.collection('users').where('email',isEqualTo: _emailTextEditingController.text.toLowerCase().trim()).get();
                    if(phoneExist.size >= 1 || emailExist.size >= 1){
                      showSnackBar(title: 'El teléfono o el correo ya esta registrado');
                      if(!mounted) return;
                      Navigator.pop(context);
                      return;
                    }
                    
                    
                    int codeEmail = Random().nextInt(9999 - 1000 + 1) + 1000;
                    int codeNumber = Random().nextInt(9999 - 1000 + 1) + 1000;
                    String phoneUser = _userPhoneTextEditingController.text.toLowerCase().trim();
                    String emailUser = _emailTextEditingController.text.toLowerCase().trim();
                    String nameUser = _nameTextEditingController.text.toLowerCase().trim();

                    bool confirmSendPhone = await sendCodeByPhone(int.parse(phone), '$codeNumber');
                    bool confirmSendEmail = await sendCodeByEmail(codeEmail);
                    if(!confirmSendPhone || !confirmSendEmail){
                      showSnackBar(title: 'No se enviaron los codigos, intentelo de nuevo');
                      if(!mounted) return;
                      Navigator.pop(context);
                      return;
                    }
                    if(!mounted) return;
                    Navigator.pop(context);
                    Route route = MaterialPageRoute(builder: (_) => SignUpOtpConfirmEmailScreen(
                      codeEmail: codeEmail,
                      codeNumber: codeNumber,
                      phoneUser: phoneUser,
                      emailUser: emailUser,
                      nameUser: nameUser,
                    ));
                    Navigator.pushAndRemoveUntil(context, route, (route) => false);

                  }, 

                ),
                SizedBox(height: (MediaQuery.of(context).size.height * 0.025).toDouble()),
                Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  AutoSizeText(
                    'Ya tienes una cuenta ?',
                    style: TextStyle(
                      fontSize: (MediaQuery.of(context).size.height * 0.025).toDouble(),
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (c) => LoginScreen(),
                        ),
                      );
                    },
                    child: AutoSizeText(
                      ' Entre Aquí',
                      style: TextStyle(
                        color: Colors.red[300],
                        fontSize: (MediaQuery.of(context).size.height * 0.025).toDouble(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              ],
            ),
          ),
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

    String username = 'info@globaloil.app';
    String password = 'rzvkfjuolafkuquf';

    try{
      final smtpServer = gmail(username, password);
      final message = Message()
      ..from = Address(username)
      ..recipients.add(_emailTextEditingController.text.toLowerCase().trim())
      ..subject = 'Validando Registro en el app Global Oil'
      ..text = ''
      ..html = ''' 
        <h2>Validando registro en el app Global Oil</h2>
        <br/>
        <p>Valide su registro ingresando el siguiente codigo en el app <b>$code</b></p>
      '''
      ;
       final sendReport = await send(message, smtpServer);
      return true;
    }
    catch(e){
      
      return false;
    }

    
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
}


