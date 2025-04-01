import 'package:ecard_app/services/app_urls.dart';
import 'package:http/http.dart';

class CardRequests {
  static Future<Response> fetchUserCards(String uuid) async {
    final url = Uri.https(AppUrl.getAllCardsById, {"uuid": uuid} as String);

    final response = await get(url, headers: {
      "Content-type": "application/json",
      "Accept": "application/json"
    });

    return response;
  }
}
