import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:ecard_app/modals/user_modal.dart';
import 'package:ecard_app/services/auth_requests.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import '../modals/user_preference.dart';

enum Status {
  NotLoggedIn,
  NotRegistered,
  LoggedIn,
  Registered,
  Authenticating,
  Registering,
  LoggedOut
}

enum AuthScreen {
  forgotPassword , loginScreen , registerScreen
}

class AuthProvider with ChangeNotifier {
  AuthScreen _currentAuthScreen = AuthScreen.loginScreen;
  AuthScreen get currentScreen => _currentAuthScreen;

  Status _loggedInStatus = Status.NotLoggedIn;
  Status _registeredStatus = Status.NotRegistered;

  Status get loggedInStatus => _loggedInStatus;
  Status get registeredStatus => _registeredStatus;

  final Map<AuthScreen , Map<String, String>> formData = {
    AuthScreen.loginScreen: {'userName': '','password' : ''},
    AuthScreen.registerScreen : {
      "firstName" : "" ,
      "middleName" : "",
      "lastName" : "" ,
      "username" : "",
      "email" : "",
      "password" : "",
      "phoneNumber" : "",
      "biography" : "",
      "companyTitle" : " ",
      "jobTitle" : ""
    },
    AuthScreen.forgotPassword : {'email': ''}
  };

  void navigateToLoginScreen() {
    _currentAuthScreen = AuthScreen.loginScreen;
    notifyListeners();
  }

  void navigateToRegisterScreen() {
    _currentAuthScreen = AuthScreen.registerScreen;
    notifyListeners();
  }
  void navigateToForgotPasswordScreen() {
    _currentAuthScreen = AuthScreen.forgotPassword;
    notifyListeners();
  }

  void updateFormField(String field, String value) {
    if(formData[_currentAuthScreen]?.containsKey(field)??false){
      formData[_currentAuthScreen]![field] = value;
      notifyListeners();
    }
  }
  void clearCurrentForm(){
    Map<String, String> emptyForm = {};
    formData[_currentAuthScreen]?.forEach((key, _){
      emptyForm[key] = '';
    });
    formData[_currentAuthScreen] = emptyForm;
    notifyListeners();
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    print("statement 2 reached=======>");
    Map<String, dynamic> result;
    final Map<String, dynamic> logInData = {
      'username': username,
      'password': password
    };

    _loggedInStatus = Status.Authenticating;
    notifyListeners();

    final response = await AuthRequests.login('login', logInData);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      developer.log("response code: ${response.statusCode}");
      developer.log("response body: ${response.body}");

      var userData = responseData['data'];
      User authenticatedUser = User.fromJson(userData);
      UserPreferences.saveUser(authenticatedUser);
      developer.log("Authenticated user${authenticatedUser.toString()}");

      _loggedInStatus = Status.LoggedIn;
      notifyListeners();
      result = {
        "status": true,
        "message": "Success",
        "user": authenticatedUser
      };
    } else {
      _loggedInStatus = Status.NotLoggedIn;
      notifyListeners();
      result = {
        "status": false,
        "message": json.decode(response.body)['error']
      };
    }
    return result;
  }

  Future<FutureOr> register(
    String firstName,
    String middleName,
    String username,
    String lastName,
    String email,
    String userRole,
    String password,
    String phoneNumber,
    String biography,
    String companyTitle,
    String jobTitle,
  ) async {
    final Map<String, dynamic> registrationData = {
      "firstName": firstName,
      "username": username,
      "middleName": middleName,
      "lastName": lastName,
      "email": email,
      "userRole": userRole,
      "password": password,
      "phoneNumber": phoneNumber,
      "biography": biography,
      "companyTitle": companyTitle,
      "jobTitle": jobTitle,
    };

    _registeredStatus = Status.Registering;
    notifyListeners();
    return await AuthRequests.register('register', registrationData)
        .then(onValue)
        .catchError(onError);
  }

  Future<FutureOr> onValue(Response response) async {
    Map<String, Object> result;
    final Map<String, dynamic> responseData = json.decode(response.body);
    if (response.statusCode == 200) {
      var userData = responseData['data'];
      User authUser = User.fromJson(userData);
      UserPreferences.saveUser(authUser);
      result = {
        "status": true,
        "message": "registered Successfully",
        "data": authUser
      };
    } else {
      result = {
        "status": false,
        "message": "registration failed",
        "data": responseData
      };
    }
    return result;
  }

  static onError(error) {
    print("the error is $error.detail");
    return {"status": false, "message": "Unsuccessful request", "data": error};
  }

}
