import 'dart:async';
import 'package:ecard_app/components/custom_widgets.dart';
import 'package:ecard_app/providers/auth_provider.dart';
import 'package:ecard_app/providers/user_provider.dart';
import 'package:ecard_app/utils/raw/model_icons.dart';
import 'package:ecard_app/utils/resources/animes/lottie_animes.dart';
import 'package:ecard_app/utils/resources/images/images.dart';
import 'package:ecard_app/utils/resources/strings/strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../components/alert_reminder.dart';
import 'dart:developer' as developer;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _formIsSubmitted = false;
  final _formKey = GlobalKey<FormState>();
  String? _password;

  // @override
  // void initState() {
  //   super.initState();
  //   _loadSavedCredentials();
  // }

  // Future<void> _loadSavedCredentials() async {
  //   try {
  //     final username = await UserPreferences.getUsername();
  //     final password = await UserPreferences.getPassword();
  //     if (username != null && password != null) {
  //       _usernameController.text = username;
  //       _passwordController.text = password;
  //     }
  //   } catch (e) {
  //     developer.log("Error loading saved credentials: $e");
  //   }
  // }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void showLoader() => Alerts.showLoader(
      context: context,
      message: Loaders.loading,
      icon: Lottie.asset(
        LottieAnimes.loading,
        width: 130,
        height: 130,
        fit: BoxFit.contain,
      ));

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

  // Helper method to show network error messages
  void showNetworkError(String message) {
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

  Future<void> handleLogin() async {
    setState(() => _formIsSubmitted = true);

    // Validate form fields
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      showErrorMessage("Please fill in all fields");
      setState(() => _formIsSubmitted = false); // Reset form submission state
      return;
    }

    if (!_formKey.currentState!.validate()) {
      setState(() => _formIsSubmitted = false); // Reset form submission state
      return;
    }
    _formKey.currentState!.save();

    showLoader();

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      auth.updateFormField('username', _usernameController.text.trim());
      auth.updateFormField('password', _passwordController.text.trim());

      bool success = await auth.signIn(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );

      // Always close the loader dialog
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (success) {
        // Show success message with Lottie animation for 2 seconds
        showSuccessMessage('Login successful!');

        Timer(const Duration(seconds: 2), () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context); // Close success dialog
          }
          Navigator.pushReplacementNamed(context, '/dashboard');
        });
      } else {
        // Display the specific error message from the auth provider
        showErrorMessage(auth.errorMessage ?? 'Login failed');
        setState(() => _formIsSubmitted = false); // Reset form submission state
      }
    } catch (e, stack) {
      // Close the loader dialog
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      developer.log("Login screen error: $e", stackTrace: stack);

      // Provide a user-friendly error message
      String errorMessage = "An error occurred while logging in";

      // Add more context if available, but keep it user-friendly
      if (e.toString().contains("SocketException") ||
          e.toString().contains("Connection")) {
        errorMessage =
            "Network connection error. Please check your internet and try again.";
      } else if (e.toString().contains("timeout")) {
        errorMessage = "Request timed out. Please try again later.";
      } else if (e.toString().contains("format")) {
        errorMessage = "Server returned an invalid response. Please try again.";
      }

      showNetworkError(errorMessage);
      setState(() => _formIsSubmitted = false); // Reset form submission state
    }
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        color: Theme.of(context).highlightColor,
        child: SingleChildScrollView(
          child: SizedBox(
            child: Column(
              children: [
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
                                    text: Headlines.loginToAccessAccount,
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
                                            right: -10,
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
                                  text: Headlines.loginDesc,
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
                Form(
                  autovalidateMode: _formIsSubmitted
                      ? AutovalidateMode.always
                      : AutovalidateMode.disabled,
                  key: _formKey,
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
                        height: MediaQuery.of(context).size.height / 2,
                        width: double.infinity,
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10, top: 0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InputField(
                                  field: 'username',
                                  controller: _usernameController,
                                  hintText: "username",
                                  icon: Icon(Icons.mail)),
                              const SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                onSaved: (value) => _password = value,
                                autofocus: false,
                                onChanged: (value) =>
                                    auth.updateFormField('password', value),
                                controller: _passwordController,
                                validator: (value) => value!.isEmpty
                                    ? "Please Enter password"
                                    : null,
                                obscureText: _obscurePassword,
                                style: GoogleFonts.nunito(
                                  textStyle: TextStyle(
                                      color: Theme.of(context).primaryColor),
                                  fontWeight: FontWeight.w500,
                                  backgroundColor: Colors.transparent,
                                ),
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color:
                                              Theme.of(context).primaryColor),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(30))),
                                  prefixIcon:
                                      Icon(CupertinoIcons.padlock_solid),
                                  labelText: "Password",
                                  labelStyle: TextStyle(
                                      color: Theme.of(context).indicatorColor),
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30)),
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () => setState(() =>
                                        _obscurePassword = !_obscurePassword),
                                    icon: Icon(_obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              auth.isLoading
                                  ? Lottie.asset(
                                      LottieAnimes.cardLoader,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.contain,
                                    )
                                  : Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: ElevatedButton(
                                        onPressed: _formIsSubmitted
                                            ? null
                                            : handleLogin,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Theme.of(context).primaryColor,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(30)),
                                          ),
                                        ),
                                        child: Text(
                                          Texts.login,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                              Center(
                                child: SizedBox(
                                  height: 50,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                            height: 1,
                                            color:
                                                Theme.of(context).primaryColor),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Container(
                                            color: Colors
                                                .white, // Match background color to "hide" the line behind the text
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: NormalHeaderWidget(
                                              text: 'OR',
                                              color: Theme.of(context)
                                                  .indicatorColor,
                                              size: '16.0',
                                              backgroundColor:
                                                  Colors.transparent,
                                            )),
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: 1, // Thickness of the line
                                          color: Theme.of(context)
                                              .primaryColor, // Color of the line
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  for (int i = 0;
                                      i <
                                          LoginWidgetClickableIcons.icons(
                                                  context)
                                              .length;
                                      i++) ...[
                                    Padding(
                                      padding: EdgeInsets.only(right: 12.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Icon(
                                            LoginWidgetClickableIcons.icons(
                                                    context)[i]
                                                .icon,
                                            size: 18,
                                            color: Theme.of(context)
                                                .highlightColor,
                                          ),
                                        ),
                                      ),
                                    )
                                  ]
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    NormalHeaderWidget(
                                        text: Texts.noAccount,
                                        color: Theme.of(context).primaryColor,
                                        size: '18.0'),
                                    SizedBox(
                                      width: 3,
                                    ),
                                    TextButton(
                                        onPressed: () =>
                                            auth.navigateToRegisterScreen(),
                                        child: Text(Texts.register)),
                                  ],
                                ),
                              ),
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
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 3,
                      ),
                      NormalHeaderWidget(
                          text: Texts.forgotPassword,
                          color: Theme.of(context).primaryColor,
                          size: '18.0'),
                      const SizedBox(
                        width: 20,
                      ),
                      TextButton(
                          onPressed: () =>
                              auth.navigateToForgotPasswordScreen(),
                          child: Text(Texts.resetPassword)),
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
