import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:team_clone/Chat/user_model.dart';
import 'package:team_clone/constants.dart';

final _firestore = FirebaseFirestore.instance;

/// Update timestamp of chat on firestore
void firstMessage(String hash, UserModel user) {
  _firestore.collection('users').doc(currentUser!.uid).update({
    'chats': FieldValue.arrayUnion([user.uid])
  });
  _firestore.collection('users').doc(user.uid).update({
    'chats': FieldValue.arrayUnion([currentUser!.uid])
  });
}
