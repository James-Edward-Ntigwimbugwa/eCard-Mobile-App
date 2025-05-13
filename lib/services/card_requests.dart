import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math' as Math;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecard_app/services/app_urls.dart';

class CardRequests {
  static Future<Response> fetchUserCards([String? uuid]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String userUuid = uuid ?? prefs.getString("userUuid") ?? '';
      final bearerToken = prefs.getString("accessToken");

      developer.log("Fetching cards for UUID: $userUuid");

      if (bearerToken == null || bearerToken.isEmpty) {
        developer.log("No valid token found, redirecting to login");
        throw Exception("Authentication required");
      }

      final url = Uri.parse("${AppUrl.getAllCardsById}?uuid=$userUuid");

      developer.log(
          "Valid token found: ${bearerToken.substring(0, Math.min(5, bearerToken.length))}..."); // Log first 5 chars for security

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

  // Additional request methods can be added here for creating/updating/deleting cards

  static Future<Response> createCard(Map<String, dynamic> cardData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bearerToken = prefs.getString("accessToken");

      if (bearerToken == null || bearerToken.isEmpty) {
        throw Exception("Authentication required");
      }

      final url = Uri.parse(AppUrl.createCard);

      final response = await post(
        url,
        headers: {
          "Authorization": "Bearer $bearerToken",
          "Content-type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(cardData),
      );

      return response;
    } catch (e) {
      developer.log("Create card API call failed: $e");
      rethrow;
    }
  }

  static Future<Response> updateCard(String cardId, Map<String, dynamic> cardData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bearerToken = prefs.getString("accessToken");

      if (bearerToken == null || bearerToken.isEmpty) {
        throw Exception("Authentication required");
      }

      final url = Uri.parse("${AppUrl.updateCard}/$cardId");

      final response = await put(
        url,
        headers: {
          "Authorization": "Bearer $bearerToken",
          "Content-type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(cardData),
      );

      return response;
    } catch (e) {
      developer.log("Update card API call failed: $e");
      rethrow;
    }
  }

  static Future<Response> deleteCard(String cardId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bearerToken = prefs.getString("accessToken");

      if (bearerToken == null || bearerToken.isEmpty) {
        throw Exception("Authentication required");
      }

      final url = Uri.parse("${AppUrl.deleteCard}/$cardId");

      final response = await delete(
        url,
        headers: {
          "Authorization": "Bearer $bearerToken",
          "Content-type": "application/json",
          "Accept": "application/json",
        },
      );

      return response;
    } catch (e) {
      developer.log("Delete card API call failed: $e");
      rethrow;
    }
  }
}