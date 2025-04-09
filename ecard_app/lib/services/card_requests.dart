import 'package:ecard_app/services/app_urls.dart';
import 'package:http/http.dart';
import 'dart:developer' as developer;

class CardRequests {
  static String bearerToken =
      "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJKYW1lc0Vkd2FyZDIwMDEiLCJyb2xlcyI6W10sImlhdCI6MTc0NDE5NDk5MCwiZXhwIjoxNzQ0MjQzMjAwfQ.sNyqW-wKoO3k14bw_iw9SsrKg-og8gV2qBcbi33F76A";

  static Future<Response> fetchUserCards(String uuid) async {
    developer.log("method 2 reached==========>");
    final url =
        Uri.https(AppUrl.baseEndpoint, AppUrl.getAllCardsById, {'uuid': uuid});
    developer.log("=========>Full endpoint ===>$url");
    final response = await get(url, headers: {
      "Authorization": "Bearer $bearerToken",
      "Content-type": "application/json",
      "Accept": "application/json",
    });
    return response;
  }
}
