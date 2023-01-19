
import 'dart:math';
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
                const SizedBox(height: 10),
                LoginHelper().loginLog(),
                const SizedBox(height: 10),
                LoginHelper().subtitleText(
                  msg: "Registro de usuario",
                  size: 32,
                  color: Colors.black
                ),
                const SizedBox(height: 10),
                LoginHelper().subtitleText(
                  msg: "Se enviará un código de confirmación a su número y correo para registrarse en la aplicación",
                  size: 18,
                  color: Colors.black
                ),
                const SizedBox(height: 30),
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
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        
                        width: MediaQuery.of(context).size.width * 0.80,
                        child: TextFormField(
                          controller: _userPhoneTextEditingController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                          
                            hintText: "04141234567",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.80,
                        child: TextFormField(
                          controller: _emailTextEditingController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "correo@dominio.com",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                
                const SizedBox(height: 40),
                ElevatedButton(
                
                  child: const Text("Continuar"),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: MediaQuery.of(context).size.width * 0.35),
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
                    var connectivityResult =
                        await Connectivity().checkConnectivity();
                    if (connectivityResult != ConnectivityResult.mobile &&
                        connectivityResult != ConnectivityResult.wifi) {
                      if(!mounted) return;
                      Navigator.pop(context);
                      showSnackBar(title: 'No internet connectivity');
                      return;
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
                const SizedBox(height: 20,),
                Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Ya tienes una cuenta ?',
                    style: TextStyle(
                      fontSize: 18.0,
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
                    child: Text(
                      ' Entre Aquí',
                      style: TextStyle(
                        color: Colors.red[300],
                        fontSize: 20.0,
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


/* import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:oilapp/Screens/Authentication/login_screen.dart';
import 'package:oilapp/config/config.dart';
import 'package:oilapp/widgets/customTextField.dart';
import 'package:oilapp/widgets/progressdialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oilapp/Screens/home_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oilapp/widgets/erroralertdialog.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:whatsapp/whatsapp.dart';
import 'package:http/http.dart' as http;
class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldkey = GlobalKey<ScaffoldState>();
  WhatsApp whatsapp = WhatsApp();
  

  final _nameTextEditingController = TextEditingController();
  final _emailTextEditingController = TextEditingController();
  final _phoneTextEditingController = TextEditingController();
  final _passwordTextEditingController = TextEditingController();
  final _cpasswordTextEditingController = TextEditingController();
  final _validationTextEditingController = TextEditingController();
  String userImage = "";
  XFile? avatarImageFile;
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    Future getImage() async {
      var image = await ImagePicker().pickImage(source: ImageSource.gallery);
      
      setState(() {
        avatarImageFile = image;
      });
    }

    return SafeArea(
      child: Scaffold(
        key: scaffoldkey,
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 25),
              const Text(
                "¡Empecemos!",
                style: TextStyle(
                  fontSize: 30,
                  fontFamily: 'Brand-Bold',
                  letterSpacing: 1,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              const Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Cree una cuenta en Global Oil para obtener todas las funciones",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Brand-Regular',
                    letterSpacing: 1,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 130,
                child: GestureDetector(
                  onTap: () {
                    getImage();
                  },
                  child: CircleAvatar(
                    radius: size.width * 0.15,
                    backgroundColor: Colors.deepOrange,
                    backgroundImage: (avatarImageFile != null)
                        ? FileImage(File(avatarImageFile!.path)) 
                        : const AssetImage("assets/authenticaiton/user_icon.png") as ImageProvider,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Form(
                key: _formkey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _nameTextEditingController,
                      textInputType: TextInputType.text,
                      data: Icons.account_circle,
                      hintText: "Nombre Completo",
                      labelText: "Nombre Completo",
                      isObsecure: false,
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: _phoneTextEditingController,
                      textInputType: TextInputType.phone,
                      data: Icons.phone,
                      hintText: "Número de teléfono",
                      labelText: "Número de teléfono",
                      isObsecure: false,
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: _emailTextEditingController,
                      textInputType: TextInputType.emailAddress,
                      data: Icons.email_outlined,
                      hintText: "Correo",
                      labelText: "Correo",
                      isObsecure: false,
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: _passwordTextEditingController,
                      textInputType: TextInputType.text,
                      data: Icons.lock_outline,
                      hintText: "Contraseña",
                      labelText: "Contraseña",
                      isObsecure: true,
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: _cpasswordTextEditingController,
                      textInputType: TextInputType.text,
                      data: Icons.lock_outline,
                      hintText: "Confirmar Contraseña",
                      labelText: "Confirmar Contraseña",
                      isObsecure: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              //--------------------Create Button-----------------------//
              Container(
                width: double.infinity,
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  /* shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ), */
                  child: Text(
                    "Crear".toUpperCase(),
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  /* color: Theme.of(context).primaryColor, */
                  onPressed: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext context) => const ProgressDialog(
                        status: "Validando Datos, Por favor espere....",
                      ),
                    );
                    //-------------Internet Connectivity--------------------//
                    var connectivityResult =
                        await Connectivity().checkConnectivity();
                    if (connectivityResult != ConnectivityResult.mobile &&
                        connectivityResult != ConnectivityResult.wifi) {
                      if(!mounted) return;
                      Navigator.pop(context);
                      showSnackBar(title: 'No internet connectivity');
                      return;
                    }
                    //----------------checking textfield--------------------//
                    if (_nameTextEditingController.text.length < 4) {
                      if(!mounted) return;
                      Navigator.pop(context);
                      
                      showSnackBar(title: 'El nombre debe tener al menos 4 caracteres');
                      return;
                    }
                    if (!_emailTextEditingController.text.contains("@")) {
                      if(!mounted) return;
                      Navigator.pop(context);
                      showSnackBar(title: "Por favor ingrese su dirección de correo electrónico válida");
                      return;
                    }

                    if (_passwordTextEditingController.text.length < 8) {
                      if(!mounted) return;
                      Navigator.pop(context);
                      showSnackBar(title: "La contraseña debe tener al menos 8 caracteres");
                      return;
                    }
                    if (_passwordTextEditingController.text !=
                        _cpasswordTextEditingController.text) {
                      if(!mounted) return;
                      Navigator.pop(context);
                      showSnackBar(title: "La Confirmación de la contraseña no coincide");
                      return;
                    }
                    final phoneRegExp = RegExp(r'^(041(2|4|6)|042(4|6))[0-9]{7}$');
                    if(!phoneRegExp.hasMatch(_phoneTextEditingController.text.trim())){
                      if(!mounted) return;
                      Navigator.pop(context);
                      showSnackBar(
                        title: "Número con formato incorrecto. Ejemplo: 04125556987",
                        seconds: 7
                      );
                      return;
                    }
                    String phone = '58${_phoneTextEditingController.text.replaceFirst('0', '')}';
              
                    QuerySnapshot<Map<String, dynamic>> phoneExist = await FirebaseFirestore.instance.collection('users').where('phone',isEqualTo: phone).get();

                    if(phoneExist.size >= 1){
                      showSnackBar(title: 'El teléfono ya esta registrado');
                      if(!mounted) return;
                      Navigator.pop(context);
                      return;
                    }
                    if(!mounted) return;
                    Navigator.pop(context);
                    
                    bool validateCode = await confirmPhone(phone: phone);

                    if(!validateCode) return;
                    
                    uploadAndSaveImage();
                  },
                ),
              ),
              const SizedBox(height: 15),
              Center(
                child: Container(
                  height: 2.0,
                  width: size.width / 2 - 30,
                  color: Colors.black45,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Ya tienes una cuenta ?',
                    style: TextStyle(
                      fontSize: 18.0,
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
                    child: Text(
                      ' Entre Aquí',
                      style: TextStyle(
                        color: Colors.red[300],
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

//--------------custom snackbar----------------------//
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

  Future<void> uploadAndSaveImage() async {
    if (avatarImageFile == null) {
      showDialog(
        context: context,
        builder: (c) {
          return const ErrorAlertDialog(
            message: "Por favor seleccione una imagen",
          );
        },
      );
    } else {
      uploadToStorage();
    }
  }

  uploadToStorage() async {
    //------show please wait dialog----------//
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => const ProgressDialog(
        status: "Registrando, Por favor espere....",
      ),
    );

    String imgeFileName = DateTime.now().microsecondsSinceEpoch.toString();
    Reference reference = FirebaseStorage.instance.ref().child(imgeFileName);
    UploadTask uploadTask = reference.putFile(File(avatarImageFile!.path));
    await uploadTask.then((res) {
      res.ref.getDownloadURL().then((urlImage) => userImage = urlImage);
      createUser();
    });
  }

//----------------------create user-----------------------//
  Future createUser() async {
    User? firebaseUser;
    await _auth
        .createUserWithEmailAndPassword(
          email: _emailTextEditingController.text.trim(),
          password: _passwordTextEditingController.text.trim(),
          
        )
        .then((auth) => firebaseUser = auth.user)
        .catchError((error) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c) {
            return ErrorAlertDialog(
              message: error.message.toString(),
            );
          });
    });


    if (firebaseUser != null) {
      saveUserInfoToFireStore(firebaseUser!).then((value) {
        Navigator.pop(context);
        Route route = MaterialPageRoute(builder: (_) => HomeScreen());
        /* Navigator.pushReplacement(context, route); */
        Navigator.pushAndRemoveUntil(context, route, (route) => false);
      });
    }
  }

//--------------------save user information to firestore-----------------//
  Future saveUserInfoToFireStore(User fUser) async {

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    String phoneUser = '58${_phoneTextEditingController.text.replaceFirst('0', '')}';
    final String? tokenFirebaseMsg = await messaging.getToken();

    FirebaseFirestore.instance.collection("users").doc(fUser.uid).set({
      "uid": fUser.uid,
      "email": fUser.email,
      "name": _nameTextEditingController.text.trim(),
      "phone": phoneUser,
      "address": "Venezuela",
      "url": "https://firebasestorage.googleapis.com/v0/b/oildatabase-781a4.appspot.com/o/no-image-user.png?alt=media&token=03a744f0-5f12-42a2-b709-e68dc0c66128",
      "logged": true,
      AutoParts.userCartList: ["garbageValue"],
    });
    await AutoParts.sharedPreferences!.setString("uid", fUser.uid);
    await AutoParts.sharedPreferences!.setString(AutoParts.userEmail, fUser.email!);
    await AutoParts.sharedPreferences!.setString(AutoParts.tokenFirebaseMsg, tokenFirebaseMsg!);
    await AutoParts.sharedPreferences!.setString(AutoParts.userName, _nameTextEditingController.text);
    await AutoParts.sharedPreferences!.setString(AutoParts.userPhone, phoneUser);
    await AutoParts.sharedPreferences!.setString(AutoParts.userAddress, 'Venezuela');
    await AutoParts.sharedPreferences!.setString(AutoParts.userAvatarUrl, userImage);
    await AutoParts.sharedPreferences!.setStringList(AutoParts.userCartList, ["garbageValue"]);
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

  Future confirmPhone( {required String phone}) async {
    int codeValidation = Random().nextInt(9999);
    return await showDialog(
      context: context,
      builder: (context) =>  AlertDialog(
        title: Text('Confimación de registro'),
        content: Container(
          height: 150,
          child: Column(
            children: [
              Container(
                child: Column(
                  children: [
                    const Text(
                      'Validando Registro:'
                    ),
                    const SizedBox(height: 5,),
                    const Text('Debe colocar el código de validación.'),
                    ElevatedButton(
                      onPressed: () async{
                        bool confirmSendCode = await _onBackPressed("Se le va a enviar un código al siguiente número: $phone");
                        if(!confirmSendCode) return;
                        sendMessageTextConfirmation(int.parse(phone), '$codeValidation');
                      }, 
                      child: Text('Solicitar el código de validación')
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
                showSnackBar(title: 'Codigo validado exitosamente');
                Navigator.of(context).pop(true);
              }
              else{
                _validationTextEditingController.text = '';
                setState(() {});
                showSnackBar(title: 'Codigo errado');
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

  Future<bool> _onBackPressed(String msg) async {
    return await showDialog(
          context: context,
          builder: (context) =>  AlertDialog(
            title:  Text('Estas seguro?'),
            content:  Text(msg),
            actions: <Widget>[
               GestureDetector(
                onTap: () => Navigator.of(context).pop(true),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("YES"),
                ),
              ),
              SizedBox(height: 16),
               GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("NO"),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ) ??
        false;
  }

}
 */