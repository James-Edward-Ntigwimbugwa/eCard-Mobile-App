import 'package:ecard_app/providers/screen_index_provider.dart';
import 'package:ecard_app/providers/user_provider.dart';
import 'package:ecard_app/screens/dashboard_screen.dart';
import 'package:ecard_app/screens/forgot_password.dart';
import 'package:ecard_app/screens/login_screen.dart';
import 'package:ecard_app/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/register_screen.dart';

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
      case '/register':
        return MaterialPageRoute(
            builder: (context) =>
                Provider.of<AuthScreensIndexProvider>(context).registerPage);
      case '/login':
        return MaterialPageRoute(
            builder: (context) =>
                Provider.of<AuthScreensIndexProvider>(context).loginPage);
      case '/forgot_password':
        return MaterialPageRoute(
            builder: (context) => Provider.of<AuthScreensIndexProvider>(context)
                .forgotPasswordPage);

      default:
        return null;
    }
  }
}
