import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFF6F9F4),
    fontFamily: 'Roboto',
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.green,
      primary: const Color(0xFF388E3C), // verde hoja
      secondary: const Color(0xFFFDD835), // amarillo claro
    ),

    // AppBar general
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF388E3C),
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 2,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Roboto',
        color: Colors.white,
      ),
    ),

    // Tarjetas y contenedores
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    // Botones elevados
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        backgroundColor: Colors.teal[50],
        foregroundColor: Colors.black87,
        textStyle: const TextStyle(fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),

    // Texto global
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontSize: 16),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    ),

    // Estilo general de íconos
    iconTheme: const IconThemeData(color: Colors.teal),
  );
}
