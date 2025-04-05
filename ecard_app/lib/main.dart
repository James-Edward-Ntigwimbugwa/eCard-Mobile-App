import 'package:ecard_app/modals/user_modal.dart';
import 'package:ecard_app/modals/user_preference.dart';
import 'package:ecard_app/providers/auth_provider.dart';
import 'package:ecard_app/providers/card_provider.dart';
import 'package:ecard_app/providers/screen_index_provider.dart';
import 'package:ecard_app/providers/user_provider.dart';
import 'package:ecard_app/router/page_router.dart';
import 'package:ecard_app/screens/dashboard_screen.dart';
import 'package:ecard_app/screens/splash_screen.dart';
import 'package:ecard_app/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight
  ]);

  // SystemChrome.setSystemUIOverlayStyle(
  //     const SystemUiOverlayStyle(
  //       statusBarColor: Color.fromARGB(255, 0, 132, 112),
  //       statusBarIconBrightness: Brightness.dark,
  //       systemNavigationBarColor: Color.fromARGB(255, 0, 132, 112),
  //       systemNavigationBarIconBrightness: Brightness.dark,
  //     )
  // );

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final bool isDarkMode = prefs.getBool("themeMode") ?? false;
  runApp(EcardApp(isDarkMode: isDarkMode));
}

class EcardApp extends StatelessWidget {
  final bool isDarkMode;
  const EcardApp({super.key, required this.isDarkMode});

  // Introduce a delay to simulate loading time
  Future<User> getUserData() async {
    await Future.delayed(
        const Duration(seconds: 2)); // Adjust the delay as needed
    return UserPreferences().getUser();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeNotifier>(
          create: (_) => ThemeNotifier(isDarkMode),
        ),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ScreenIndexProvider()),
        ChangeNotifierProvider(create: (_) => TabIndexProvider()),
        ChangeNotifierProvider(create: (_) => CardProvider())
      ],
      child: Consumer<ThemeNotifier>(
        builder: (context, theme, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppThemeController.lightMode,
            darkTheme: AppThemeController.darkMode,
            themeMode: theme.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            initialRoute: '/',
            onGenerateRoute: PageRouter.switchRoute,
            home: FutureBuilder<User>(
              future: getUserData(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return SplashScreen(); // Show SplashScreen while waiting
                  case ConnectionState.done:
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (snapshot.hasData &&
                        snapshot.data!.accessToken == null) {
                      return SplashScreen(); // User not logged in
                    }
                    if (snapshot.hasData &&
                        snapshot.data!.accessToken != null) {
                      return DashboardPage(
                          user: snapshot.data!); // User logged in
                    }
                    return SplashScreen(); // Default to login if no data or token
                  default:
                    return SplashScreen();
                }
              },
            ),
          );
        },
      ),
    );
  }
}

class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode;
  ThemeNotifier(this._isDarkMode);
  bool get isDarkMode => _isDarkMode;

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("themeMode", _isDarkMode);
  }
}
