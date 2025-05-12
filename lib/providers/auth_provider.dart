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
    AuthScreen.registerScreen: {'firstName': '', 'middleName': '', 'username': '', 'lastName': '', 'email': '', 'role': '', 'password': '', 'phoneNumber': '', 'bio': '', 'companyTitle': '', 'jobTitle': '',},
    AuthScreen.forgotPassword: {'email': ''},
    AuthScreen.verifyWithOtp: {'otp': ''},
  };


  void navigateToLoginScreen() { _currentScreen = AuthScreen.loginScreen; notifyListeners(); }
  void navigateToVerifyWithOptScreen() { _currentScreen = AuthScreen.verifyWithOtp; notifyListeners(); }
  void navigateToRegisterScreen() { _currentScreen = AuthScreen.registerScreen; notifyListeners(); }
  void navigateToForgotPasswordScreen() { _currentScreen = AuthScreen.forgotPassword; notifyListeners(); }

  void updateFormField(String field, String value) {
    formData[_currentScreen]![field] = value;
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    var result;

    final Map<String, dynamic> loginData = {
        'username': username,
        'password': password
    };

    _loggedInStatus = Status.Authenticating;
    notifyListeners();

    Response response = await AuthRequests.login('login', loginData);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      var userData = responseData['data'];

      User authUser = User.fromJson(userData);

      UserPreferences.saveUser(authUser);

      _loggedInStatus = Status.LoggedIn;
      notifyListeners();

      result = {'status': true, 'message': 'Successful', 'user': authUser};
    } else {
      _loggedInStatus = Status.NotLoggedIn;
      notifyListeners();
      result = {
        'status': false,
        'message': json.decode(response.body)['error']
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

    return await AuthRequests.register('register', registrationData)
        .then(onValue)
        .catchError(onError);
  }

  static Future<Map<String, dynamic>> onValue(Response response) async {
    var result;
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

      result = {
        'status': false,
        'message': 'Registration failed',
        'data': responseData
      };
    }

    return result;
  }

  static onError(error) {
    print("the error is $error.detail");
    return {'status': false, 'message': 'Unsuccessful Request', 'data': error};
  }

  Future<Map<String, dynamic>> verifyOtp(String otp) async {
    try {
      final response = await AuthRequests.activateAccount(otp);
      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
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

}