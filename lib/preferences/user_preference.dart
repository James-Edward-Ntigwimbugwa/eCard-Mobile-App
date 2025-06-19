// Fixed UserPreferences class
import 'package:ecard_app/modals/user_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class UserPreferences {
  // Make this a singleton for consistency
  static final UserPreferences _instance = UserPreferences._internal();

  factory UserPreferences() {
    return _instance;
  }

  UserPreferences._internal();

  // Fixed saveUser method to be static and properly await all operations
  static Future<bool> saveUser(User user) async {
    try {
      developer.log("Saving user data to preferences: ${user.toString()}");
      final prefs = await SharedPreferences.getInstance();

      // Store fields with null checks - fixed to save all fields properly
      await prefs.setString("userId", user.id ?? '');
      await prefs.setString("userUuid", user.uuid ?? '');
      await prefs.setString("username", user.username ?? '');
      await prefs.setString(
          "userEmail", user.email ?? ''); // Fixed: now saves email
      await prefs.setString("phone", user.phone ?? '');
      await prefs.setString("userType",
          user.userType ?? ''); // Fixed: changed from "type" to "userType"
      await prefs.setString("accessToken", user.accessToken ?? '');
      await prefs.setString("refreshToken", user.refreshToken ?? '');
      await prefs.setString("firstName", user.firstName ?? '');
      await prefs.setString("lastName", user.lastName ?? '');
      await prefs.setString("jobTitle", user.jobTitle ?? '');
      await prefs.setString("companyName", user.companyName ?? '');
      await prefs.setString(
          "tokenType", user.tokenType ?? ''); // Added tokenType
      await prefs.setString(
          "lastLogin", user.lastLogin ?? ''); // Added lastLogin

      developer.log("User data saved successfully");
      return true;
    } catch (e, stack) {
      developer.log("Error saving user: $e", stackTrace: stack);
      return false;
    }
  }

  Future<User> getUser() async {
    User user = User();
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if required data exists
      final String? accessToken = prefs.getString("accessToken");
      final String? userId = prefs.getString("userId");

      // Early return if essential data is missing - but still return empty user object
      if (accessToken == null ||
          accessToken.isEmpty ||
          userId == null ||
          userId.isEmpty) {
        developer.log(
            "No valid user data found in preferences ======> user_preferences");
        return user; // Return empty user object instead of continuing
      }

      // Build user object from preferences
      user = User(
        id: userId,
        uuid: prefs.getString("userUuid"),
        username: prefs.getString("username"),
        email: prefs.getString("userEmail"), // Fixed: retrieves email properly
        phone: prefs.getString("phone"),
        userType: prefs
            .getString("userType"), // Fixed: changed from "type" to "userType"
        accessToken: accessToken,
        refreshToken: prefs.getString("refreshToken"),
        firstName: prefs.getString("firstName"),
        lastName: prefs.getString("lastName"),
        jobTitle: prefs.getString("jobTitle"),
        companyName: prefs.getString("companyName"),
        tokenType: prefs.getString("tokenType"), // Added tokenType
        lastLogin: prefs.getString("lastLogin"), // Added lastLogin
      );

      developer.log("Retrieved user from preferences: ${user.toString()}");
      return user;
    } catch (e, stack) {
      developer.log("Error retrieving user: $e", stackTrace: stack);
      return user; // Return empty user object on error
    }
  }

  static Future<bool> removeUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Clear all user-related data
      await prefs.remove("userId");
      await prefs.remove("userUuid");
      await prefs.remove("username");
      await prefs.remove("userEmail");
      await prefs.remove("phone");
      await prefs
          .remove("userType"); // Fixed: changed from "type" to "userType"
      await prefs.remove("accessToken");
      await prefs.remove("refreshToken");
      await prefs.remove("firstName");
      await prefs.remove("lastName");
      await prefs.remove("jobTitle");
      await prefs.remove("companyName");
      await prefs.remove("tokenType"); // Added tokenType removal
      await prefs.remove("lastLogin"); // Added lastLogin removal

      developer.log("User data cleared from preferences");
      return true;
    } catch (e, stack) {
      developer.log("Error removing user: $e", stackTrace: stack);
      return false;
    }
  }

  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("accessToken");
      developer.log(
          "Retrieved token: ${token != null && token.isNotEmpty ? 'Valid token' : 'Null/Empty token'}");
      return token;
    } catch (e, stack) {
      developer.log("Error retrieving token: $e", stackTrace: stack);
      return null;
    }
  }

  // Helper method to check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("userId");

      return token != null &&
          token.isNotEmpty &&
          userId != null &&
          userId.isNotEmpty;
    } catch (e) {
      developer.log("Error checking login status: $e");
      return false;
    }
  }
}
