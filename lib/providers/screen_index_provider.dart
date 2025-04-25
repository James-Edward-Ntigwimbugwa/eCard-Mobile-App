import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScreenIndexProvider with ChangeNotifier {
  int screenIndex = 0;
  int get currentScreenIndex => screenIndex;

  void setCurrentIndex(int newIndex) {
    screenIndex = newIndex;
    notifyListeners();
  }
}

class TabIndexProvider with ChangeNotifier {
  int _currentScreenIndex = 0;

  int get currentScreenIndex => _currentScreenIndex;

  void setCurrentIndex(int index) {
    if (_currentScreenIndex != index) {
      _currentScreenIndex = index;
      notifyListeners();

      // Consider saving to persistent storage
      _saveTabIndex(index);
    }
  }

  // Add persistence using shared preferences
  Future<void> _saveTabIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('saved_tab_index', index);
  }

  // Load saved tab index
  Future<void> loadSavedIndex() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIndex = prefs.getInt('saved_tab_index');
    if (savedIndex != null) {
      _currentScreenIndex = savedIndex;
      notifyListeners();
    }
  }
}
