class AppUrl {
  static const String liveUrl = "https://alltanzaniaecard.onrender.com";
  static const String localhost = "192.168.1.163:8080";

  static const String baseEndpoint = localhost;
  static const String loginUrl = "$baseEndpoint/auth/login";
  static String getAllCardsById = "/api/v1/cards/user-cards";
  static const String registerUrl = "$baseEndpoint/auth/register";
  static const String forgotPassword = "$baseEndpoint/auth/forgotPassword";

}
