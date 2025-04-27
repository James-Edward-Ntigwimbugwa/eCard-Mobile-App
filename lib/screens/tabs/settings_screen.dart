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
  bool darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    void showBottomDialog() {
      showModalBottomSheet(
        context: context,
        isScrollControlled:
            true, // Allows the sheet to expand beyond default height
        backgroundColor:
            Colors.transparent, // Makes the sheet background transparent
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

                            Navigator.pushReplacementNamed(context, '/auth');
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

    return Scaffold(
      backgroundColor: Theme.of(context).highlightColor,
      body: Column(
        children: [
          // Profile Section with Gradient Background
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: <Color>[
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.98)
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Theme.of(context).cardColor, width: 2),
                      image: DecorationImage(
                          image: AssetImage(Images.profileImage),
                          fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 20),
                  NormalHeaderWidget(
                      text: 'James Edward',
                      color: Theme.of(context).highlightColor,
                      size: '18.0'),
                  const SizedBox(height: 4),
                  NormalHeaderWidget(
                      text: 'Mabibo , Dar es Salaam',
                      color: Theme.of(context).highlightColor.withAlpha(2),
                      size: '14'),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Settings Section with White Background
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).highlightColor,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    topLeft: Radius.circular(30)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeaderBoldWidget(
                      text: "Settings",
                      color: Theme.of(context).indicatorColor,
                      size: '24.0'),
                  const SizedBox(height: 20),
                  NormalHeaderWidget(
                      text: 'AccountSettings',
                      color: Theme.of(context).indicatorColor,
                      size: '20.0'),
                  const SizedBox(height: 20),
                  SettingItem(
                      title: 'Edit Profile', hasArrow: true, onTap: () {}),
                  const Divider(height: 1),
                  SettingItem(
                      title: 'ChangePassword', onTap: () {
                        Navigator.pushNamed(context, '/change-password');
                  }, hasArrow: true),
                  const Divider(height: 1),
                  SettingItem(
                      title: 'Add Payment Method',
                      onTap: () {},
                      hasArrow: true),
                  const Divider(height: 1),
                  SettingToggleItem(
                    title: 'Push Notifications',
                    onChanged: (value) {
                      setState(() {
                        pushNotificationEnabled = value;
                      });
                    },
                    activeColor: Theme.of(context).primaryColor,
                    value: pushNotificationEnabled,
                  ),
                  const Divider(height: 1),
                  Consumer<ThemeNotifier>(
                    builder: (context, themeNotifier, child) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: NormalHeaderWidget(
                                  text: "Dark Mode",
                                  color: Theme.of(context).indicatorColor,
                                  size: '16.0'),
                            ),
                            Switch(
                              value: themeNotifier.isDarkMode,
                              onChanged: (value) {
                                setState(() {
                                  darkModeEnabled = value;
                                });
                                themeNotifier.toggleTheme();
                              },
                              activeColor: Theme.of(context).primaryColor,
                              activeTrackColor: Theme.of(context).cardColor,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  SettingItem(
                      title: 'Logout',
                      onTap: showBottomDialog,
                      hasArrow: false,
                      icon: Icons.logout_rounded),
                  const Divider(height: 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingItem extends StatelessWidget {
  final String title;
  final IconData? icon;
  final VoidCallback onTap;
  final bool hasArrow;

  const SettingItem(
      {super.key,
      required this.title,
      this.icon,
      required this.onTap,
      required this.hasArrow});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          children: [
            Expanded(
                child: NormalHeaderWidget(
                    text: title,
                    color: Theme.of(context).indicatorColor,
                    size: '16.0')),
            if (icon != null)
              Icon(
                icon,
                color: Theme.of(context).indicatorColor,
              ),
            if (hasArrow)
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).indicatorColor,
              )
          ],
        ),
      ),
    );
  }
}

class SettingToggleItem extends StatelessWidget {
  final String title;
  final Function(bool) onChanged;
  final Color activeColor;
  final bool value;
  const SettingToggleItem(
      {super.key,
      required this.title,
      required this.onChanged,
      required this.activeColor,
      required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
              child: NormalHeaderWidget(
                  text: title,
                  color: Theme.of(context).indicatorColor,
                  size: '16.0')),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).canvasColor,
            activeTrackColor: activeColor,
          )
        ],
      ),
    );
  }
}
