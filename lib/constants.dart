/// Contains all the values that are required in most screens
/// Or items whose values are fixed and will never change

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:team_clone/Chat/user_model.dart';

User? currentUser;
bool isDark = false;

String defaultGroup =
    'https://firebasestorage.googleapis.com/v0/b/team-clone-5631e.appspot.com/o/default%2Fgroup.png?alt=media&token=ac260c24-3ca3-4bc6-9be1-c6ac2632ffb1';
String defaultProfile =
    'https://firebasestorage.googleapis.com/v0/b/team-clone-5631e.appspot.com/o/default%2Fprofile.jpg?alt=media&token=314e3117-0edd-4304-8cde-5d28c0848c2a';

Map<String, dynamic> tasks = Map();
Map<String, UserModel> allUsers = Map();
Map<String, UserModel> allGroups = Map();
Map<String, String> allTime = Map();

/// Color scheme for Dark mode
Color darkThemeDark = Color(0xFF1F1D2B);
Color darkThemeLight = Color(0xFF252836);
Color darkThemeBar = Color(0xFF2f3042);

/// Color scheme for light mode
Color lightThemeDark = Color(0xFFF3F3F8);
Color lightThemeLight = Color(0xFFFFFFFF);
Color lightThemeBar = Color(0xFFe3e2f0);

/// Primary color of the app
Color primary = Color(0xFF525298);

/// variable that are used to set the theme
Color bar = lightThemeBar;
Color light = lightThemeBar;
Color dark = darkThemeBar;

List<BoxShadow> lightShadow = [
  BoxShadow(
    color: Colors.grey[300]!,
    offset: Offset(4.0, 4.0),
    blurRadius: 4.0,
    spreadRadius: 1.0,
  ),
  BoxShadow(
    color: Colors.grey[100]!,
    offset: Offset(-4.0, -4.0),
    blurRadius: 4.0,
    spreadRadius: 1.0,
  ),
];
List<BoxShadow> darkShadow = [
  BoxShadow(
    color: Colors.black54,
    offset: Offset(4.0, 4.0),
    blurRadius: 4.0,
    spreadRadius: 1.0,
  ),
  BoxShadow(
    color: Colors.black12,
    offset: Offset(-4.0, -4.0),
    blurRadius: 4.0,
    spreadRadius: 1.0,
  ),
];

List<BoxShadow> lightShadowTop = [
  BoxShadow(
    offset: Offset(0.0, -5.0),
    color: light,
    blurRadius: 2.0,
    spreadRadius: 0,
  ),
];

List<BoxShadow> darkShadowTop = [
  BoxShadow(
    offset: Offset(0.0, -5.0),
    color: Colors.black26.withOpacity(0.3),
    blurRadius: 2.0,
    spreadRadius: 0,
  ),
];
