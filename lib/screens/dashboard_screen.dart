import 'dart:io';
import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:ecard_app/providers/screen_index_provider.dart';
import 'package:ecard_app/screens/tabs/main_screen_tab.dart';
import 'package:ecard_app/screens/tabs/nearby_screen.dart';
import 'package:ecard_app/screens/tabs/scanning_screen.dart';
import 'package:ecard_app/screens/tabs/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../modals/user_modal.dart';
import '../router/router_path.dart';
import 'package:camera/camera.dart';

import 'tabs/messages_screen.dart';

class DashboardPage extends StatefulWidget {
  final User user;
  const DashboardPage({super.key, required this.user});
  @override
  State<StatefulWidget> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {


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
    QRScannerScreen(),
    ScanningScreen(),
    MessagesScreen(),
    SettingsScreen()
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Color.fromARGB(255, 255, 255, 255),
    ));

    final screenIndexProvider = Provider.of<ScreenIndexProvider>(context);
    int currentIndex = screenIndexProvider.currentScreenIndex;
    return Scaffold(
      extendBodyBehindAppBar: true,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).highlightColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.7),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: CircleNavBar(
          color: Theme.of(context)
              .highlightColor, // Use highlightColor instead of transparent
          circleShadowColor: Theme.of(context).primaryColor.withOpacity(0.3),
          circleColor: Theme.of(context).primaryColor,
          height: 60,
          elevation:
          0, // Keep elevation at 0 to avoid conflict with container shadow
          shadowColor: Colors.transparent,
          circleWidth: 40,
          onTap: (value) => screenIndexProvider.setCurrentIndex(value),
          activeIcons: [
            Icon(FontAwesomeIcons.home,
                size: 18, // Reduced icon size
                color: currentIndex == 0
                    ? Theme.of(context).highlightColor
                    : Theme.of(context).primaryColor),
            Icon(FontAwesomeIcons.qrcode,
                size: 18, // Reduced icon size
                color: currentIndex == 1
                    ? Theme.of(context).highlightColor
                    : Theme.of(context).primaryColor),
            Icon(FontAwesomeIcons.rss, // Changed to hotspot/scanning icon
                size: 18, // Reduced icon size
                color: currentIndex == 2
                    ? Theme.of(context).highlightColor
                    : Theme.of(context).primaryColor),
            Icon(FontAwesomeIcons.message, // Messages icon
                size: 18, // Reduced icon size
                color: currentIndex == 3
                    ? Theme.of(context).highlightColor
                    : Theme.of(context).primaryColor),
            Icon(FontAwesomeIcons.gear,
                size: 18, // Reduced icon size
                color: currentIndex == 4
                    ? Theme.of(context).highlightColor
                    : Theme.of(context).primaryColor),
          ],
          activeIndex: currentIndex,
          inactiveIcons: [
            Icon(FontAwesomeIcons.home,
                size: 18, // Reduced icon size
                color: currentIndex == 0
                    ? Theme.of(context).highlightColor
                    : Theme.of(context).primaryColor),
            Icon(FontAwesomeIcons.qrcode,
                size: 18, // Reduced icon size
                color: currentIndex == 1
                    ? Theme.of(context).highlightColor
                    : Theme.of(context).primaryColor),
            Icon(FontAwesomeIcons.rss, // Changed to hotspot/scanning icon
                size: 18, // Reduced icon size
                color: currentIndex == 2
                    ? Theme.of(context).highlightColor
                    : Theme.of(context).primaryColor),
            Icon(FontAwesomeIcons.message, // Messages icon
                size: 18, // Reduced icon size
                color: currentIndex == 3
                    ? Theme.of(context).highlightColor
                    : Theme.of(context).primaryColor),
            Icon(FontAwesomeIcons.gear,
                size: 18, // Reduced icon size
                color: currentIndex == 4
                    ? Theme.of(context).highlightColor
                    : Theme.of(context).primaryColor),
          ],
        ),
      ),
      body: screens[currentIndex],
    );
  }
}