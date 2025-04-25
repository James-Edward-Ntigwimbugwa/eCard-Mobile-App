import 'dart:convert';
import 'package:ecard_app/modals/card_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class CardPreferences {
  static const String _cardsKey = 'user_cards';

  static Future<bool> saveCard(CustomCard card) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String cardJson = jsonEncode(card.toJson());
      return await prefs.setString(_cardsKey, cardJson);
    } catch (e) {
      developer.log('Error saving card: $e');
      return false;
    }
  }

  static Future<bool> saveCards(List<CustomCard> cards) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> cardsJsonList =
          cards.map((card) => card.toJson()).toList();
      final String cardsJson = jsonEncode(cardsJsonList);
      return await prefs.setString(_cardsKey, cardsJson);
    } catch (e) {
      print('Error saving cards: $e');
      return false;
    }
  }

  static Future<List<CustomCard>> getCards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cardsJson = prefs.getString(_cardsKey);

      if (cardsJson == null) {
        return [];
      }

      final dynamic jsonData = jsonDecode(cardsJson);

      if (jsonData is List) {
        return jsonData
            .map((cardJson) => CustomCard.fromJson(cardJson))
            .toList();
      } else if (jsonData is Map<String, dynamic>) {
        // Handle single card case
        return [CustomCard.fromJson(jsonData)];
      }

      return [];
    } catch (e) {
      developer.log('Error retrieving cards: $e');
      return [];
    }
  }

  static Future<bool> clearCards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_cardsKey);
    } catch (e) {
      print('Error clearing cards: $e');
      return false;
    }
  }
}
