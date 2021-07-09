import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:team_clone/constants.dart';

void updateTime(String hash, String message) {
  FirebaseFirestore.instance.collection('chat').doc(hash).set({
    'text': message,
    'sender': currentUser!.email != null && currentUser!.email!.isNotEmpty
        ? currentUser!.email
        : currentUser!.phoneNumber,
    'time': DateTime.now().toIso8601String().toString()
  }, SetOptions(merge: true));
}
