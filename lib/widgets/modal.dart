import 'package:flutter/material.dart';

class ModalAlertDialog extends StatelessWidget {

  final String title;
  final String content;
  const ModalAlertDialog({
    Key? key, required this.title, required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
      ),
      content: Text(content),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            backgroundColor: Color.fromARGB(255, 3, 3, 247),
            shape: const StadiumBorder()
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("OK"),
        ),
      ],
    );
  }
}
