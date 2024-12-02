import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:sizer/sizer.dart';
import 'package:sensestride/screens/signup.dart';
import 'package:sensestride/storage.dart';
import 'package:sensestride/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sensestride/screens/profile.dart';
import 'package:sensestride/screens/welcome.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  bool isPasswordVisible = false;
  bool isFocusedEmail = false;
  bool isFocusedPassword = false;

  @override
  void initState() {
    super.initState();

    // Añadir listeners a los FocusNodes para actualizar el estado cuando cambie el foco
    _phoneFocusNode.addListener(() {
      setState(() {
        isFocusedEmail = _phoneFocusNode.hasFocus;
      });
    });

    _passwordFocusNode.addListener(() {
      setState(() {
        isFocusedPassword = _passwordFocusNode.hasFocus;
      });
    });

    checkAuthentication(); // Verificar autenticación al iniciar
  }

  // Función para verificar si el usuario está autenticado
  Future<void> checkAuthentication() async {
    String? accessToken = await Storage.read('access_token');
    if (accessToken != null) {
      bool isExpired = JwtDecoder.isExpired(accessToken);
      if (!isExpired) {
        if (!mounted) return; // Verificar si el widget sigue montado

        // Token válido, navegar a la página de perfil
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Profile()),
        );
      } else {
        await refreshAccessToken();
      }
    }
  }

  // Función para refrescar el access token usando el refresh token
  Future<void> refreshAccessToken() async {
    String? refreshToken = await Storage.read('refresh_token');
    if (refreshToken != null) {
      final url = Uri.parse('${Config.baseUrl}/api/refresh');
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({"refresh_token": refreshToken}),
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);

          // Guardar el nuevo access token
          await Storage.write('access_token', responseData['access_token']);

          if (!mounted) return; // Verificar si el widget sigue montado

          // Navegar a la página de perfil
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Profile()),
          );
        } else {
          if (!mounted) return; // Verificar si el widget sigue montado

          // El refresh token es inválido, solicitar inicio de sesión
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Sesión expirada. Por favor, inicia sesión de nuevo.'),
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al refrescar el token: $e'),
          ),
        );
      }
    }
  }

  // Función de login
  Future<void> login() async {
    // Verificar si los campos están vacíos
    if (_phoneController.text.isEmpty || _passwordController.text.isEmpty) {
      if (!mounted) return; // Verificar si el widget sigue montado

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor, completa todos los campos',
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
      return; // Detener la ejecución si los campos están vacíos
    }

    final url = Uri.parse('${Config.baseUrl}/api/login/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "numero": _phoneController.text,
          "contraseña": _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Almacenar los tokens de forma segura
        await Storage.write('access_token', responseData['access_token']);
        await Storage.write('refresh_token', responseData['refresh_token']);
        await Storage.write('phone_number', _phoneController.text);

        if (!mounted) return; // Verificar si el widget sigue montado

        // Navegar a la página de perfil
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Profile()),
        );
      } else {
        if (!mounted) return; // Verificar si el widget sigue montado

        // Mostrar mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Número o contraseña incorrectos'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return; // Verificar si el widget sigue montado

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de conexión: $e'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Container(
                height: 100.h,
                decoration: const BoxDecoration(color: Colors.white),
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 3.h),
                    FadeInDown(
                      delay: const Duration(milliseconds: 900),
                      duration: const Duration(milliseconds: 1000),
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          IconlyBroken.arrow_left,
                          size: 3.6.h,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FadeInDown(
                            delay: const Duration(milliseconds: 800),
                            duration: const Duration(milliseconds: 900),
                            child: Text(
                              'Vamos a iniciar sesión',
                              style: TextStyle(
                                fontSize: 25.sp,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                          SizedBox(height: 1.h),
                          FadeInDown(
                            delay: const Duration(milliseconds: 700),
                            duration: const Duration(milliseconds: 800),
                            child: Text(
                              '¡Bienvenido de nuevo!',
                              style: TextStyle(
                                fontSize: 25.sp,
                                fontWeight: FontWeight.w400,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                          FadeInDown(
                            delay: const Duration(milliseconds: 600),
                            duration: const Duration(milliseconds: 700),
                            child: Text(
                              'Es hora de entrenar',
                              style: TextStyle(
                                fontSize: 25.sp,
                                fontWeight: FontWeight.w400,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 5.h),
                    FadeInDown(
                      delay: const Duration(milliseconds: 700),
                      duration: const Duration(milliseconds: 800),
                      child: Text(
                        'Teléfono',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                    FadeInDown(
                      delay: const Duration(milliseconds: 600),
                      duration: const Duration(milliseconds: 700),
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 0.8.h),
                        padding: EdgeInsets.symmetric(
                            horizontal: 5.w, vertical: .3.h),
                        decoration: BoxDecoration(
                          color: isFocusedEmail
                              ? Colors.white
                              : const Color(0xFFF1F0F5),
                          border: Border.all(
                              width: 1, color: const Color(0xFFD2D2D4)),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            if (isFocusedEmail)
                              BoxShadow(
                                color: const Color(0xFF835DF1).withOpacity(.3),
                                blurRadius: 4.0,
                                spreadRadius: 2.0,
                              ),
                          ],
                        ),
                        child: TextField(
                          controller: _phoneController,
                          focusNode: _phoneFocusNode,
                          keyboardType: TextInputType.phone,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Tu teléfono',
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 15.0),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    FadeInDown(
                      delay: const Duration(milliseconds: 500),
                      duration: const Duration(milliseconds: 600),
                      child: Text(
                        'Contraseña',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                    FadeInDown(
                      delay: const Duration(milliseconds: 400),
                      duration: const Duration(milliseconds: 500),
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 0.8.h),
                        padding: EdgeInsets.symmetric(
                            horizontal: 5.w, vertical: .3.h),
                        decoration: BoxDecoration(
                          color: isFocusedPassword
                              ? Colors.white
                              : const Color(0xFFF1F0F5),
                          border: Border.all(
                              width: 1, color: const Color(0xFFD2D2D4)),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            if (isFocusedPassword)
                              BoxShadow(
                                color: const Color(0xFF835DF1).withOpacity(.3),
                                blurRadius: 4.0,
                                spreadRadius: 2.0,
                              ),
                          ],
                        ),
                        child: TextField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          obscureText: !isPasswordVisible,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: Icon(
                                isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                                size: 20.sp,
                              ),
                              onPressed: () {
                                setState(() {
                                  isPasswordVisible = !isPasswordVisible;
                                });
                              },
                            ),
                            border: InputBorder.none,
                            hintText: 'Contraseña',
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 15.0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    FadeInUp(
                      delay: const Duration(milliseconds: 600),
                      duration: const Duration(milliseconds: 700),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed:
                                  login, // Llama a la función de inicio de sesión
                              child: FadeInUp(
                                delay: const Duration(milliseconds: 700),
                                duration: const Duration(milliseconds: 800),
                                child: Text(
                                  'Iniciar sesión',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                textStyle: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w500),
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    FadeInUp(
                      delay: const Duration(milliseconds: 800),
                      duration: const Duration(milliseconds: 900),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '¿No tienes una cuenta?',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterPage(),
                                ),
                              );
                            },
                            child: Text(
                              'Regístrate',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
