import 'package:flutter/material.dart';
import 'package:sensestride/storage.dart';
import 'package:sensestride/screens/welcome.dart';
//import 'dart:async';

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  void _logout(BuildContext context) async {
    // Eliminar los tokens del almacenamiento seguro
    await Storage.delete('access_token');
    await Storage.delete('refresh_token');

    // Navegar a la pantalla de bienvenida y eliminar las rutas anteriores
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WelcomePage()),
      (Route<dynamic> route) => false,
    );
  }

  // Función para mostrar el diálogo de confirmación
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
                _logout(context); // Llamar a la función de logout
              },
              child: const Text('Cerrar sesión'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Perfil"),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono circular simulando la imagen de perfil
            CircleAvatar(
              radius: 70, // Tamaño del círculo
              child: const Icon(
                Icons.person,
                size: 70, // Tamaño del icono dentro del círculo
              ),
            ),
            const SizedBox(height: 16), // Espacio entre el icono y el texto
            // Nombre y apellido
            const Text(
              "Nombre Apellido",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32), // Espacio entre el texto y los botones
            // Primer botón para navegar a otra pantalla
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/first');
              },
              child: const Text("Ir a entrenar"),
            ),
            const SizedBox(height: 16), // Espacio entre los botones
            // Segundo botón para navegar a otra pantalla
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/second');
              },
              child: const Text("Ver historico"),
            ),
          ],
        ),
      ),
    );
  }
}
