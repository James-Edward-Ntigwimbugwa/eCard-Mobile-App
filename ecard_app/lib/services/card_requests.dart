import 'package:ecard_app/services/app_urls.dart';
import 'package:http/http.dart';
import 'dart:developer' as developer;

class CardRequests {
  static Future<Response> fetchUserCards(String uuid) async {
    developer.log("method 2 reached==========>");
    final url = Uri.http(AppUrl.baseEndpoint, AppUrl.getAllCardsById, {'uuid':uuid});
    developer.log("=========>Full endpoint ===>$url");
    final response = await get(url, headers: {
      "Authorization" : "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJKYW1lc0Vkd2FyZDIwMDEiLCJyb2xlcyI6W10sImlhdCI6MTc0MzgwMTQxNSwiZXhwIjoxNzQzODg2ODAwfQ.M_yrL-q-YwPI0zhvyJGRaBKTbZX2av20Z_F_dD1VYfo",
      "Content-type": "application/json",
      "Accept": "application/json",
    });
    return response;
  }
}
