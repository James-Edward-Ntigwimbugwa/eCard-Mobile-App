import 'dart:convert';
import 'dart:developer' as developer;
import 'package:ecard_app/modals/card_modal.dart';
import 'package:ecard_app/modals/card_preference.dart';
import 'package:ecard_app/services/card_requests.dart';
import 'package:flutter/material.dart';

class CardProvider with ChangeNotifier {
  Future<Map<String, dynamic>> fetchCards(String uuid) async {
    developer.log("method reached ===============>");
    Map<String, dynamic> result;
    final response = await CardRequests.fetchUserCards(uuid);

    if (response.statusCode == 200) {
      developer.log("response code was 200=======>");
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      developer.log("response body : $responseData");

      var cardData = responseData['data'];
      CustomCard card = CustomCard.fromJson(cardData);
      CardPreferences.saveCard(card);
      developer.log("Saved Card : ${card.toString()}");
      result = {"status": true, "message": "Success", "card data": card};
      notifyListeners();
    } else {
      result = {"status": false, "message": "an error occurred"};
      notifyListeners();
    }

    return result;
  }
}
