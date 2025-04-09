import 'package:ecard_app/modals/user_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static Future<bool> saveUser(User user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setInt("userId", user.id.toString() as int);
    prefs.setString("username", user.username.toString());
    prefs.setString("userEmail", user.email.toString());
    prefs.setString("phone", user.phone.toString());
    prefs.setString("type", user.userType.toString());
    prefs.setString("accessToken", user.accessToken.toString());
    prefs.setString("refreshToken", user.refreshToken.toString());

    return prefs.commit();
  }

  Future<User> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int? userId = prefs.getInt("userId");
    String? username = prefs.getString("username");
    String? userEmail = prefs.getString("userEmail");
    String? phoneNumber = prefs.getString("phone");
    String? userType = prefs.getString("type");
    String? accessToken = prefs.getString("accessToken");
    String? refreshToken = prefs.getString("refreshToken");

    return User(
        id: userId.toString(),
        username: username,
        email: userEmail,
        phone: phoneNumber,
        userType: userType,
        accessToken: accessToken,
        refreshToken: refreshToken);
  }

  void removeUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.remove("username");
    prefs.remove("phone");
    prefs.remove("userEmail");
    prefs.remove("type");
    prefs.remove("accessToken");
  }

  Future<String?> getToken(args) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("accessToken");
    return token;
  }
}
