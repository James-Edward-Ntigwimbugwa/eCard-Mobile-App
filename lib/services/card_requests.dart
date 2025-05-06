import 'package:ecard_app/services/app_urls.dart';
import 'package:http/http.dart';
import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';

class CardRequests {
  static Future<Response> fetchUserCards(String uuid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      developer.log("Stored UUID: ${prefs.getString("userUuid")}");
      developer.log("Stored Token: ${prefs.getString("accessToken")}");
      final bearerToken = prefs.getString("accessToken");
      if (bearerToken == null || bearerToken.isEmpty) {
        developer.log("No valid token found, redirecting to login");
        throw Exception("Authentication required");
      }

      final url = Uri.parse("${AppUrl.getAllCardsById}?uuid=$uuid");

      developer.log(
          "Valid token found: ${bearerToken.substring(0, 5)}..."); // Log first 5 chars for security

      final response = await get(
        url,
        headers: {
          "Authorization": "Bearer $bearerToken",
          "Content-type": "application/json",
          "Accept": "application/json",
        },
      );

      return response;
    } catch (e) {
      developer.log("API call failed: $e");
      rethrow;
    }
  }
}
