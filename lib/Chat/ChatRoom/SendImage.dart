import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:team_clone/Chat/ChatRoom/FirstMessage.dart';
import 'Notification.dart';
import 'timeUpdate.dart';
import 'package:team_clone/Chat/user_model.dart';
import '../../constants.dart';

final _firestore = FirebaseFirestore.instance;

/// Send image to chat
class SendImage extends StatefulWidget {
  final File image;
  final String hash;
  final UserModel user;
  SendImage({required this.image, required this.hash, required this.user});

  @override
  _SendImageState createState() => _SendImageState();
}

class _SendImageState extends State<SendImage> {
  late File _imageFile;
  var progress;

  /// Crop image functionality
  Future<Null> _cropImage() async {
    File? croppedFile = await ImageCropper.cropImage(
        sourcePath: _imageFile.path,
        aspectRatioPresets:  [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            activeControlsWidgetColor: primary,
            toolbarColor: primary),
        iosUiSettings: IOSUiSettings(
          title: 'Crop Image',
        ));
    if (croppedFile != null) {
      setState(() {
        _imageFile = croppedFile;
      });
    }
  }

  /// Send image in the chat
  Future<void> sendImage(BuildContext context) async {
    String fileName = basename(_imageFile.path);
    final Reference firebaseStoreReference =
        FirebaseStorage.instance.ref().child(fileName);

    await firebaseStoreReference.putFile(_imageFile);

    if (widget.hash.length != 18) {
      firstMessage(widget.hash, widget.user);
    }

    String url = await firebaseStoreReference.getDownloadURL();
    if (url.trim() != '') {
      _firestore.collection(widget.hash).add({
        'text': url,
        'sender': currentUser!.email != null && currentUser!.email!.isNotEmpty
            ? currentUser!.email
            : currentUser!.phoneNumber,
        'time': DateTime.now().toIso8601String().toString(),
        'img': true,
      });

      sendNotification(widget.hash, 'image', widget.user.token);
      updateTime(widget.hash, 'image');
    }
  }

  @override
  void initState() {
    _imageFile = widget.image;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: ProgressHUD(
          indicatorColor: primary,
          backgroundColor: Colors.transparent,
          borderColor: Colors.transparent,
          child: Builder(builder: (context) {
            progress = ProgressHUD.of(context);
            return Column(
              children: <Widget>[
                Expanded(
                  child: Stack(
                    children: [
                      Center(
                        child: Image.file(
                          _imageFile,
                        ),
                      ),
                      Positioned(
                          top: 5,
                          left: 5,
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 30,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          )),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      child: FlatButton(
                        onPressed: _cropImage,
                        child: Text(
                          'CROP',
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      child: FlatButton(
                        onPressed: () async {
                          progress.show();
                          await sendImage(context);
                          progress.dismiss();
                          Navigator.pop(context);
                        },
                        child: Text(
                          'SEND',
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
