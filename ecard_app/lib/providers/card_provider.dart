import 'dart:convert';
import 'dart:developer' as developer;
import 'package:ecard_app/modals/card_modal.dart';
import 'package:ecard_app/preferences/card_preference.dart';
import 'package:ecard_app/services/card_requests.dart';
import 'package:flutter/material.dart';

class CardProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<Map<String, dynamic>> fetchCards(String uuid) async {
    Future.microtask(() {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    });

    try {
      developer.log("Fetching cards for UUID: $uuid");
      final response = await CardRequests.fetchUserCards(uuid);

      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);
        developer.log("Card data received successfully");

        // if (responseData['content'] == null) {
        //   throw Exception('No card data in response');
        // }

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
        if (cards.isNotEmpty) {
          await CardPreferences.saveCard(cards.first);
        }
        developer.log("Processed ${cards.length} cards");

        _isLoading = false;
        notifyListeners();

        return {"status": true, "message": "Success", "cards": cards};
      } else {
        _errorMessage =
            "Failed to load cards: Server returned ${response.statusCode}";
        developer.log(_errorMessage!);

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

      _isLoading = false;
      notifyListeners();

      return {
        "status": false,
        "message": _errorMessage,
        "cards": <CustomCard>[]
      };
    }
  }
}
