import 'dart:async';
import 'dart:convert';
import 'package:ecard_app/models/user_model.dart';
import 'package:ecard_app/services/auth_requests.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'dart:developer' as developer;
import '../preferences/user_preference.dart';

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
  final AuthRequests _apiService = AuthRequests();
  Status _loggedInStatus = Status.NotLoggedIn;
  Status _registeredInStatus = Status.NotRegistered;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;
  String? _accessToken;
  int? _userId;
  String? _email;

  Status get loggedInStatus => _loggedInStatus;

  Status get registeredInStatus => _registeredInStatus;

  bool get isLoading => _isLoading;

  bool get isAuthenticated => _isAuthenticated;

  String? get errorMessage => _errorMessage;

  int? get userId => _userId;

  String? get email => _email;

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

  Future<Map<String, dynamic>> signIn(
      {required String username, required String password}) async {
    _isLoading = true;
    _loggedInStatus = Status.Authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.login(username, password);

      // Parse the response body first to check for error field
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['error'] != true) {
        _accessToken = data['accessToken'];

        if (data.containsKey('data') &&
            data['data'] != null &&
            data.containsKey('user')) {
          User authUser = User.fromJson(data['user']);
          await UserPreferences.saveUser(authUser);
        }

        _isAuthenticated = true;
        _loggedInStatus = Status.LoggedIn;
        _isLoading = false;
        notifyListeners();
        return {
          'success': true,
          'message': data['message'] ?? 'Login successful'
        };
      } else {
        // Handle non-200 status codes or error responses
        String errorMessage;
        try {
          final errorData = data ?? jsonDecode(response.body);
          errorMessage = errorData['message'] ??
              errorData['detail'] ??
              'Login failed: ${response.statusCode}';
        } catch (e) {
          errorMessage =
              'Login failed with status code: ${response.statusCode}';
        }

        _errorMessage = errorMessage;
        _loggedInStatus = Status.NotLoggedIn;
        _isLoading = false;
        notifyListeners();
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      developer.log("Login error: $e");

      String errorMessage;
      if (e.toString().contains("SocketException") ||
          e.toString().contains("Connection") ||
          e.toString().contains("NetworkException")) {
        errorMessage =
            'Connection error. Please check your internet connection.';
      } else if (e.toString().contains("timeout") ||
          e.toString().contains("TimeoutException")) {
        errorMessage = 'Request timed out. Please try again later.';
      } else if (e.toString().contains("FormatException") ||
          e.toString().contains("format")) {
        errorMessage = 'Server returned an invalid response. Please try again.';
      } else {
        errorMessage = 'An unexpected error occurred. Please try again.';
      }

      _errorMessage = errorMessage;
      _loggedInStatus = Status.NotLoggedIn;
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': errorMessage};
    } finally {
      // Ensure that the loading state is reset
      _isLoading = false;
      notifyListeners();
    }
  }

  // Updated register method with improved error handling
  Future<bool> register(
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
    _isLoading = true;
    _registeredInStatus = Status.Registering;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.register(
        firstName,
        middleName,
        username,
        lastName,
        email,
        role,
        password,
        phoneNumber,
        bio,
        companyTitle,
        jobTitle,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access'];

        if (_accessToken != null) {
          Map<String, dynamic> decodedToken = Jwt.parseJwt(_accessToken!);
          _userId = decodedToken['user_id'];
        }

        _email = email;

        // If user data is available, save it
        if (data.containsKey('user')) {
          User authUser = User.fromJson(data['user']);
          await UserPreferences.saveUser(authUser);
        }

        _isAuthenticated = true;
        _registeredInStatus = Status.Registered;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        String errorMessage;
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['detail'] ??
              errorData['message'] ??
              'Registration failed: ${response.statusCode}';
        } catch (e) {
          errorMessage =
              'Registration failed with status code: ${response.statusCode}';
        }

        _errorMessage = errorMessage;
        _registeredInStatus = Status.NotRegistered;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      developer.log("Registration error: $e");
      _errorMessage =
          'Connection error. Please check your internet connection.';
      _registeredInStatus = Status.NotRegistered;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Updated OTP verification with improved error handling
  Future<Response> verifyOtp(String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.activateAccount(otp);

      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return response;
      } else {
        String errorMessage;
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ??
              errorData['detail'] ??
              'Verification failed with status code: ${response.statusCode}';
        } catch (e) {
          errorMessage =
              'Verification failed with status code: ${response.statusCode}';
        }

        _errorMessage = errorMessage;
        _isLoading = false;
        notifyListeners();
        return response;
      }
    } catch (e) {
      developer.log("OTP verification error: $e");
      if (e.toString().contains("SocketException") ||
          e.toString().contains("Connection")) {
        _errorMessage =
            "Network connection error. Please check your internet and try again.";
      } else if (e.toString().contains("timeout")) {
        _errorMessage = "Request timed out. Please try again later.";
      } else {
        _errorMessage = "An unexpected error occurred. Please try again.";
      }
      _isLoading = false;
      notifyListeners();
      return Response('{"error": "$_errorMessage"}', 500);
    }
  }

  // Sign out method
  Future<void> logout() async {
    _isAuthenticated = false;
    _loggedInStatus = Status.LoggedOut;
    _userId = null;
    _accessToken = null;
    _email = null;
    _errorMessage = null;

    // Clear stored preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await UserPreferences.removeUser();

    notifyListeners();
  }
}
