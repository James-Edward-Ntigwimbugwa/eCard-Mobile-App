import 'package:ecard_app/providers/user_provider.dart';
import 'package:ecard_app/screens/dashboard_screen.dart';
import 'package:ecard_app/screens/splash_screen.dart';
import 'package:ecard_app/screens/auth_navigator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PageRouter {
  static Route<dynamic>? switchRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case '/dashboard':
        return MaterialPageRoute(builder: (context) {
          final userProvider =
              Provider.of<UserProvider>(context, listen: false);
          return DashboardPage(user: userProvider.user);
        });
      case '/auth':
        return MaterialPageRoute(builder: (context) => const AuthNavigator());
      default:
        return null;
    }
  }
}
