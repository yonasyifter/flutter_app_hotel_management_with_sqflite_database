import 'package:flutter/material.dart';

class AppTheme {
  static const cream = Color(0xFFF5F0E8);
  static const ink = Color(0xFF1A1208);
  static const brown = Color(0xFF6B4226);
  static const amber = Color(0xFFD4870A);
  static const amberLight = Color(0xFFF0B84A);
  static const green = Color(0xFF2D6A4F);
  static const greenLight = Color(0xFF52B788);
  static const red = Color(0xFFB5323A);
  static const redLight = Color(0xFFE76F51);
  static const paper = Color(0xFFFBF8F2);
  static const rule = Color(0xFFD8CEBF);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'NotoEthiopic', // Global Amharic font

      scaffoldBackgroundColor: cream,
      colorScheme: const ColorScheme.light(
        primary: ink,
        secondary: amber,
        surface: paper,
        error: red,
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 38,
          fontWeight: FontWeight.w900,
          color: ink,
          letterSpacing: 0,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: ink,
          letterSpacing: 0,
          height: 1.2,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: ink,
          height: 1.3,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: ink,
          height: 1.3,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: ink,
          height: 1.4,
        ),
        bodyLarge: TextStyle(
          fontSize: 16, // Increased for readability
          color: ink,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14, // Increased for readability
          color: brown,
          height: 1.5,
        ),
        labelSmall: TextStyle(
          fontSize: 12,
          color: brown,
          letterSpacing: 0,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: rule),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: rule),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: amber, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        labelStyle: const TextStyle(
          fontSize: 13,
          color: brown,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ink,
          foregroundColor: cream,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'NotoEthiopic',
          ),
        ),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: ink,
        foregroundColor: cream,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: cream,
          fontFamily: 'NotoEthiopic',
        ),
        iconTheme: IconThemeData(color: amberLight),
      ),
      
      dividerTheme: const DividerThemeData(
        color: rule,
        thickness: 1,
      ),

      cardTheme: CardThemeData(
        color: paper,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: rule, width: 1.5),
        ),
        margin: const EdgeInsets.only(bottom: 12),
      ),
    );
  }
}

// Updated currency for Ethiopia (Birr)
String formatCurrency(double amount) =>
    '${amount.toStringAsFixed(2)} ብር';