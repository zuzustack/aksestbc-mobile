import 'package:flutter/material.dart';
import 'views/main_screen.dart';

void main() {
  runApp(const AksesTBCApp());
}

class AksesTBCApp extends StatelessWidget {
  const AksesTBCApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AksesTBC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF007B7A),
        // Gunakan font yang sesuai, misalnya Google Fonts (Inter atau Poppins)
        fontFamily: 'Inter',
      ),
      // Set MainScreen sebagai tampilan pertama yang muncul
      home: const MainScreen(),
    );
  }
}