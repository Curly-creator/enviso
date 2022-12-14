//import 'package:enviso/services/utils.dart';
import 'package:enviso/screens/settings/settings_page.dart';
import 'package:enviso/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:enviso/screens/home/home_page.dart';
import 'package:enviso/screens/authenticate/auth_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Settings.init(cacheProvider: SharePreferenceCache());
  runApp(const MyApp());
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static const String title = 'eNVISO';

  @override
  Widget build(BuildContext context) {
    return ValueChangeObserver<bool>(
      cacheKey: SettingsPage.keyDarkMode,
      defaultValue: false,
      builder: (_, isDarkMode, __) => MaterialApp(
        //scaffoldMessengerKey: Utils.messengerKey,  **** needs to be fixed
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: title,
        theme: isDarkMode
            ? ThemeData(
                primaryColor: colorGreen,
                brightness: Brightness.dark,
                scaffoldBackgroundColor: colorBlackLight,
                canvasColor: Colors.grey[600],
                fontFamily: 'Inter',
              )
            : ThemeData(
                primaryColor: colorGreen,
                brightness: Brightness.light,
                scaffoldBackgroundColor: colorWhite,
                canvasColor: colorWhite,
                fontFamily: 'Inter',
              ),
        //home: const MainPage(),
        home: HomePage(),
      ),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(
                  child: Text('Something went wrong'),
                );
              } else if (snapshot.hasData) {
                return HomePage();
              } else {
                return const AuthPage();
              }
            }),
      );
}
