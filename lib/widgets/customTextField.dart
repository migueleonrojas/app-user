import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final IconData? data;
  final String? hintText;
  final String? labelText;
  final TextInputType? textInputType;
  void Function()? function;
  bool? isObsecure = true;
  bool? showCursor = true;

  CustomTextField({
    Key? key,
    this.controller,
    this.data,
    this.hintText,
    this.isObsecure,
    this.showCursor,
    this.textInputType,
    this.labelText,
    this.function,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal:16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        showCursor: showCursor,
        controller: controller,
        obscureText: isObsecure!,
        keyboardType: textInputType,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          prefixIcon: Icon(
            data,
            color: Theme.of(context).primaryColor,
          ),
          focusColor: Theme.of(context).primaryColor,
          hintText: hintText,
        ),
        onTap: function
        
      ),
    );
  }
}
