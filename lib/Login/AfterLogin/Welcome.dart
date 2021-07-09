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

List features = [
  [
    'login.jpg',
    'Chat with friends and family',
    "Reach anyone if they don't have Teams"
  ],
  [
    'login.jpg',
    'Free Video Calls',
    "Check in with friends or catch up with the whole family - without limits"
  ],
  ['login.jpg', 'Privacy', "Your privacy is important to us."]
];

class _WelcomeState extends State<Welcome> {
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
                WelcomeList(
                  img: features[0][0],
                  heading: features[0][1],
                  desc: features[0][2],
                ),
                WelcomeList(
                  img: features[1][0],
                  heading: features[1][1],
                  desc: features[1][2],
                ),
                WelcomeList(
                  img: features[2][0],
                  heading: features[2][1],
                  desc: features[2][2],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 50,
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                  primary: light),
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
