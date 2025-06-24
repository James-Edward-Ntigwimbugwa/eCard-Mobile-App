import 'package:ecard_app/components/custom_widgets.dart';
import 'package:ecard_app/preferences/user_preference.dart';
import 'package:ecard_app/utils/resources/images/images.dart';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool pushNotificationEnabled = false;
  bool emailNotificationsEnabled = false;
  bool cardScanAlertsEnabled = false;
  bool biometricLoginEnabled = false;
  bool darkModeEnabled = false;

  // User data fields
  String userName = '';
  String userJobTitle = '';
  String userEmail = '';
  String userDepartment = '';
  String userEmployeeId = '';
  String userPhone = '';
  String userLocation = 'Mabibo, Dar es Salaam'; // Default location

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userPreferences = UserPreferences();
      final user = await userPreferences.getUser();

      setState(() {
        userName = _formatName(user.firstName, user.lastName);
        userJobTitle = user.jobTitle ?? 'Not specified';
        userEmail = user.email ?? 'Not specified';
        userDepartment =
            'Engineering'; // You might want to add this to your User model
        userEmployeeId = user.id ?? 'N/A';
        userPhone = user.phone ?? 'Not specified';
      });
      developer.log("Loaded user data for settings screen: $userName");

      // Load other settings from SharedPreferences if needed
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        pushNotificationEnabled = prefs.getBool('pushNotifications') ?? false;
        emailNotificationsEnabled =
            prefs.getBool('emailNotifications') ?? false;
        cardScanAlertsEnabled = prefs.getBool('cardScanAlerts') ?? false;
        biometricLoginEnabled = prefs.getBool('biometricLogin') ?? false;
      });
    } catch (e) {
      developer.log("Error loading user data: $e");
    }
  }

  String _formatName(String? firstName, String? lastName) {
    if (firstName != null && firstName.isNotEmpty) {
      if (lastName != null && lastName.isNotEmpty) {
        return '$firstName $lastName';
      }
      return firstName;
    }
    return 'User';
  }

  void showLogoutDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).highlightColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          height: 220,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HeaderBoldWidget(
                  text: "Are you Sure?",
                  color: Theme.of(context).primaryColor,
                  size: '20.0'),
              const SizedBox(height: 12),
              Text(
                "Upon logout your session will be restored and required to login again",
                textAlign: TextAlign.center,
                style: GoogleFonts.aBeeZee(
                    textStyle: TextStyle(
                        color: Theme.of(context).indicatorColor,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: HeaderBoldWidget(
                            text: "Cancel",
                            color: Theme.of(context).primaryColor,
                            size: '18.0')),
                  ),
                  SizedBox(
                    height: 24,
                    child: VerticalDivider(
                        width: 20, color: Theme.of(context).indicatorColor),
                  ),
                  Expanded(
                    child: TextButton(
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          prefs.remove("accessToken");
                          prefs.remove("userUuid");
                          prefs.remove("userId");
                          prefs.remove("username");
                          prefs.remove("phone");
                          prefs.remove("userEmail");
                          prefs.remove("type");
                          UserPreferences.removeUser();
                          developer.log(
                              "======> ${prefs.getString('accessToken')} , ======> ${prefs.getString('username')}");
                          //predicate: This is a function that takes a Route and returns a boolean.
                          // It's called for each route in the stack, and if it returns true,
                          // the route will be removed.
                          //In this case (route) => false, we are telling it to remove all routes
                          //so it go back to the auth screen.
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/auth', (route) => false);
                        },
                        child: HeaderBoldWidget(
                            text: "Logout",
                            color: Theme.of(context).primaryColor,
                            size: '18.0')),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).highlightColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).highlightColor,
        elevation: 0,
        title: Text(
          'App Settings',
          style: TextStyle(
            color: Theme.of(context).indicatorColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Card
              _buildProfileCard(),
              const SizedBox(height: 24),

              // Theme Settings
              _buildSectionTitle('Theme'),
              _buildThemeSelector(),
              const SizedBox(height: 16),

              // Language Settings
              _buildSectionTitle('Language'),
              _buildLanguageSelector(),
              const SizedBox(height: 16),

              // Sound Effects
              _buildSettingWithSwitch(
                'Sound Effects',
                Icons.volume_up_outlined,
                true,
                (value) {
                  // Implement sound effects toggle
                },
              ),
              const Divider(
                height: 1,
              ),

              // Vibration
              _buildSettingWithSwitch(
                'Vibration',
                Icons.vibration,
                true,
                (value) {
                  // Implement vibration toggle
                },
              ),

              const SizedBox(height: 16),

              // Account Section
              _buildSectionTitle('Account'),

              // Security Settings
              _buildSettingItem(
                'Security Settings',
                Icons.security_outlined,
                onTap: () {
                  // Navigate to security settings
                },
              ),

              const Divider(
                height: 1,
              ),
              // Change Password
              _buildSettingItem(
                'Change Password',
                Icons.key_outlined,
                onTap: () {
                  Navigator.pushNamed(context, '/change-password');
                },
              ),
              const Divider(
                height: 1,
              ),

              // Two-Factor Authentication
              _buildSettingWithSwitch(
                'Two-Factor Authentication',
                Icons.phone_android_outlined,
                false,
                (value) {
                  // Implement 2FA toggle
                },
              ),

              const Divider(
                height: 1,
              ),
              // Biometric Login
              _buildSettingWithSwitch(
                'Biometric Login',
                Icons.fingerprint,
                biometricLoginEnabled,
                (value) {
                  setState(() {
                    biometricLoginEnabled = value;
                    // Save the preference
                    SharedPreferences.getInstance().then((prefs) {
                      prefs.setBool('biometricLogin', value);
                    });
                  });
                },
              ),

              const SizedBox(height: 16),

              // Notification Settings
              _buildSectionTitle('Notification Preferences'),

              // Push Notifications
              _buildSettingWithSwitch(
                'Push Notifications',
                Icons.notifications_none_outlined,
                pushNotificationEnabled,
                (value) {
                  setState(() {
                    pushNotificationEnabled = value;
                    // Save the preference
                    SharedPreferences.getInstance().then((prefs) {
                      prefs.setBool('pushNotifications', value);
                    });
                  });
                },
              ),
              const Divider(
                height: 1,
              ),
              // Email Notifications
              _buildSettingWithSwitch(
                'Email Notifications',
                Icons.email_outlined,
                emailNotificationsEnabled,
                (value) {
                  setState(() {
                    emailNotificationsEnabled = value;
                    // Save the preference
                    SharedPreferences.getInstance().then((prefs) {
                      prefs.setBool('emailNotifications', value);
                    });
                  });
                },
              ),
              const Divider(
                height: 1,
              ),

              // Card Scan Alerts
              _buildSettingWithSwitch(
                'Card Scan Alerts',
                Icons.qr_code_scanner_outlined,
                cardScanAlertsEnabled,
                (value) {
                  setState(() {
                    cardScanAlertsEnabled = value;
                    // Save the preference
                    SharedPreferences.getInstance().then((prefs) {
                      prefs.setBool('cardScanAlerts', value);
                    });
                  });
                },
              ),

              const Divider(
                height: 1,
              ),
              const SizedBox(height: 16),

              // Help & Support
              _buildSettingItem(
                'Help & Support',
                Icons.help_outline,
                onTap: () {
                  // Navigate to help & support
                },
              ),

              const Divider(
                height: 1,
              ),

              // About
              _buildSettingItem(
                'About',
                Icons.info_outline,
                subtitle: 'v2.1.1',
                onTap: () {
                  // Navigate to about screen
                },
              ),

              const Divider(
                height: 1,
              ),
              // Terms & Privacy
              _buildSettingItem(
                'Terms & Privacy',
                Icons.article_outlined,
                onTap: () {
                  // Navigate to terms & privacy
                },
              ),

              const SizedBox(height: 24),

              // Logout Button
              _buildLogoutButton(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).secondaryHeaderColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile info row with responsive layout
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage(Images.profileImage),
              ),
              const SizedBox(width: 16),
              // User info with flexible layout
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Theme.of(context).indicatorColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    NormalHeaderWidget(
                      text: userJobTitle,
                      color: Theme.of(context).hintColor.withOpacity(0.6),
                      size: '14.0',
                    ),
                    const SizedBox(height: 6),
                    // Row for buttons with flexible layout
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          icon: Icon(
                            Icons.edit,
                            size: 14,
                            color: Theme.of(context).indicatorColor,
                          ),
                          label: Text(
                            'Edit Profile',
                            style: TextStyle(
                              color: Theme.of(context).indicatorColor,
                            ),
                          ),
                          onPressed: () {
                            // Navigate to edit profile
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Theme.of(context).highlightColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            minimumSize: const Size(0, 32),
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          icon: Icon(
                            Icons.location_on,
                            size: 14,
                            color: Theme.of(context).indicatorColor,
                          ),
                          label: Text(
                            'Your location',
                            style: TextStyle(
                              color: Theme.of(context).indicatorColor,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/location-picker');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Theme.of(context).highlightColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            minimumSize: const Size(0, 32),
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Location display with text overflow handling
                    Text(
                      userLocation,
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            Theme.of(context).indicatorColor.withOpacity(0.6),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Contact information layout (unchanged)
          Row(
            children: [
              Expanded(
                child: _buildInfoItem('Email', userEmail),
              ),
              Expanded(
                child: _buildInfoItem('Department', userDepartment),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem('Employee ID', userEmployeeId),
              ),
              Expanded(
                child: _buildInfoItem('Phone', userPhone),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).hintColor.withOpacity(0.6),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).indicatorColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).indicatorColor,
            ),
          ),
          const Spacer(),
          if (title == 'Theme' || title == 'Language')
            Text(
              title == 'Theme' ? 'Light' : 'English',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).indicatorColor.withOpacity(0.6),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildThemeSelector() {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return Container(
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).secondaryHeaderColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (themeNotifier.isDarkMode) {
                      themeNotifier.toggleTheme();
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: !themeNotifier.isDarkMode
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Light',
                      style: TextStyle(
                        color: Theme.of(context).indicatorColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (!themeNotifier.isDarkMode) {
                      themeNotifier.toggleTheme();
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: themeNotifier.isDarkMode
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Dark',
                      style: TextStyle(
                        color: Theme.of(context).indicatorColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    'System',
                    style: TextStyle(
                      color: Theme.of(context).indicatorColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).secondaryHeaderColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                'English',
                style: TextStyle(
                  color: Theme.of(context).indicatorColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: Text(
                'Spanish',
                style: TextStyle(
                  color: Theme.of(context).indicatorColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: Text(
                'French',
                style: TextStyle(
                  color: Theme.of(context).indicatorColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: Text(
                'German',
                style: TextStyle(
                  color: Theme.of(context).indicatorColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String title, IconData icon,
      {String? subtitle, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).indicatorColor,
                ),
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).indicatorColor,
                ),
              ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).indicatorColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingWithSwitch(
      String title, IconData icon, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).indicatorColor,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).highlightColor,
            activeTrackColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return InkWell(
      onTap: showLogoutDialog,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout,
              color: Colors.red,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Logout',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
