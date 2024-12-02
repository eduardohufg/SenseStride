import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Para manejar JSON
import 'package:sensestride/storage.dart';
import 'package:sensestride/screens/welcome.dart';
import 'package:sensestride/screens/home.dart';
import 'package:sensestride/screens/history.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String nombre = "Nombre";
  String apellidos = "Apellido";
  bool isLoading = true; // Estado de carga
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

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

  Future<void> _fetchUserData() async {
    try {
      // Obtener el número desde el almacenamiento
      String? numero = await Storage.read('phone_number');

      if (numero == null || numero.isEmpty) {
        setState(() {
          errorMessage = 'Número de usuario no encontrado.';
          isLoading = false;
        });
        return;
      }

      // URL del endpoint
      final String apiUrl =
          'http://10.48.70.112:8000/api/load_data/get_names'; // Reemplaza con tu URL

      // Opcional: Obtener el token de acceso si tu API lo requiere
      String? token = await Storage.read('access_token');

      // Configurar los headers
      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      // Realizar la solicitud GET
      final response = await http.get(
        Uri.parse('$apiUrl?number=$numero'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // Parsear la respuesta JSON
        final data = json.decode(response.body);
        setState(() {
          nombre = data['nombre'];
          apellidos = data['apellidos'];
          isLoading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          errorMessage = 'El usuario no existe.';
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Error al obtener los datos del usuario.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error de conexión: $e';
        isLoading = false;
      });
    }
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
        child: isLoading
            ? const CircularProgressIndicator()
            : errorMessage.isNotEmpty
                ? Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 18),
                  )
                : Column(
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
                      const SizedBox(
                          height: 16), // Espacio entre el icono y el texto
                      // Nombre y apellido
                      Text(
                        "$nombre $apellidos",
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                          height: 32), // Espacio entre el texto y los botones
                      // Primer botón para navegar a otra pantalla
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomePage(),
                            ),
                          );
                        },
                        child: const Text("Ir a entrenar"),
                      ),
                      const SizedBox(height: 16), // Espacio entre los botones
                      // Segundo botón para navegar a otra pantalla
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HistoryPage(),
                            ),
                          );
                        },
                        child: const Text("Ver histórico"),
                      ),
                    ],
                  ),
      ),
    );
  }
}
