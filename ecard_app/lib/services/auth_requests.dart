import 'dart:convert';
import 'package:ecard_app/services/app_urls.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

class AuthRequests {
  static Future<http.Response> login(String path, Object object) async {
    final url = Uri.parse("${AppUrl.loginUrl}/$path");
    print('Final URL: $url');
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json", // Add this
      },
      body: jsonEncode(object),
    );
    return response;
  }

  static Future<http.Response> register(String path, Object object) async {
    var response = await http.post(
        Uri.parse("${AppUrl.baseEndpoint}/auth/$path"),
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json"
        },
        body: jsonEncode(object));

    developer.log("========>Full endpoint ${AppUrl.baseEndpoint}/auth/$path");

    return response;
  }

  static Future<http.Response> activateAccount(String otp) {
    var response = http.get(
        Uri.parse("${AppUrl.baseEndpoint}/auth/activate?otp='$otp'"),
        headers: {
          'Content-type': 'Application/json',
          'Accept': 'application/json'
        });

    return response;
  }
}
