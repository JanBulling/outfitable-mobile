import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

class AppTheme {
  static final ThemeData light = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.light().copyWith(
      primary: lightAccentColor,
      secondary: lightAccentColor,
      onSecondary: Colors.white,
    ),
    primaryColor: lightPrimaryColor,
    accentColor: lightAccentColor,
    //textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
  );
}
