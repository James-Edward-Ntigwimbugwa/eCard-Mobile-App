import 'dart:async';
import 'package:ecard_app/providers/auth_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import '../components/alert_reminder.dart';
import '../components/custom_widgets.dart';
import '../utils/resources/images/images.dart';
import '../utils/resources/strings/strings.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _formIsSubmitted = false;

  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void showLoader() {
    Alerts.show(
        context,
        Loaders.loading,
        LoadingAnimationWidget.stretchedDots(
            color: Theme.of(context).primaryColor, size: 24.0));
  }

  void handleResetPassword() {
    setState(() {
      _formIsSubmitted = true;
    });

    final form = formKey.currentState;
    if (_emailController.text.isEmpty) {
      Alerts.show(
          context,
          "Please enter your email",
          Image.asset(
            Images.errorImage,
            height: 30,
            width: 30,
          ));
      Future.delayed(Duration(seconds: 2), () {
        Navigator.of(context).pop();
      });
      return;
    }

    if (form == null || !form.validate()) {
      print("Invalid form...==>");
      return;
    }

    form.save();
    showLoader();

    // Simulate API call for password reset
    Timer(Duration(seconds: 2), () {
      Navigator.pop(context); // Close loader

      // Show success message
      Alerts.show(
        context,
        "Password reset link sent!",
        Icon(
          Icons.check_circle_outline,
          color: Theme.of(context).primaryColor,
          size: 40,
        ),
      );

      Future.delayed(Duration(seconds: 2), () {
        Navigator.pop(context); // Close alert
        Navigator.pushNamed(context, '/login');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        color: Theme.of(context).highlightColor,
        child: SingleChildScrollView(
          child: SizedBox(
            child: Column(
              children: [
                // Top curved container with header
                DecoratedBox(
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius:
                          BorderRadius.only(bottomRight: Radius.circular(50))),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height / 2.6,
                    width: double.infinity,
                    child: Padding(
                        padding:
                            EdgeInsets.only(left: 20.0, top: 50.0, right: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                HeaderBoldWidget(
                                    text: "Password Recovery",
                                    color: Theme.of(context).highlightColor,
                                    size: "24.0"),
                                ClipOval(
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey,
                                    child: Stack(
                                      children: [
                                        Positioned(
                                            left: 0,
                                            right: 0,
                                            child: Image.asset(
                                              Images.splashImage,
                                              height: 60,
                                              width: 60,
                                              fit: BoxFit.cover,
                                            ))
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 0.0, top: 20.0),
                              child: NormalHeaderWidget(
                                  text: Texts.forgetBanner,
                                  color: Theme.of(context).highlightColor,
                                  size: "18.0"),
                            ),
                          ],
                        )),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                // Main form container
                Form(
                  autovalidateMode: _formIsSubmitted
                      ? AutovalidateMode.always
                      : AutovalidateMode.disabled,
                  key: formKey,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.0,
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(context).highlightColor,
                        border: Border(
                          top:
                              BorderSide(color: Theme.of(context).primaryColor),
                          bottom:
                              BorderSide(color: Theme.of(context).primaryColor),
                          left:
                              BorderSide(color: Theme.of(context).primaryColor),
                          right:
                              BorderSide(color: Theme.of(context).primaryColor),
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height / 3,
                        width: double.infinity,
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10, top: 0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Email input field
                              InputField(
                                  field: 'email',
                                  controller: _emailController,
                                  hintText: "Enter your email",
                                  icon: Icon(CupertinoIcons.mail)),
                              const SizedBox(
                                height: 30,
                              ),
                              // Reset password button
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 2,
                                child: ElevatedButton(
                                  onPressed: handleResetPassword,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    "Send email reset link",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                // Return to login link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      NormalHeaderWidget(
                          text: "Remember your password?",
                          color: Theme.of(context).primaryColor,
                          size: '18.0'),
                      SizedBox(width: 3),
                      TextButton(
                          onPressed: () {
                            final authProvider = Provider.of<AuthProvider>(
                                context,
                                listen: false);
                            authProvider.navigateToLoginScreen();
                          },
                          child: Text("Login Now")),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
