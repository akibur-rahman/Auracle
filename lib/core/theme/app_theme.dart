import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _primaryColor = Color(0xFF1DB954); // Spotify-like green
  static const _amoledBlack = Color(0xFF000000); // True AMOLED black
  static const _darkSurfaceColor = Color(0xFF121212); // Dark surface for cards
  static const _darkSurfaceVariant = Color(
    0xFF1E1E1E,
  ); // Slightly lighter for contrast

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: _amoledBlack,
    colorScheme: ColorScheme.dark(
      primary: _primaryColor,
      surface: _amoledBlack,
      background: _amoledBlack,
      surfaceContainerHighest: _darkSurfaceColor,
      surfaceContainerHigh: _darkSurfaceVariant,
      onSurface: Colors.white,
      onPrimary: Colors.white,
      brightness: Brightness.dark,
    ),
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
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: _primaryColor.withOpacity(0.5),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _primaryColor,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    cardTheme: CardTheme(
      color: _darkSurfaceColor,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    listTileTheme: ListTileThemeData(
      tileColor: _darkSurfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
  );
}
