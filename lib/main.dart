import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_clone/nav_bar_file.dart';
import 'NetworkCheck.dart';
import 'package:team_clone/Login/login_screen.dart';
import 'package:team_clone/Login/welcome_screen.dart';
import 'DarkThemeProvider.dart';
import 'constants.dart';

DarkThemeProvider themeChangeProvider = new DarkThemeProvider();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_messageHandler);

  final prefs = await SharedPreferences.getInstance();

  String? s = prefs.getString('tasks');
  if (s != null && s.length != 0)
    tasks = await json.decode(s);
  else {
    tasks = Map();
  }

  themeChangeProvider.darkTheme =
      await themeChangeProvider.darkThemePreference.getTheme();
  themeChangeProvider.addListener(() {});
  Widget screenToShow = NavBarClass(0);

  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile ||
      connectivityResult == ConnectivityResult.wifi) {
    if (prefs.getBool('shownWelcomeScreen') ?? false) {
      screenToShow = LoginScreen();
    } else {
      screenToShow = WelcomeScreen();
    }
  } else {
    screenToShow = NetworkCheck();
  }
  runApp(MyApp(screenToShow: screenToShow));
}

Future<void> _messageHandler(RemoteMessage message) async {}

class MyApp extends StatefulWidget {
  MyApp({required this.screenToShow});

  final Widget screenToShow;

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        return themeChangeProvider;
      },
      child: Consumer<DarkThemeProvider>(
          builder: (BuildContext context, value, child) {
        return ScreenUtilInit(
          designSize: Size(384, 837),
          builder: () => new MaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode: ThemeMode.light,
            builder: (context, child) {
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.portraitUp,
                DeviceOrientation.portraitDown
              ]);
              return MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                  child: child!);
            },
            theme: themeChangeProvider.darkTheme
                ? ThemeData(
                    brightness: Brightness.dark,
                    accentColor: light,
                    primaryColor: dark,
                    canvasColor: dark,
                    textSelectionTheme: TextSelectionThemeData(
                      cursorColor: light,
                      selectionHandleColor: light,
                    ),
                  )
                : ThemeData(
                    brightness: Brightness.light,
                    accentColor: light,
                    primaryColor: dark,
                    canvasColor: dark,
                    textSelectionTheme: TextSelectionThemeData(
                      cursorColor: light,
                      selectionHandleColor: light,
                    ),
                    backgroundColor: Colors.white),
            darkTheme: themeChangeProvider.darkTheme
                ? ThemeData(
                    brightness: Brightness.dark,
                    accentColor: light,
                    textSelectionTheme: TextSelectionThemeData(
                      cursorColor: light,
                      selectionHandleColor: light,
                    ),
                  )
                : ThemeData(
                    brightness: Brightness.light,
                    accentColor: light,
                    textSelectionTheme: TextSelectionThemeData(
                      cursorColor: light,
                      selectionHandleColor: light,
                    ),
                    backgroundColor: Colors.white),
            home: widget.screenToShow,
            title: "Teams",
          ),
        );
      }),
    );
  }
}
