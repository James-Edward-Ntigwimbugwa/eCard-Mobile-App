import 'dart:convert';

import 'package:ecard_app/services/app_urls.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceProximtyRequests {
  static Future<Response> getNearbyProximalDevices(
      {required Object jsonBody}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString("accessToken");
      final Response response;
      final url = Uri.parse(AppUrl.getNearbyProximalDevices);

      response = await post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(jsonBody),
      );

      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception(
            "Failed to fetch nearby devices: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      throw Exception("Failed to fetch nearby devices: $e");
    }
  }
}
