import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Color kAppColor = Colors.black;
// ColorScheme kColorScheeme = ColorScheme.fromSeed(seedColor: kAppColor);

ThemeData darkTheme = ThemeData.dark().copyWith(
  //
  // ------------ Text Theme ------------

  textTheme: TextTheme(
    displayLarge: GoogleFonts.bungee().copyWith(
      color: Colors.grey,
    ),
    labelMedium: TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 16,
    ),
  ),

  //  ------------ Button Style ----------

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.grey.shade300,
      textStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.grey.shade300,
      textStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
      ),
    ),
  ),

  //  ------------ TextField Style ----------

  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
);
