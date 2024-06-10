import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Color kAppColor = Colors.green;
ColorScheme kColorScheeme = ColorScheme.fromSeed(
  seedColor: kAppColor,
  background: Colors.white,
);

ThemeData lighTheme = ThemeData(
  canvasColor: Colors.red,
  colorScheme: kColorScheeme,

  // ------------ Text Theme ------------

  textTheme: TextTheme(
    displayLarge: GoogleFonts.bungee().copyWith(
      color: kAppColor,
    ),
    labelMedium: TextStyle(
      color: kColorScheeme.primary,
      fontWeight: FontWeight.w600,
      fontSize: 16,
    ),
  ),

  //  ------------ Button Style ----------

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kColorScheeme.primary,
      foregroundColor: kColorScheeme.onPrimary,
      textStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: kColorScheeme.primary,
      side: BorderSide(color: kAppColor),
      textStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
      ),
    ),
  ),

  //  ------------ TextField Style ----------

  inputDecorationTheme: InputDecorationTheme(
    hintStyle: TextStyle(
      color: kColorScheeme.primaryContainer,
    ),
    prefixIconColor: kColorScheeme.primary,
    suffixIconColor: kColorScheeme.primary,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
);
