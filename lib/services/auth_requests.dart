import 'dart:convert';
import 'package:ecard_app/services/app_urls.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

class AuthRequests {
  // login method
  static Future<http.Response> login(String path, Object object) async {
    final url = Uri.parse("${AppUrl.loginUrl}/$path");
    developer.log('Final Login URL=========>: $url');
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
  static Future<http.Response> register(String path, Object object) async {
    final url = Uri.parse("${AppUrl.registerUrl}/$path");
    developer.log("Register endpoint: $url");

    var response = await http.post(url,
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json"
        },
        body: jsonEncode(object));

    return response;
  }

  // activate account
  static Future<http.Response> activateAccount(String otp) async {
    final url =
        Uri.parse("${AppUrl.baseEndpoint}/auth/activate-account?otp=$otp");
    developer.log("Activation endpoint: $url");

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
