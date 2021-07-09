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
import 'package:team_clone/settings.dart';
import 'Chat/chatScreen.dart';
import 'homeScreen.dart';
import 'package:team_clone/Login/login_screen.dart';
import 'Calendar/CalendarScreen.dart';
import 'main.dart';
import 'constants.dart';
import 'package:flutter/services.dart';

class NavBarClass extends StatefulWidget {
  int currIndex;
  NavBarClass(this.currIndex);
  @override
  _NavBarClassState createState() => _NavBarClassState();
}

class _NavBarClassState extends State<NavBarClass> {
  bool isSwitched = false;
  late List<bool> isSelected;
  PageController _pageController = new PageController();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    isDark = themeChangeProvider.darkTheme;
    isSelected = [true, false];

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

  void firebaseCloudMessagingListeners(BuildContext context) {
    _firebaseMessaging.getToken().then((deviceToken) {
      print("Firebase Device token: $deviceToken");

      //FCM token update for notification
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

  void showNotification(message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'com.example.team_clone',
      'Team Chat',
      'Chat notification',
      playSound: true,
      enableVibration: true,
      importance: Importance.max,
      priority: Priority.high,
    );
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
        appBar: AppBar(title: Text('Microsoft Teams',style: GoogleFonts.montserrat())),
        drawer: Drawer(
          child: Container(
            color: isDark ? dark : Colors.white,
            child: ListView(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? dark : Color(0xFFECEDF5),
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
                                backgroundColor:
                                    isDark ? Colors.white : Colors.black,
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
                                  backgroundColor: isDark ? dark : Colors.white,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Text(
                                  currentUser!.displayName ?? 'User',
                                  style: GoogleFonts.karla(
                                    textStyle:GoogleFonts.montserrat(
                                      color:
                                          isDark ? Colors.white : Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
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
                                  style: GoogleFonts.karla(
                                    textStyle: GoogleFonts.montserrat(
                                      color:
                                          isDark ? Colors.white : Colors.black,
                                      fontSize: 14,
                                    ),
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
                SidebarTile("Setting", SettingsPage(), true),
                GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 15.0, right: 15.0, top: 4.0, bottom: 4.0),
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: isDark ? darkShadow : lightShadow,
                        color: light.withOpacity(0.8),
                        borderRadius: BorderRadius.all(
                          Radius.circular(14),
                        ),
                      ),
                      child: Container(
                        margin: EdgeInsets.only(left: 12.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark ? dark : Colors.white,
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
                                              style: GoogleFonts.montserrat(
                                                color: isDark
                                                    ? Colors.white
                                                    : Colors.black,
                                              )),
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
                        title: 'Team Clone',
                        text: 'Download Team-Clone using the link:',
                        linkUrl:
                            'https://bit.ly/3hkQhmV',
                        chooserTitle: 'Example Chooser Title');
                  },
                ),
                GestureDetector(
                  onTap: () async {
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser!.uid)
                        .set({'token': ''}, SetOptions(merge: true));

                    currentUser = null;

                    tasks.clear();
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setString('tasks', json.encode(tasks));

                    await Authentication.signOut(context: context);
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                        (Route<dynamic> route) => false);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(
                        left: 80.0, right: 80.0, top: 15.0, bottom: 10.0),
                    decoration: BoxDecoration(
                      color: light,
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          "Log Out",
                          style: GoogleFonts.karla(
                            textStyle: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
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
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              widget.currIndex = index;
            });
          },
          children: [HomePage(), ChatPage(), Calendar()],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.shifting,
          backgroundColor: Colors.white,
          unselectedItemColor: isDark ? Colors.white : Colors.black87,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              backgroundColor: isDark ? dark : Colors.white,
              icon: Icon(Icons.videocam),
              label: 'Meet',
            ),
            BottomNavigationBarItem(
              backgroundColor: isDark ? dark : Colors.white,
              icon: Icon(Icons.message),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              backgroundColor: isDark ? dark : Colors.white,
              icon: Icon(Icons.calendar_today_rounded),
              label: 'Calendar',
            ),
          ],
          currentIndex: widget.currIndex,
          selectedItemColor: Colors.indigoAccent,
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
