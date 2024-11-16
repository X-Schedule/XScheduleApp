import 'package:flutter/material.dart';

/*
Themes:
Class designed to organize app themes(color scheme, fonts, etc.)

Using Flutter themes allows for easier adjustments to global colors and a more professional UI
 */

class Themes {
  static ThemeData blueTheme = ThemeData(
      colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: Colors.blueAccent,
    onPrimary: Colors.white,
    primaryContainer: Colors.white,
    secondary: Colors.blue,
    onSecondary: Color(0xFFCBCBCB),
    tertiaryContainer: Color(0xFF6A6D75),
    surface: Color(0xFFDCDCDC),
    shadow: Color(0xFFCBCBCB),
    onSurface: Colors.black,
    surfaceContainer: Color(0xFFC9C9C9),
    error: Colors.transparent,
    onError: Colors.transparent,
  ));
}
