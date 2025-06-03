import 'package:flutter/material.dart';

class AppTheme {
  static final Color backgroundColor = Color(0xFF1A2E1A);
  static final Color textFieldBackgroundColor = Color(0xFF2A402A);
  static final Color accentColor = Color(0xFF8BC34A);
  static final Color textColor = Colors.white.withOpacity(0.8);
  static final Color hintColor = Colors.white.withOpacity(0.5);

  static ThemeData get darkTheme { // Atau lightTheme jika preferensi Anda berbeda
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark, // Karena latarnya gelap
      primaryColor: accentColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.dark(
        primary: accentColor,
        secondary: accentColor,
        surface: textFieldBackgroundColor, // Warna permukaan seperti Card, TextField
        background: backgroundColor,
        error: Colors.redAccent,
        onPrimary: Colors.black87, // Warna teks di atas primary color (tombol)
        onSecondary: Colors.black87,
        onSurface: textColor, // Warna teks di atas surface
        onBackground: textColor,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        titleTextStyle: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: textFieldBackgroundColor,
        hintStyle: TextStyle(color: hintColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        labelStyle: TextStyle(color: textColor), // Untuk floating label jika ada
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.black87, // Warna teks tombol
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: hintColor.withOpacity(0.8), // Warna teks untuk text button
        ),
      ),
      textTheme: TextTheme( // Definisikan gaya teks utama
        bodyLarge: TextStyle(color: textColor),
        bodyMedium: TextStyle(color: textColor),
        titleMedium: TextStyle(color: textColor),
        titleSmall: TextStyle(color: textColor),
        headlineSmall: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        // ... definisikan gaya teks lain jika perlu
      ).apply(bodyColor: textColor, displayColor: textColor), // Pastikan semua teks defaultnya sesuai
    );
  }
}