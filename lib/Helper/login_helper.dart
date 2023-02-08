import 'package:auto_size_text/auto_size_text.dart';
import 'package:oilapp/Screens/Authentication/signup_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginHelper extends ChangeNotifier {
  Widget loginLog(BuildContext context) {

    return Image.asset(
      "assets/authenticaiton/global-oil.jpg",
      width: MediaQuery.of(context).size.width * 0.7,
      height: MediaQuery.of(context).size.height * 0.3,
    );
  }

  Widget welcomeText() {
    return const AutoSizeText(
      "Bienvenido de nuevo!",
      style: TextStyle(
        fontSize: 30,
        fontFamily: 'Brand-Bold',
        letterSpacing: 1,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget subtitleText({
    required String msg,
    required double size,
    required Color color
  }) {
    
    return  Padding(
      padding:  const EdgeInsets.symmetric(horizontal: 16.0),
      child:  AutoSizeText(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: size,
          fontFamily: 'Inter',
          letterSpacing: 1,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget orText() {
    return const AutoSizeText(
      'O',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Widget googlesigninhelper(BuildContext context) {
  //   return Container(
  //     width: double.infinity,
  //     height: 50,
  //     margin: EdgeInsets.symmetric(horizontal: 16),
  //     child: RaisedButton.icon(
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(8.0),
  //       ),
  //       icon: Icon(
  //         FontAwesomeIcons.google,
  //         color: Colors.redAccent,
  //       ),
  //       label: AutoSizeText(
  //         " Continue with Google",
  //         style: TextStyle(
  //           fontSize: 22,
  //           color: Colors.white,
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //       color: Colors.blueAccent,
  //       onPressed: () {
  //         googleaccountSignIn(context);
  //       },
  //     ),
  //   );
  // }

  Widget divider(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Center(
      child: Container(
        height: 2.0,
        width: size.width / 2 - 30,
        color: Colors.black45,
      ),
    );
  }

  Widget donthaveaccount(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        AutoSizeText(
          '¿No tiene una cuenta?',
          style: TextStyle(
            fontSize: (MediaQuery.of(context).size.height * 0.022).toDouble(),
            color: Colors.black,
            fontWeight: FontWeight.w800,
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (c) => SignUpScreen(),
              ),
            );
          },
          child: AutoSizeText(
            ' Registrarse',
            style: TextStyle(
              color: Colors.red,
              fontSize: (MediaQuery.of(context).size.height * 0.024).toDouble(),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
