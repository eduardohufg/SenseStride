import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:sensestride/screens/welcome.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: '',
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.white,
              brightness: Brightness.dark,
              primary: const Color(0xFF107dd8),
              onPrimary: Colors.black,
              secondary: const Color(0xFF112b3c),
              onSecondary: Colors.white,
              tertiary: const Color(0xff5b6670),
              primaryContainer: const Color(0x52131B44),
              onPrimaryContainer: const Color.fromARGB(255, 224, 224, 224),
              secondaryContainer: const Color.fromARGB(255, 17, 31, 85),
              onSecondaryContainer: const Color.fromARGB(255, 105, 105, 105),
              surface: const Color.fromARGB(255, 255, 255, 255),
              error: Colors.red,
              onError: Colors.white,
            ),
          ),
          home: WelcomePage()),
    );
  }
}
