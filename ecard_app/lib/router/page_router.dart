import 'package:ecard_app/providers/user_provider.dart';
import 'package:ecard_app/router/router_path.dart';
import 'package:ecard_app/screens/dashboard_screen.dart';
import 'package:ecard_app/screens/splash_screen.dart';
import 'package:ecard_app/screens/auth_navigator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/change_password.dart';

class PageRouter {
  static Route<dynamic>? switchRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouterPath.splash:
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case RouterPath.dashboard:
        return MaterialPageRoute(builder: (context) {
          final userProvider =
              Provider.of<UserProvider>(context, listen: false);
          return DashboardPage(user: userProvider.user);
        });
      case '/auth':
        return MaterialPageRoute(builder: (context) => const AuthNavigator());
      case '/change-password':
        return MaterialPageRoute(
            builder: (context) => const ChangePasswordScreen());
      default:
        return null;
    }
  }
}
