// lib/app.dart
import 'package:flutter/material.dart';
import 'package:rental_mobil_app_flutter/features/auth/presentation/screens/login_screen.dart';
import 'package:rental_mobil_app_flutter/config/theme/app_theme.dart'; // Import tema

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rental Mobil App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme, // Gunakan tema kustom
      home: const LoginScreen(),
    );
  }
}