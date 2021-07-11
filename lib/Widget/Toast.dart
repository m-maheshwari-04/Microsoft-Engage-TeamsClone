import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// Toast to display some error or wrong input
Future<bool?> toast(String message) {
  return Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0);
}
