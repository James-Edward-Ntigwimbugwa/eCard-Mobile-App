import 'package:ecard_app/providers/auth_provider.dart';
import 'package:ecard_app/screens/forgot_password.dart';
import 'package:ecard_app/screens/login_screen.dart';
import 'package:ecard_app/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthNavigator extends StatefulWidget{
  const AuthNavigator({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AuthNavigatorState();
  
}

class _AuthNavigatorState extends State<AuthNavigator>{
  final LoginPage _loginScreen = const LoginPage();
  final RegisterPage _registerPage = const RegisterPage();
  final ForgetPasswordPage _forgetPasswordPage = const ForgetPasswordPage();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    Widget currentScreen;
    switch(authProvider.currentScreen){
      case AuthScreen.loginScreen:
        currentScreen = _loginScreen;
        break;
      case AuthScreen.registerScreen:
        currentScreen = _registerPage;
        break;
      case AuthScreen.forgotPassword:
        currentScreen = _forgetPasswordPage;
        break;
      default:
          currentScreen = _loginScreen;
      }
    return currentScreen;
  }
  
}