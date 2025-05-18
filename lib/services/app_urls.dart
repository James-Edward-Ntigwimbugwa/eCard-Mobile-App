class AppUrl {
  static const String liveUrl = "https://alltanzaniaecard.onrender.com";

  static const String localhost = "http://192.168.1.12:8080";

  static const String baseEndpoint = localhost;
  static const String loginUrl = "$baseEndpoint/auth";
  static String getAllCardsById = "$baseEndpoint/api/v1/cards/user-cards";
  static const String registerUrl = "$baseEndpoint/auth";
  static const String forgotPassword = "$baseEndpoint/auth/forgotPassword";
  static var updateCard;

  // ignore: prefer_typing_uninitialized_variables
  static var deleteCard;

  static String createCard = '$baseEndpoint/api/v1/cards/create';
}
