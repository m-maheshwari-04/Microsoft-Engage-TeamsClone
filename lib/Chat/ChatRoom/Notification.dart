import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:team_clone/constants.dart';

String url = 'https://teams-notification-00.herokuapp.com/sendNotification';

/// Send notification to other user using fcm token
void sendNotification(String hash, String message, String? token) {
  if (hash.length != 18) {
    fcmNotification(
        message,
        currentUser!.email != null && currentUser!.email!.isNotEmpty
            ? currentUser!.email!
            : currentUser!.phoneNumber!,
        [token!]);
  } else {
    /// Getting fcm token of all users in a group
    List tokens = [];
    FirebaseFirestore.instance
        .collection('group')
        .doc(hash)
        .get()
        .then((value) => value['members'].forEach((element) {
              if (element != currentUser!.uid) {
                tokens.add(allUsers[element]!.token);
              }
            }))
        .then((value) => fcmNotification(
            message,
            currentUser!.email != null && currentUser!.email!.isNotEmpty
                ? currentUser!.email!
                : currentUser!.phoneNumber!,
            tokens));
  }
}

///Post request to NodeJs server for notification
Future fcmNotification(String message, String from, List tokens) async {
  Map<String, String> headers = {"Content-type": "application/json"};
  final body = jsonEncode({"message": message, "from": from, "tokens": tokens});

  http.Response response =
      await http.post(Uri.parse(url), body: body, headers: headers);

  if (response.statusCode == 200) {
    return;
  } else {
    print(response.body);
  }
}
