import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:oil_app/Helper/login_helper.dart';
import 'package:oil_app/Screens/Authentication/login_screen.dart';
import 'package:oil_app/Screens/Authentication/signup_otp_confirm_phone.dart';
import 'package:oil_app/Screens/Authentication/signup_screen.dart';
import 'package:oil_app/config/config.dart';
import 'package:oil_app/widgets/progressdialog.dart';

class SignUpOtpConfirmEmailScreen extends StatefulWidget {

  final int codeEmail;
  final String phoneUser; 
  final String emailUser;
  final String nameUser;


  const SignUpOtpConfirmEmailScreen({super.key, required this.codeEmail, required this.phoneUser, required this.emailUser, required this.nameUser});

  @override
  State<SignUpOtpConfirmEmailScreen> createState() => _SignUpOtpConfirmEmailScreenState();
}

class _SignUpOtpConfirmEmailScreenState extends State<SignUpOtpConfirmEmailScreen> {

  int codeEmailOtp = 0;
  String codeOtpTextField  = "";

  @override
  void initState() {
    super.initState();
    codeEmailOtp = widget.codeEmail;
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
                  SizedBox(height: (MediaQuery.of(context).size.height * 0.025).toDouble()),
                  LoginHelper().loginLog(context),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.014),
                  LoginHelper().subtitleText(
                    msg: "Introduzca el código de confirmación enviada a",
                    size: MediaQuery.of(context).size.height * 0.038,
                    color: Colors.black
                  ),
                  SizedBox(height: (MediaQuery.of(context).size.height * 0.025).toDouble()),
                  LoginHelper().subtitleText(
                    msg: widget.emailUser,
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
                    child: const AutoSizeText(
                      "Continuar",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      
      
                      if(codeOtpTextField.length != 4) {
                        showSnackBar(title: 'Debe ingresar los 4 digitos.');
                        return; 
                      }
                      else if(codeOtpTextField != codeEmailOtp.toString()){
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
                        /* Route route = MaterialPageRoute(builder: (_) => SignUpOtpConfirmPhoneScreen(
                          codeEmail: codeEmailOtp,
                          emailUser: widget.emailUser,
                          nameUser: widget.nameUser,
                          phoneUser: widget.phoneUser,
                        ));
                        Navigator.pushAndRemoveUntil(context, route, (route) => false); */
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
                    child: const AutoSizeText(
                      "Enviar nuevo código",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      int codeEmail = Random().nextInt(9999 - 1000 + 1) + 1000;
                      bool confirmSend = await sendCodeByEmail(codeEmail);
                      if(!confirmSend){
                        showSnackBar(title: 'El codigo no se pudo enviar, intente de nuevo.');
                        return;
                      }
                      showSnackBar(title: 'El codigo se envio de nuevo a ${widget.emailUser}');
                      codeEmailOtp = codeEmail; 
                      setState(() {});
                    }
                  ),
                ],
              ),
             )
          )
      
        ),
      )
    );

  }

    Future <bool> sendCodeByEmail(int code) async{

    String username = 'migueleonrojas@gmail.com';
    String password = 'iguqlscuzmzjyrpy';

    try{
      final smtpServer = gmail(username, password);
      final message = Message()
      ..from = Address(username)
      ..recipients.add(widget.emailUser)
      ..subject = 'Validando Registro en el app'
      ..text = ''
      ..html = ''' 
        <h2>Validando registro en el app</h2>
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
      "url": "https://firebasestorage.googleapis.com/v0/b/globaloil-d853e.appspot.com/o/no-image-user.png?alt=media&token=0e64926c-3058-4092-a918-b30d50a49a13",
      "logged": false,
      "attempts": 0,
      "timeForTheNextOtp": DateTime.now(),
      "tokenFirebaseToken":tokenFirebaseMsg,
      AutoParts.userCartList: ["garbageValue"],
    });
    await AutoParts.sharedPreferences!.setString("uid", userId);
    await AutoParts.sharedPreferences!.setString(AutoParts.userEmail, widget.emailUser);
    await AutoParts.sharedPreferences!.setString(AutoParts.tokenFirebaseMsg, tokenFirebaseMsg!);
    await AutoParts.sharedPreferences!.setString(AutoParts.userName, widget.nameUser);
    await AutoParts.sharedPreferences!.setString(AutoParts.userPhone, phoneUser);
    await AutoParts.sharedPreferences!.setString(AutoParts.userAddress, 'Venezuela');
    await AutoParts.sharedPreferences!.setString(AutoParts.userAvatarUrl, "https://firebasestorage.googleapis.com/v0/b/globaloil-d853e.appspot.com/o/no-image-user.png?alt=media&token=0e64926c-3058-4092-a918-b30d50a49a13");
    await AutoParts.sharedPreferences!.setStringList(AutoParts.userCartList, ["garbageValue"]);

  }
}