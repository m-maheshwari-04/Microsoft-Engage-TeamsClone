import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Login/Auth/Google.dart';
import 'package:team_clone/Notes/notes.dart';
import 'package:team_clone/Widget/sideBar.dart';
import 'package:team_clone/Login/AfterLogin/Profile.dart';
import 'package:team_clone/about.dart';
import 'Chat/chatScreen.dart';
import 'homeScreen.dart';
import 'package:team_clone/Login/login_screen.dart';
import 'Calendar/CalendarScreen.dart';
import 'main.dart';
import 'constants.dart';
import 'package:flutter/services.dart';

/// Implements a flutter widget that renders the basic structure of app
///
/// Header, drawer and bottom navigation bar are implemented here=
class NavBarClass extends StatefulWidget {
  int currIndex;
  NavBarClass(this.currIndex);
  @override
  _NavBarClassState createState() => _NavBarClassState();
}

class _NavBarClassState extends State<NavBarClass> {
  /// variable to control the app theme
  bool isSwitched = false;

  /// PageController for navigation to home/chat/calendar screen
  PageController _pageController = new PageController();

  /// Instance of FirebaseMessaging
  /// used for sending push notification via firebase
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    isDark = themeChangeProvider.darkTheme;

    _pageController = PageController(initialPage: widget.currIndex);
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _pageController = PageController(initialPage: widget.currIndex);
      });
    });

    Future.delayed(Duration.zero, () {
      this.firebaseCloudMessagingListeners(context);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Initializing firebase notification for chat
  void firebaseCloudMessagingListeners(BuildContext context) {
    _firebaseMessaging.getToken().then((deviceToken) {
      ///FCM token update for firebase notification
      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .set({'token': deviceToken ?? ''}, SetOptions(merge: true));
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print("message received");
      showNotification(event.notification);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (context) => NavBarClass(1)),
      );
    });
  }

  /// Displaying any message received in device notifications
  void showNotification(message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'com.example.team_clone', 'Team Chat', 'Chat notification',
        playSound: true,
        enableVibration: true,
        importance: Importance.max,
        priority: Priority.high,
        icon: 'icontest');
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, message.title.toString(),
        message.body.toString(), platformChannelSpecifics);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    return SafeArea(
      child: Scaffold(
        /// Overall app's appbar
        appBar: AppBar(title: Text('Teams', style: GoogleFonts.montserrat())),

        /// Drawer containing list of options available
        drawer: Drawer(
          child: Container(
            color: dark,
            child: ListView(
              children: [
                /// About user
                Container(
                  decoration: BoxDecoration(
                    color: dark,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 15.0,
                          ),
                          Column(
                            children: [
                              CircleAvatar(
                                radius: 62.0,
                                backgroundColor: light,
                                child: CircleAvatar(
                                  radius: 60.0,
                                  child: ClipOval(
                                      child: currentUser != null &&
                                              currentUser!.photoURL != null
                                          ? CircleAvatar(
                                              radius: 100,
                                              backgroundImage: NetworkImage(
                                                  currentUser!.photoURL!))
                                          : Image(
                                              image: AssetImage('images/1.png'),
                                              height: 110,
                                            )),
                                  backgroundColor: dark,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Text(
                                  currentUser!.displayName ?? 'User',
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: Text(
                                  currentUser!.email != null &&
                                          currentUser!.email!.isNotEmpty
                                      ? currentUser!.email!
                                      : currentUser!.phoneNumber.toString(),
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () async {
                              themeChangeProvider.darkTheme =
                                  !themeChangeProvider.darkTheme;
                              setState(() {
                                isDark = themeChangeProvider.darkTheme;
                              });
                            },
                            child: isDark
                                ? Icon(
                                    Icons.nights_stay_outlined,
                                    color: Colors.white,
                                  )
                                : Icon(Icons.wb_sunny_outlined,
                                    color: Colors.black),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                SidebarTile("Profile", Profile(edit: true), true),
                SidebarTile("Home", NavBarClass(0), false),
                SidebarTile("Chat", NavBarClass(1), false),
                SidebarTile("Notes", NotesPage(), true),
                SidebarTile("Calendar", NavBarClass(2), false),
                SidebarTile("About the app", AboutPage(), true),
                GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 15.0, right: 15.0, top: 4.0, bottom: 4.0),
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: isDark ? darkShadow : lightShadow,
                        color: primary,
                        borderRadius: BorderRadius.all(
                          Radius.circular(14),
                        ),
                      ),
                      child: Container(
                        margin: EdgeInsets.only(left: 12.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: light,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(14),
                              bottomRight: Radius.circular(14),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 15.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 150,
                                          child: AutoSizeText('Invite',
                                              style: GoogleFonts.montserrat()),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await FlutterShare.share(
                        title: 'Teams',
                        text: 'Download Teams using the link:',
                        linkUrl: 'https://bit.ly/3hkQhmV',
                        chooserTitle: 'Teams');
                  },
                ),

                /// Logout button
                GestureDetector(
                  onTap: () async {
                    /// Clearing FCM token from firebase
                    /// so that user does not receive notification on this device
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser!.uid)
                        .set({'token': ''}, SetOptions(merge: true));

                    currentUser = null;

                    tasks.clear();
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setString('tasks', json.encode(tasks));

                    /// Signing out
                    await Authentication.signOut(context: context);

                    /// Navigate to login screen
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                        (Route<dynamic> route) => false);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(
                        left: 80.0, right: 80.0, top: 15.0, bottom: 10.0),
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          "Log Out",
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        /// Controller to navigate to different screens in bottom nav bar
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              widget.currIndex = index;
            });
          },

          /// Bottom nav bar options
          children: [HomePage(), ChatPage(), Calendar()],
        ),

        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.shifting,
          backgroundColor: bar,
          unselectedItemColor: isDark ? Colors.white : Colors.black87,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              backgroundColor: bar,
              icon: Icon(Icons.videocam),
              label: 'Meet',
            ),
            BottomNavigationBarItem(
              backgroundColor: bar,
              icon: Icon(Icons.message),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              backgroundColor: bar,
              icon: Icon(Icons.calendar_today_rounded),
              label: 'Calendar',
            ),
          ],
          currentIndex: widget.currIndex,
          selectedLabelStyle: GoogleFonts.montserrat(),
          unselectedLabelStyle: GoogleFonts.montserrat(),
          selectedItemColor: primary,
          onTap: (index) {
            setState(() {
              widget.currIndex = index;
            });
            _pageController.animateToPage(index,
                duration: const Duration(milliseconds: 250),
                curve: Curves.ease);
          },
        ),
      ),
    );
  }
}
