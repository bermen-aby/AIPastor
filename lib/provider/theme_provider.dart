import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.light;
  bool get isDarkMode => themeMode == ThemeMode.dark;

  // ignore: avoid_positional_boolean_parameters
  void toggleTheme(bool isOn) {
    isOn == true ? themeMode = ThemeMode.dark : themeMode = ThemeMode.light;
    SystemChrome.setSystemUIOverlayStyle(
        isDarkMode ? darkOverlayStyle : lightOverlayStyle);
    notifyListeners();
  }

  // ignore: avoid_positional_boolean_parameters
  void toggleInit(bool isOn) {
    isOn == true ? themeMode = ThemeMode.dark : themeMode = ThemeMode.light;
    // notifyListeners();
  }
}
