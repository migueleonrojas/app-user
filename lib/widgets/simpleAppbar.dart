import 'package:flutter/material.dart';

AppBar simpleAppBar(bool isMainTitle, String title) {
  return AppBar(
    backgroundColor: Colors.white,
    iconTheme: IconThemeData(color: Colors.black),
    elevation: 0,
    title: Text(
      
      isMainTitle ? "AutoParts" : title,
      style: TextStyle(
        fontSize: 20,
        letterSpacing: 1.5,
        fontWeight: FontWeight.bold,
        fontFamily: "Brand-Regular",
        color: Colors.black
      ),
    ),
    centerTitle: true,
  );
}
