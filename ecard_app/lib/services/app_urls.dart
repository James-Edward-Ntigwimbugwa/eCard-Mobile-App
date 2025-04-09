class AppUrl {
  static const String liveUrl = "alltanzaniaecard.onrender.com";
  static const String localhost = "192.168.1.165:8080";

  static const String baseEndpoint = liveUrl;
  static const String loginUrl = "$baseEndpoint/auth/login";
  static String getAllCardsById = "/api/v1/cards/user-cards";
  static const String registerUrl = "$baseEndpoint/auth/register";
  static const String forgotPassword = "$baseEndpoint/auth/forgotPassword";
}
