import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:team_clone/Calendar/CalendarConstants.dart';
import 'package:team_clone/Chat/ChatRoom/FirstMessage.dart';
import 'package:team_clone/Widget/Toast.dart';
import 'ChatRoom/ImageViewingScreen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'ChatRoom/Notification.dart';
import 'ChatRoom/SendImage.dart';
import 'package:team_clone/Chat/groupInfo.dart';
import 'ChatRoom/timeUpdate.dart';
import 'package:team_clone/VideoCall/JitsiMeeting.dart';
import 'package:team_clone/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

final _firestore = FirebaseFirestore.instance;

/// Stores chat for sending email
String body = '';

/// User chat or group chat screen
class Chat extends StatefulWidget {
  static const String id = 'chat';

  final UserModel user;
  final String hash;
  Chat({required this.user, required this.hash});

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final messageTextController = TextEditingController();
  String? messageText;

  @override
  void initState() {
    body = '';
    super.initState();
  }

  /// More options
  Future<void> handleClick(String value) async {
    switch (value) {
      case 'Delete':
        {
          widget.user.members!.forEach((element) {
            FirebaseFirestore.instance.collection('users').doc(element).update({
              'groups': FieldValue.arrayRemove([widget.user.uid])
            });
          });

          FirebaseFirestore.instance
              .collection('group')
              .doc(widget.user.uid)
              .delete();

          Navigator.pop(context);
          break;
        }
      case 'Copy code':
        {
          FlutterClipboard.copy(widget.hash.substring(0, 10))
              .then((value) => print('copied'));
          break;
        }
      case 'Email chat':
        {
          final Email email = Email(
            body: body,
            subject: "${widget.user.name} Chat",
            isHTML: false,
          );
          try {
            await FlutterEmailSender.send(email);
          } catch (error) {
            print(error.toString());
          }
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: dark,
      appBar: AppBar(
        elevation: 0.4,
        backgroundColor: bar,
        title: GestureDetector(
          onTap: () {
            if (widget.hash.length == 18) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        GroupInfo(hash: widget.hash, user: widget.user)),
              );
            }
          },
          child: Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                margin: EdgeInsets.fromLTRB(0, 5, 10, 0),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(widget.user.imgUrl),
                  backgroundColor: Colors.grey[200],
                  minRadius: 30,
                ),
              ),
              Flexible(
                child: AutoSizeText(
                  widget.user.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.montserrat(fontSize: 16.sp),
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.videocam,
            ),
            onPressed: () {
              if (widget.hash.length != 18) {
                firstMessage(widget.hash, widget.user);
              }

              _firestore.collection(widget.hash).add({
                'text':
                    '${currentUser!.displayName} started a meeting on ${(DateTime.now()).toString().substring(0, 16)}',
                'sender':
                    currentUser!.email != null && currentUser!.email!.isNotEmpty
                        ? currentUser!.email
                        : currentUser!.phoneNumber,
                'time': DateTime.now().toIso8601String().toString(),
                'call': true
              });

              sendNotification(
                  widget.hash, 'Meeting started', widget.user.token);
              updateTime(widget.hash, 'Meeting started');

              JitsiMeeting.joinMeeting(
                  widget.hash.endsWith('!@#%^&*(')
                      ? widget.hash.substring(0, 10)
                      : widget.hash,
                  '${widget.hash.length == 18 ? widget.user.name : currentUser!.displayName} meeting',
                  false,
                  false);
            },
          ),
          PopupMenuButton<String>(
            onSelected: handleClick,
            itemBuilder: (BuildContext context) {
              return {
                if (widget.hash.length == 18 &&
                    widget.hash.endsWith('!@#%^&*('))
                  'Copy code',
                'Email chat',
                if (widget.hash.length == 18) 'Delete'
              }.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(
                    choice,
                    style: GoogleFonts.montserrat(),
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(hash: widget.hash),
            Container(
              width: MediaQuery.of(context).size.width,
              child: Container(
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(
                  2,
                ),
                decoration: BoxDecoration(
                  color: light,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Row(
                  children: <Widget>[
                    /// Take new photo
                    IconButton(
                      splashRadius: 1,
                      padding: EdgeInsets.all(0),
                      icon: Icon(
                        Icons.camera,
                        color: primary,
                      ),
                      onPressed: () async {
                        await ImagePicker()
                            .getImage(source: ImageSource.camera)
                            .then((PickedFile? value) {
                          if (value != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SendImage(
                                      image: File(value.path),
                                      hash: widget.hash,
                                      user: widget.user)),
                            );
                          }
                        });
                      },
                    ),

                    /// Select photo from gallery
                    IconButton(
                      splashRadius: 1,
                      padding: EdgeInsets.all(0),
                      icon: Icon(
                        Icons.image,
                        color: primary,
                      ),
                      onPressed: () async {
                        await ImagePicker()
                            .getImage(source: ImageSource.gallery)
                            .then((PickedFile? value) {
                          if (value != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SendImage(
                                      image: File(value.path),
                                      hash: widget.hash,
                                      user: widget.user)),
                            );
                          }
                        });
                      },
                    ),

                    /// Message box
                    Expanded(
                      child: TextFormField(
                        controller: messageTextController,
                        keyboardType: TextInputType.multiline,
                        maxLines: 5,
                        minLines: 1,
                        onChanged: (value) {
                          messageText = value;
                        },
                        decoration: InputDecoration(
                          hintText: 'Write message...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    /// Send message
                    IconButton(
                      icon: Icon(
                        Icons.send,
                        color: primary,
                      ),
                      splashRadius: 1,
                      onPressed: () {
                        if (messageText == null || messageText!.trim() == '') {
                          return;
                        }
                        messageText = messageText!.trimRight();
                        messageText = messageText!.trimLeft();
                        if (widget.hash.length != 18) {
                          firstMessage(widget.hash, widget.user);
                        }
                        messageTextController.clear();
                        _firestore.collection(widget.hash).add({
                          'text': messageText,
                          'sender': currentUser!.email != null &&
                                  currentUser!.email!.isNotEmpty
                              ? currentUser!.email
                              : currentUser!.phoneNumber,
                          'time': DateTime.now().toIso8601String().toString()
                        });

                        sendNotification(
                            widget.hash, messageText!, widget.user.token);
                        updateTime(widget.hash, messageText!);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Get messages from firebase
class MessageStream extends StatelessWidget {
  final String hash;
  MessageStream({required this.hash});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection(hash).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }

        var notSortedMessages = snapshot.data!.docs;

        /// Sort messages according to time
        notSortedMessages.sort((a, b) => a['time'].compareTo(b['time']));

        var messages = List.from(notSortedMessages.reversed);

        List<Bubble> messageBubbles = [];
        body = 'Chat ' + '\n\n';
        for (var message in messages) {
          final messageText = message.data()['text'];
          final messageSender = message.data()['sender'];
          final messageTime = message.data()['time'];
          final messageImage = message.data()['img'];
          final messageCall = message.data()['call'];

          DateTime time = DateTime.parse(messageTime);

          if (!(messageCall ?? false) && !(messageImage ?? false)) {
            body += messageSender +
                ' (' +
                time.day.toString() +
                ' ' +
                shortHandMonths[time.month - 1] +
                ' ' +
                formatTime('0' + time.hour.toString()) +
                ':' +
                formatTime('0' + time.minute.toString()) +
                ') : ' +
                messageText +
                '\n\n';
          }
          final messageBubble = Bubble(
            hash: hash,
            message: messageText,
            isMe: messageSender ==
                (currentUser!.email != null && currentUser!.email!.isNotEmpty
                    ? currentUser!.email
                    : currentUser!.phoneNumber),
            sender: messageSender,
            image: messageImage ?? false,
            call: messageCall ?? false,
            time: time,
          );
          messageBubbles.add(messageBubble);
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}

/// Chat message buble
class Bubble extends StatelessWidget {
  final bool isMe;
  final bool image;
  final bool call;
  final String message;
  final String sender;
  final String hash;
  final DateTime time;

  Bubble(
      {required this.message,
      required this.isMe,
      required this.sender,
      required this.hash,
      required this.image,
      required this.call,
      required this.time});

  Widget build(BuildContext context) {
    return call
        ?

        /// New call start
        Padding(
            padding: const EdgeInsets.all(10.0),
            child: GestureDetector(
              onTap: () {
                JitsiMeeting.joinMeeting(
                    hash.endsWith('!@#%^&*(') ? hash.substring(0, 10) : hash,
                    'Meet',
                    false,
                    false);
              },
              child: Container(
                padding: EdgeInsets.all(12.h),
                decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.all(
                      Radius.circular(15),
                    )),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                          color: Colors.white, fontSize: 15),
                    ),
                    Text(
                      'Tap to join the meeting',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w200),
                    )
                  ],
                ),
              ),
            ),
          )
        : GestureDetector(
            onLongPress: () {
              if (!image) {
                FlutterClipboard.copy(message)
                    .then((value) => toast('Message copied'));
              }
            },
            child: Container(
              margin: EdgeInsets.all(5),
              padding:
                  isMe ? EdgeInsets.only(left: 40) : EdgeInsets.only(right: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Column(
                    mainAxisAlignment:
                        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: <Widget>[
                      hash.length == 18 && !isMe
                          ? Text(
                              sender,
                              style: GoogleFonts.montserrat(fontSize: 12.0),
                            )
                          : Container(),
                      image
                          ?

                          /// Image in chat
                          Container(
                              padding: EdgeInsets.only(
                                  top: 10.0, bottom: 10.0, left: 10.0),
                              child: Material(
                                elevation: 7.0,
                                borderRadius: isMe
                                    ? BorderRadius.only(
                                        topRight: Radius.circular(15),
                                        topLeft: Radius.circular(15),
                                        bottomRight: Radius.circular(0),
                                        bottomLeft: Radius.circular(15),
                                      )
                                    : BorderRadius.only(
                                        topRight: Radius.circular(15),
                                        topLeft: Radius.circular(15),
                                        bottomRight: Radius.circular(15),
                                        bottomLeft: Radius.circular(0),
                                      ),
                                color: isMe ? light : primary.withOpacity(0.3),
                                child: Padding(
                                  padding: EdgeInsets.all(1.0),
                                  child: Column(
                                    mainAxisAlignment: isMe
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ImageView(
                                                          url: this.message)));
                                        },
                                        child: CachedNetworkImage(
                                          placeholder: (context, url) =>
                                              Container(
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                     primary),
                                            ),
                                            width: 250.0,
                                            height: 250.0,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                  bottomRight:
                                                      Radius.circular(30.0),
                                                  topLeft:
                                                      Radius.circular(30.0),
                                                  bottomLeft:
                                                      Radius.circular(30.0)),
                                            ),
                                          ),
                                          imageUrl: this.message,
                                          width: 200.0,
                                          height: 200.0,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            right: 8.0.h, bottom: 5.h),
                                        child: chatTime(),
                                      )
                                    ],
                                  ),
                                ),
                                clipBehavior: Clip.hardEdge,
                              ),
                            )
                          :

                          /// Text message
                          Container(
                              constraints: BoxConstraints(
                                minWidth: 80.0,
                              ),
                              decoration: BoxDecoration(
                                color: isMe ? light : primary.withOpacity(0.3),
                                borderRadius: isMe
                                    ? BorderRadius.only(
                                        topRight: Radius.circular(15),
                                        topLeft: Radius.circular(15),
                                        bottomRight: Radius.circular(0),
                                        bottomLeft: Radius.circular(15),
                                      )
                                    : BorderRadius.only(
                                        topRight: Radius.circular(15),
                                        topLeft: Radius.circular(15),
                                        bottomRight: Radius.circular(15),
                                        bottomLeft: Radius.circular(0),
                                      ),
                              ),
                              child: Stack(
                                children: [
                                  Container(
                                    padding:
                                        EdgeInsets.fromLTRB(10, 10, 10, 14),
                                    child: Text(
                                      message,
                                      textAlign: isMe
                                          ? TextAlign.end
                                          : TextAlign.start,
                                      style: GoogleFonts.montserrat(),
                                    ),
                                  ),
                                  Positioned(
                                      bottom: 2,
                                      right: isMe ? 6 : 8,
                                      child: chatTime())
                                ],
                              ),
                            ),
                    ],
                  )
                ],
              ),
            ),
          );
  }

  /// UI for message timestamp
  Text chatTime() {
    return Text(
      time.day.toString() +
          ' ' +
          shortHandMonths[time.month - 1] +
          ' ' +
          formatTime('0' + time.hour.toString()) +
          ' : ' +
          formatTime('0' + time.minute.toString()),
      style: GoogleFonts.montserrat(
        fontSize: 9.0,
        fontWeight: FontWeight.w300,
      ),
    );
  }
}

String formatTime(String time) {
  return time.substring(time.length - 2);
}
