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
import 'dart:async';
import 'package:flutter/painting.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance()
        .then((value) => value.setBool('shownWelcomeScreen', true));

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
      await Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (context) => Calendar()),
      );
    });
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              // await Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => CaptchaScreen(),
              //   ),
              // );
            },
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    JitsiMeet.removeAllListeners();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: isDark ? dark : Colors.white,
        resizeToAvoidBottomInset: false,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Image(
                height: 300.h,
                image: AssetImage('images/home.png'),
                fit: BoxFit.scaleDown,
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            meetingButton(
              context,
              SizedBox(
                height: 50.0.h,
                width: double.maxFinite,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      primary: light),
                  child: Text(
                    "Join Meeting",
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onPressed: () {
                    JitsiMeeting.meeting(context,false);
                  },
                ),
              ),
            ),
            meetingButton(
              context,
              SizedBox(
                height: 50.0.h,
                width: double.maxFinite,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        primary: light),
                    child: Text(
                      "Create Meeting",
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: () {
                      JitsiMeeting.meeting(context,true);
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container meetingButton(BuildContext context, Widget button) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 2.h),
      padding: EdgeInsets.symmetric(horizontal: 10.0.w, vertical: 6.h),
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: button,
      ),
    );
  }
}
