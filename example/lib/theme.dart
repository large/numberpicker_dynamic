import 'package:flutter/material.dart';

///Theme handler is used to switch between light and dark theme
class ThemeHandler with ChangeNotifier {
  bool _isDark = false;

  ThemeMode currentTheme() {
    return _isDark ? ThemeMode.dark : ThemeMode.light;
  }

  void switchTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
}
