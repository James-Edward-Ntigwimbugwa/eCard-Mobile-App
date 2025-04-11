import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool pushNotificationsEnabled = true;
  bool darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 0, 132, 112), // Dark green-black
              // Theme.of(context).primaryColor.withOpacity(0.5), // Dark green-black
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar with back button
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),

              // Profile section
              Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      image: const DecorationImage(
                        image: NetworkImage('/api/placeholder/80/80'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Dreev Stitches',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Lagos Nigeria',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Settings content
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Account Settings label
                      const Text(
                        'Account Settings',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Settings items
                      SettingItem(
                        title: 'Edit profile',
                        hasArrow: true,
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      SettingItem(
                        title: 'Change password',
                        hasArrow: true,
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      SettingItem(
                        title: 'Add a payment method',
                        icon: Icons.add,
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      SettingToggleItem(
                        title: 'Push notifications',
                        value: pushNotificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            pushNotificationsEnabled = value;
                          });
                        },
                        activeColor: const Color(0xFF1E8B3B),
                      ),
                      const Divider(height: 1),
                      SettingToggleItem(
                        title: 'Dark mode',
                        value: darkModeEnabled,
                        onChanged: (value) {
                          setState(() {
                            darkModeEnabled = value;
                          });
                        },
                        activeColor: const Color(0xFF1E8B3B),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingItem extends StatelessWidget {
  final String title;
  final IconData? icon;
  final bool hasArrow;
  final VoidCallback onTap;

  const SettingItem({
    super.key,
    required this.title,
    this.icon,
    this.hasArrow = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            if (icon != null)
              Icon(icon, color: Colors.grey),
            if (hasArrow)
              const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class SettingToggleItem extends StatelessWidget {
  final String title;
  final bool value;
  final Function(bool) onChanged;
  final Color activeColor;

  const SettingToggleItem({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: activeColor,
          ),
        ],
      ),
    );
  }
}