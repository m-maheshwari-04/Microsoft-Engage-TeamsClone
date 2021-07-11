import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:team_clone/Widget/Toast.dart';
import 'package:team_clone/constants.dart';
import 'package:team_clone/nav_bar_file.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../Widget/ProfilePic.dart';

final _firestore = FirebaseStorage.instance;
File? pickedImage;
var progress;

class Profile extends StatefulWidget {
  final bool? edit;
  Profile({this.edit});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final name = TextEditingController(text: currentUser!.displayName ?? "");
  String photoUrl = defaultProfile;

  @override
  void initState() {
    super.initState();
    pickedImage = null;
    if (currentUser!.photoURL != null) {
      photoUrl = currentUser!.photoURL!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: dark,
        body: ProgressHUD(
          indicatorColor: primary,
          backgroundColor: Colors.transparent,
          borderColor: Colors.transparent,
          child: Builder(
            builder: (context) {
              progress = ProgressHUD.of(context);
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 20.h,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 30.0, left: 20, right: 30, bottom: 15),
                      child: Text(
                        "Your Profile",
                        style: GoogleFonts.montserrat(
                          textStyle: GoogleFonts.montserrat(
                              fontSize: 24, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 85.0,
                          backgroundColor: light,
                          child: CircleAvatar(
                            radius: 82.0,
                            child: GestureDetector(
                              onTap: () async {
                                await chooseDialog();
                                setState(() {});
                              },
                              child: ClipOval(
                                child: pickedImage == null
                                    ? CircleAvatar(
                                        radius: 100,
                                        backgroundImage: NetworkImage(photoUrl))
                                    : CircleAvatar(
                                        radius: 100,
                                        backgroundImage:
                                            FileImage(pickedImage!),
                                      ),
                              ),
                            ),
                            backgroundColor: light,
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            await chooseDialog();
                            setState(() {});
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 25.0),
                            child: Text(
                              'Edit image',
                              maxLines: 1,
                              style: GoogleFonts.montserrat(
                                color: isDark ? Colors.white : Colors.black,
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.all(15.0.h),
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                            color: light,
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(color: light)),
                        child: TextFormField(
                          cursorColor: isDark ? Colors.white70 : Colors.black87,
                          style: GoogleFonts.montserrat(),
                          controller: name,
                          decoration: InputDecoration(
                            hintText: "Your name",
                            hintStyle:
                                GoogleFonts.montserrat(color: Colors.grey),
                            labelStyle:
                                GoogleFonts.montserrat(color: Colors.grey),
                            alignLabelWithHint: true,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 10),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.transparent, width: 0),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.transparent, width: 0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(25.0.h),
                          child: Text(
                            'Your picture and name will be visible to others on Teams. People can find you on Teams by:',
                            maxLines: 3,
                            style: GoogleFonts.montserrat(
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 8.h, horizontal: 25.0.w),
                          child: Text(
                            currentUser!.email ?? currentUser!.phoneNumber!,
                            maxLines: 1,
                            style: GoogleFonts.montserrat(
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 100.h,
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                            primary: primary),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 100),
                          child: Text(
                            "Continue",
                            style: GoogleFonts.montserrat(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        onPressed: () async {
                          if (name.text.isEmpty) {
                            toast("Enter your name");
                            return;
                          }

                          progress.show();

                          await Future.wait([updateName(), updateImage()])
                              .then((List responses) async {
                            currentUser = await FirebaseAuth.instance.currentUser;
                          });

                          progress.dismiss();

                          String? token =
                              await FirebaseMessaging.instance.getToken();

                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(currentUser!.uid)
                              .set({
                            'name': currentUser!.displayName,
                            'id': currentUser!.email != null &&
                                    currentUser!.email!.isNotEmpty
                                ? currentUser!.email
                                : currentUser!.phoneNumber,
                            'img': currentUser!.photoURL,
                            'uid': currentUser!.uid,
                            'token': token ?? ''
                          }, SetOptions(merge: true));

                          setState(() {});
                          pickedImage = null;
                          if (widget.edit ?? false) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NavBarClass(0)),
                            );
                          }
                        }),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future updateName() async {
    return await currentUser!.updateDisplayName(name.text);
  }

  Future updateImage() async {
    String imgUrl = photoUrl;
    if (pickedImage != null) {
      final file = File(pickedImage!.path);
      TaskSnapshot upload = await _firestore
          .ref()
          .child('profile')
          .child(currentUser!.uid)
          .putFile(file);
      if (upload.state == TaskState.success) {
        imgUrl = await upload.ref.getDownloadURL();
      }
    }
    return await currentUser!.updatePhotoURL(imgUrl);
  }

  /// Select image from gallery or take new picture
  Future<void> chooseDialog() {
    return showDialog(
      context: context,
      builder: (ctx) => Dialog(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          height: 112,
          child: Column(
            children: <Widget>[
              FlatButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await ImagePicker()
                      .getImage(source: ImageSource.gallery)
                      .then((PickedFile? value) {
                    if (value != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ProfilePic(image: File(value.path))),
                      ).then((value) => setState(() {}));
                    }
                  });
                },
                child: Text(
                  'CHOOSE FROM GALLERY',
                ),
              ),
              Divider(),
              FlatButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await ImagePicker()
                      .getImage(source: ImageSource.camera)
                      .then((PickedFile? value) {
                    if (value != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ProfilePic(image: File(value.path))),
                      ).then((value) => setState(() {}));
                    }
                  });
                },
                child: Text('TAKE PHOTO'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
