import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

AppBar simpleAppBar(bool isMainTitle, String title, BuildContext context) {

  Size size = MediaQuery.of(context).size;

  return AppBar(
    backgroundColor: Colors.white,
    iconTheme: IconThemeData(color: Colors.black),
    elevation: 0,
    title: AutoSizeText(
      
      isMainTitle ? "AutoParts" : title,
      style: TextStyle(
        fontSize: size.height * 0.025,
        letterSpacing: 1.5,
        fontWeight: FontWeight.bold,
        fontFamily: "Brand-Regular",
        color: Colors.black
      ),
    ),
    centerTitle: true,
  );
}
