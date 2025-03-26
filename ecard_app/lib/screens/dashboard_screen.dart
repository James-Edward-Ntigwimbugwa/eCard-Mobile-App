import 'dart:io';
import 'package:ecard_app/providers/screen_index_provider.dart';
import 'package:ecard_app/screens/subScreens/main_screen_tab.dart';
import 'package:ecard_app/screens/subScreens/nearby_screen.dart';
import 'package:ecard_app/screens/subScreens/scanning_screen.dart';
import 'package:ecard_app/screens/subScreens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../modals/user_modal.dart';
import '../router/router_path.dart';
import 'package:camera/camera.dart';

class DashboardPage extends StatefulWidget {
  final User user;
  const DashboardPage({super.key, required this.user});
  @override
  State<StatefulWidget> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  // TabController? tabController;
  // int currentTab = 0;remote: Support for password authentication was removed on August 13, 2021.

  String tabLocation = RouterPath.dashboard;
  late StatefulWidget app;
  late CameraController camera;
  Future checkAvailable() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final cameras = await availableCameras();
      final firstCamera = cameras.first;
      // app = ScanningScreen(camera: firstCamera);
    }
  }

  List<dynamic> screens = [
    MainScreenTab(),
    NearbyScreen(),
    ScanningScreen(),
    SettingsScreen()
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Color.fromARGB(255, 255, 255, 255),
    ));

    final screenIndexProvider = Provider.of<ScreenIndexProvider>(context);
    int _currentIndex = screenIndexProvider.currentScreenIndex;
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).highlightColor,
          showSelectedLabels: false,
          selectedItemColor: Theme.of(context).primaryColor,
          showUnselectedLabels: false,
          elevation: 1.5,
          currentIndex: _currentIndex,
          onTap: (value) => screenIndexProvider.setCurrentIndex(value),
          items: [
            BottomNavigationBarItem(
                icon: Icon(
                    (_currentIndex == 0 ? Icons.home : Icons.home_outlined)),
                label: ''),
            BottomNavigationBarItem(
                icon: Icon(_currentIndex == 1
                    ? Icons.scanner
                    : Icons.scanner_outlined),
                label: ''),
            BottomNavigationBarItem(
                icon: Icon(_currentIndex == 2
                    ? Icons.signal_wifi_4_bar_outlined
                    : Icons.signal_wifi_4_bar),
                label: ''),
            BottomNavigationBarItem(
                icon: Icon(_currentIndex == 3
                    ? Icons.settings
                    : Icons.settings_outlined),
                label: '')
          ]),
      body: screens[_currentIndex],
    );
  }
}
