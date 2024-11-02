// success_dialog.dart
import 'package:flutter/material.dart';
import 'package:sensestride/screens/login.dart';

class SuccessDialog extends StatelessWidget {
  const SuccessDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Registro Exitoso"),
      content: const Text("Registro exitoso. Por favor, inicie sesión."),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
          child: const Text("Aceptar"),
        ),
      ],
    );
  }
}
