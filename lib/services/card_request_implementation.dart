import 'dart:convert';
import 'dart:developer' as developer;
import 'package:ecard_app/modals/card_modal.dart';
import 'package:ecard_app/preferences/card_preference.dart';
import 'package:ecard_app/services/card_requests.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../modals/saved_card_response.dart';
import 'app_urls.dart';

class CardProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  Future<Map<String, dynamic>> createCard(
      {required String title,
      required String cardDescription,
      required String organization,
      required String address,
      required String cardLogo,
      required String phoneNumber,
      required String email,
      String? profilePhoto = '',
      String? linkedIn = '',
      String? website = '',
      String? department = '',
      required String backgroundColor,
      required String fontColor}) async {
    // Fixed: Use the correct field names expected by the server
    final Object cardRegistrationData = {
      'title': title,
      'cardDescription': cardDescription,
      'publishCard': true,
      'organization': organization,
      'address': address,
      'cardLogo': cardLogo,
      'phoneNumber': phoneNumber,
      'email': email,
      'profilePhoto': profilePhoto,
      'linkedin': linkedIn,
      'websiteUrl': website,
      'department': department,
      'fontColor': fontColor,
      'backgroundColor': backgroundColor,
    };

    debugPrint(
        "= \n \n================= Card request data ============= \n \n ${cardRegistrationData.toString()}"
        "\n \n =============================\n \n");

    _isLoading = true;
    notifyListeners();

    try {
      Response response = await CardRequests.createCard(cardRegistrationData);

      var result = await _processCardResponse(response);

      _isLoading = false;
      notifyListeners();

      return result;
    } catch (e) {
      developer.log("Card creation error: $e");
      _isLoading = false;
      notifyListeners();
      return {
        'status': false,
        'message': 'Error creating card: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> _processCardResponse(Response response) async {
    try {
      developer.log("Card creation response status: ${response.statusCode}");
      developer.log("Card creation response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic responseData = jsonDecode(response.body);
        final List<dynamic>? content = responseData['content'];

        if (content != null && content.isNotEmpty) {
          try {
            final cardData = content[0]; // Single card for creation
            CustomCard card = CustomCard.fromJson(cardData);
            await CardPreferences.saveCard(card);
            developer.log("Card saved to local preferences successfully");

            return {
              'status': true,
              'message': 'Card created successfully',
              'card': card,
            };
          } catch (e) {
            developer.log("Error parsing or saving card: $e");
            return {
              'status': true,
              'message':
                  'Card created, but could not be saved locally: ${e.toString()}',
            };
          }
        } else {
          developer.log("Card data is null or not found in response");
          return {
            'status': true,
            'message':
                'Card created successfully, but no data returned from server',
          };
        }
      } else {
        String errorMessage;
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['error'] ??
              errorData['message'] ??
              'Card creation failed with status ${response.statusCode}';
        } catch (e) {
          errorMessage =
              'Card creation failed with status ${response.statusCode}';
        }

        developer.log("Card creation error: $errorMessage");

        return {
          'status': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      developer.log("Error processing card response: $e");
      return {
        'status': false,
        'message': 'Error processing response: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> fetchCards(String uuid) async {
    Future.microtask(() {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    });
    try {
      final response = await CardRequests.fetchUserCards(uuid);

      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);
        final List<dynamic>? content = responseData['content'];
        developer.log("Card data received successfully");

        List<CustomCard> cards = [];
        if (content != null) {
          cards =
              content.map((cardJson) => CustomCard.fromJson(cardJson)).toList();
        }

        if (cards.isNotEmpty) {
          await CardPreferences.saveCards(cards);
          developer.log("Saved ${cards.length} cards to SQLite database");
        }

        developer.log("Processed ${cards.length} cards");

        _isLoading = false;
        notifyListeners();

        return {"status": true, "message": "Success", "cards": cards};
      } else {
        _errorMessage =
            "Failed to load cards: Server returned ${response.statusCode}";
        developer.log(_errorMessage!);

        final localCards = await CardPreferences.getCardsByUser(uuid);
        if (localCards != null && localCards.isNotEmpty) {
          developer
              .log("Loaded ${localCards.length} cards from local database");
          _isLoading = false;
          notifyListeners();
          return {
            "status": true,
            "message": "Loaded from local storage",
            "cards": localCards
          };
        }

        _isLoading = false;
        notifyListeners();

        return {
          "status": false,
          "message": _errorMessage,
          "cards": <CustomCard>[]
        };
      }
    } catch (e) {
      _errorMessage = "Error fetching cards: ${e.toString()}";
      developer.log(_errorMessage!);

      try {
        final localCards = await CardPreferences.getCardsByUser(uuid);
        if (localCards != null && localCards.isNotEmpty) {
          developer
              .log("Loaded ${localCards.length} cards from local database");
          _isLoading = false;
          notifyListeners();
          return {
            "status": true,
            "message": "Loaded from local storage",
            "cards": localCards
          };
        }
      } catch (dbError) {
        developer.log("Error loading from local database: $dbError");
      }

      _isLoading = false;
      notifyListeners();

      return {
        "status": false,
        "message": _errorMessage,
        "cards": <CustomCard>[]
      };
    }
  }

  Future<CustomCard?> getCardByUuid({required String uuid}) async {
    try {
      final response = await CardRequests.fetchCardDetails(uuid);
      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);
        final List<dynamic>? content = responseData['content'];
        developer.log("Card data received successfully");

        if (content != null && content.isNotEmpty) {
          CustomCard card = CustomCard.fromJson(content[0]);
          await CardPreferences.saveCard(card);
          developer.log("Saved card to SQLite database successfully");
          return card;
        }
        return null;
      } else if (response.statusCode == 404) {
        developer.log("Card not found");
        return null;
      } else if (response.statusCode == 500) {
        developer.log("Server error: ${response.statusCode}");
        return null;
      } else {
        developer.log("Failed to fetch card: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      developer.log("Error fetching card by UUID: $e");
      return null;
    }
  }

  Future<bool> saveOrganizationCard(
      {required int userId, required int cardId}) async {
    debugPrint(
        "Save Card organization in card-request-implementation executed ====>");
    final Object savingBody = {"userId": userId, "cardId": cardId};

    debugPrint("==============================================="
        "\n \n saving card for organization \n \n "
        "id : $cardId \n "
        "user id : $userId");
    try {
      final response = await CardRequests.saveCard(savingBody: savingBody);

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint(e as String);
      throw Exception("Caught an exception");
    }
  }

  static Future<List<SavedCardResponse>> getSavedCardsWithAuth({required
  int cardId}) async {
    try {
      final response = await CardRequests.getSavedPeople(cardId: cardId);

      debugPrint('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);

        return jsonList
            .map((json) => SavedCardResponse.fromJson(json))
            .toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Invalid or expired token');
      } else if (response.statusCode == 404) {
        throw Exception('Card not found');
      } else {
        throw Exception('Failed to load saved cards: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching saved cards: $e');
      throw Exception('Failed to fetch saved cards: $e');
    }
  }
}
