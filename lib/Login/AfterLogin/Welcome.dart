import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:team_clone/Widget/welcomeList.dart';
import 'package:team_clone/constants.dart';
import 'package:team_clone/Login/AfterLogin/Profile.dart';

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
                textStyle: TextStyle(
                    fontSize: 24,
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                //   child: Column(
                //     children: [
                //       Padding(
                //         padding:
                //             const EdgeInsets.only(left: 16.0, right: 32.0),
                //         child: Container(
                //           width: MediaQuery.of(context).size.width * 0.8,
                //           child: Text(
                //             "Here is your time-table for ",
                //             style: GoogleFonts.montserrat(
                //               textStyle: TextStyle(
                //                 color: isdark ? Colors.white : Colors.black,
                //                 fontSize: 15,
                //               ),
                //             ),
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
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
