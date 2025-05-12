// user_preference.dart
import 'package:ecard_app/modals/user_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class UserPreferences {
  static Future<bool> saveUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Safely save fields with null-aware
      await prefs.setString("userId", user.id ?? '');
      await prefs.setString("userUuid", user.uuid ?? '');
      await prefs.setString("username", user.username ?? '');
      await prefs.setString("userEmail", user.email ?? '');
      await prefs.setString("phone", user.phone ?? '');
      await prefs.setString("type", user.userType ?? '');
      await prefs.setString("accessToken", user.accessToken ?? '');
      await prefs.setString("refreshToken", user.refreshToken ?? '');
      return await prefs.commit();
    } catch (e, stack) {
      developer.log("Error saving user: $e", stackTrace: stack);
      return false;
    }
  }

  Future<User?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final user = User(
        id: prefs.getString("userId") ?? '',
        uuid: prefs.getString("userUuid"),
        username: prefs.getString("username"),
        email: prefs.getString("userEmail"),
        phone: prefs.getString("phone"),
        userType: prefs.getString("type"),
        accessToken: prefs.getString("accessToken"),
        refreshToken: prefs.getString("refreshToken"),
      );
      // If essential fields are missing, return null
      if (user.id!.isEmpty || user.accessToken == null) {
        return null;
      }
      return user;
    } catch (e, stack) {
      developer.log("Error retrieving user: $e", stackTrace: stack);
      return null;
    }
  }

  static Future<bool> removeUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove("userId");
      await prefs.remove("userUuid");
      await prefs.remove("username");
      await prefs.remove("userEmail");
      await prefs.remove("phone");
      await prefs.remove("type");
      await prefs.remove("accessToken");
      await prefs.remove("refreshToken");
      return await prefs.commit();
    } catch (e, stack) {
      developer.log("Error removing user: $e", stackTrace: stack);
      return false;
    }
  }

  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString("accessToken");
    } catch (e, stack) {
      developer.log("Error retrieving token: $e", stackTrace: stack);
      return null;
    }
  }
}
