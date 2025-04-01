class AppUrl {
  static const String liveUrl = "https://alltanzaniaecard.onrender.com";
  static const String localhost = "http://localhost:8080";

  static const String baseEndpoint = liveUrl;
  static const String loginUrl = "$baseEndpoint/auth";
  static String getAllCardsById =
      "$baseEndpoint/api/v1/cards/card-by-uuid?uuid={}";
  static const String registerUrl = "$baseEndpoint/auth/register";
  static const String forgotPassword = "$baseEndpoint/auth/forgotPassword";
}
