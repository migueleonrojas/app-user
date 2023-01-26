import 'package:oilapp/Screens/Authentication/signup_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginHelper extends ChangeNotifier {
  Widget loginLog() {
    return Image.asset(
      "assets/authenticaiton/global-oil.jpg",
      width: 300,
      height: 150,
    );
  }

  Widget welcomeText() {
    return const Text(
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
      child:  Text(
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
    return const Text(
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
  //       label: Text(
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
        const Text(
          '¿No tiene una cuenta?',
          style: TextStyle(
            fontSize: 18.0,
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
          child: Text(
            ' Registrarse',
            style: TextStyle(
              color: Colors.red,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
