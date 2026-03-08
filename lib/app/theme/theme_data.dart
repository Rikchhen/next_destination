import 'package:flutter/material.dart';
import 'package:next_destination/core/utils/colors.dart';

ThemeData getApplicationTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: primaryRed,
    primary: primaryRed,
    secondary: accentAmber,
    surface: surfaceWhite,
    brightness: Brightness.light,
  );

  return ThemeData(
    useMaterial3: true,
    primaryColor: primaryRed,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: const Color(0xFFF9F6F6),
    fontFamily: 'OpenSans Regular',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: Colors.black87),
      titleTextStyle: TextStyle(
        fontFamily: 'OpenSans SemiBold',
        fontSize: 22,
        color: Colors.black87,
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontFamily: 'OpenSans Bold',
        fontSize: 30,
        color: Colors.black87,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'OpenSans SemiBold',
        fontSize: 24,
        color: Colors.black87,
      ),
      titleLarge: TextStyle(
        fontFamily: 'OpenSans SemiBold',
        fontSize: 20,
        color: Colors.black87,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'OpenSans Regular',
        fontSize: 16,
        color: Colors.black87,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'OpenSans Regular',
        fontSize: 14,
        color: Colors.black54,
      ),
    ),
    cardTheme: CardThemeData(
      color: surfaceWhite,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: Colors.black.withOpacity(0.07),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceWhite,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: TextStyle(
        color: Colors.black.withOpacity(0.45),
        fontFamily: 'OpenSans Regular',
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: const BorderSide(color: borderSoft),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: const BorderSide(color: borderSoft),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: const BorderSide(color: primaryRed, width: 1.8),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryRed,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(
          fontFamily: 'OpenSans SemiBold',
          fontSize: 15,
          letterSpacing: 0.2,
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceSoft,
      selectedColor: primaryRed.withOpacity(0.14),
      labelStyle: const TextStyle(
        color: Colors.black87,
        fontFamily: 'OpenSans Medium',
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      side: const BorderSide(color: borderSoft),
    ),
  );
}

ThemeData getDarkApplicationTheme() {
  const darkSurface = Color(0xFF191C23);
  const darkCard = Color(0xFF21262F);
  final colorScheme = ColorScheme.fromSeed(
    seedColor: primaryRed,
    primary: const Color(0xFFE57373),
    secondary: accentAmber,
    brightness: Brightness.dark,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: colorScheme.primary,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: const Color(0xFF10131A),
    fontFamily: 'OpenSans Regular',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: darkCard,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.52)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.09)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.09)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.8),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );
}

