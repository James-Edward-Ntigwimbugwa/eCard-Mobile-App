import 'dart:async';
import 'package:ecard_app/components/custom_widgets.dart';
import 'package:ecard_app/providers/auth_provider.dart';
import 'package:ecard_app/screens/register_screen.dart';
import 'package:ecard_app/services/auth_requests.dart';
import 'package:ecard_app/components/alert_reminder.dart';
import 'package:ecard_app/utils/resources/animes/lottie_animes.dart';
import 'package:ecard_app/utils/resources/images/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;
import '../providers/user_provider.dart';
import '../utils/resources/strings/strings.dart';

class OtpVerifier extends StatefulWidget {
  const OtpVerifier({super.key});

  @override
  State<StatefulWidget> createState() => OtpVerifierState();
}

class OtpVerifierState extends State<OtpVerifier> {
  String _otpCode = '';
  bool _isSubmitting = false;

  // Helper method to show success message
  void showSuccessMessage(String message) {
    Alerts.showSuccess(
      context: context,
      message: message,
      icon: Lottie.asset(
        LottieAnimes.successLoader,
        width: 60,
        height: 60,
        fit: BoxFit.contain,
      ),
    );
  }

  // Helper method to show error messages
  void showErrorMessage(String message) {
    Alerts.showError(
      context: context,
      message: message,
      icon: Lottie.asset(
        LottieAnimes.errorLoader,
        width: 60,
        height: 60,
        fit: BoxFit.contain,
      ),
    );
  }

  Future<void> _verifyOtp() async {
    if (_otpCode.length < 6) {
      showErrorMessage("Please enter the complete 6-digit OTP code");
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    Alerts.showLoader(
        context: context,
        message: "Verifying OTP...",
        icon: Lottie.asset(
          LottieAnimes.loading,
          width: 60,
          height: 60,
          fit: BoxFit.contain,
        ));

    try {
      final authRequests = AuthRequests();
      final response = await authRequests.activateAccount(_otpCode);

      // Close the loading dialog
      Navigator.pop(context);

      if (response.statusCode == 200) {
        // Account activated successfully
        showSuccessMessage("Account activated successfully!");

        // Wait for success animation to show for 2 seconds before navigating
        Timer(const Duration(seconds: 2), () {
          Navigator.pop(context); // Close success alert

          // Check if username and password are available
          final registerPageState =
              Provider.of<RegisterPageState>(context, listen: false);
          final username = registerPageState.username;
          final password = registerPageState.password;

          if (username.text.isNotEmpty && password.text.isNotEmpty) {
            // Proceed with auto-login
            _performAutoLogin(username.text, password.text);
          } else {
            // Navigate back to login screen if credentials are not available
            final authProvider =
                Provider.of<AuthProvider>(context, listen: false);
            authProvider.navigateToLoginScreen();
          }
        });
      } else {
        // Activation failed
        showErrorMessage("Invalid OTP code. Please try again.");
        setState(() {
          _isSubmitting = false;
        });
      }
    } catch (error) {
      Navigator.pop(context); // Close loading dialog
      showErrorMessage(
          "Verification failed. Please check your connection and try again.");
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _performAutoLogin(String username, String password) async {
    Alerts.showLoader(
        context: context,
        message: "Logging in ...",
        icon: Lottie.asset(
          LottieAnimes.cardLoader,
          width: 60,
          height: 60,
          fit: BoxFit.contain,
        ));

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final response = await authProvider
          .signIn(username, password)
          .timeout(const Duration(seconds: 60));

      if (response == true) {
        var userProvider = Provider.of<UserProvider>(context, listen: false);
        // Optionally set user if needed, e.g. userProvider.setUser(authProvider.user);
        Navigator.pop(context); // Close loader
        
        // Show login success message for 2 seconds
        showSuccessMessage("Login successful!");
        Timer(const Duration(seconds: 2), () {
          Navigator.pop(context); // Close success dialog
          Navigator.pushReplacementNamed(context, '/dashboard');
        });
      } else {
        Navigator.pop(context); // Close loader
        showErrorMessage("Login failed. Please try again.");
        authProvider.navigateToLoginScreen();
      }
    } on TimeoutException {
      Navigator.pop(context); // Close loader
      showErrorMessage(
          "Login request timed out. Please check your internet connection.");
      authProvider.navigateToLoginScreen();
    } catch (error) {
      developer.log("Error during auto-login: $error",
          name: 'OtpVerifierScreen',
          error: error,
          stackTrace: StackTrace.current);

      Navigator.pop(context); // Close loader
      showErrorMessage("Error logging in. Please try again.");
      authProvider.navigateToLoginScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).highlightColor,
      appBar: AppBar(
        title: Text('Account Verification'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).highlightColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                HeaderBoldWidget(
                    text: Headlines.verifyOtp,
                    color: Theme.of(context).indicatorColor,
                    size: '24.0'),
                const SizedBox(height: 20),
                NormalHeaderWidget(
                    text: "Enter the 6-digit code sent to your phone",
                    color: Theme.of(context).primaryColor,
                    size: '16.0'),
                const SizedBox(height: 30),
                OtpTextField(
                  numberOfFields: 6,
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  showFieldAsBox: true,
                  borderColor: Theme.of(context).primaryColor,
                  focusedBorderColor: Theme.of(context).primaryColor,
                  onCodeChanged: (String code) {
                    _otpCode = code;
                  },
                  onSubmit: (String verificationCode) {
                    _otpCode = verificationCode;
                    if (verificationCode.length == 6) {
                      _verifyOtp();
                    }
                  },
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)))),
                  child: Text(
                    'Verify OTP',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    // Here you would implement resend OTP functionality
                    showSuccessMessage("OTP code resent!");
                  },
                  child: Text(
                    "Didn't receive the code? Resend",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                    onPressed: () {
                      final auth =
                          Provider.of<AuthProvider>(context, listen: false);
                      auth.navigateToLoginScreen();
                    },
                    child: Text(Texts.backToRegister)),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}