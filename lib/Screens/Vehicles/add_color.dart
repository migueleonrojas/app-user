import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:oil_app/config/config.dart';


class AddColor extends StatefulWidget {
  Color? pickerColor;
  AddColor({this.pickerColor});
  @override
  State<AddColor> createState() => _AddColorState();
}

class _AddColorState extends State<AddColor> {

  void changeColor(Color color) {
   setState(() => widget.pickerColor = color);
  }

  
  Color? currentColor;

  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: ColorPicker(
          pickerColor: widget.pickerColor ?? Colors.black, 
          onColorChanged: changeColor,
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Agregar'),
          onPressed: () {
            Navigator.of(context).pop(widget.pickerColor!.value);
            
          },
        ),
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }  
  
}