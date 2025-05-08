import 'package:ecard_app/modals/user_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class UserPreferences {
  static Future<bool> saveUser(User user) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("userId", user.id ?? '');
      await prefs.setString("userUuid", user.uuid ?? '');
      await prefs.setString("username", user.username ?? '');
      await prefs.setString("userEmail", user.email ?? '');
      await prefs.setString("phone", user.phone ?? '');
      await prefs.setString("type", user.userType ?? '');
      await prefs.setString("accessToken", user.accessToken ?? '');
      await prefs.setString("refreshToken", user.refreshToken ?? '');

      return prefs.commit();
    } catch (e) {
      developer.log("Error saving user $e");
      return false;
    }
  }

  Future<User> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? userId = prefs.getString("userId");
    String? uuid = prefs.getString("userUuid");
    String? username = prefs.getString("username");
    String? userEmail = prefs.getString("userEmail");
    String? phoneNumber = prefs.getString("phone");
    String? userType = prefs.getString("type");
    String? accessToken = prefs.getString("accessToken");
    String? refreshToken = prefs.getString("refreshToken");

    return User(
        id: userId.toString(),
        uuid: uuid,
        username: username,
        email: userEmail,
        phone: phoneNumber,
        userType: userType,
        accessToken: accessToken,
        refreshToken: refreshToken);
  }

  static void removeUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("userId");
    prefs.remove("username");
    prefs.remove('userUuid');
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
