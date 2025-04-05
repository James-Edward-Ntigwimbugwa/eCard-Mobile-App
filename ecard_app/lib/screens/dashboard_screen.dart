import 'dart:io';
import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:ecard_app/providers/screen_index_provider.dart';
import 'package:ecard_app/screens/subScreens/main_screen_tab.dart';
import 'package:ecard_app/screens/subScreens/nearby_screen.dart';
import 'package:ecard_app/screens/subScreens/scanning_screen.dart';
import 'package:ecard_app/screens/subScreens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
    int currentIndex = screenIndexProvider.currentScreenIndex;
    return Scaffold(
      bottomNavigationBar: CircleNavBar(
        color: Theme.of(context).highlightColor,
        circleShadowColor: Theme.of(context).primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 1.0),
        circleColor: Theme.of(context).primaryColor,
        height: 60,
        elevation: 10,
        shadowColor: Theme.of(context).primaryColor,
        circleWidth: 50,
        cornerRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        onTap: (value) => screenIndexProvider.setCurrentIndex(value),
        activeIcons: [
          Icon((FontAwesomeIcons.home),
              color: currentIndex == 0
                  ? Theme.of(context).highlightColor
                  : Theme.of(context).primaryColor),
          Icon((FontAwesomeIcons.qrcode),
              color: currentIndex == 1
                  ? Theme.of(context).highlightColor
                  : Theme.of(context).primaryColor),
          Icon((FontAwesomeIcons.wifi),
              color: currentIndex == 2
                  ? Theme.of(context).highlightColor
                  : Theme.of(context).primaryColor),
          Icon((FontAwesomeIcons.gear),
              color: currentIndex == 3
                  ? Theme.of(context).highlightColor
                  : Theme.of(context).primaryColor),
        ],
        activeIndex: currentIndex,
        inactiveIcons: [
          Icon((FontAwesomeIcons.home),
              color: currentIndex == 0
                  ? Theme.of(context).highlightColor
                  : Theme.of(context).primaryColor),
          Icon((FontAwesomeIcons.qrcode),
              color: currentIndex == 1
                  ? Theme.of(context).highlightColor
                  : Theme.of(context).primaryColor),
          Icon((FontAwesomeIcons.wifi),
              color: currentIndex == 2
                  ? Theme.of(context).highlightColor
                  : Theme.of(context).primaryColor),
          Icon((FontAwesomeIcons.gear),
              color: currentIndex == 3
                  ? Theme.of(context).highlightColor
                  : Theme.of(context).primaryColor),
        ],
      ),
      body: screens[currentIndex],
    );
  }
}
