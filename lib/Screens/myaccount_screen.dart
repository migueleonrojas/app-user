import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:oilapp/Model/user_model.dart';
import 'package:oilapp/Screens/User/update_user.dart';
import 'package:oilapp/widgets/customsimpledialogoption.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oilapp/config/config.dart';
import 'package:oilapp/widgets/loading_widget.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:oilapp/widgets/mytextFormfield.dart';
import 'package:oilapp/widgets/simpleAppbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyAccountScreen extends StatefulWidget {
  @override
  _MyAccountScreenState createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  XFile? file;
  String url = '';
  // @override
  // void initState() {
  //   nameController.text =
  //       AutoParts.sharedPreferences.getString(AutoParts.userName);
  //   phoneController.text =
  //       AutoParts.sharedPreferences.getString(AutoParts.userPhone);
  //   addressController.text =
  //       AutoParts.sharedPreferences.getString(AutoParts.userAddress);
  //   super.initState();
  // }
  

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop(AutoParts.sharedPreferences!.getString(AutoParts.userAvatarUrl));
          
          return true;

        },
        child: Scaffold(
          
          appBar: simpleAppBar(false, 'Mi Cuenta', context),
          
          bottomNavigationBar: BottomAppBar(
            child: SizedBox(
              height: size.height * 0.064,
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .where("uid",
                          isEqualTo: AutoParts.sharedPreferences!
                              .getString(AutoParts.userUID))
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return Container();
                    UserModel userModel = UserModel.fromJson(
                              (snapshot.data!.docs[0] as dynamic).data());
                    return ElevatedButton(
                      onPressed: () async {
                        final alert =  UpdateUser(userModel: userModel);
                        final newValues = await showDialog(context: context, builder: (_) => alert);
                        
                        /* await getImageFromUrl((snapshot.data!.docs[0] as dynamic).data()['url']);
                        setState(() {
                          for (int i = 0; i < snapshot.data!.docs.length; i++) {
                           
                            nameController.text =
                                (snapshot.data!.docs[i] as dynamic).data()['name'];
                            phoneController.text =
                                (snapshot.data!.docs[i] as dynamic).data()['phone'];
                            addressController.text =
                                (snapshot.data!.docs[i] as dynamic).data()['address'];
                          }
                        });
                        showDialog(
                            context: context,
                            builder: (context) {
                              return CupertinoAlertDialog(
                                title: const AutoSizeText(
                                  "Actualizar Perfil",
                                  textAlign: TextAlign.center,
                                ),
                                actions: [
                                  CupertinoDialogAction(
                                    isDestructiveAction: true,
                                    onPressed: () {
                                      updateUserProfileInfo().whenComplete(() {
                                        setState(() {});
                                      });
                                      Navigator.of(context).pop();
                                    },
                                    child: const AutoSizeText('Enviar'),
                                  ),
                                  CupertinoDialogAction(
                                    isDestructiveAction: true,
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const AutoSizeText('Cancelar'),
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
                                            height: 230.0,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: (file != null)
                                                  ? FileImage(File(file!.path))
                                                  : AssetImage(
                                                    "assets/authenticaiton/user_icon.png",
                                                  ) as ImageProvider,
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
                                          controller: addressController,
                                          hintText: "Ingresa tu correo",
                                          labelText: 'Correo',
                                          maxLine: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }); */
                      },
                      /* color: Theme.of(context).accentColor, */
                      child: AutoSizeText(
                        "Actualizar Perfil",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Brand-Bold",
                          letterSpacing: 1.5,
                          fontSize: size.height * 0.022,
                        ),
                      ),
                    );
                  }),
            ),
          ),
          body: SingleChildScrollView(
            child: Container(
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .where("uid",
                          isEqualTo: AutoParts.sharedPreferences!
                              .getString(AutoParts.userUID))
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return circularProgress();
                    return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: size.height * 0.022),
                            Center(
                              child: Material(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(size.height * 0.096)),
                                elevation: 5.0,
                                child: Container(
                                  width: size.width * 0.385,
                                  height: size.height * 0.174,
                                  child: CircleAvatar(
                                    radius: size.width * 0.15,
                                    backgroundColor: Colors.deepOrange,
                                    backgroundImage: NetworkImage(
                                      (snapshot.data!.docs[index] as dynamic).data()['url'],
                                    ),
                                    // backgroundImage: NetworkImage(
                                    //   AutoParts.sharedPreferences
                                    //       .getString(AutoParts.userAvatarUrl),
                                    // ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: size.height * 0.014),
                            Container(
                              padding:  EdgeInsets.symmetric(
                                horizontal: size.width * 0.09,
                                vertical: size.height * 0.016,
                              ),
                              width: double.infinity,
                              child: Padding(
                                padding:  EdgeInsets.all(size.height * 0.006),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: size.height * 0.006),
                                    ProfileText(
                                      title: "Nombre: ",
                                      informationtext: (snapshot.data!.docs[index] as dynamic)
                                          .data()['name'],
                                      // informationtext: AutoParts.sharedPreferences
                                      //     .getString(AutoParts.userName),
                                    ),
                                    SizedBox(height: size.height * 0.006),
                                    ProfileText(
                                      title: "Correo: ",
                                      informationtext: (snapshot.data!.docs[index] as dynamic)
                                          .data()['email'],
                                      // informationtext: AutoParts.sharedPreferences
                                      //     .getString(AutoParts.userEmail),
                                    ),
                                    SizedBox(height: size.height * 0.006),
                                    ProfileText(
                                      title: "Teléfono: ",
                                      informationtext: (snapshot.data!.docs[index] as dynamic)
                                          .data()['phone'],
                                      // informationtext: AutoParts.sharedPreferences
                                      //     .getString(AutoParts.userPhone),
                                    ),
                                    SizedBox(height: size.height * 0.006),
                                    ProfileText(
                                      title: "Dirección: ",
                                      informationtext: (snapshot.data!.docs[index] as dynamic)
                                          .data()['address'],
                                      // informationtext: AutoParts.sharedPreferences
                                      //     .getString(AutoParts.userAddress),
                                    ),
                                    SizedBox(height: size.height * 0.006),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }),
            ),
          ),
        ),
      ),
    );
  }

  Future updateUserProfileInfo() async {
    FirebaseFirestore.instance
        .collection("users")
        .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
        .update({
      "name": nameController.text.trim(),
      "phone": phoneController.text.trim(),
      "address": addressController.text.trim(),
    });
    await AutoParts.sharedPreferences!
        .setString(AutoParts.userName, nameController.text);
    await AutoParts.sharedPreferences!
        .setString(AutoParts.userPhone, phoneController.text);
    await AutoParts.sharedPreferences!
        .setString(AutoParts.userAddress, addressController.text);
  }

  Future getImageFromUrl(String urlFromDB) async{

    String baseUrl = '';
    String endPoint = '';
    Map<String, String> _queryParameters = {};

    urlFromDB.replaceAllMapped(RegExp(r'[^\/][a-z]+[\.]+[a-z]+[\.][a-z]+'), (Match m) {
      baseUrl = '${m[0]}';
      return '';
    });
    urlFromDB.replaceAllMapped(RegExp(r'[\/][v][0](\/[a-z0-9\.-]+){4}'), (Match m) {
      endPoint = '${m[0]}';
      return '';
    });
    urlFromDB.replaceAllMapped(RegExp(r'[a-z]+[=][a-z0-9-]+'), (Match m) {
      _queryParameters.addAll({
        m[0]!.split('=')[0]:m[0]!.split('=')[1]
      });
      return '';
    });

  
    final urlToUri = Uri.https(baseUrl, endPoint,_queryParameters);
    final http.Response responseData = await http.get(urlToUri);
    Uint8List uint8list = responseData.bodyBytes;
    final buffer = uint8list.buffer;
    ByteData byteData = ByteData.view(buffer);
    final tempDir = await getTemporaryDirectory();
    File fileFromFirebase = await File('${tempDir.path}/img.jpg').writeAsBytes(
    buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    file = XFile(fileFromFirebase.path); 
    setState(() {
      
    });
    
  }

  takeImage(mContext) {
      return showDialog(
          context: mContext,
          builder: (con) {
            return SimpleDialog(
              title: const AutoSizeText(
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
                  child: const AutoSizeText(
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
}

class ProfileText extends StatelessWidget {
  final String? title;
  final String? informationtext;

  const ProfileText({
    Key? key,
    this.title,
    this.informationtext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: <TextSpan>[
          TextSpan(
            text: title,
            style: TextStyle(
              fontSize: 22,
              color: Colors.blueGrey,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: informationtext,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontFamily: "Brand-Regular",
            ),
          ),
        ],
      ),
    );
  }
}
