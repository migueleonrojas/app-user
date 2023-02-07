import 'package:flutter/material.dart';

class MyTextFormField extends StatelessWidget {
  const MyTextFormField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.labelText,
    required this.maxLine,
  }) : super(key: key);

  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final int maxLine;
  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.075,
        vertical: size.height * 0.012,
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLine,
        style: TextStyle(
          fontSize: size.height * 0.022,
          fontWeight: FontWeight.w600,
          fontFamily: "Brand-Regular",
        ),
        decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: size.height * 0.022,
              fontWeight: FontWeight.w600,
              fontFamily: "Brand-Regular",
            ),
            labelText: labelText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(size.height * 0.014),
            )),
      ),
    );
  }
}
