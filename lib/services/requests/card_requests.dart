import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecard_app/services/app_urls.dart';

class CardRequests {
  static Future<Response> fetchUserCards([String? uuid]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String userUuid = uuid ?? prefs.getString("userUuid") ?? '';
      final String bearerToken = prefs.getString("accessToken") ?? '';

      debugPrint("Fetching cards for UUID: $userUuid");
      debugPrint("Bearer token available: ${bearerToken.isNotEmpty}");

      if (bearerToken.isEmpty || userUuid.isEmpty) {
        debugPrint("No valid token or UUID found, authentication required");
        throw Exception("Authentication required");
      }

      final url = Uri.parse("${AppUrl.getAllCardsById}?uuid=$userUuid");

      debugPrint(
          "Making API request with token: ${bearerToken.substring(0, Math.min(5, bearerToken.length))}...");

      final response = await get(
        url,
        headers: {
          "Authorization": "Bearer $bearerToken",
          "Content-type": "application/json",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 401) {
        debugPrint("Authentication failed: 401 Unauthorized");
        throw Exception("Authentication token expired");
      }

      return response;
    } catch (e) {
      developer.log("API call failed: $e");
      rethrow;
    }
  }

  static Future<Response> createCard(Object cardData) async {
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

  static Future<Response> updateCard(
      String cardId, Map<String, dynamic> cardData) async {
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

  static Future<Response> fetchCardDetails(String cardId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bearerToken = prefs.getString("accessToken");
      debugPrint("Bearer token in cardProvider ========>: $bearerToken");

      if (bearerToken == null || bearerToken.isEmpty) {
        throw Exception("Authentication required");
      }

      final url = Uri.parse("${AppUrl.getCardDetails}/$cardId");

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
      developer.log("Fetch card details API call failed: $e");
      rethrow;
    }
  }
  static Future<Response> fetchUserSavedCards({required String userId}) async{
    try {
      final prefs = await SharedPreferences.getInstance();
      final bearerToken = prefs.getString("accessToken");

      if (bearerToken == null || bearerToken.isEmpty) {
        throw Exception("Authentication required");
      }

      final url = Uri.parse("${AppUrl.getAllUserSavedCards}/${int.parse(userId)}");

      final response = await get(
        url,
        headers: {
          "Authorization": "Bearer $bearerToken",
          "Content-type": "application/json",
          "Accept": "application/json",
        },
      );

      return response;

    }catch(e){
      debugPrint("Fetch card details API call failed in card_request.dart: $e");
      rethrow;
    }
  }

  static Future<Response> saveCard({required Object savingBody}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bearerToken = prefs.getString("accessToken");
      debugPrint(
          "========Bearer token in cardProvider ========>: $bearerToken");

      if (bearerToken == null || bearerToken.isEmpty) {
        throw Exception("Authentication is required");
      }

      final url = Uri.parse(AppUrl.saveCard);
      debugPrint("final url in card-request ========>: $url");

      final response = await post(url,
          headers: {
            "Authorization": "Bearer $bearerToken",
            "Content-type": "application/json",
            "Accept": "application/json"
          },
          body: jsonEncode(savingBody));

      return response;
    } catch (e) {
      debugPrint(e as String?);
      throw Exception("An exception caught");
    }
  }

  static Future<Response> getSavedPeople({required int cardId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bearerToken = prefs.getString("accessToken");
      debugPrint(
          "========Bearer token in cardProvider ========>: $bearerToken");

      if (bearerToken == null || bearerToken.isEmpty) {
        throw Exception("Authentication is required");
      }

      final url = Uri.parse('${AppUrl.getPeopleWhoSavedCard}/$cardId');
      debugPrint("final url in card-request ========>: $url");

      final response = await get(url, headers: {
        "Authorization": "Bearer $bearerToken",
        "Content-type": "application/json",
        "Accept": "application/json"
      });

      return response;
    } catch (e) {
      debugPrint(e as String?);
      throw Exception("An exception caught");
    }
  }
}
