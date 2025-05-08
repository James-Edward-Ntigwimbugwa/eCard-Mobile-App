import 'dart:convert';
import 'package:ecard_app/services/auth_requests.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Define authentication screens
enum AuthScreen { loginScreen, registerScreen, forgotPassword, verifyWithOtp }

class AuthProvider extends ChangeNotifier {
  AuthScreen _currentScreen = AuthScreen.loginScreen;
  AuthScreen get currentScreen => _currentScreen;

  // Add a flag to track if account is verified
  bool _isAccountVerified = false;
  bool get isAccountVerified => _isAccountVerified;

  // Track login status
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  // Store user data
  Map<String, dynamic> _userData = {};
  Map<String, dynamic> get userData => _userData;

  // Store form data for each screen to persist input across screen transitions
  Map<AuthScreen, Map<String, String>> formData = {
    AuthScreen.loginScreen: {},
    AuthScreen.registerScreen: {},
    AuthScreen.forgotPassword: {},
  };

  void updateFormField(String field, String value) {
    formData[_currentScreen] ??= {};
    formData[_currentScreen]![field] = value;
  }

  void navigateToLoginScreen() {
    _currentScreen = AuthScreen.loginScreen;
    notifyListeners();
  }

  void navigateToVerifyWithOptScreen() {
    _currentScreen = AuthScreen.verifyWithOtp;
    notifyListeners();
  }

  void navigateToRegisterScreen() {
    _currentScreen = AuthScreen.registerScreen;
    notifyListeners();
  }

  void navigateToForgotPasswordScreen() {
    _currentScreen = AuthScreen.forgotPassword;
    notifyListeners();
  }

  void setAccountVerified(bool value) {
    _isAccountVerified = value;
    notifyListeners();
  }

  // Check verification status when app starts
  Future<void> checkVerificationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isAccountVerified = prefs.getBool('accountVerified') ?? false;
    notifyListeners();
  }

  // Save verification status
  Future<void> saveVerificationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('accountVerified', _isAccountVerified);
  }

  // Login method
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final Map<String, String> loginData = {
        'username': username,
        'password': password,
      };

      // Make the login request
      final response = await AuthRequests.login('login', loginData);
      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Check if account is verified before allowing login
        if (responseData['accountVerified'] == true || _isAccountVerified) {
          _isLoggedIn = true;
          _userData = responseData['userData'] ?? {};

          // Save user data and verification status
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('userData', json.encode(_userData));
          await prefs.setBool('accountVerified', true);
          _isAccountVerified = true;

          notifyListeners();
          return {
            'status': true,
            'message': 'Login successful',
          };
        } else {
          // Account is not verified, redirect to OTP verification
          return {
            'status': false,
            'message': 'Please verify your account first',
            'needsVerification': true,
          };
        }
      } else {
        return {
          'status': false,
          'message': responseData['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'An error occurred. Please try again.',
      };
    }
  }

  // Register method
  Future<Map<String, dynamic>> register(
    String firstName,
    String middleName,
    String username,
    String lastName,
    String email,
    String role,
    String password,
    String phoneNumber,
    String bio,
    String companyTitle,
    String jobTitle,
  ) async {
    try {
      final Map<String, String> registerData = {
        'firstName': firstName,
        'middleName': middleName,
        'username': username,
        'lastName': lastName,
        'email': email,
        'role': role,
        'password': password,
        'phoneNumber': phoneNumber,
        'bio': bio,
        'companyTitle': companyTitle,
        'jobTitle': jobTitle,
      };

      final response = await AuthRequests.register('register', registerData);
      final responseData = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Save temporary user data but don't log in yet
        _userData = {
          'firstName': firstName,
          'email': email,
          'username': username,
          // Add other fields as needed
        };

        // Mark account as not verified
        _isAccountVerified = false;
        await saveVerificationStatus();

        notifyListeners();
        return {
          'status': true,
          'message': 'Registration successful. Please verify your account.',
        };
      } else {
        return {
          'status': false,
          'message': responseData['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'An error occurred. Please try again.',
      };
    }
  }

  // Verify OTP and activate account
  Future<Map<String, dynamic>> verifyOtp(String otp) async {
    try {
      final response = await AuthRequests.activateAccount(otp);
      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Mark account as verified
        _isAccountVerified = true;
        await saveVerificationStatus();

        notifyListeners();
        return {
          'status': true,
          'message': 'Account verified successfully',
        };
      } else {
        return {
          'status': false,
          'message': responseData['message'] ?? 'Verification failed',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'An error occurred. Please try again.',
      };
    }
  }

  // Logout method
  Future<void> logout() async {
    _isLoggedIn = false;
    _userData = {};

    // Clear user data but keep verification status
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userData');

    notifyListeners();
  }

  // Check login status when app starts
  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (_isLoggedIn) {
      final userDataStr = prefs.getString('userData');
      if (userDataStr != null) {
        _userData = json.decode(userDataStr);
      }
    }

    // Also check verification status
    _isAccountVerified = prefs.getBool('accountVerified') ?? false;

    notifyListeners();
    return _isLoggedIn;
  }
}
