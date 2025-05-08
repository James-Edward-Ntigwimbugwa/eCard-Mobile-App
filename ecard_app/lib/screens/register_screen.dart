import 'dart:async';

import 'package:ecard_app/providers/auth_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import '../components/custom_widgets.dart';
import '../utils/resources/images/images.dart';
import '../utils/resources/strings/strings.dart';
import '../components/alert_reminder.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<StatefulWidget> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _companyTitleController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool obscure = true;
  String? _password;
  bool _formIsSubmitted = false;

  void _handleRegister() {
    setState(() {
      _formIsSubmitted = true;
    });

    final form = _formKey.currentState;
    if (_firstNameController.text.isEmpty ||
        _middleNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneNumberController.text.isEmpty) {
      Alerts.show(
          context,
          "Fill in all required fields",
          Image.asset(
            Images.errorImage,
            height: 30,
            width: 30,
          ));
      Future.delayed(Duration(seconds: 2) , () {
        Navigator.pop(context);
      });
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
    Alerts.show(
        context,
        "Loading ...",
        LoadingAnimationWidget.stretchedDots(
            color: Theme.of(context).primaryColor, size: 20));
    Timer(const Duration(seconds: 1), () {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      auth.updateFormField('firstName', _firstNameController.text.trim());
      auth.updateFormField('secondName', _middleNameController.text.trim());
      auth.updateFormField('lastName', _lastNameController.text.trim());
      auth.updateFormField('email', _emailController.text.trim());
      auth.updateFormField('phoneNumber', _phoneNumberController.text.trim());
      auth.updateFormField('bio', _bioController.text.trim());
      auth.updateFormField('companyTitle', _companyTitleController.text.trim());
      auth.updateFormField('username', _usernameController.text.trim());
      auth.updateFormField('password', _passwordController.text.trim());

      auth
          .register(
              _firstNameController.text.trim(),
              _middleNameController.text.trim(),
              _usernameController.text.trim(),
              _lastNameController.text.trim(),
              _emailController.text.trim(),
              "USER",
              _passwordController.text.trim(),
              _phoneNumberController.text.trim(),
              _bioController.text.trim(),
              _companyTitleController.text.trim(),
              _jobTitleController.text.trim().isEmpty
                  ? "N/A"
                  : _jobTitleController.text.trim())
          .then((response) {
        if (response['status'] == true) {
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, '/verify_with_otp');
        } else {
          Alerts.show(context,response['message'] ?? 'Registration failed',
              Image.asset(Images.errorImage));
        }
      }).catchError((error) => print(error));
    });
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final formData = auth.formData[AuthScreen.registerScreen];
      if (formData != null) {
        _firstNameController.text = formData['firstName'] ?? '';
        _middleNameController.text = formData['secondName'] ?? '';
        _lastNameController.text = formData['lastName'] ?? '';
        _emailController.text = formData['email'] ?? '';
        _phoneNumberController.text = formData['phoneNumber'] ?? '';
        _bioController.text = formData['bio'] ?? '';
        _companyTitleController.text = formData['companyTitle'] ?? '';
        _jobTitleController.text = formData['jobTitle'] ?? '';
        _usernameController.text = formData['username'] ?? '';
        _passwordController.text = formData['password'] ?? '';
      }
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _bioController.dispose();
    _companyTitleController.dispose();
    _jobTitleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final formKey = GlobalKey<FormState>();
    return Scaffold(
      body: Container(
        color: Theme.of(context).highlightColor,
        child: SizedBox(
          height: double.maxFinite,
          child: Column(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius:
                        BorderRadius.only(bottomRight: Radius.circular(50))),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height / 2.8,
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
                                  text: Headlines.registerHeader,
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
                                text: Headlines.registerDesc,
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
                key: _formKey,
                autovalidateMode: _formIsSubmitted
                    ? AutovalidateMode.always
                    : AutovalidateMode.disabled,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height / 1.9,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              InputField(
                                controller: _firstNameController,
                                icon: Icon(Icons.person),
                                hintText: "First Name",
                                field: 'firstName',
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              InputField(
                                controller: _middleNameController,
                                icon: Icon(Icons.person),
                                hintText: "Second Name",
                                field: 'secondName',
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              InputField(
                                controller: _lastNameController,
                                icon: Icon(Icons.person),
                                hintText: "Last Name",
                                field: 'lastName',
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              InputField(
                                controller: _emailController,
                                icon: Icon(Icons.email),
                                hintText: "Email",
                                field: 'email',
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              InputField(
                                controller: _phoneNumberController,
                                icon: Icon(Icons.phone),
                                hintText: "Phone number",
                                field: 'phoneNumber',
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              InputField(
                                controller: _bioController,
                                icon: Icon(FontAwesomeIcons.borderNone),
                                hintText: "Your bio (Optional)",
                                field: 'bio',
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              InputField(
                                controller: _companyTitleController,
                                icon: Icon(CupertinoIcons.house_alt_fill),
                                hintText: "Company Title",
                                field: 'companyTitle',
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              InputField(
                                controller: _jobTitleController,
                                icon: Icon(FontAwesomeIcons.mailchimp),
                                hintText: "job Title",
                                field: 'jobTitle',
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              InputField(
                                controller: _usernameController,
                                icon: Icon(Icons.contact_mail),
                                hintText: "username",
                                field: 'username',
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                onSaved: (value) {
                                  if (value != null) {
                                    if (value.length < 8) {
                                      Alerts.show(
                                          context,
                                          'Password must be at least 8 characters long',
                                          Image.asset(Images.errorImage));
                                    } else {
                                      _password = value;
                                    }
                                  }
                                },
                                autofocus: false,
                                controller: _passwordController,
                                validator: (value) => value!.isEmpty
                                    ? "Please Enter password"
                                    : null,
                                obscureText: obscure,
                                style: GoogleFonts.nunito(
                                  textStyle: TextStyle(
                                      color: Theme.of(context).primaryColor),
                                  fontWeight: FontWeight.w500,
                                  backgroundColor: Colors.transparent,
                                ),
                                decoration: InputDecoration(
                                  prefixIcon:
                                      Icon(CupertinoIcons.padlock_solid),
                                  labelText: "Password",
                                  labelStyle: TextStyle(
                                      color: Theme.of(context).indicatorColor),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color:
                                              Theme.of(context).primaryColor),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(30))),
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30)),
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      // Update state for icon and password visibility
                                      setState(() {
                                        obscure = !obscure;
                                      });
                                    },
                                    icon: Icon(obscure
                                        ? CupertinoIcons.eye_slash_fill
                                        : CupertinoIcons.eye_fill),
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
                                    NormalHeaderWidget(
                                        text: Texts.haveAccount,
                                        color: Theme.of(context).primaryColor,
                                        size: '18.0'),
                                    TextButton(
                                        onPressed: () => authProvider
                                            .navigateToLoginScreen(),
                                        child: Text(Texts.login))
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleRegister,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)))),
                child: Text(
                  Texts.register,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
