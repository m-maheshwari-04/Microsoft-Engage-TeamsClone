import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_clone/constants.dart';
import 'package:team_clone/main.dart';
import 'package:url_launcher/url_launcher.dart';

/// Implements a flutter widget that renders the Setting Screen
///
/// Contains the following features
/// - changing theme
/// - link to github repo
///
class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late String selectedTheme;

  @override
  Widget build(BuildContext context) {
    /// Used to change the theme
    setState(() {
      if (isDark) {
        selectedTheme = 'dark';
      } else {
        selectedTheme = 'light';
      }
    });

    /// UI of Setting screen
    return Scaffold(
      backgroundColor: dark,
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          Container(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              /// Navigate back to previous screen
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                    padding:
                        const EdgeInsets.only(top: 24, left: 24, right: 24),
                    child: Icon(Icons.arrow_back)),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 36, right: 24),
                child: Container(
                  margin: EdgeInsets.only(top: 8, bottom: 16, left: 8),
                  child: Text(
                    'Settings',
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w700, fontSize: 36),
                  ),
                ),
              ),

              /// App theme
              cardWidget(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('App Theme',
                        style: GoogleFonts.montserrat(fontSize: 24)),
                    Container(
                      height: 20,
                    ),
                    Row(
                      children: <Widget>[
                        Radio(
                          activeColor: !isDark ? Colors.black : Colors.white,
                          value: 'light',
                          groupValue: selectedTheme,
                          onChanged: (value) {
                            themeChangeProvider.darkTheme = false;
                            setState(() {
                              isDark = themeChangeProvider.darkTheme;
                            });
                          },
                        ),
                        Text(
                          'Light theme',
                          style: GoogleFonts.montserrat(fontSize: 18),
                        )
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Radio(
                          activeColor: !isDark ? Colors.black : Colors.white,
                          value: 'dark',
                          groupValue: selectedTheme,
                          onChanged: (value) {
                            themeChangeProvider.darkTheme = true;
                            setState(() {
                              isDark = themeChangeProvider.darkTheme;
                            });
                          },
                        ),
                        Text(
                          'Dark theme',
                          style: GoogleFonts.montserrat(fontSize: 18),
                        )
                      ],
                    ),
                  ],
                ),
              ),

              /// About section
              cardWidget(Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text('About app',
                      style: GoogleFonts.montserrat(
                        fontSize: 24,
                      )),
                  Container(
                    height: 40,
                  ),
                  Center(
                    child: Text('Developed by'.toUpperCase(),
                        style: GoogleFonts.montserrat(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1)),
                  ),
                  Center(
                      child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                    child: Text(
                      'Mukund Maheshwari',
                      style: GoogleFonts.montserrat(fontSize: 24),
                    ),
                  )),

                  /// Redirect to github repo of this app
                  Container(
                    alignment: Alignment.center,
                    child: OutlineButton.icon(
                      icon: Icon(Icons.link),
                      label: Text('GITHUB',
                          style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1,
                              color: Colors.grey.shade500)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      onPressed: () async {
                        String _url =
                            'https://github.com/m-maheshwari-04/Microsoft-Engage-TeamClone';
                        await canLaunch(_url)
                            ? await launch(_url)
                            : throw 'Could not launch $_url';
                      },
                    ),
                  ),
                  Container(
                    height: 30,
                  ),
                  Center(
                    child: Text('Made With'.toUpperCase(),
                        style: GoogleFonts.montserrat(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          FlutterLogo(
                            size: 40,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Flutter',
                              style: GoogleFonts.montserrat(fontSize: 24),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ))
            ],
          ))
        ],
      ),
    );
  }

  Widget cardWidget(Widget child) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark ? darkShadowTop : lightShadowTop),
      margin: EdgeInsets.all(20.h),
      padding: EdgeInsets.all(20.h),
      child: child,
    );
  }
}
