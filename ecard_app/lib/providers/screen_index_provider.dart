import 'package:flutter/material.dart';

class ScreenIndexProvider with ChangeNotifier {
  int screenIndex = 0;
  int get currentScreenIndex => screenIndex;

  void setCurrentIndex(int newIndex) {
    screenIndex = newIndex;
    notifyListeners();
  }
}
