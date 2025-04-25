import 'package:flutter/material.dart';

class AppThemeColor {
  static const primaryColor = Color.fromARGB(255, 0, 132, 112);
  static const darkMode = Color.fromARGB(255, 0, 96, 81);
  static const greenBrighter = Color.fromARGB(255, 9, 148, 127);
  static const greenLower = Color.fromARGB(255, 0, 197, 168);
  static const brightness = Colors.white;
  static const blue = Color.fromARGB(255, 68, 17, 129);
  static const shadows = Color.fromARGB(129, 0, 0, 0);
  static const black = Color.fromARGB(129, 0, 0, 0);
}

class AppThemeController {
  static final lightMode = ThemeData(
      primaryColor: AppThemeColor.primaryColor,
      primaryColorLight: AppThemeColor.greenBrighter,
      primaryColorDark: AppThemeColor.darkMode,
      cardColor: const Color.fromARGB(255, 227, 227, 227),
      highlightColor: AppThemeColor.brightness,
      canvasColor: const Color.fromARGB(255, 205, 218, 216),
      hintColor: const Color.fromARGB(255, 33, 33, 33),
      secondaryHeaderColor: const Color.fromARGB(255, 232, 232, 232),
      focusColor: Colors.white70,
      indicatorColor: Colors.black38);

  static final darkMode = ThemeData(
      primaryColor: AppThemeColor.darkMode,
      primaryColorLight: AppThemeColor.greenLower,
      primaryColorDark: AppThemeColor.darkMode,
      cardColor: const Color.fromARGB(179, 56, 56, 56),
      canvasColor: const Color.fromARGB(255, 28, 129, 17),
      highlightColor: const Color.fromARGB(20,169, 169, 169),
      hintColor: const Color.fromARGB(255, 255, 255, 255),
      secondaryHeaderColor: const Color.fromARGB(255, 36, 36, 36),
      focusColor: const Color.fromARGB(179, 56, 56, 56),
      indicatorColor: const Color.fromARGB(218, 238, 238, 238));
}