/*
  * themes.dart *
  Class in charge of managing teh app's themes.
 */
import 'package:flutter/material.dart';

/// Manages the themes, including colorSchemes, of the app.
/// Contains blueTheme.
class Themes {
  // St. X Blue theme
  static final ThemeData blueTheme = ThemeData(
      colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF448AFF),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFFFFFFF),
    secondary: Color(0xFF2196F3),
    onSecondary: Color(0xFFE1E1E1),
    tertiary: Color(0xFF495F69),
    onTertiary: Color(0xFF1C1E21),
    tertiaryContainer: Color(0xFF6E707C),
    surface: Color(0xFFE1E1E1),
    shadow: Color(0xFF3B3B3B),
    onSurface: Color(0xFF000000),
    surfaceContainer: Color(0xFFC9C9C9),
    //Hides all error shit
    error: Color(0xFF550312),
    onError: Color(0xFFE1E1E1),
  ));
}
