import 'dart:convert';
import 'package:ecard_app/services/app_urls.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

class AuthRequests {
  // login method
  Future<http.Response> login(String username, String password) async {
    final Object object = {"username": username, "password": password};
    final url = Uri.parse(AppUrl.loginUrl);
    debugPrint('Final Login URL=========>: $url');
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(object),
    );
    return response;
  }

  // register method
  Future<http.Response> register(
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
      String jobTitle) async {
    final Object object = {
      "firstName": firstName,
      "middleName": middleName,
      "username": username,
      "lastName": lastName,
      "email": email,
      "role": role,
      "password": password,
      "phoneNumber": phoneNumber,
      "bio": bio,
      "companyTitle": companyTitle,
      "jobTitle": jobTitle
    };
    final url = Uri.parse(AppUrl.registerUrl);
    debugPrint("Register endpoint========>: $url");

    var response = await http.post(url,
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json"
        },
        body: jsonEncode(object));

    return response;
  }

  // activate account
  Future<http.Response> activateAccount(String otp) async {
    final url = Uri.parse("${AppUrl.verifyWithOtp}$otp");
    debugPrint("Activation endpoint=========>: $url");

    var response = await http.post(url, headers: {
      'Content-type': 'application/json',
      'Accept': 'application/json'
    });

    return response;
  }

  // Add method to check if account is verified
  static Future<http.Response> checkAccountStatus(String username) async {
    final url =
        Uri.parse("${AppUrl.baseEndpoint}/auth/status?username=$username");
    developer.log("Status check endpoint: $url");

    var response = await http.get(url, headers: {
      'Content-type': 'application/json',
      'Accept': 'application/json'
    });

    return response;
  }

  // Add method to resend OTP
  static Future<http.Response> resendOtp(String email) async {
    final url = Uri.parse("${AppUrl.baseEndpoint}/auth/resend-otp");
    developer.log("Resend OTP endpoint: $url");

    var response = await http.post(url,
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json'
        },
        body: jsonEncode({'email': email}));

    return response;
  }
}
