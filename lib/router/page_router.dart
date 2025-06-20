import 'package:ecard_app/providers/user_provider.dart';
import 'package:ecard_app/router/router_path.dart';
import 'package:ecard_app/screens/dashboard_screen.dart';
import 'package:ecard_app/screens/new_card.dart';
import 'package:ecard_app/screens/splash_screen.dart';
import 'package:ecard_app/screens/auth_navigator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/change_password.dart';
import '../screens/location_picker.dart';
import '../screens/otp_verifier_screen.dart';
import '../screens/people_card_saves.dart';

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
      case RouterPath.newCard:
        return MaterialPageRoute(builder: (context) => CreateNewCard());
      case '/auth':
        return MaterialPageRoute(builder: (context) => const AuthNavigator());
      case '/change-password':
        return MaterialPageRoute(
            builder: (context) => const ChangePasswordScreen());
      case RouterPath.locationPicker:
        return MaterialPageRoute(
            builder: (context) => GoogleMapLocationPicker());

      case RouterPath.otpVerifier:
        return MaterialPageRoute(builder: (context) => const OtpVerifier());

      case RouterPath.cardSaves:
        return MaterialPageRoute(builder: (context) => const PeopleCardSaves());
      default:
        return null;
    }
  }
}
