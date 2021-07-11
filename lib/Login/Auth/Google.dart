import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:team_clone/Widget/Toast.dart';
import 'package:team_clone/constants.dart';
import 'package:team_clone/nav_bar_file.dart';
import 'package:team_clone/Login/AfterLogin/Welcome.dart';

/// All functionalities related to Firebase authentication
class Authentication {
  /// Firebase initialization
  static Future<FirebaseApp> initializeFirebase({
    required BuildContext context,
  }) async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUser = user;

      if (user.displayName == null || user.photoURL == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => Welcome()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => NavBarClass(0)),
        );
      }
    }
    return firebaseApp;
  }

  /// Sign in with google
  static Future<User?> signInWithGoogle({required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    final GoogleSignInAccount? googleSignInAccount =
        await GoogleSignIn().signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        final UserCredential userCredential =
            await auth.signInWithCredential(credential);

        user = userCredential.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          toast('The account already exists with a different credential');
        } else if (e.code == 'invalid-credential') {
          toast('Error occurred while accessing credentials. Try again.');
        }
      } catch (e) {
        toast('Error occurred using Google Sign In. Try again.');
      }
    }
    return user;
  }

  /// Sign out from firebase
  static Future<void> signOut({required BuildContext context}) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      await googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      toast('Error signing out. Try again.');
    }
  }
}
