import 'dart:async';
import 'dart:convert';
import 'package:ecard_app/modals/user_modal.dart';
import 'package:ecard_app/services/auth_requests.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:developer' as developer;
import '../preferences/user_preference.dart';

// Define authentication screens
enum AuthScreen { loginScreen, registerScreen, forgotPassword, verifyWithOtp }

enum Status {
  NotLoggedIn,
  NotRegistered,
  LoggedIn,
  Registered,
  Authenticating,
  Registering,
  LoggedOut
}

class AuthProvider with ChangeNotifier {
  Status _loggedInStatus = Status.NotLoggedIn;
  Status _registeredInStatus = Status.NotRegistered;

  Status get loggedInStatus => _loggedInStatus;
  Status get registeredInStatus => _registeredInStatus;

  AuthScreen _currentScreen = AuthScreen.loginScreen;

  AuthScreen get currentScreen => _currentScreen;

  // Store form data for each screen
  Map<AuthScreen, Map<String, dynamic>> formData = {
    AuthScreen.loginScreen: {'username': '', 'password': ''},
    AuthScreen.registerScreen: {
      'firstName': '',
      'middleName': '',
      'username': '',
      'lastName': '',
      'email': '',
      'role': '',
      'password': '',
      'phoneNumber': '',
      'bio': '',
      'companyTitle': '',
      'jobTitle': '',
    },
    AuthScreen.forgotPassword: {'email': ''},
    AuthScreen.verifyWithOtp: {'otp': ''},
  };

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

  void updateFormField(String field, String value) {
    formData[_currentScreen]![field] = value;
  }

// Fixed login method for your auth provider
  Future<Map<String, dynamic>> login(String username, String password) async {
    var result;

    final Map<String, dynamic> loginData = {
      'username': username,
      'password': password
    };

    _loggedInStatus = Status.Authenticating;
    notifyListeners();

    try {
      Response response = await AuthRequests.login('login', loginData);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        var userData = responseData['data'];
        developer.log("Received user data from API: $userData");

        User authUser = User.fromJson(userData);
        developer.log("Parsed user object: ${authUser.toString()}");

        // Make sure to await the save operation and check result
        bool saveResult = await UserPreferences.saveUser(authUser);

        if (saveResult) {
          developer.log("User data saved successfully to preferences");
        } else {
          developer.log("Failed to save user data to preferences");
        }

        _loggedInStatus = Status.LoggedIn;
        notifyListeners();

        result = {'status': true, 'message': 'Successful', 'user': authUser};
      } else {
        _loggedInStatus = Status.NotLoggedIn;
        notifyListeners();

        // Improved error handling - extract message from response body safely
        String errorMessage;
        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          errorMessage = errorData['error'] ??
              errorData['message'] ??
              'Login failed: ${response.statusCode}';
        } catch (e) {
          errorMessage =
              'Login failed with status code: ${response.statusCode}';
        }

        result = {'status': false, 'message': errorMessage};
      }
    } catch (e) {
      _loggedInStatus = Status.NotLoggedIn;
      notifyListeners();

      developer.log("Login error: $e");
      result = {
        'status': false,
        'message': 'Connection error. Please check your internet connection.'
      };
    }

    return result;
  }

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
    final Map<String, dynamic> registrationData = {
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

    _registeredInStatus = Status.Registering;
    notifyListeners();

    try {
      Response response =
          await AuthRequests.register('register', registrationData);
      return onValue(response);
    } catch (error) {
      return onError(error);
    }
  }

  static Future<Map<String, dynamic>> onValue(Response response) async {
    var result;

    try {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        var userData = responseData['data'];

        User authUser = User.fromJson(userData);

        UserPreferences.saveUser(authUser);
        result = {
          'status': true,
          'message': 'Successfully registered',
          'data': authUser
        };
      } else {
        // Improved error handling - extract message from response body
        String errorMessage;
        try {
          errorMessage = responseData['error'] ??
              responseData['message'] ??
              'Registration failed with status code: ${response.statusCode}';
        } catch (e) {
          errorMessage =
              'Registration failed with status code: ${response.statusCode}';
        }

        result = {
          'status': false,
          'message': errorMessage,
          'data': responseData
        };
      }
    } catch (e) {
      developer.log("Error parsing registration response: $e");
      result = {
        'status': false,
        'message': 'Error processing server response',
        'data': null
      };
    }

    return result;
  }

  static Map<String, dynamic> onError(error) {
    developer.log("Registration error: $error");
    return {
      'status': false,
      'message': 'Connection error. Please check your internet connection.',
      'data': error.toString()
    };
  }

  Future<Map<String, dynamic>> verifyOtp(String otp) async {
    try {
      final response = await AuthRequests.activateAccount(otp);

      try {
        final responseData = json.decode(response.body);

        if (response.statusCode == 200) {
          notifyListeners();
          return {
            'status': true,
            'message': 'Account verified successfully',
          };
        } else {
          // Extract error message from response
          String errorMessage = responseData['message'] ??
              responseData['error'] ??
              'Verification failed with status code: ${response.statusCode}';

          return {
            'status': false,
            'message': errorMessage,
          };
        }
      } catch (e) {
        developer.log("Error parsing OTP verification response: $e");
        return {
          'status': false,
          'message': 'Error processing server response',
        };
      }
    } catch (e) {
      developer.log("OTP verification error: $e");
      return {
        'status': false,
        'message': 'Connection error. Please check your internet connection.',
      };
    }
  }
}
