import 'dart:convert';
import 'dart:developer' as developer;
import 'package:ecard_app/modals/card_modal.dart';
import 'package:ecard_app/preferences/card_preference.dart';
import 'package:ecard_app/services/card_requests.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

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
    final Map<String, dynamic> cardRegistrationData = {
      'title': title,
      'cardDescription': cardDescription,
      'publishCard': true,
      'organization': organization,
      'address': address,
      'cardLogo': cardLogo,
      'phoneNumber': phoneNumber,
      'email': email,
      'profilePhoto': profilePhoto,
      'linkedIn': linkedIn,
      'website': website,
      'department': department,
      'backgroundColor': backgroundColor,
    };

    _isLoading = true;
    notifyListeners();

    return await CardRequests.createCard(cardRegistrationData)
        .then(onValue)
        .catchError(onError);
  }

  static Future<Map<String, dynamic>> onValue(Response response) async {
    var result;
    if (response.statusCode == 200) {
      final dynamic responseData = jsonDecode(response.body);
      CardPreferences.saveCard(CustomCard.fromJson(responseData['content']));
      result = {
        'status': true,
        'message': 'Card data successfully registered',
      };
    } else {
      result = {
        'status': false,
        'message': 'card Registration failed',
      };
    }
    return result;
  }

  static onError(error) {
    developer.log("the error is $error.detail");
    return {'status': false, 'message': 'Unsuccessful Request', 'data': error};
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
        developer.log("Card data received successfully");

        var cardsData = responseData['content'];
        List<CustomCard> cards = [];

        if (cardsData is List) {
          for (var cardJson in cardsData) {
            CustomCard card = CustomCard.fromJson(cardJson);
            cards.add(card);
          }
        } else if (cardsData is Map<String, dynamic>) {
          CustomCard card = CustomCard.fromJson(cardsData);
          cards.add(card);
        }

        // Save all cards to SQLite database
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

        // Try to load cards from local SQLite database as fallback
        final localCards = await CardPreferences.getCardsByUser(uuid);
        if (localCards!.isNotEmpty) {
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

      // Try to load cards from local SQLite database as fallback
      try {
        final localCards = await CardPreferences.getCardsByUser(uuid);
        if (localCards!.isNotEmpty) {
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

  Future<bool> updateCard(CustomCard card) async {
    try {
      bool result = await CardPreferences.updateCard(card);
      if (result) {
        notifyListeners();
      }
      return result;
    } catch (e) {
      _errorMessage = "Error updating card: ${e.toString()}";
      developer.log(_errorMessage!);
      return false;
    }
  }

  Future<bool> deleteCard(String id) async {
    try {
      bool result = await CardPreferences.deleteCard(id);
      if (result) {
        notifyListeners();
      }
      return result;
    } catch (e) {
      _errorMessage = "Error deleting card: ${e.toString()}";
      developer.log(_errorMessage!);
      return false;
    }
  }
}
