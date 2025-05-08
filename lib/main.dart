import 'package:ecard_app/modals/user_modal.dart';
import 'package:ecard_app/preferences/user_preference.dart';
import 'package:ecard_app/providers/auth_provider.dart';
import 'package:ecard_app/providers/card_provider.dart';
import 'package:ecard_app/providers/screen_index_provider.dart';
import 'package:ecard_app/providers/user_provider.dart';
import 'package:ecard_app/router/page_router.dart';
import 'package:ecard_app/screens/splash_screen.dart';
import 'package:ecard_app/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
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

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final bool isDarkMode = prefs.getBool("themeMode") ?? false;
  runApp(DevicePreview(builder:(context)=>EcardApp(isDarkMode: isDarkMode)));
  // runApp(EcardApp(isDarkMode: isDarkMode));
}

class EcardApp extends StatelessWidget {
  final bool isDarkMode;
  const EcardApp({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Theme.of(context).highlightColor,
      systemNavigationBarIconBrightness:
      brightness == Brightness.dark ? Brightness.light : Brightness.dark,
      statusBarIconBrightness:
      brightness == Brightness.dark ? Brightness.light : Brightness.dark,
      statusBarColor: Colors.transparent,
    ));

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
        builder: (context, themeNotifier, _) {
          return AnimatedTheme(
            data: themeNotifier.isDarkMode
                ? AppThemeController.darkMode
                : AppThemeController.lightMode,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeIn,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppThemeController.lightMode,
              darkTheme: AppThemeController.darkMode,
              themeMode:
              themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              initialRoute: '/',
              onGenerateRoute: PageRouter.switchRoute,
              home: SplashScreen(), // Always start with SplashScreen
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