import 'package:flutter/material.dart';

void main() {
  runApp(const CampusBuddyApp());
}

class CampusBuddyApp extends StatelessWidget {
  const CampusBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampusBuddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A73E8),
          primary: const Color(0xFF1A73E8),
          secondary: const Color(0xFF0D47A1),
          surface: const Color(0xFFFFFFFF),
          error: const Color(0xFFD32F2F),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            'CampusBuddy',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A73E8),
            ),
          ),
        ),
      ),
    );
  }
}
