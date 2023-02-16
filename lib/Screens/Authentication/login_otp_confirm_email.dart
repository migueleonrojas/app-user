import 'dart:async';
import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:oilapp/Helper/login_helper.dart';
import 'package:oilapp/Screens/Authentication/login_screen.dart';
import 'package:oilapp/Screens/Authentication/signup_otp_confirm_phone.dart';
import 'package:oilapp/Screens/Authentication/signup_screen.dart';
import 'package:oilapp/Screens/home_screen.dart';
import 'package:oilapp/config/config.dart';
import 'package:oilapp/widgets/progressdialog.dart';

class LoginOtpConfirmEmailScreen extends StatefulWidget {

  final int codeEmail;
  final String emailUser;
  final QuerySnapshot<Map<String, dynamic>> user;

  const LoginOtpConfirmEmailScreen({super.key, required this.codeEmail, required this.emailUser, required this.user});

  @override
  State<LoginOtpConfirmEmailScreen> createState() => _LoginOtpConfirmEmailScreenState();
}

class _LoginOtpConfirmEmailScreenState extends State<LoginOtpConfirmEmailScreen> {

  int codeEmailOtp = 0;
  int timeForTheNextOtp = 0;
  int attempts = 0;
  String codeOtpTextField  = "";
  int? secondsNextOtp;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    codeEmailOtp = widget.codeEmail;
    Future.delayed(Duration.zero,  () async {

      DocumentSnapshot<Map<String, dynamic>> docUser = await FirebaseFirestore.instance
        .collection(AutoParts.collectionUser)
        .doc(widget.user.docs[0].data()['uid'])
        .get();

      DateTime dateTimeForTheNextOtp = (docUser.data() as dynamic)['timeForTheNextOtp'].toDate();

      attempts = (docUser.data() as dynamic)['attempts'];

      DateTime timeNow = DateTime.now();
        
      secondsNextOtp = ((dateTimeForTheNextOtp.millisecondsSinceEpoch - timeNow.millisecondsSinceEpoch)/1000).truncate();

      timer = Timer.periodic(Duration(seconds: 1), (timer) {

        if(secondsNextOtp! < 0) return;
        secondsNextOtp = secondsNextOtp! - 1;
        setState(() {});
              
      });

    });
  }

  @override
  void dispose() {
    
    super.dispose();
    timer!.cancel();
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
                  LoginHelper().loginLog(context),
                  SizedBox(height: MediaQuery.of(context).size.height.toDouble() * 0.010),
                  LoginHelper().subtitleText(
                    msg: "Introduzca el código de confirmación enviada a",
                    size: MediaQuery.of(context).size.height.toDouble() * 0.038,
                    color: Colors.black
                  ),
                  const SizedBox(height: 5),
                  LoginHelper().subtitleText(
                    msg: widget.emailUser,
                    size: MediaQuery.of(context).size.height.toDouble() * 0.025,
                    color: Colors.grey
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height.toDouble() * 0.020),
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
                  SizedBox(height: MediaQuery.of(context).size.height.toDouble() * 0.040),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.030, horizontal: MediaQuery.of(context).size.width * 0.35),
                      backgroundColor: Color.fromARGB(255, 3, 3, 247),
                      shape: const StadiumBorder()
                    ),
                    child: const AutoSizeText("Continuar"),
                    onPressed: () async {
                      
      
                      if(codeOtpTextField.length != 4) {
                        showSnackBar(title: 'Debe ingresar los 4 digitos.');
                        return; 
                      }
                      else if(codeOtpTextField != codeEmailOtp.toString()){

                        if(attempts >= 3) {
                          return;
                        }
                        attempts++;
                        await FirebaseFirestore.instance
                          .collection(AutoParts.collectionUser)
                          .doc(widget.user.docs[0].data()['uid'])
                          .update({
                            "attempts": attempts
                          });
                        if(attempts >= 3) {
                          await FirebaseFirestore.instance
                            .collection(AutoParts.collectionUser)
                            .doc(widget.user.docs[0].data()['uid'])
                            .update({
                              "timeForTheNextOtp": DateTime.now().add(Duration(hours: 1))
                            });
                          secondsNextOtp = ((DateTime.now().add(Duration(hours: 1)).millisecondsSinceEpoch - DateTime.now().millisecondsSinceEpoch)/1000).truncate();
                        }



                        showSnackBar(title: 'El código ingresado esta errado.');
                        return; 
                      }
                      else{
                        showSnackBar(title: 'El código ingresado es exitoso.', seconds: 2);
                        await FirebaseFirestore.instance
                          .collection(AutoParts.collectionUser)
                          .doc(widget.user.docs[0].data()['uid'])
                          .update({
                            "attempts": 0
                          });
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
                        showSnackBar(title: 'Ingreso con exito a Global Oil.');
                        Route route = MaterialPageRoute(builder: (_) => HomeScreen());
                        Navigator.pushAndRemoveUntil(context, route, (route) => false);
                      }
      
                      
                    }
                  ),
                  SizedBox(height:  MediaQuery.of(context).size.height.toDouble() * 0.050),
                  if(secondsNextOtp != null && secondsNextOtp! < 0)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 20, horizontal: MediaQuery.of(context).size.width * 0.15),
                      backgroundColor: Color.fromARGB(255, 3, 3, 247),
                      shape: const StadiumBorder()
                    ),
                    child: const AutoSizeText("Enviar nuevo código"),
                    onPressed: () async {
                      int codeEmail = Random().nextInt(9999 - 1000 + 1) + 1000;
                      bool confirmSend = await sendCodeByEmail(codeEmail);
                      if(!confirmSend){
                        showSnackBar(title: 'El codigo no se pudo enviar, intente de nuevo.');
                        return;
                      }
                      await FirebaseFirestore.instance
                            .collection(AutoParts.collectionUser)
                            .doc(widget.user.docs[0].data()['uid'])
                            .update({
                              "timeForTheNextOtp": DateTime.now().add(Duration(seconds: 90))
                            });
                      secondsNextOtp = ((DateTime.now().add(Duration(seconds: 90)).millisecondsSinceEpoch - DateTime.now().millisecondsSinceEpoch)/1000).truncate();
                      showSnackBar(title: 'El codigo se envio de nuevo a ${widget.emailUser}.');
                      codeEmailOtp = codeEmail; 
                      setState(() {});
                    }
                  ),
                  if(secondsNextOtp != null && secondsNextOtp! > 0)
                  textNextTimeOtp(secondsNextOtp!)
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
      "logged":true,
      "tokenFirebaseToken":tokenFirebaseMsg
    });

  }

  Widget textNextTimeOtp(int secondsNextOtp) {
    Text timeNextOtp = Text('');
    if(secondsNextOtp < 0){
      return timeNextOtp;
    }
    
    int hourRest =   (secondsNextOtp/60/60).truncate();

    int minutesRest =  ((secondsNextOtp/60) - ( (hourRest * 60) )).truncate();
        
    int secondRest =  ((secondsNextOtp) - ( (hourRest * 60 * 60) + (minutesRest * 60)  )).truncate();

    String contentCountDown = '';

    if(secondsNextOtp <= 90) {

      contentCountDown = 'Restan ${minutesRest} minutos ${secondRest} segundos, para reenviar otp.';
      timeNextOtp = Text(contentCountDown);
      
    }
    else {
      contentCountDown = 'Restan ${minutesRest} minutos ${secondRest} segundos, para reenviar otp.';
      timeNextOtp = Text(contentCountDown);
    }

    return timeNextOtp;

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