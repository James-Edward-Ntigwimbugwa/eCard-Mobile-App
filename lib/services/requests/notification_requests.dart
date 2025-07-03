import 'dart:convert';

import 'package:ecard_app/services/app_urls.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationRequests {
  static Future<Response> fetchNotifications({required String? id}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String userId = id ?? prefs.getString("userId") ?? '';
      final String bearerToken = prefs.getString("accessToken") ?? '';

      final Response response;
      final url = Uri.parse('${AppUrl.getUserNotification}/$userId');
      if (bearerToken.isEmpty || userId.isEmpty) {
        throw Exception("Authentication required");
      }

      response = await get(url, headers: {
        "Authorization": "Bearer $bearerToken",
        "Content-type": "application/json",
        "Accept": "application/json",
      });
      if (response.statusCode == 401) {
        throw Exception("Authentication required");
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Response> sendNotificationToUsers({
    required String cardId,
    required String message,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final String bearerToken = prefs.getString("accessToken") ?? '';

    if (bearerToken.isEmpty) {
      throw Exception("Not Authorized");
    }

    final url = Uri.parse('${AppUrl.sendNotification}/$cardId');
    final response = await post(
      url,
      headers: {
        "Authorization": "Bearer $bearerToken",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: message
    );

    return response;
  }
}
