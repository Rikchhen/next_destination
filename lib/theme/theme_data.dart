import 'package:flutter/material.dart';
import 'package:next_destination/utils/colors.dart';

ThemeData getApplicationTheme() {
  return ThemeData(
    primaryColor: primaryRed,
    primarySwatch: Colors.red,
    fontFamily: 'OpenSans Regular',

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide: BorderSide(color: primaryRed, width: 2),
      ),
    ),
  );
}
