import 'dart:math';
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
                const SizedBox(height: 10),
                LoginHelper().loginLog(),
                const SizedBox(height: 10),
                LoginHelper().subtitleText(
                  msg: "Introduzca su número celular o correo",
                  size: 32,
                  color: Colors.black
                ),
                const SizedBox(height: 30),
                LoginHelper().subtitleText(
                  msg: 'Se enviará un código de confirmación a su número o correo para conectarse con la aplicación',
                  size: 14,
                  color: Colors.grey
                ),
                const SizedBox(height: 30),
                Form(
                  key: _formkey,
                  child: Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.80,
                        child: TextFormField(
                          controller: _credentialTextEditingController,
                          decoration: InputDecoration(
                            hintText: "04141234567 o correo@dominio.com",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                LoginHelper().donthaveaccount(context),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: MediaQuery.of(context).size.width * 0.35),
                    backgroundColor: Color.fromARGB(255, 3, 3, 247),
                    shape: const StadiumBorder()
                  ),
                  child: const Text("Continuar"),
                  onPressed: () async {

                    FocusScope.of(context).requestFocus(FocusNode());
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext context) => const ProgressDialog(
                        status: "Validando Datos, Por favor espere....",
                      ),
                    );
                    var connectivityResult =
                        await Connectivity().checkConnectivity();
                    if (connectivityResult != ConnectivityResult.mobile &&
                        connectivityResult != ConnectivityResult.wifi) {
                      if(!mounted) return;
                      Navigator.pop(context);
                      showSnackBar(title: "No internet connectivity");
                      
                      return;
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
                      if(!mounted) return;
                      Navigator.pop(context);
                      Route route = MaterialPageRoute(builder: (_) => LoginOtpConfirmEmailScreen(
                        codeEmail: codeEmail,
                        emailUser: email ,
                        user: emailExist,

                      ));
                      Navigator.pushAndRemoveUntil(context, route, (route) => false);

                    }
                    if(isPhone) {
                      
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

                      if(!mounted) return;
                      Navigator.pop(context);
                      Route route = MaterialPageRoute(builder: (_) => LoginOtpConfirmPhoneScreen(
                        codeNumber: codeNumber,
                        phoneUser: phoneExist.docs[0].data()["phone"],
                        user: phoneExist,
                        
                      ));
                      Navigator.pushAndRemoveUntil(context, route, (route) => false);
                      
                    }

                    if(!isEmail && !isPhone) {
                      if(!mounted) return;
                      Navigator.pop(context);
                      showSnackBar(title: 'Debe ingresar un correo o número de teléfono valido');
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
      content: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 15),
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

  Future <bool> sendCodeByEmail(int code) async{

    String username = 'info@globaloil.app';
    String password = 'rzvkfjuolafkuquf';

    try{
      final smtpServer = gmail(username, password);
      final message = Message()
      ..from = Address(username)
      ..recipients.add(_credentialTextEditingController.text.toLowerCase().trim())
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
  
}


/* import 'dart:convert';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:oilapp/Helper/login_helper.dart';
import 'package:oilapp/config/config.dart';
import 'package:oilapp/widgets/customTextField.dart';
import 'package:oilapp/widgets/progressdialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oilapp/Screens/home_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:whatsapp/whatsapp.dart';
import 'package:oilapp/widgets/erroralertdialog.dart';
import 'package:oilapp/config/config.dart';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  WhatsApp whatsapp = WhatsApp();
  FirebaseAuth _auth = FirebaseAuth.instance;
  final _validationTextEditingController = TextEditingController();
  final googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldState> scaffoldkey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final _emailTextEditingController = TextEditingController();
  final _phoneTextEditingController = TextEditingController();
  final _passwordTextEditingController = TextEditingController();
  String? userloginemail;
  String? userloginpassword;
  bool isExist = false;
  bool isNotLogged = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    /* whatsapp.setup(
	    accessToken: "EAAISTvJmRyQBAGFatYJxQqTVmmV4mLSK95MrQZCA21GLdNoMrYAudmeZBrhAJyaIgAdvFZBkJrYa5IMphSMo81RWQDTJpX9ZBXLdAE3TtczlIm95oxdlxphZClg7FHOslFFUTG9BqndykfPWuKMz0iAhrUZCbG8PwZCoFpuk04bSgKm5jRNMm15",
	    fromNumberId: 115672898059238
    ); */

    

  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldkey,
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              LoginHelper().loginLog(),
              LoginHelper().welcomeText(),
              const SizedBox(height: 10),
              LoginHelper().subtitleText(),
              const SizedBox(height: 20),
              Form(
                key: _formkey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _emailTextEditingController,
                      textInputType: TextInputType.emailAddress,
                      data: Icons.email_outlined,
                      hintText: "Correo",
                      labelText: "Correo",
                      isObsecure: false,
                    ),
                    SizedBox(height: 15),
                    CustomTextField(
                      controller: _phoneTextEditingController,
                      textInputType: TextInputType.phone,
                      data: Icons.phone,
                      hintText: "Teléfono",
                      labelText: "Teléfono",
                      isObsecure: false,
                    ),
                    SizedBox(height: 15,),
                    CustomTextField(
                      controller: _passwordTextEditingController,
                      textInputType: TextInputType.text,
                      data: Icons.lock_outline,
                      hintText: "Contraseña",
                      labelText: "Contraseña",
                      isObsecure: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  /* shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ), */
                  child: const Text(
                    "Acceder",
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  /* color: Theme.of(context).primaryColor, */
                  onPressed: () async {
                    //-------------Internet Connectivity--------------------//
                    FocusScope.of(context).requestFocus(FocusNode());
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext context) => const ProgressDialog(
                        status: "Validando Datos, Por favor espere....",
                      ),
                    );
                    var connectivityResult =
                        await Connectivity().checkConnectivity();
                    if (connectivityResult != ConnectivityResult.mobile &&
                        connectivityResult != ConnectivityResult.wifi) {
                      if(!mounted) return;
                      Navigator.pop(context);
                      showSnackBar("No internet connectivity");
                      
                      return;
                    }
                    //----------------checking textfield--------------------//
                    userloginemail = _emailTextEditingController.text;
                    userloginpassword = _passwordTextEditingController.text;
                    if (!userloginemail!.contains("@")) {
                      if(!mounted) return;
                      Navigator.pop(context);
                      showSnackBar("Por favor ingrese su dirección de correo electrónico válido");
                    
                      return;
                    }

                    if (userloginpassword!.length < 8) {
                      if(!mounted) return;
                      Navigator.pop(context);
                      showSnackBar("La contraseña debe tener al menos 8 caracteres");
                      
                      return;
                    }
                    final phoneRegExp = RegExp(r'^(041(2|4|6)|042(4|6))[0-9]{7}$');
                    if(!phoneRegExp.hasMatch(_phoneTextEditingController.text.trim())){
                      if(!mounted) return;
                      Navigator.pop(context);
                      showSnackBar("Número con formato incorrecto. Ejemplo: 04125556987");
                      
                      return;
                    }
                    String phone = '58${_phoneTextEditingController.text.replaceFirst('0', '')}';
                    QuerySnapshot<Map<String, dynamic>> phoneExist = await FirebaseFirestore.instance.collection('users').where('phone',isEqualTo: phone).get();
                    if(phoneExist.size == 0){
                      if(!mounted) return;
                      Navigator.pop(context);
                      showSnackBar('El teléfono no esta registrado');
                      
                      return;
                    }
                    Navigator.pop(context);
                    final email = userloginemail!.trim();
                    final password = userloginpassword!.trim();
                    if(!mounted) return;
                    bool validateCode = await confirmPhone(phone: phone);

                    if(!validateCode) {
                      if(!mounted) return;
                      Navigator.pop(context);
                      return;
                    }
                    loginUser(email, password, context);
                  },
                ),
              ),
              const SizedBox(height: 10),
              /* LoginHelper().orText(), */
              /* const SizedBox(height: 10),
              Container(
                width: double.infinity,
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    backgroundColor: Colors.blueAccent,
                  ),
                  
                  icon: const Icon(
                    FontAwesomeIcons.google,
                    color: Colors.orangeAccent,
                  ),
                  label: const Text(
                    " Continuar con Google",
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    googleaccountSignIn(context);
                  },
                ),
              ), */
              const SizedBox(height: 15),
              /* LoginHelper().divider(context), */
              const SizedBox(height: 15),
              LoginHelper().donthaveaccount(context),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  void showSnackBar(String title) {
    final snackbar = SnackBar(
      content: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15),
      ),
    );
    
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  Future loginUser(String email, String password, BuildContext context) async {
    
    FocusScope.of(context).requestFocus(FocusNode());

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => const ProgressDialog(
        status: "Ingresando, Espere por favor....",
      ),
    );

    final QuerySnapshot<Map<String, dynamic>> user = await FirebaseFirestore.instance
      .collection('users')
      .where('email', isEqualTo: _emailTextEditingController.text.trim())
      .get();

    if(user.size == 0) {

      showSnackBar("El usuario no existe");
      _emailTextEditingController.text = '';
      _passwordTextEditingController.text = '';
      setState(() {});
      if(!mounted) return;
      Navigator.pop(context);
      return;
    }


    try{
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailTextEditingController.text.trim(),
        password: _passwordTextEditingController.text.trim(),
      );
      await readEmailSignInUserData(userCredential);
      
      if(isExist && isNotLogged){
        if(!mounted) return;
        Navigator.pop(context);
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid)
        .update({
            "logged":true
        });
        
        /* Navigator.pop(context); */
        Route route = MaterialPageRoute(builder: (_) => HomeScreen());
        Navigator.pushAndRemoveUntil(context, route, (route) => false);
      }
      else if(!isExist){
        
        _auth.signOut();
        Navigator.pop(context);
        /* Navigator.pop(context); */
      }
      else if(!isNotLogged){

        bool confirmSingOut = await _onBackPressed();
        if(confirmSingOut){
          _auth.signOut();
          await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid)
          .update({
            "logged":false
          });
          userCredential = await _auth.signInWithEmailAndPassword(
            email: _emailTextEditingController.text.trim(),
            password: _passwordTextEditingController.text.trim(),
          );
          
          await readEmailSignInUserData(userCredential);
          Navigator.pop(context);
          await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid)
          .update({
            "logged":true
          });
          Route route = MaterialPageRoute(builder: (_) => HomeScreen());
          Navigator.pushAndRemoveUntil(context, route, (route) => false);

        }
        else{
          Navigator.pop(context);
        }
        

      }


    }
    catch(e){
      showSnackBar("El usuario o la contraseña no es valida");
      _emailTextEditingController.text = '';
      _passwordTextEditingController.text = '';
      setState(() {});
      Navigator.pop(context);
    }
   
    
  }
  
  Future readEmailSignInUserData(UserCredential fUser) async {
  
    await FirebaseFirestore.instance.collection('users').doc(fUser.user!.uid).get()
    .then((dataSnapshot) async {

      if(dataSnapshot.data() == null) {
        
        return;
      }
      isExist = true;
      if((dataSnapshot.data() as dynamic)['logged']){
        return;
      }
      isNotLogged = true;

      FirebaseMessaging messaging = FirebaseMessaging.instance;
      final String? tokenFirebaseMsg = await messaging.getToken();
      
      await AutoParts.sharedPreferences!.setString("uid", (dataSnapshot.data() as dynamic)[AutoParts.userUID]);
      await AutoParts.sharedPreferences!.setString(AutoParts.userEmail, (dataSnapshot.data() as dynamic)[AutoParts.userEmail]);
      await AutoParts.sharedPreferences!.setString(AutoParts.userName, (dataSnapshot.data() as dynamic)[AutoParts.userName]);
      await AutoParts.sharedPreferences!.setString(AutoParts.userPhone, (dataSnapshot.data() as dynamic)[AutoParts.userPhone]);
      await AutoParts.sharedPreferences!.setString(AutoParts.tokenFirebaseMsg, tokenFirebaseMsg!);
      await AutoParts.sharedPreferences!.setString(AutoParts.userAvatarUrl,(dataSnapshot.data() as dynamic)[AutoParts.userAvatarUrl]);
      List<String> cartList = (dataSnapshot.data() as dynamic)[AutoParts.userCartList].cast<String>();
      await AutoParts.sharedPreferences!.setStringList(AutoParts.userCartList, cartList);

    });

    

  }
 
  

  Future<bool> googleaccountSignIn(BuildContext context) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => const ProgressDialog(
        status: "Ingresando, Espere por favor....",
      ),
    );
    User? currentUser;
    GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
    if (googleSignInAccount != null) {
      GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      final User? user = userCredential.user;
      assert(user!.email != null);
      assert(user!.displayName != null);
      assert(!user!.isAnonymous);
      assert(await user!.getIdToken() != null);
      currentUser = await _auth.currentUser;
      final User googlecurrentuser = _auth.currentUser!;
      assert(googlecurrentuser.uid == currentUser!.uid);
      if (googlecurrentuser != null) {
        await saveUserGoogleSignInInfoToFirebase(googlecurrentuser).whenComplete(() {
          setState(() {
            Navigator.pushAndRemoveUntil(
              context, 
              MaterialPageRoute(
                builder: (c) => HomeScreen(),
              ), 
              (route) => false
            );
          });
        });
      }
    }
    return Future.value(true);
  }

  Future saveUserGoogleSignInInfoToFirebase(User currentUser) async {
    FirebaseFirestore.instance.collection("users").doc(currentUser.uid).set({
      "uid": currentUser.uid,
      "email": currentUser.email,
      "name": currentUser.displayName,
      "phone": AutoParts.userPhone,
      "address": '',
      "url": currentUser.photoURL,
      AutoParts.userCartList: ["garbageValue"],
    });
    await AutoParts.sharedPreferences!.setString("uid", currentUser.uid);
    await AutoParts.sharedPreferences!.setString(AutoParts.userEmail, currentUser.email!);
    await AutoParts.sharedPreferences!.setString(AutoParts.userName, currentUser.displayName!);
    await AutoParts.sharedPreferences!.setString(AutoParts.userPhone, AutoParts.userPhone);
    await AutoParts.sharedPreferences!.setString(AutoParts.userAddress, '');
    await AutoParts.sharedPreferences!.setString(AutoParts.userAvatarUrl, currentUser.photoURL!);
    await AutoParts.sharedPreferences!.setStringList(AutoParts.userCartList, ["garbageValue"]);
  }

  Future<bool> _onBackPressed() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Usuario con sesión activa'),
            content: const Text('Deseas cerrar sesión en el otro dispositivo e iniciar sesión aqui?'),
            actions: <Widget>[
              GestureDetector(
                onTap: () => Navigator.of(context).pop(true),
                child: const Text("YES"),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
                child: const Text("NO"),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ) ??
        false;
  }

  Future confirmPhone( {required String phone}) async {
    int codeValidation = Random().nextInt(9999);
    return await showDialog(
      context: context,
      builder: (context) =>  AlertDialog(
        title: Text('Confimación de Acceso'),
        content: Container(
          height: 150,
          child: Column(
            children: [
              Container(
                child: Column(
                  children: [
                    const Text(
                      'Validando Acceso:'
                    ),
                    const SizedBox(height: 5,),
                    const Text('Debe colocar el código de validación.'),
                    ElevatedButton(
                      onPressed: (){
                        
                        sendMessageTextConfirmation(int.parse(phone), '$codeValidation');
                      }, 
                      child: const Text('Solicitar el código de validación')
                    )
                  ],
                ),
              ),
              Form(
                  child: Column(
                    children: [
                      TextFormField(
                        keyboardType: TextInputType.number,
                        controller: _validationTextEditingController,
                        decoration: const InputDecoration(
                          hintText: "Colocar codigo de validación",
                        ),
                      ),
                    ],
                  )
                )
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {

              if(_validationTextEditingController.text == codeValidation.toString()){
                _validationTextEditingController.text = '';
                showSnackBar('Codigo validado exitosamente');
                Navigator.of(context).pop(true);
              }
              else{
                _validationTextEditingController.text = '';
                setState(() {});
                showSnackBar('Codigo errado');
                Navigator.of(context).pop(false);
              }
            
            },
            child: Text('Aceptar')
          ),
          ElevatedButton(
            onPressed: (){
              Navigator.of(context).pop(false);
            }, 
            child: Text('Cancelar')
          )
        ], 

      )
    )?? false;

  }

  sendMessageTextConfirmation(int number, String msg) async {
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

    final response = await http.post(url, headers: headers, body: json);

  }


}
 */