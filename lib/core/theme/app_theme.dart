import 'package:flutter/material.dart';

enum NavThemeMode {
  darkNavy,
  nightVisionRed,
}

class AppTheme {
  // --- Dark Navy Palette ---
  static const Color navyBackground = Color(0xFF0A192F);
  static const Color navySurface = Color(0xFF112240);
  static const Color navyCard = Color(0xFF1E3A5F);
  static const Color neonCyan = Color(0xFF00E5FF);
  static const Color electricBlue = Color(0xFF0284C7);
  static const Color navyTextPrimary = Color(0xFFF1F5F9);
  static const Color navyTextSecondary = Color(0xFF94A3B8);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color alertRed = Color(0xFFEF4444);
  static const Color successGreen = Color(0xFF10B981);

  // --- Night Vision Red Palette (for night watches & preserving captain's night vision) ---
  static const Color nightBackground = Color(0xFF0D0202);
  static const Color nightSurface = Color(0xFF1F0505);
  static const Color nightCard = Color(0xFF2E0909);
  static const Color nightRedPrimary = Color(0xFFFF3B30);
  static const Color nightRedSecondary = Color(0xFFB91C1C);
  static const Color nightTextPrimary = Color(0xFFFF6B6B);
  static const Color nightTextSecondary = Color(0xFF991B1B);

  static ThemeData get darkNavyTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: navyBackground,
      colorScheme: const ColorScheme.dark(
        primary: neonCyan,
        onPrimary: navyBackground,
        secondary: electricBlue,
        onSecondary: Colors.white,
        surface: navySurface,
        onSurface: navyTextPrimary,
        error: alertRed,
        onError: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: navySurface,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF233554), width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: navyBackground,
        foregroundColor: navyTextPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: neonCyan,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: navyBackground,
        selectedItemColor: neonCyan,
        unselectedItemColor: navyTextSecondary,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  static ThemeData get nightVisionTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: nightBackground,
      colorScheme: const ColorScheme.dark(
        primary: nightRedPrimary,
        onPrimary: nightBackground,
        secondary: nightRedSecondary,
        onSecondary: Colors.black,
        surface: nightSurface,
        onSurface: nightTextPrimary,
        error: nightRedPrimary,
        onError: Colors.black,
      ),
      cardTheme: CardThemeData(
        color: nightSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: nightRedSecondary, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: nightBackground,
        foregroundColor: nightRedPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: nightRedPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: nightBackground,
        selectedItemColor: nightRedPrimary,
        unselectedItemColor: nightTextSecondary,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
