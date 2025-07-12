import 'dart:async';
import 'package:ecard_app/components/custom_widgets.dart';
import 'package:ecard_app/providers/auth_provider.dart';
import 'package:ecard_app/components/alert_reminder.dart';
import 'package:ecard_app/utils/resources/animes/lottie_animes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
        width: 130,
        height: 130,
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
        width: 130,
        height: 130,
        fit: BoxFit.contain,
      ),
    );
  }

  void showLoader(String message) => Alerts.showLoader(
      context: context,
      message: message,
      icon: Lottie.asset(
        LottieAnimes.loading,
        width: 130,
        height: 130,
        fit: BoxFit.contain,
      ));

  Future<void> _verifyOtp() async {
    if (_otpCode.length < 6) {
      showErrorMessage("Please enter the complete 6-digit OTP code");
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    showLoader("Verifying OTP...");

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final Response response = await authProvider
          .verifyOtp(_otpCode)
          .timeout(const Duration(seconds: 60));
      debugPrint("OTP verification response: $response");

      // Close the loading dialog
      Navigator.pop(context);
      if (response.statusCode == 200) {
        // Account activated successfully
        showSuccessMessage("Account activated successfully!");

        // Wait for success animation to show for 2 seconds before navigating
        Timer(const Duration(seconds: 2), () async {
          // Close the success dialog
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }

          // Check if username and password are available
          final prefs = await SharedPreferences.getInstance();
          final String? username = prefs.getString("autoLoginUsername");
          final String? password = prefs.getString("autoLoginPassword");

          developer.log(
              "Auto-login credentials check - Username: ${username ?? 'null'}, Password: ${password != null ? '[PRESENT]' : 'null'}",
              name: 'OtpVerifierScreen');

          if (username != null &&
              password != null &&
              username.isNotEmpty &&
              password.isNotEmpty) {
            // Proceed with auto-login
            developer.log("Proceeding with auto-login",
                name: 'OtpVerifierScreen');
            _performAutoLogin(username, password);
          } else {
            // Navigate back to login screen if credentials are not available
            developer.log(
                "Auto-login credentials not available, navigating to login",
                name: 'OtpVerifierScreen');
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
      if (Navigator.canPop(context)) {
        Navigator.pop(context); // Close loading dialog
      }
      showErrorMessage(
          "Verification failed. Please check your connection and try again.");
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _performAutoLogin(String username, String password) async {
    showLoader("Logging in ...");

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final response = await authProvider
          .signIn(username: username, password: password)
          .timeout(const Duration(seconds: 60));

      if (response == true) {
        var userProvider = Provider.of<UserProvider>(context, listen: false);
        if (Navigator.canPop(context)) {
          Navigator.pop(context); // Close loader
        }

        // Show login success message for 2 seconds
        showSuccessMessage("Login successful!");
        Timer(const Duration(seconds: 2), () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context); // Close success dialog
          }
          Navigator.pushReplacementNamed(context, '/dashboard');
        });
      } else {
        if (Navigator.canPop(context)) {
          Navigator.pop(context); // Close loader
        }
        showErrorMessage("Login failed. Please try again.");
        authProvider.navigateToLoginScreen();
      }
    } on TimeoutException {
      if (Navigator.canPop(context)) {
        Navigator.pop(context); // Close loader
      }
      showErrorMessage(
          "Login request timed out. Please check your internet connection.");
      authProvider.navigateToLoginScreen();
    } catch (error) {
      developer.log("Error during auto-login: $error",
          name: 'OtpVerifierScreen',
          error: error,
          stackTrace: StackTrace.current);
      if (Navigator.canPop(context)) {
        Navigator.pop(context); // Close loader
      }
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
                    onPressed: _isSubmitting
                        ? null
                        : () {
                            final auth = Provider.of<AuthProvider>(context,
                                listen: false);
                            auth.navigateToLoginScreen();
                          },
                    child: Text(
                      Texts.backToRegister,
                      style: TextStyle(
                        color: _isSubmitting
                            ? Colors.grey
                            : Theme.of(context).primaryColor,
                      ),
                    )),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
