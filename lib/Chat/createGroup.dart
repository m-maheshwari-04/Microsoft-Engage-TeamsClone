import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';
import 'package:team_clone/Chat/avatar.dart';
import 'package:team_clone/Chat/user_model.dart';
import 'package:team_clone/Login/AfterLogin/Profile.dart';
import 'package:team_clone/Widget/Toast.dart';
import 'package:team_clone/constants.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Widget/ProfilePic.dart';

final _firestore = FirebaseStorage.instance;
var progress;

/// Create new group widget
class CreateGroup extends StatefulWidget {
  @override
  _CreateGroupState createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  final groupName = TextEditingController();
  List userList = [];

  Map<String, bool> selected = Map();

  Widget buildUserList(UserModel user, BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        selected[user.uid] = !(selected[user.uid] ?? false);
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
            color: light.withOpacity(
                (selected[user.uid] == null || selected[user.uid] == false)
                    ? 0
                    : 1),
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Row(
          children: [
            Avatar(url: user.imgUrl),
            SizedBox(width: 8.0),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: GoogleFonts.montserrat(
                      fontSize: 15.0, fontWeight: FontWeight.w400),
                ),
                SizedBox(height: 2.0),
                Text(user.id,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                        color: Colors.grey,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w300))
              ],
            )),
            SizedBox(width: 8.0),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  void getUsers() async {
    userList.clear();
    allUsers.forEach((key, value) {
      if (currentUser!.uid != key) userList.add(value);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: dark,
        appBar: AppBar(
            title: Text(
          'New Group Chat',
          style: GoogleFonts.montserrat(),
        )),
        body: ProgressHUD(
          indicatorColor: primary,
          backgroundColor: Colors.transparent,
          borderColor: Colors.transparent,
          child: Builder(
            builder: (context) {
              progress = ProgressHUD.of(context);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: 10.h,
                    width: double.infinity,
                  ),
                  CircleAvatar(
                    radius: 60.0,
                    backgroundColor: light,
                    child: CircleAvatar(
                      radius: 58.0,
                      child: ClipOval(
                        child: pickedImage == null
                            ? CircleAvatar(
                                radius: 60,
                                backgroundImage: NetworkImage(defaultGroup))
                            : CircleAvatar(
                                radius: 60,
                                backgroundImage: FileImage(pickedImage!),
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
                      padding: EdgeInsets.symmetric(vertical: 6.h),
                      child: Text(
                        'Edit image',
                        maxLines: 1,
                        style: GoogleFonts.montserrat(
                          color: isDark?Colors.white:Colors.black,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(10.h),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: Colors.black)),
                    child: TextFormField(
                      cursorColor: Colors.black,
                      style: GoogleFonts.montserrat(
                        color: Colors.black,
                      ),
                      controller: groupName,
                      decoration: InputDecoration(
                        hintText: "Group name",
                        hintStyle: GoogleFonts.montserrat(color: Colors.black),
                        labelStyle: GoogleFonts.montserrat(color: Colors.black),
                        alignLabelWithHint: true,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 10),
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
                  Padding(
                    padding: EdgeInsets.all(12.0.h),
                    child: Text(
                      'Select the people you want to add in this group:',
                      maxLines: 3,
                      style: GoogleFonts.montserrat(
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 12.0.w),
                      itemCount: userList.length,
                      itemBuilder: (BuildContext ctx, int index) =>
                          buildUserList(userList[index], context),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(15.h),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                            primary: primary),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 12.h, horizontal: 100.w),
                          child: Text(
                            "Continue",
                            style: GoogleFonts.montserrat(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        onPressed: () async {
                          if (groupName.text.isEmpty) {
                            toast("Enter group name");
                            return;
                          }
                          progress.show();

                          List users = [];
                          users.add(currentUser!.uid);

                          selected.forEach((key, value) {
                            if (value) {
                              users.add(key);
                            }
                          });

                          if (users.length <= 2) {
                            toast("Add at least 2 users");
                            progress.dismiss();
                            return;
                          }

                          String imgUrl = defaultGroup;
                          String groupId = randomAlphaNumeric(18).toUpperCase();

                          if (pickedImage != null) {
                            final file = File(pickedImage!.path);
                            TaskSnapshot upload = await _firestore
                                .ref()
                                .child('profile')
                                .child(groupId)
                                .putFile(file);
                            if (upload.state == TaskState.success) {
                              imgUrl = await upload.ref.getDownloadURL();
                            }
                          }

                          FirebaseFirestore.instance
                              .collection('group')
                              .doc(groupId)
                              .set({
                            'name': groupName.text,
                            'id': currentUser!.email != null &&
                                    currentUser!.email!.isNotEmpty
                                ? currentUser!.email
                                : currentUser!.phoneNumber,
                            'img': imgUrl,
                            'uid': groupId,
                            'members': users
                          });

                          users.forEach((element) {
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(element)
                                .update({
                              'groups': FieldValue.arrayUnion([groupId])
                            });
                          });

                          FirebaseFirestore.instance
                              .collection('chat')
                              .doc(groupId)
                              .set({
                            'text': '',
                            'sender': currentUser!.email != null &&
                                    currentUser!.email!.isNotEmpty
                                ? currentUser!.email
                                : currentUser!.phoneNumber,
                            'time': DateTime.now().toIso8601String().toString()
                          }, SetOptions(merge: true));

                          progress.dismiss();

                          setState(() {});
                          pickedImage = null;
                          Navigator.pop(context);
                        }),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// Select group image from gallery or take new picture using camera
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
