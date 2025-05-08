import 'dart:async';
import 'package:ecard_app/components/custom_widgets.dart';
import 'package:ecard_app/providers/auth_provider.dart';
import 'package:ecard_app/services/auth_requests.dart';
import 'package:ecard_app/components/alert_reminder.dart';
import 'package:ecard_app/utils/resources/images/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import '../utils/resources/strings/strings.dart';

class OtpVerifier extends StatefulWidget {
  const OtpVerifier({super.key});

  @override
  State<StatefulWidget> createState() => OtpVerifierState();
}

class OtpVerifierState extends State<OtpVerifier> {
  String _otpCode = '';
  bool _isSubmitting = false;

  Future<void> _verifyOtp() async {
    if (_otpCode.length < 6) {
      Alerts.show(
          context,
          "Please enter the complete 6-digit OTP code",
          Image.asset(Images.errorImage, height: 30, width: 30)
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    Alerts.show(
        context,
        "Verifying OTP...",
        LoadingAnimationWidget.stretchedDots(
            color: Theme.of(context).primaryColor,
            size: 20
        )
    );

    try {
      final response = await AuthRequests.activateAccount(_otpCode);

      // Close the loading dialog
      Navigator.pop(context);

      if (response.statusCode == 200) {
        // Account activated successfully
        Alerts.show(
            context,
            "Account activated successfully!",
            Icon(Icons.check_circle, color: Colors.green, size: 30)
        );

        // Wait for alert to show before navigating
        Timer(const Duration(seconds: 2), () {
          Navigator.pop(context); // Close alert

          // Get auth provider and mark account as verified
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          authProvider.setAccountVerified(true);

          // Navigate to login screen
          Navigator.pushReplacementNamed(context, '/auth');
        });
      } else {
        // Activation failed
        Alerts.show(
            context,
            "Invalid OTP code. Please try again.",
            Image.asset(Images.errorImage , height: 30, width: 30,)
        );
        setState(() {
          _isSubmitting = false;
        });
      }
    } catch (error) {
      Navigator.pop(context); // Close loading dialog
      Alerts.show(
          context,
          "Verification failed. Please check your connection and try again.",
          Image.asset(Images.errorImage)
      );
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    size: '24.0'
                ),
                const SizedBox(height: 20),
                NormalHeaderWidget(
                    text: "Enter the 6-digit code sent to your phone",
                    color: Theme.of(context).primaryColor,
                    size: '16.0'
                ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))
                      )
                  ),
                  child: Text(
                    'Verify OTP',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    // Here you would implement resend OTP functionality
                    Alerts.show(
                        context,
                        "OTP code resent!",
                        Icon(Icons.email, color: Theme.of(context).primaryColor, size: 30)
                    );
                  },
                  child: Text(
                    "Didn't receive the code? Resend",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),
                TextButton(onPressed: () {
                  final auth = Provider.of<AuthProvider>(context , listen: false);
                  auth.navigateToRegisterScreen();
                }, child: Text(Texts.backToRegister)),

                const SizedBox(height: 10,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}