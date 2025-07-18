class AppUrl {
  static const String liveUrl = "https://alltanzaniaecard.onrender.com";
  static const String localhost = "http://192.168.1.150:8080";
  // static const String localhost = "http://localhost:8080";

  // authentication endpoints here
  static const String baseEndpoint = localhost;
  static const String loginUrl = "$baseEndpoint/auth/login";
  static const String registerUrl = "$baseEndpoint/auth/register";
  static const String forgotPassword = "$baseEndpoint/auth/forgotPassword";
  static const String verifyWithOtp =
      "$baseEndpoint/auth/activate-account?otp=";

  // card endpoints here
  static String getCardDetails = "$baseEndpoint/api/v1/cards/card-by-uuid";
  static String getAllCardsById = "$baseEndpoint/api/v1/cards/user-cards";
  static var updateCard = "$baseEndpoint/api/v1/cards/update";
  static var deleteCard = "$baseEndpoint/api/v1/cards/delete";
  static var saveCard = "$baseEndpoint/api/saved-cards/save-card";
  static var getPeopleWhoSavedCard = '$baseEndpoint/api/saved-cards/card';
  static String createCard = '$baseEndpoint/api/v1/cards/create';
  static String getAllUserSavedCards = '$baseEndpoint/api/saved-cards/user';

  // notification endpoints
  static String getUserNotification = '$baseEndpoint/api/notifications/user';
  static String sendNotification =
      '$baseEndpoint/api/notifications/send-notifications';
  static String markAsRead = '$baseEndpoint/api/notifications/mark-read';

  // deviceProximity requests
  static const String getNearbyProximalDevices =
      '$baseEndpoint/api/v1/device-proximity/search-with-json-body';
}
