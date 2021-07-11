import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:team_clone/Widget/welcomeList.dart';
import 'package:team_clone/constants.dart';
import 'package:team_clone/Login/AfterLogin/Profile.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => _WelcomeState();
}


class _WelcomeState extends State<Welcome> {

  List features = [
    ['noChat.png', 'Connect with friends instantly'],
    ['1.png', 'Free Video Calls'],
    ['photo.png', 'Share your moments'],
    ['3.png', 'Manage your tasks'],
    ['notes.png', 'Manage your notes'],
    ['login.png', 'Email your chat']
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ? dark : Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 30.0, left: 20, right: 30, bottom: 15),
            child: Text(
              "Welcome to Teams",
              style: GoogleFonts.montserrat(
                textStyle: GoogleFonts.montserrat(
                    fontSize: 24,
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 28.w),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                WelcomeList(img: features[0][0], heading: features[0][1]),
                WelcomeList(img: features[1][0], heading: features[1][1]),
                WelcomeList(img: features[2][0], heading: features[2][1]),
                WelcomeList(img: features[3][0], heading: features[3][1]),
                WelcomeList(img: features[4][0], heading: features[4][1]),
                WelcomeList(img: features[5][0], heading: features[5][1]),
              ],
            ),
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                  primary: primary),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 100),
                child: Text(
                  "Get started",
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              onPressed: () async {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Profile()),
                );
              }),
        ],
      ),
    );
  }
}
