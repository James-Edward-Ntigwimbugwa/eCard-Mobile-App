import 'dart:async';
import 'package:ecard_app/components/custom_widgets.dart';
import 'package:ecard_app/providers/auth_provider.dart';
import 'package:ecard_app/providers/screen_index_provider.dart';
import 'package:ecard_app/providers/user_provider.dart';
import 'package:ecard_app/utils/raw/model_icons.dart';
import 'package:ecard_app/utils/resources/images/images.dart';
import 'package:ecard_app/utils/resources/strings/strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import '../components/alert_reminder.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _password;
  bool _obscurePassword = true;

  final formKey = GlobalKey<FormState>();
  void showLoader() {
    Alerts.show(
        context,
        Loaders.loading,
        LoadingAnimationWidget.stretchedDots(
            color: Theme.of(context).primaryColor, size: 24.0));
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider auth = Provider.of<AuthProvider>(context);

    void handleLogin() {
      final form = formKey.currentState;

      if (_usernameController.text.isEmpty ||
          _passwordController.text.isEmpty) {
        Alerts.show(
            context,
            "Fill in all fields",
            Image.asset(
              Images.errorImage,
              height: 30,
              width: 30,
            ));
        Future.delayed(Duration(seconds: 2), () {
          Navigator.of(context).pop();
        });
      }

      if (form == null || !form.validate()) {
        print("Invalid form...==>");
        return;
      }

      form.save();
      showLoader();
      Timer(Duration(seconds: 2), () {
        auth
            .login(
          _usernameController.text.trim(),
          _passwordController.text.trim(),
        )
            .then((response) {
          Navigator.pop(context);
          if (response['status'] == true) {
            var user = Provider.of<UserProvider>(context, listen: false)
                .setUser(response['user']);
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response['message'] ?? 'Invalid credentials'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }).catchError((error) {
          Alerts.show(
              context,
              "Network error",
              Image.asset(
                Images.networkErrorImage,
                width: 40,
                height: 40,
              ));
          Future.delayed(Duration(seconds: 4), () {
            Navigator.pop(context);
            Navigator.pop(context);
          });
        });
      });
    }

    return Scaffold(
      body: SingleChildScrollView(
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              HeaderBoldWidget(
                                  text: Headlines.loginToAccessAccount,
                                  color: Theme.of(context).highlightColor,
                                  size: "24.0"),
                              const SizedBox(
                                width: 100,
                              ),
                              ClipOval(
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                          left: -10,
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
                autovalidateMode: AutovalidateMode.onUserInteraction,
                key: formKey,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 5.0,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Theme.of(context).primaryColor),
                        bottom:
                            BorderSide(color: Theme.of(context).primaryColor),
                        left: BorderSide(color: Theme.of(context).primaryColor),
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
                                controller: _usernameController,
                                hintText: "username",
                                icon: Icon(Icons.mail)),
                            const SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              onSaved: (value) => _password = value,
                              autofocus: false,
                              controller: _passwordController,
                              validator: (value) => value!.isEmpty
                                  ? "Please Enter password"
                                  : null,
                              obscureText: _obscurePassword,
                              style: GoogleFonts.nunito(
                                textStyle: TextStyle(
                                    color: Theme.of(context).primaryColor),
                                fontWeight: FontWeight.w500,
                                backgroundColor: Colors.white,
                              ),
                              decoration: InputDecoration(
                                prefixIcon: Icon(CupertinoIcons.padlock_solid),
                                hintText: "Password",
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
                            ElevatedButton(
                              onPressed: handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                minimumSize: Size(
                                    MediaQuery.of(context).size.width / 4,
                                    48.0),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12.0),
                              ),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.1),
                                  shape: BoxShape.rectangle,
                                ),
                                child: SizedBox(
                                  height: 30.0,
                                  width: MediaQuery.of(context).size.width / 6,
                                  child: Center(
                                    child: HeaderBoldWidget(
                                      text: Texts.login,
                                      color: Theme.of(context).highlightColor,
                                      size: '24.0',
                                    ),
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
                                        child: Text(
                                          "OR",
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
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
                                        LoginWidgetClickableIcons.icons(context)
                                            .length;
                                    i++) ...[
                                  Padding(
                                    padding: EdgeInsets.only(right: 12.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Icon(
                                          LoginWidgetClickableIcons.icons(
                                                  context)[i]
                                              .icon,
                                          size: 18,
                                          color:
                                              Theme.of(context).highlightColor,
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
                                      color: Theme.of(context).highlightColor,
                                      size: '14.0'),
                                  SizedBox(
                                    width: 3,
                                  ),
                                  GestureDetector(
                                    child: HeaderBoldWidget(
                                        text: Texts.register,
                                        color: Theme.of(context).primaryColor,
                                        size: '14.0'),
                                    onTap: () {
                                      final authScreenIndexProvider =
                                          Provider.of<AuthScreensIndexProvider>(
                                              context,
                                              listen: false);
                                      final currentRoute =
                                          ModalRoute.of(context)?.settings.name;
                                      int currentIndex = authScreenIndexProvider
                                          .currentScreenIndex;

                                      String targetRoute = (currentIndex == 0)
                                          ? '/login'
                                          : '/register';
                                      if (currentRoute != targetRoute) {
                                        authScreenIndexProvider.setCurrentIndex(
                                            currentIndex == 0 ? 1 : 0);
                                        Navigator.pushNamed(
                                            context, targetRoute);
                                      }
                                    },
                                  )
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
                    GestureDetector(
                      child: HeaderBoldWidget(
                          text: Texts.forgotPassword,
                          color: Theme.of(context).primaryColor,
                          size: '14.0'),
                      onTap: () {
                        Navigator.pushNamed(context, '/forgot_password');
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
