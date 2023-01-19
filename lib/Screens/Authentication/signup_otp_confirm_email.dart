import 'dart:math';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:oilapp/Helper/login_helper.dart';
import 'package:oilapp/Screens/Authentication/signup_otp_confirm_phone.dart';
import 'package:oilapp/Screens/Authentication/signup_screen.dart';

class SignUpOtpConfirmEmailScreen extends StatefulWidget {

  final int codeEmail;
  final int codeNumber;
  final String phoneUser; 
  final String emailUser;
  final String nameUser;


  const SignUpOtpConfirmEmailScreen({super.key, required this.codeEmail, required this.codeNumber, required this.phoneUser, required this.emailUser, required this.nameUser});

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
                    msg: widget.emailUser,
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
                      bool confirmSend = await sendCodeByEmail(codeEmail);
                      if(!confirmSend){
                        showSnackBar(title: 'El codigo no se pudo enviar, intente de nuevo.');
                        return;
                      }
                      codeEmailOtp = codeEmail; 
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
                    onPressed: () {
                      
      
                      if(codeOtpTextField.length != 4) {
                        showSnackBar(title: 'Debe ingresar los 4 digitos.');
                        return; 
                      }
                      else if(codeOtpTextField != codeEmailOtp.toString()){
                        showSnackBar(title: 'El código ingresado esta errado.');
                        return; 
                      }
                      else{
                        showSnackBar(title: 'El código ingresado es exitoso.');
                        Route route = MaterialPageRoute(builder: (_) => SignUpOtpConfirmPhoneScreen(
                          codeEmail: codeEmailOtp,
                          codeNumber: widget.codeNumber,
                          emailUser: widget.emailUser,
                          nameUser: widget.nameUser,
                          phoneUser: widget.phoneUser,
                        ));
                        Navigator.pushAndRemoveUntil(context, route, (route) => false);
                      }
      
                      
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

    String username = 'info@globaloil.app';
    String password = 'rzvkfjuolafkuquf';

    try{
      final smtpServer = gmail(username, password);
      final message = Message()
      ..from = Address(username)
      ..recipients.add(widget.emailUser)
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