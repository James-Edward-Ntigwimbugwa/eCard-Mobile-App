class AppUrl {
  static const String liveUrl = "https://alltanzaniaecard.onrender.com";

  static const String localhost = "http://192.168.1.151:8080";

  // authentication endpoints here
  static const String baseEndpoint = localhost;
  static const String loginUrl = "$baseEndpoint/auth/login";
  static const String registerUrl = "$baseEndpoint/auth/register";
  static const String forgotPassword = "$baseEndpoint/auth/forgotPassword";
  static const String verifyWithOtp = "$baseEndpoint/auth/activate-account?otp=";


  // card endpoints here
  static String getCardDetails = "$baseEndpoint/api/v1/cards/card-by-uuid";
  static String getAllCardsById = "$baseEndpoint/api/v1/cards/user-cards";
  static var updateCard = "$baseEndpoint/api/v1/cards/update";
  static var deleteCard = "$baseEndpoint/api/v1/cards/delete";
  static var saveCard = "$baseEndpoint/api/v1/saved-cards/save-card";

  static String createCard = '$baseEndpoint/api/v1/cards/create';
}

