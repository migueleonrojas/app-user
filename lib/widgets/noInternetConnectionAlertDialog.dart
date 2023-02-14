import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class NoInternetConnectionAlertDialog extends StatelessWidget {
  const NoInternetConnectionAlertDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "No posee conexión a internet",
      ),
      content: Text("Comprueba la configuración de tu red e inténtalo de nuevo."),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height.toDouble() * 0.035, horizontal: MediaQuery.of(context).size.height.toDouble() * 0.035),
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
