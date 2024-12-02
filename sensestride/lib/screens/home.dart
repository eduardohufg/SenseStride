import 'package:flutter/material.dart';
import 'dart:async';
import 'package:sensestride/storage.dart'; // Asegúrate de importar Storage
import 'package:sensestride/screens/welcome.dart'; // Importar WelcomePage para navegar

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Timer? _timer; // Declarar como nullable
  int _milliseconds = 0; // Tiempo en milisegundos
  bool _isRunning = false;
  bool _isFinished = false;

  /// Iniciar o detener el cronómetro
  void _startStopTimer() {
    if (_isRunning) {
      _stopTimer();
    } else {
      _startTimer();
    }
  }

  /// Iniciar el cronómetro
  void _startTimer() {
    setState(() {
      _isRunning = true;
      _isFinished = false;
    });
    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (!mounted) return; // Verificar si el widget aún está montado
      setState(() {
        _milliseconds += 10;
      });
    });
  }

  /// Detener el cronómetro
  void _stopTimer() {
    _timer?.cancel(); // Cancelar si no es null
    setState(() {
      _isRunning = false;
      _isFinished = true; // Indica que el cronómetro está detenido
    });
  }

  /// Reiniciar el cronómetro
  void _resetTimer() {
    setState(() {
      _milliseconds = 0;
      _isFinished = false;
      _isRunning = false;
    });
  }

  /// Guardar el tiempo (puedes implementar la lógica según tus necesidades)
  void _saveTime() {
    // Implementar función para guardar el tiempo
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tiempo guardado')),
    );
    _resetTimer();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancelar el timer si está activo
    super.dispose();
  }

  /// Formatear el tiempo en mm:ss:hh
  String _formatTime(int milliseconds) {
    int minutes = (milliseconds ~/ 60000) % 60;
    int seconds = (milliseconds ~/ 1000) % 60;
    int hundredths = (milliseconds ~/ 10) % 100;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}:'
        '${hundredths.toString().padLeft(2, '0')}';
  }

  /// Función para cerrar sesión
  void _logout() async {
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

  /// Mostrar diálogo de confirmación para cerrar sesión
  void _showLogoutDialog() {
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
                _logout(); // Llamar a la función de logout
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
        automaticallyImplyLeading: true,
        title: const Text('Cronómetro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              _showLogoutDialog();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatTime(_milliseconds),
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startStopTimer,
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(50), // Tamaño del botón
                backgroundColor: Colors.blue, // Color del botón
              ),
              child: Text(
                _isRunning ? 'Detener' : 'Iniciar',
                style: const TextStyle(fontSize: 20),
              ),
            ),
            if (_isFinished)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _resetTimer,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                    ),
                    child: const Text(
                      'Reiniciar',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _saveTime,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                    ),
                    child: const Text(
                      'Guardar tiempo',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
