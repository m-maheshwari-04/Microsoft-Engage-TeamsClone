import 'dart:ui';
import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:random_string/random_string.dart';
import 'package:team_clone/Widget/Toast.dart';
import 'package:team_clone/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// All functionalities related to Jitsi
///
class JitsiMeeting {
  /// Joining video call
  static joinMeeting(
      String roomCode, String? roomName, bool audio, bool video) async {
    String? serverUrl;

    Map<FeatureFlagEnum, bool> featureFlags = {
      FeatureFlagEnum.WELCOME_PAGE_ENABLED: false,
    };

    featureFlags[FeatureFlagEnum.CALL_INTEGRATION_ENABLED] = false;

    /// Setting options for joining video call
    var options = JitsiMeetingOptions(room: roomCode)
      ..serverURL = serverUrl
      ..subject = roomName
      ..userDisplayName =
          currentUser!.email != null && currentUser!.email!.isNotEmpty
              ? currentUser!.email
              : currentUser!.phoneNumber
      ..userEmail = currentUser!.email != null && currentUser!.email!.isNotEmpty
          ? currentUser!.email
          : currentUser!.phoneNumber
      ..audioOnly = false
      ..audioMuted = !audio
      ..videoMuted = !video
      ..featureFlags.addAll(featureFlags)
      ..webOptions = {
        "roomName": roomName,
        "width": "100%",
        "height": "100%",
        "enableWelcomePage": false,
        "chromeExtensionBanner": null,
        "userInfo": {
          "displayName":
              currentUser!.email != null && currentUser!.email!.isNotEmpty
                  ? currentUser!.email
                  : currentUser!.phoneNumber ?? 'Anonymous'
        }
      };

    await JitsiMeet.joinMeeting(
      options,
      listener: JitsiMeetingListener(
          onConferenceWillJoin: (message) {},
          onConferenceJoined: (message) {},
          onConferenceTerminated: (message) {},
          genericListeners: [
            JitsiGenericListener(
                eventName: 'readyToClose', callback: (dynamic message) {}),
          ]),
    );
  }

  /// Dialog for creating or joining Jitsi meet
  static void meeting(BuildContext context, bool newMeeting) {
    bool audio = false;
    bool video = false;

    bool copy = false;
    bool share = false;

    // roomName for new meeting, roomCode for joining a meeting
    final room = TextEditingController(
        text: newMeeting ? "${currentUser!.displayName}'s Meeting" : "");

    String roomCode = randomAlphaNumeric(8);
    roomCode = roomCode.substring(0, 3) +
        '-' +
        roomCode.substring(3, 5) +
        '-' +
        roomCode.substring(5, 8);
    roomCode = roomCode.toUpperCase();

    /// If new meeting is created then the roomCode is added to firebase and
    /// a group chat is created which other users will join using roomCode
    if (newMeeting) {
      FirebaseFirestore.instance
          .collection('Jitsi')
          .doc('roomId')
          .get()
          .then((value) {
        Map roomIds = value.data() != null && value.data()!.containsKey('id')
            ? value['id']
            : Map();
        roomIds[roomCode] = true;
        FirebaseFirestore.instance.collection('Jitsi').doc('roomId').set({
          'id': roomIds,
        }, SetOptions(merge: true));
      });

      String groupId = roomCode + '!@#%^&*(';

      FirebaseFirestore.instance.collection('group').doc(groupId).set({
        'name': room.text,
        'id': currentUser!.email != null && currentUser!.email!.isNotEmpty
            ? currentUser!.email
            : currentUser!.phoneNumber,
        'img': defaultGroup,
        'uid': groupId,
        'members': [currentUser!.uid]
      });

      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .update({
        'groups': FieldValue.arrayUnion([groupId])
      });

      FirebaseFirestore.instance.collection('chat').doc(groupId).set({
        'text': 'Meeting created',
        'sender': currentUser!.email != null && currentUser!.email!.isNotEmpty
            ? currentUser!.email
            : currentUser!.phoneNumber,
        'time': DateTime.now().toIso8601String().toString()
      }, SetOptions(merge: true));
    }

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
            child: AlertDialog(
              buttonPadding: EdgeInsets.all(10),
              backgroundColor: dark,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              title: Text(
                newMeeting
                    ? "Here's the link to your meeting"
                    : "Join with a code",
                style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w500,
                    fontSize: newMeeting ? 16 : 18),
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Text(
                      newMeeting
                          ? 'Copy this code and send it to people that you want to meet with. Ask them to paste this code in join meeting section and join the meet.'
                          : 'Enter the code provided by the meeting organizer',
                      style: GoogleFonts.montserrat(
                          fontSize: newMeeting ? 14 : 16,
                          fontWeight: FontWeight.w300),
                    ),
                    SizedBox(height: 15.h),
                    if (newMeeting)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(width: 20.w),
                          Text(
                            roomCode,
                            style: GoogleFonts.montserrat(fontSize: 18),
                          ),
                          SizedBox(width: 20.w),
                          GestureDetector(
                            onTap: () {
                              /// Copy roomCode
                              FlutterClipboard.copy(roomCode)
                                  .then((value) => print('copied'));
                              toast('Link copied to clipboard');
                            },
                            onTapDown: (value) {
                              setState(() {
                                copy = true;
                              });
                            },
                            onTapUp: (value) {
                              setState(() {
                                copy = false;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: copy
                                    ? Colors.white.withOpacity(0.2)
                                    : Colors.transparent,
                              ),
                              child: Icon(Icons.copy_rounded, size: 25),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              /// Share roomCode
                              await FlutterShare.share(
                                  title: 'Teams',
                                  text:
                                      'To join the meeting on Teams use the code \n\n$roomCode \n\nDownload from:',
                                  linkUrl: 'https://bit.ly/3hkQhmV',
                                  chooserTitle: 'Teams');
                            },
                            onTapDown: (value) {
                              setState(() {
                                share = true;
                              });
                            },
                            onTapUp: (value) {
                              setState(() {
                                share = false;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: share
                                    ? Colors.white.withOpacity(0.2)
                                    : Colors.transparent,
                              ),
                              child: Icon(Icons.share_rounded, size: 25),
                            ),
                          )
                        ],
                      ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                          color: light,
                          borderRadius: BorderRadius.circular(15.0),
                          border: Border.all(color: dark)),
                      child: TextFormField(
                        cursorColor: isDark ? Colors.white70 : Colors.black87,
                        style: GoogleFonts.montserrat(),
                        controller: room,
                        decoration: InputDecoration(
                          hintText: newMeeting ? "Room Name" : "Room Code",
                          hintStyle: GoogleFonts.montserrat(color: Colors.grey),
                          alignLabelWithHint: true,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                          enabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.transparent, width: 0),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.transparent, width: 0),
                          ),
                        ),
                      ),
                    ),
                    /// Audio toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "Audio",
                          style: GoogleFonts.montserrat(fontSize: 16),
                        ),
                        Transform.scale(
                          scale: 0.8,
                          child: CupertinoSwitch(
                            activeColor: primary,
                            value: audio,
                            onChanged: (bool? value) {
                              setState(() {
                                audio = value ?? true;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    /// Video toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "Video",
                          style: GoogleFonts.montserrat(fontSize: 16),
                        ),
                        Transform.scale(
                          scale: 0.8,
                          child: CupertinoSwitch(
                            activeColor: primary,
                            value: video,
                            onChanged: (bool? value) {
                              setState(() {
                                video = value ?? true;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel',
                      style: GoogleFonts.montserrat(
                          color: isDark ? Colors.white : Colors.black)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  color: primary,
                  child: Text(
                    newMeeting ? 'Create' : 'Join',
                    style: GoogleFonts.montserrat(color: Colors.white),
                  ),
                  onPressed: () {
                    if (newMeeting) {
                      createRoom(roomCode, room.text, audio, video, context);
                    } else {
                      joinRoom(room.text, audio, video, context);
                    }
                  },
                ),
              ],
            ),
          );
        });
      },
    );
  }

  /// Called when new room is created
  static void createRoom(String roomCode, String roomName, bool audio,
      bool video, BuildContext context) {
    if (roomName.length == 0) {
      toast("Room name cannot be empty");
      return;
    }
    Navigator.of(context).pop();

    /// Updating groupName in firebase
    String groupId = roomCode + '!@#%^&*(';
    FirebaseFirestore.instance
        .collection('group')
        .doc(groupId)
        .set({'name': roomName}, SetOptions(merge: true));

    /// Join video call
    joinMeeting(roomCode, roomName, audio, video);
  }

  /// Called when user is joining with a roomCode
  static void joinRoom(
      String roomCode, bool audio, bool video, BuildContext context) {
    if (roomCode.length != 10) {
      toast("Invalid room code");
      return;
    }
    roomCode = roomCode.toUpperCase();

    /// Checking is room code is valid or not
    FirebaseFirestore.instance
        .collection('Jitsi')
        .doc('roomId')
        .get()
        .then((value) {
      Map roomIds = value['id'] ?? Map();
      if (!roomIds.containsKey(roomCode)) {
        toast("Invalid room code");
        return;
      }

      /// If room code is valid then user is added to group chat and
      /// joins the video call
      String groupId = roomCode + '!@#%^&*(';

      FirebaseFirestore.instance.collection('group').doc(groupId).update({
        'members': FieldValue.arrayUnion([currentUser!.uid])
      });

      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .update({
        'groups': FieldValue.arrayUnion([groupId])
      });

      FirebaseFirestore.instance.collection('chat').doc(groupId).set({
        'text': '${currentUser!.displayName} joined the group',
        'sender': currentUser!.email != null && currentUser!.email!.isNotEmpty
            ? currentUser!.email
            : currentUser!.phoneNumber,
        'time': DateTime.now().toIso8601String().toString()
      }, SetOptions(merge: true));

      Navigator.of(context).pop();
      JitsiMeeting.joinMeeting(roomCode, " ", true, false);
    });
  }
}
