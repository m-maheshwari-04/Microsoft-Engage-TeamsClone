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

// Color light = Color(0xFF30475E);
// Color dark = Color(0xFF222831);

// Color light = Color(0xFF47597E);
// Color dark = Color(0xFF0A1931);

Color light = Color(0xFF1F4068);
Color dark = Color(0xFF17223B);

// Color light = Color(0xFF29435C);
// Color dark = Color(0xFF152A38);

List<String> months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December'
];

List<String> shortHandMonths = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec'
];

List<String> years = [
  '2021',
  '2022',
  '2023',
  '2024',
  '2025',
  '2026',
  '2027',
  '2028',
  '2029',
  '2030'
];

List week = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

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
    color: Colors.grey[100]!,
    blurRadius: 2.0, // soften the shadow
    spreadRadius: 0,
  ),
];

List<BoxShadow> darkShadowTop = [
  BoxShadow(
    offset: Offset(0.0, -5.0),
    color: Colors.black26.withOpacity(0.3),
    blurRadius: 2.0, // soften the shadow
    spreadRadius: 0,
  ),
];
