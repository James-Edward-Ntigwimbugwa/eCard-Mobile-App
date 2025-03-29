import 'package:ecard_app/screens/forgot_password.dart';
import 'package:ecard_app/screens/login_screen.dart';
import 'package:ecard_app/screens/register_screen.dart';
import 'package:flutter/material.dart';

class ScreenIndexProvider with ChangeNotifier {
  int screenIndex = 0;
  int get currentScreenIndex => screenIndex;

  void setCurrentIndex(int newIndex) {
    screenIndex = newIndex;
    notifyListeners();
  }
}

class AuthScreensIndexProvider with ChangeNotifier {
  int screenIndex = 0;
  int get currentScreenIndex => screenIndex;
  final loginPage = const LoginPage();
  final registerPage = const RegisterPage();
  final forgotPasswordPage = const ForgetPasswordPage();

  void setCurrentIndex(int newIndex) {
    screenIndex = newIndex;
    notifyListeners();
  }
}
