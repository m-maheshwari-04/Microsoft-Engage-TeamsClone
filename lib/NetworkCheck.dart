import 'package:auto_size_text/auto_size_text.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_clone/constants.dart';
import 'package:team_clone/main.dart';
import 'package:team_clone/Login/login_screen.dart';
import 'package:team_clone/Login/welcome_screen.dart';

class NetworkCheck extends StatefulWidget {
  @override
  _NetworkCheckState createState() => _NetworkCheckState();
}

class _NetworkCheckState extends State<NetworkCheck> {
  late Widget screenToShow;

  @override
  void initState() {
    super.initState();
    isDark = themeChangeProvider.darkTheme;
  }

  Future<void> retry() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      if (sharedPreferences.getBool('shownWelcomeScreen') ?? false) {
        screenToShow = LoginScreen();
      } else {
        screenToShow = WelcomeScreen();
      }
    } else {
      screenToShow = NetworkCheck();
    }

    Route route = MaterialPageRoute(builder: (context) => screenToShow);
    Navigator.of(context).pushReplacement(route);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return Scaffold(
      backgroundColor: !isDark ? Colors.white : dark,
      body: Container(
        child: Column(
          children: [
            SizedBox(
              height: 100,
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image(
                  image: AssetImage('images/no_internet.png'),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text('No internet connection',
                  maxLines: 3,
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                      fontSize: 18,
                      color: isDark ? Colors.white : Colors.black)),
            ),
            Padding(
              padding: const EdgeInsets.all(50.0),
              child: SizedBox(
                height: 40,
                child: RaisedButton.icon(
                  elevation: 1,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  onPressed: () {
                    retry();
                  },
                  icon: Icon(
                    Icons.autorenew_outlined,
                    color: light,
                  ),
                  label: AutoSizeText('Retry',
                      style:
                      GoogleFonts.montserrat(color: light, fontWeight: FontWeight.w700)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
