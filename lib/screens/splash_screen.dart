import 'dart:developer' as developer;

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:ecard_app/components/custom_widgets.dart';
import 'package:ecard_app/modals/user_modal.dart';
import 'package:ecard_app/preferences/user_preference.dart';
import 'package:ecard_app/screens/dashboard_screen.dart';
import 'package:ecard_app/utils/resources/images/images.dart';
import 'package:ecard_app/utils/resources/strings/strings.dart';
import 'package:flutter/material.dart';
import 'auth_navigator.dart';

// ignore: must_be_immutable
class SplashScreen extends StatefulWidget {
  SplashScreen({super.key});
  bool login = false;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch user data when the splash screen initializes
    _checkUserAuthentication();
  }

  Widget? _nextScreen;

  // Check if user is authenticated
  Future<void> _checkUserAuthentication() async {
    User? user = await UserPreferences().getUser();
    developer.log("User data======> $user");
    setState(() {
      // If user is non-null and has a token, go to dashboard
      if (user != null &&
          user.accessToken != null &&
          user.accessToken!.isNotEmpty) {
        _nextScreen = DashboardPage(user: user);
      } else {
        _nextScreen = const AuthNavigator();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
        splash: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Column(
              children: [
                ClipOval(
                  child: Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey,
                    child: Stack(
                      children: [
                        Positioned(
                            left: -10,
                            child: Image.asset(
                              Images.splashImage,
                              height: 120,
                              width: 120,
                              fit: BoxFit.cover,
                            ))
                      ],
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HeaderBoldWidget(
                        text: 'e',
                        color: Theme.of(context).canvasColor,
                        size: "24"),
                    HeaderBoldWidget(
                        text: Headlines.businessApp,
                        color: Theme.of(context).cardColor,
                        size: "24")
                  ],
                ),
                NormalHeaderWidget(
                    text: Headlines.splashMessage,
                    color: Theme.of(context).cardColor,
                    size: "12")
              ],
            )),
        duration: 3000,
        splashIconSize: 500,
        backgroundColor: Theme.of(context).primaryColor,
        nextScreen: _nextScreen ??
            const AuthNavigator()); // Use the determined next screen or default to AuthNavigator
  }
}
