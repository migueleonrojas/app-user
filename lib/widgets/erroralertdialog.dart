import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class ErrorAlertDialog extends StatelessWidget {
  final String? message;

  const ErrorAlertDialog({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: key,
      content: Text(message!),
      actions: [
        ElevatedButton(
          /* color: Colors.red, */
          onPressed: () {
            Navigator.pop(context);
          },
          child: Center(
            child: Text("Ok"),
          ),
        ),
      ],
    );
  }
}
