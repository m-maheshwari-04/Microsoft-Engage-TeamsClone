import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_clone/Calendar/CalendarScreen.dart';
import 'package:team_clone/VideoCall/JitsiMeeting.dart';
import 'package:team_clone/constants.dart';
import 'package:flutter/painting.dart';

/// Local notification
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Implements a flutter widget that renders the entire Home screen
///
/// Contains the following features
/// - Create meeting
/// - Join meeting

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    /// Used to change the launch page
    SharedPreferences.getInstance()
        .then((value) => value.setBool('shownWelcomeScreen', true));

    /// Setting up Jitsi SDK
    JitsiMeet.addListener(JitsiMeetingListener(
        onConferenceWillJoin: (message) {},
        onConferenceJoined: (message) {},
        onConferenceTerminated: (message) {},
        onError: (error) {}));

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('icontest');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
      /// Navigate on notification tap
      await Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (context) => Calendar()),
      );
    });
  }

  @override
  void dispose() {
    super.dispose();

    /// Disposing Jitsi variable on app termination
    JitsiMeet.removeAllListeners();
  }

  /// UI of Home Screen
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: dark,
        resizeToAvoidBottomInset: false,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(10.h),
              child: Image(
                height: 300.h,
                image: AssetImage('images/home.png'),
                fit: BoxFit.scaleDown,
              ),
            ),
            SizedBox(
              height: 20.h,
            ),

            /// Button to join meeting with code
            meetingButton(context, "Join Meeting", false),

            /// Button to create new meeting
            meetingButton(context, "Create Meeting", true),
          ],
        ),
      ),
    );
  }

  /// Homepage button UI
  Container meetingButton(BuildContext context, String text, bool newMeeting) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 2.h),
      padding: EdgeInsets.symmetric(horizontal: 10.0.w, vertical: 6.h),
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: SizedBox(
          height: 50.0.h,
          width: double.maxFinite,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                primary: primary),
            child: Text(
              text,
              style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
            ),
            onPressed: () {
              JitsiMeeting.meeting(context, newMeeting);
            },
          ),
        ),
      ),
    );
  }
}
