import 'dart:async';
import 'dart:developer' as developer;

import 'package:ecard_app/providers/auth_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  State<StatefulWidget> createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _secondNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _companyTitleController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  TextEditingController get username => _usernameController;
  TextEditingController get password => _passwordController;

  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Restore form data if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final formData = auth.formData[AuthScreen.registerScreen];
      if (formData != null) {
        _firstNameController.text = formData['firstName'] ?? '';
        _secondNameController.text = formData['secondName'] ?? '';
        _lastNameController.text = formData['lastName'] ?? '';
        _emailController.text = formData['email'] ?? '';
        _phoneNumberController.text = formData['phoneNumber'] ?? '';
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
    _secondNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _companyTitleController.dispose();
    _jobTitleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (value.length < 10) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    return null;
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  Future<void> _handleRegister() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    // Validate form
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = false; // Set to false if validation fails
      });
      return;
    }

    // Save form data to provider
    final auth = Provider.of<AuthProvider>(context, listen: false);
    auth.updateFormField('firstName', _firstNameController.text.trim());
    auth.updateFormField('secondName', _secondNameController.text.trim());
    auth.updateFormField('lastName', _lastNameController.text.trim());
    auth.updateFormField('email', _emailController.text.trim());
    auth.updateFormField('phoneNumber', _phoneNumberController.text.trim());
    auth.updateFormField('companyTitle', _companyTitleController.text.trim());
    auth.updateFormField('jobTitle', _jobTitleController.text.trim());
    auth.updateFormField('username', _usernameController.text.trim());
    auth.updateFormField('password', _passwordController.text.trim());

    try {
      // Show loading indicator
      Alerts.showLoader(
        context: context,
        message: "Creating account...",
        icon: LoadingAnimationWidget.stretchedDots(
          color: Theme.of(context).primaryColor,
          size: 20,
        ),
      );

      // Call register method
      bool success = await auth.register(
        _firstNameController.text.trim(),
        _secondNameController.text.trim(),
        _usernameController.text.trim(),
        _lastNameController.text.trim(),
        _emailController.text.trim(),
        "USER", // Fixed role
        _passwordController.text.trim(),
        _phoneNumberController.text.trim(),
        "", // Bio not included
        _companyTitleController.text.trim(),
        _jobTitleController.text.trim(),
      );

      // Hide loading indicator
      if (mounted) {
        Navigator.pop(context);
      }

      if (success) {
        // Navigate to OTP verification screen
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/verify_with_otp');
        }
      } else {
        // Show error message
        if (mounted) {
          Alerts.showError(
            context: context,
            message:
                auth.errorMessage ?? 'Registration failed. Please try again.',
            icon: Image.asset(
              Images.errorImage,
              height: 30,
              width: 30,
            ),
          );
        }
      }
    } catch (error) {
      // Hide loading indicator
      if (mounted) {
        Navigator.pop(context);
      }

      developer.log('Registration error: $error');

      if (mounted) {
        Alerts.showError(
          context: context,
          message: 'An unexpected error occurred. Please try again.',
          icon: Image.asset(
            Images.errorImage,
            height: 30,
            width: 30,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).highlightColor,
      body: SizedBox(
        child: Column(
          children: [
            // Header Section (Fixed)
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(50),
                ),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: HeaderBoldWidget(
                          text: Headlines.registerHeader,
                          color: Theme.of(context).highlightColor,
                          size: "24.0",
                        ),
                      ),
                      const SizedBox(width: 20),
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
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  NormalHeaderWidget(
                    text: Headlines.registerDesc,
                    color: Theme.of(context).highlightColor,
                    size: "18.0",
                  ),
                ],
              ),
            ),

            // Scrollable Form Section
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(10.0),
                child: Form(
                  key: _formKey,
                  autovalidateMode: _isSubmitting
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).primaryColor),
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                    ),
                    padding: const EdgeInsets.all(5.0),
                    child: Column(
                      children: [
                        // First Name (Required)
                        TextFormField(
                          controller: _firstNameController,
                          validator: (value) =>
                              _validateRequired(value, 'First name'),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.person),
                            labelText: "First Name *",
                            labelStyle: TextStyle(
                                color: Theme.of(context).indicatorColor),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(30)),
                            ),
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Second Name (Optional)
                        TextFormField(
                          controller: _secondNameController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.person_outline),
                            labelText: "Second Name",
                            labelStyle: TextStyle(
                                color: Theme.of(context).indicatorColor),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(30)),
                            ),
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Last Name (Required)
                        TextFormField(
                          controller: _lastNameController,
                          validator: (value) =>
                              _validateRequired(value, 'Last name'),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.person),
                            labelText: "Last Name *",
                            labelStyle: TextStyle(
                                color: Theme.of(context).indicatorColor),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(30)),
                            ),
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Email (Required)
                        TextFormField(
                          controller: _emailController,
                          validator: _validateEmail,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.email),
                            labelText: "Email ",
                            labelStyle: TextStyle(
                                color: Theme.of(context).indicatorColor),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(30)),
                            ),
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Phone Number (Required)
                        TextFormField(
                          controller: _phoneNumberController,
                          validator: _validatePhone,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.phone),
                            labelText: "Phone Number ",
                            labelStyle: TextStyle(
                                color: Theme.of(context).indicatorColor),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(30)),
                            ),
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Company Title (Required)
                        TextFormField(
                          controller: _companyTitleController,
                          validator: (value) =>
                              _validateRequired(value, 'Company title'),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.business),
                            labelText: "Company Title ",
                            labelStyle: TextStyle(
                                color: Theme.of(context).indicatorColor),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(30)),
                            ),
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Job Title (Required)
                        TextFormField(
                          controller: _jobTitleController,
                          validator: (value) =>
                              _validateRequired(value, 'Job title'),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.work),
                            labelText: "Job Title ",
                            labelStyle: TextStyle(
                                color: Theme.of(context).indicatorColor),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(30)),
                            ),
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Username (Required)
                        TextFormField(
                          controller: _usernameController,
                          validator: (value) =>
                              _validateRequired(value, 'Username'),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.account_circle),
                            labelText: "Username ",
                            labelStyle: TextStyle(
                                color: Theme.of(context).indicatorColor),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(30)),
                            ),
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Password (Required)
                        TextFormField(
                          controller: _passwordController,
                          validator: _validatePassword,
                          obscureText: _obscurePassword,
                          style: GoogleFonts.nunito(
                            textStyle: TextStyle(
                                color: Theme.of(context).primaryColor),
                            fontWeight: FontWeight.w500,
                            backgroundColor: Colors.transparent,
                          ),
                          decoration: InputDecoration(
                            prefixIcon:
                                const Icon(CupertinoIcons.padlock_solid),
                            labelText: "Password ",
                            labelStyle: TextStyle(
                                color: Theme.of(context).indicatorColor),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(30)),
                            ),
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? CupertinoIcons.eye_slash_fill
                                    : CupertinoIcons.eye_fill,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Navigation Links
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            NormalHeaderWidget(
                              text: Texts.haveAccount,
                              color: Theme.of(context).primaryColor,
                              size: '16.0',
                            ),
                            TextButton(
                              onPressed: () {
                                final auth = Provider.of<AuthProvider>(context,
                                    listen: false);
                                auth.navigateToLoginScreen();
                              },
                              child: Text(
                                Texts.login,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            final auth = Provider.of<AuthProvider>(context,
                                listen: false);
                            auth.navigateToVerifyWithOptScreen();
                          },
                          child: Text(
                            Texts.activateAccountWithOtp,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Register Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                              ),
                            ),
                            child: _isSubmitting
                                ? LoadingAnimationWidget.stretchedDots(
                                    color: Colors.white,
                                    size: 20,
                                  )
                                : Text(
                                    Texts.register,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
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
          ],
        ),
      ),
    );
  }
}
