import 'dart:developer' as developer;

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:ecard_app/components/custom_widgets.dart';
import 'package:ecard_app/modals/user_modal.dart';
import 'package:ecard_app/preferences/user_preference.dart';
import 'package:ecard_app/screens/dashboard_screen.dart';
import 'package:ecard_app/utils/resources/animes/lottie_animes.dart';
import 'package:ecard_app/utils/resources/images/images.dart';
import 'package:ecard_app/utils/resources/strings/strings.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'auth_navigator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Default to AuthNavigator
  Widget _nextScreen = const AuthNavigator();

  @override
  void initState() {
    super.initState();
    // Check authentication status when splash screen initializes
    _checkUserAuthentication();
  }

  // Check if user is authenticated
  Future<void> _checkUserAuthentication() async {
    try {
      User? user = await UserPreferences().getUser();
      developer.log("User data from preferences: ${user?.toString()}");

      // Determine which screen to navigate to
      if (user != null &&
          user.accessToken != null &&
          user.accessToken!.isNotEmpty) {
        developer.log("Valid user found, navigating to Dashboard");
        _nextScreen = DashboardPage(user: user);
      } else {
        developer.log("No valid user found, navigating to Auth");
        _nextScreen = const AuthNavigator();
      }
    } catch (e) {
      developer.log("Error checking authentication: $e");
      _nextScreen = const AuthNavigator();
    } finally {
      // Update state only if widget is still mounted
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Container(
        decoration: const BoxDecoration(
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
                      child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 120,
                        height: 120,
                        color: Colors.white, // Optional: background color
                        child: Lottie.asset(
                        LottieAnimes.cardLoader,
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                        ),
                      ),
                      ),
                    ),
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
                  size: "24",
                ),
                HeaderBoldWidget(
                  text: Headlines.businessApp,
                  color: Theme.of(context).cardColor,
                  size: "24",
                ),
              ],
            ),
            NormalHeaderWidget(
              text: Headlines.splashMessage,
              color: Theme.of(context).cardColor,
              size: "12",
            ),
          ],
        ),
      ),
      duration: 6000,
      splashIconSize: 500,
      backgroundColor: Theme.of(context).primaryColor,
      nextScreen: _nextScreen,
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.fade,
    );
  }
}
