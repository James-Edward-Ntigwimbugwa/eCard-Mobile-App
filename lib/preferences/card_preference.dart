import 'package:ecard_app/modals/card_modal.dart';
import 'dart:developer' as developer;
import '../database/database_helper.dart';

class CardPreferences {
  static Future<bool> saveCard(CustomCard card) async {
    try {
      final result = await DatabaseHelper.instance.insertCard(card);
      return result! > 0;
    } catch (e) {
      developer.log('Error saving card: $e');
      return false;
    }
  }

  static Future<bool> saveCards(List<CustomCard> cards) async {
    try {
      final result = await DatabaseHelper.instance.insertCards(cards);
      return result > 0;
    } catch (e) {
      developer.log('Error saving cards: $e');
      return false;
    }
  }

  static Future<List<CustomCard>?> getCards() async {
    try {
      return await DatabaseHelper.instance.getAllCards();
    } catch (e) {
      developer.log('Error retrieving cards: $e');
      return [];
    }
  }

  static Future<List<CustomCard>?> getCardsByUser(String userUuid) async {
    try {
      return await DatabaseHelper.instance.getCardsByUser(userUuid);
    } catch (e) {
      developer.log('Error retrieving cards for user: $e');
      return [];
    }
  }

  static Future<bool> clearCards() async {
    try {
      final result = await DatabaseHelper.instance.clearAllCards();
      return result! > 0;
    } catch (e) {
      developer.log('Error clearing cards: $e');
      return false;
    }
  }

  static Future<bool> deleteCard(String id) async {
    try {
      final result = await DatabaseHelper.instance.deleteCard(id);
      return result! > 0;
    } catch (e) {
      developer.log('Error deleting card: $e');
      return false;
    }
  }

  static Future<bool> updateCard(CustomCard card) async {
    try {
      final result = await DatabaseHelper.instance.updateCard(card);
      return result! > 0;
    } catch (e) {
      developer.log('Error updating card: $e');
      return false;
    }
  }
}