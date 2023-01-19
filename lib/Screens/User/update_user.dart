import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:oilapp/Model/user_model.dart';
import 'package:oilapp/Screens/Authentication/update_otp_confirm_email.dart';
import 'package:oilapp/Screens/Authentication/update_otp_confirm_phone.dart';
import 'package:oilapp/Screens/myaccount_screen.dart';
import 'package:oilapp/Screens/splash_screen.dart';
import 'package:oilapp/widgets/progressdialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oilapp/config/config.dart';
import 'package:oilapp/widgets/customsimpledialogoption.dart';
import 'package:oilapp/widgets/mytextFormfield.dart';

class UpdateUser extends StatefulWidget {

  final UserModel userModel;

  const UpdateUser({super.key, required this.userModel});

  @override
  State<UpdateUser> createState() => _UpdateUserState();
}

class _UpdateUserState extends State<UpdateUser> {

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController _validationTextEditingController = TextEditingController();
  TextEditingController oldEmailController = TextEditingController();
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmNewPasswordController = TextEditingController();
  UserCredential? userCredential;
  XFile? file;
  String pathFile = '';
  FirebaseAuth _auth = FirebaseAuth.instance;
   @override
   void initState() {
     nameController.text = widget.userModel.name!;
         
     phoneController.text = widget.userModel.phone!;
        
     emailController.text = widget.userModel.email!;

     pathFile = widget.userModel.url!;
     
     /* getImageFromUrl(widget.userModel.url!); */
     super.initState();
   }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text(
        "Actualizar Perfil",
        textAlign: TextAlign.center,
      ),
      actions: [
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: () async {
            bool validateCode = false;
            bool confirm = await _onBackPressed("¿De que quieres actualizar los datos de la cuenta?");
            if(!confirm) return;

            if(
              file == null && 
              widget.userModel.name == nameController.text &&
              widget.userModel.phone == phoneController.text &&
              widget.userModel.email == emailController.text
            ){
              await Fluttertoast.showToast(
                msg: "No hay ningun valor diferente a cambiar",
                toastLength: Toast.LENGTH_LONG
              );
              return;
            }
            /* validateCode  = await confirmPhone();
            
            if(!validateCode) return; */
            
            
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context) => const ProgressDialog(
               status: "Actualizando los datos, Por favor espere....",
              ),
            );
            await updateUserProfileInfo();
            /* Navigator.of(context).pop();
            Navigator.of(context).pop(); */

            
          },
          child: const Text('Enviar'),
        ),
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
      ],
      content: SingleChildScrollView(
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {                                          
                  takeImage(context);
                },
                child: Container(
                  height: 140.0,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      
                      image: (file != null)
                        ? FileImage(File(file!.path))
                        : (pathFile.isNotEmpty)
                          ? NetworkImage(pathFile) as ImageProvider
                          : const AssetImage('assets/authenticaiton/user_icon.png'),
                      fit: BoxFit.contain,
                      
                    ),
                  ),
                ),
              ),
              MyTextFormField(
                controller: nameController,
                hintText: "Ingrese su nombre completo",
                labelText: 'Nombre',
                maxLine: 1,
              ),
              MyTextFormField(
                controller: phoneController,
                hintText: "Ingresa tu Teléfono",
                labelText: 'Teléfono',
                maxLine: 1,
              ),
              MyTextFormField(
                controller: emailController,
                hintText: "Ingresa tu correo",
                labelText: 'Correo',
                maxLine: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future deleteImage() async {
    if(file == null && pathFile.isNotEmpty){
     
      if(FirebaseStorage.instance.refFromURL(widget.userModel.url!).name != "no-image-user.png"){
        FirebaseStorage.instance.refFromURL(pathFile).delete();
        
      }
      
      FirebaseFirestore.instance
      .collection("users")
      .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
      .update({
        "name": nameController.text.trim(),
        "phone": phoneController.text.trim(),
        "email": emailController.text.trim(),
        "url": 'https://firebasestorage.googleapis.com/v0/b/oildatabase-781a4.appspot.com/o/no-image-user.png?alt=media&token=012134ea-3488-4061-ab18-a9f4196b202c'
      });

      final QuerySnapshot<Map<String, dynamic>> reviews = await FirebaseFirestore.instance
        .collection('ratingandreviews')
        .where('userId', isEqualTo: AutoParts.sharedPreferences!.getString(AutoParts.userUID))
        .get();
      
      for(final review in reviews.docs) {
        await review.reference.update({
          'productId': review.data()['productId'],
          'productImage': review.data()['productImage'],
          'productName': review.data()['productName'],
          'publishedDate': review.data()['publishedDate'],
          'rating': review.data()['rating'],
          'reviewMessage': review.data()['reviewMessage'],
          'userAvatar': 'https://firebasestorage.googleapis.com/v0/b/oildatabase-781a4.appspot.com/o/no-image-user.png?alt=media&token=012134ea-3488-4061-ab18-a9f4196b202c',
          'userId': review.data()['userId'],
          'userName': review.data()['userName']
        });
      }

      await AutoParts.sharedPreferences!
        .setString(AutoParts.userName, nameController.text);
      await AutoParts.sharedPreferences!
        .setString(AutoParts.userPhone, phoneController.text);
      await AutoParts.sharedPreferences!
        .setString(AutoParts.userEmail, emailController.text);
      await AutoParts.sharedPreferences!
        .setString(AutoParts.userAvatarUrl, 'https://firebasestorage.googleapis.com/v0/b/oildatabase-781a4.appspot.com/o/no-image-user.png?alt=media&token=012134ea-3488-4061-ab18-a9f4196b202c');
      pathFile = 'https://firebasestorage.googleapis.com/v0/b/oildatabase-781a4.appspot.com/o/no-image-user.png?alt=media&token=012134ea-3488-4061-ab18-a9f4196b202c';
      
      setState(() {
        
      });
      
    }
    Navigator.pop(context);
    Navigator.pop(context);

    
    
    
  }

  Future updateUserProfileInfo() async {

    String newEmail = widget.userModel.email!;
    String newPhone = widget.userModel.phone!;
    String newName = widget.userModel.name!;
    String newUrlImage = widget.userModel.url!;

    if(widget.userModel.email != emailController.text && widget.userModel.phone != phoneController.text){
      newEmail = emailController.text;
      newPhone = phoneController.text;
      String phoneUser = '${newPhone}';
      int codeEmail = Random().nextInt(9999 - 1000 + 1) + 1000;
      int codeNumber = Random().nextInt(9999 - 1000 + 1) + 1000;

      
      QuerySnapshot<Map<String, dynamic>> userDBEmail = await FirebaseFirestore.instance.collection(AutoParts.collectionUser)
        .where("email", isEqualTo: newEmail)
        .get();
      

      QuerySnapshot<Map<String, dynamic>> userDBPhone = await FirebaseFirestore.instance.collection(AutoParts.collectionUser)
        .where("phone", isEqualTo: phoneUser)
        .get();

      if(userDBPhone.size > 0 || userDBEmail.size > 0){
        Navigator.of(context).pop(); 
        await Fluttertoast.showToast(
          msg: "El número o el correo ya esta en uso.",
          toastLength: Toast.LENGTH_LONG
        );
        return;
      }

      bool confirmSendEmail = await sendCodeByEmail(codeEmail);
      if(!confirmSendEmail) {
        Navigator.of(context).pop(); 
        await Fluttertoast.showToast(
          msg: "Fallo el envio del código, intente nuevamente",
          toastLength: Toast.LENGTH_LONG
        );
        return;
      }
      Route routeEmail =  MaterialPageRoute(builder: (_) => UpdateOtpConfirmEmailScreen(
        codeEmail: codeEmail,
        emailUser: newEmail,
        user: userDBEmail,
      ));
      if(!mounted) return;
      final confirmEmailOtp = await Navigator.push(context, routeEmail);
      if(!confirmEmailOtp){
        Navigator.of(context).pop(); 
        await Fluttertoast.showToast(
          msg: "Fallo en la validación del código",
          toastLength: Toast.LENGTH_LONG
        );
        return;
      }
      
      bool confirmSendNumber = await sendCodeByPhone(int.parse(phoneUser), '$codeNumber');
      if(!confirmSendNumber){
        Navigator.of(context).pop(); 
        await Fluttertoast.showToast(
          msg: "Fallo el envio del código, intente nuevamente",
          toastLength: Toast.LENGTH_LONG
        );
        return;
      }
      Route routePhone =  MaterialPageRoute(builder: (_) => UpdateOtpConfirmPhoneScreen(
        codeNumber: codeNumber,
        phoneUser: newPhone,
        user: userDBPhone,
      ));
      if(!mounted) return;
      final confirmPhoneOtp = await Navigator.push(context, routePhone);
      if(!confirmPhoneOtp){
        Navigator.of(context).pop(); 
        await Fluttertoast.showToast(
          msg: "Fallo en la validación del código",
          toastLength: Toast.LENGTH_LONG
        );
        return;
      }




    }

    else if(widget.userModel.email != emailController.text) {
      int codeEmail = Random().nextInt(9999 - 1000 + 1) + 1000;

      newEmail = emailController.text;
      QuerySnapshot<Map<String, dynamic>> userDBEmail = await FirebaseFirestore.instance.collection(AutoParts.collectionUser)
        .where("email", isEqualTo: newEmail)
        .get();
      

      if(userDBEmail.size > 0){
        Navigator.of(context).pop(); 
        await Fluttertoast.showToast(
          msg: "El correo ya esta en uso.",
          toastLength: Toast.LENGTH_LONG
        );
        return; 

      }

      bool confirmSendEmail = await sendCodeByEmail(codeEmail);
       if(!confirmSendEmail) {
        Navigator.of(context).pop(); 
        await Fluttertoast.showToast(
          msg: "Fallo el envio del código, intente nuevamente",
          toastLength: Toast.LENGTH_LONG
        );
        return;
      }

      
      Route routeEmail =  MaterialPageRoute(builder: (_) => UpdateOtpConfirmEmailScreen(
        codeEmail: codeEmail,
        emailUser: newEmail,
        user: userDBEmail,
      ));
      if(!mounted) return;
      final confirmEmailOtp = await Navigator.push(context, routeEmail);
      if(!confirmEmailOtp){
        Navigator.of(context).pop(); 
        await Fluttertoast.showToast(
          msg: "Fallo en la validación del código",
          toastLength: Toast.LENGTH_LONG
        );
        return;
      }
      
    }
    
    else if(widget.userModel.phone != phoneController.text){

      int codeNumber = Random().nextInt(9999 - 1000 + 1) + 1000;
      newPhone = phoneController.text;
      String phoneUser = '${newPhone}';

      QuerySnapshot<Map<String, dynamic>> userDBPhone = await FirebaseFirestore.instance.collection(AutoParts.collectionUser)
        .where("phone", isEqualTo: phoneUser)
        .get();
      if(userDBPhone.size > 0){
        Navigator.of(context).pop(); 
        await Fluttertoast.showToast(
          msg: "El número ya esta en uso.",
          toastLength: Toast.LENGTH_LONG
        );
        return;
      }

      bool confirmSendNumber = await sendCodeByPhone(int.parse(phoneUser), '$codeNumber');
      if(!confirmSendNumber) {
        Navigator.of(context).pop(); 
        await Fluttertoast.showToast(
          msg: "Fallo el envio del código, intente nuevamente",
          toastLength: Toast.LENGTH_LONG
        );
        return;
      }
      Route routePhone =  MaterialPageRoute(builder: (_) => UpdateOtpConfirmPhoneScreen(
        codeNumber: codeNumber,
        phoneUser: newPhone,
        user: userDBPhone,
      ));
      if(!mounted) return;
      final confirmPhoneOtp = await Navigator.push(context, routePhone);
      if(!confirmPhoneOtp){
        Navigator.of(context).pop(); 
        await Fluttertoast.showToast(
          msg: "Fallo en la validación del código",
          toastLength: Toast.LENGTH_LONG
        );
        return;
      }



    }

    if(widget.userModel.name != nameController.text){
      newName = nameController.text;
    }

    if(file != null) {
      String imgeFileName = DateTime.now().microsecondsSinceEpoch.toString();
      Reference reference = FirebaseStorage.instance.ref().child(imgeFileName);
      UploadTask uploadTask = reference.putFile(File(file!.path));
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      if(pathFile.isNotEmpty){
        if(FirebaseStorage.instance.refFromURL(widget.userModel.url!).name != "no-image-user.png"){

          FirebaseStorage.instance.refFromURL(widget.userModel.url!).delete();
          
        }
        
      }
      newUrlImage = downloadUrl;
    }

    FirebaseFirestore.instance
      .collection("users")
      .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
      .set({
        "uid":AutoParts.sharedPreferences!.getString(AutoParts.userUID),
        "email": newEmail,
        "name": newName,
        "phone": newPhone,
        "address":widget.userModel.address,
        "url": newUrlImage,
        "logged": true,
        AutoParts.userCartList: ["garbageValue"]
      });

  
      

    final QuerySnapshot<Map<String, dynamic>> reviews = await FirebaseFirestore.instance
        .collection('ratingandreviews')
        .where('userId', isEqualTo: AutoParts.sharedPreferences!.getString(AutoParts.userUID))
        .get();

    for(final review in reviews.docs) {
        await review.reference.update({
          'productId': review.data()['productId'],
          'productImage': review.data()['productImage'],
          'productName': review.data()['productName'],
          'publishedDate': review.data()['publishedDate'],
          'rating': review.data()['rating'],
          'reviewMessage': review.data()['reviewMessage'],
          'userAvatar': newUrlImage,
          'userId': review.data()['userId'],
          'userName': review.data()['userName']
        });
      }
      
      
      await AutoParts.sharedPreferences!.setString(AutoParts.userName, newName);
      await AutoParts.sharedPreferences!.setString(AutoParts.userPhone, newPhone);
      await AutoParts.sharedPreferences!.setString(AutoParts.userEmail, newEmail);
      await AutoParts.sharedPreferences!.setString(AutoParts.userAvatarUrl, newUrlImage);


      
      await FirebaseFirestore.instance
        .collection('users')
        .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
        .update({
          "logged":false
        });
      Navigator.of(context).pop(); 
      await Fluttertoast.showToast(
        msg: "Actualización exitosa",
        toastLength: Toast.LENGTH_LONG
      );
      Route route = MaterialPageRoute(builder: (_) => SplashScreen());
      Navigator.pushAndRemoveUntil(context, route, (route) => false);
      /* AutoParts.auth!.signOut().then((c) {

        Route route = MaterialPageRoute(builder: (_) => SplashScreen());
        Navigator.pushAndRemoveUntil(context, route, (route) => false);
        
      }); */
        
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
      ..recipients.add(emailController.text.toLowerCase().trim())
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


  takeImage(mContext) {
      return showDialog(
          context: mContext,
          builder: (con) {
            return SimpleDialog(
              title: const Text(
                "Imagen del perfil",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.deepOrangeAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: [
                 SimpleDialogOption(
                  onPressed: capturePhotoWithCamera,
                  child: const CustomSimpleDialogOption(
                    icon:  Icons.photo_camera_outlined,
                    title: "Capturar con una Camera",
                  ),
                ),
                SimpleDialogOption(
                  onPressed: pickPhotoFromGallery,
                  child: const CustomSimpleDialogOption(
                    icon: Icons.photo_outlined,
                    title: "Seleccionar desde la Galería",
                  ),
                ),
                SimpleDialogOption(
                  onPressed:() async {
                    bool confirm = await _onBackPressed('De que quieres eliminar tu foto de perfil?');
                    if(!confirm) return;
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext context) => const ProgressDialog(
                        status: "Eliminando foto de perfil, Por favor espere....",
                      ),
                    );
                    await deleteImage();
                    Navigator.pop(context);
                  },
                  child: const CustomSimpleDialogOption(
                    icon: Icons.highlight_remove_sharp,
                    title: "Eliminar foto de perfil",
                  ),
                ),
                SimpleDialogOption(
                  child: const Text(
                    "Cancelar",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
    }

    capturePhotoWithCamera() async {
      Navigator.pop(context);
      final imageFile = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxHeight: 680,
        maxWidth: 970,
      );
      setState(() {
        file = imageFile;
      });
    }

    pickPhotoFromGallery() async {
      Navigator.pop(context);
      final imageFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxHeight: 680,
        maxWidth: 970,
      );
      setState(() {
        file = imageFile;
      });
    }

    Future<bool> _onBackPressed(String msg) async {
    return await showDialog(
          context: context,
          builder: (context) =>  AlertDialog(
            title:  const Text('¿Estas seguro?'),
            content:  Text(msg),
            actions: <Widget>[
               GestureDetector(
                onTap: () => Navigator.of(context).pop(true),
                child: const Padding(
                  padding:  EdgeInsets.all(8.0),
                  child: Text("YES"),
                ),
              ),
              const SizedBox(height: 16),
               GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("NO"),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ) ??
        false;
  }

  Future confirmPhone() async {
    int codeValidation = Random().nextInt(9999);
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confimación de cambios en la cuenta'),
        content: Container(
          height: 150,
          child: Column(
            children: [
              Container(
                child: Column(
                  children: [
                    const Text(
                      'Validando Cambios:'
                    ),
                    const SizedBox(height: 5,),
                    const Text('Debe colocar el código de validación.'),
                    ElevatedButton(
                      onPressed: () async {
                        bool confirmSendCode = await _onBackPressed("Se le va a enviar un código al siguiente número: ${phoneController.text}");
                        if(!confirmSendCode) return;
                        await sendMessageTextConfirmation(int.parse(phoneController.text), '$codeValidation');
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
          )
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

  Future <dynamic> confirmChangeEmail() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ingrese las credenciales del correo actual'),
        content: Container(
          height: 280,
          child: Column(
            children: [
              
              Form(
                  child: Column(
                    children: [
                      const Text('Ingrese el correo y la clave del correo actual'),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        controller: oldEmailController,
                        decoration: const InputDecoration(
                          hintText: "Ingrese su correo actual",
                        ),
                      ),
                      TextFormField(
                        keyboardType: TextInputType.visiblePassword,
                        controller: oldPasswordController,
                        decoration: const InputDecoration(
                          hintText: "Ingrese la clave",
                        ),
                      ),
                      const SizedBox(height: 20,),
                      const Text('Coloque la nueva clave y la confirmación de la misma'),
                      TextFormField(
                        keyboardType: TextInputType.visiblePassword,
                        controller: newPasswordController,
                        decoration: const InputDecoration(
                          hintText: "Clave para su nuevo correo",
                        ),
                      ),
                      TextFormField(
                        keyboardType: TextInputType.visiblePassword,
                        controller: confirmNewPasswordController,
                        decoration: const InputDecoration(
                          hintText: "Confirmación de la nueva clave",
                        ),
                      ),
                    ],
                  )
                )
            ],
          )
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
               userCredential =  await _auth.signInWithEmailAndPassword(
                email: oldEmailController.text,
                password: oldPasswordController.text
              );

              if(
                oldEmailController.text.isEmpty     && oldPasswordController.text.isEmpty &&
                newPasswordController.text.isEmpty  && confirmNewPasswordController.text.isEmpty
              ){

                await Fluttertoast.showToast(
                  msg: "Debe indicar toda la informacion solicitada",
                  toastLength: Toast.LENGTH_LONG
                );
                
                return;
              }
              else if(newPasswordController.text.length < 8){
                await Fluttertoast.showToast(
                  msg: "Debe colocar una clave mayor a 8 digitos",
                  toastLength: Toast.LENGTH_LONG
                );
                
                return;
              }
              else if(newPasswordController.text != confirmNewPasswordController.text){
                await Fluttertoast.showToast(
                  msg: "La clave nueva no coincide con la confirmación de la clave",
                  toastLength: Toast.LENGTH_LONG
                );
                
                return;
              }

              

              else if(userCredential == null) {
                await Fluttertoast.showToast(
                  msg: "Las credenciales del correo actual estan erradas",
                  toastLength: Toast.LENGTH_LONG
                );
                
                return;
              }

              else {
                if(!mounted) return;
                Navigator.of(context).pop(true);
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