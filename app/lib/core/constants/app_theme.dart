import 'package:flutter/material.dart';

class AppTheme {
  // Color palette
  static const Color primaryOrange = Color(0xFFF24C00);
  static const Color lightOrange = Color(0xFFFC7A1E);
  static const Color paleOrange = Color(0xFFF9C784);
  static const Color darkBlue = Color(0xFF485696);
  static const Color lightGrey = Color(0xFFE7E7E7);
  static const Color cardBackground = Color(0xFFFCFBF8);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Satoshi',
      colorScheme: ColorScheme.fromSeed(
        seedColor: lightOrange,
        primary: lightOrange,
        secondary: darkBlue,
        brightness: Brightness.light,
      ),
      primaryColor: lightOrange,
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      cardTheme: CardThemeData(
        elevation: 2,
        color: cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Satoshi',
      colorScheme: ColorScheme.fromSeed(
        seedColor: lightOrange,
        primary: lightOrange,
        secondary: darkBlue,
        brightness: Brightness.dark,
      ),
      primaryColor: lightOrange,
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
