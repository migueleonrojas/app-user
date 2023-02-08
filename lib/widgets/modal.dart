import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class ModalAlertDialog extends StatelessWidget {

  final String title;
  final String content;
  const ModalAlertDialog({
    Key? key, required this.title, required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return AlertDialog(
      title: AutoSizeText(
        title,
      ),
      content: AutoSizeText(content),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: size.height * 0.025, horizontal: size.width * 0.1),
            backgroundColor: const Color.fromARGB(255, 3, 3, 247),
            shape: const StadiumBorder()
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          child: AutoSizeText("OK"),
        ),
      ],
    );
  }
}
