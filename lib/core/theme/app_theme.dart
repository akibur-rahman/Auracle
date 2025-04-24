import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _primaryColor = Color(0xFF1DB954); // Spotify-like green
  static const _darkBackgroundColor = Color(
    0xFF121212,
  ); // Very dark gray, almost black
  static const _darkSurfaceColor = Color(0xFF1E1E1E); // Dark gray for inputs

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: _primaryColor,
    colorScheme: const ColorScheme.dark(
      primary: _primaryColor,
      background: _darkBackgroundColor,
      surface: _darkSurfaceColor,
      onSurface: Colors.white,
      onBackground: Colors.white,
      onPrimary: Colors.white,
    ),
    scaffoldBackgroundColor: _darkBackgroundColor,
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkSurfaceColor,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 20.0,
        horizontal: 20.0,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _primaryColor),
      ),
      hintStyle: const TextStyle(color: Colors.grey),
      prefixIconColor: Colors.grey,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return _primaryColor.withOpacity(0.5);
          }
          return _primaryColor;
        }),
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        textStyle: MaterialStateProperty.all<TextStyle>(
          const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
          const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(_primaryColor),
        textStyle: MaterialStateProperty.all<TextStyle>(
          const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    ),
  );
}
