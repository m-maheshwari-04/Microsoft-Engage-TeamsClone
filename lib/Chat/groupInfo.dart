import 'dart:ui';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:team_clone/Chat/avatar.dart';
import 'package:team_clone/Chat/user_model.dart';
import 'package:team_clone/Login/AfterLogin/Profile.dart';
import 'package:team_clone/constants.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Widget/ProfilePic.dart';

var progress;

/// Group Info widget
class GroupInfo extends StatefulWidget {
  final String hash;
  final UserModel user;
  GroupInfo({required this.hash, required this.user});

  @override
  _GroupInfoState createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  late TextEditingController groupName;
  List allChats = [];

  Map<String, bool> selected = Map();

  /// UI of user list
  Widget buildUsers(UserModel user, BuildContext context) {
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
    groupName = TextEditingController(text: widget.user.name);
    getUsers();
  }

  /// Initializing list specifying whether user present in the group or not
  void getUsers() async {
    allChats.clear();
    allUsers.forEach((key, value) {
      if (currentUser!.uid != key) allChats.add(value);
    });

    widget.user.members!.forEach((element) {
      selected[element] = true;
    });
    setState(() {});
  }

  /// UI of group info
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: dark,
        appBar: AppBar(
          elevation: 0.4,
          backgroundColor: bar,
          title: Text(
            'Edit group details',
            style: GoogleFonts.montserrat(fontSize: 16.sp),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.done,
              ),
              onPressed: () async {
                /// Updating group info
                progress.show();

                String imgUrl = defaultGroup;

                if (pickedImage != null) {
                  final file = File(pickedImage!.path);
                  TaskSnapshot upload = await FirebaseStorage.instance
                      .ref()
                      .child('profile')
                      .child(widget.user.uid)
                      .putFile(file);
                  if (upload.state == TaskState.success) {
                    imgUrl = await upload.ref.getDownloadURL();
                  }
                }

                widget.user.members!.forEach((element) {
                  if (selected[element] == false) {
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(element)
                        .update({
                      'groups': FieldValue.arrayRemove([widget.user.uid])
                    });
                  }
                });

                List users = [];

                selected.forEach((key, value) {
                  if (value) {
                    users.add(key);
                  }
                });

                FirebaseFirestore.instance
                    .collection('group')
                    .doc(widget.user.uid)
                    .set({
                  'name': groupName.text.length == 0
                      ? widget.user.name
                      : groupName.text,
                  'id': currentUser!.email != null &&
                          currentUser!.email!.isNotEmpty
                      ? currentUser!.email
                      : currentUser!.phoneNumber,
                  'img': imgUrl,
                  'members': users,
                  'uid': widget.user.uid
                });

                users.forEach((element) {
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(element)
                      .update({
                    'groups': FieldValue.arrayUnion([widget.user.uid])
                  });
                });

                progress.dismiss();

                setState(() {});
                pickedImage = null;
                Navigator.pop(context);
              },
            )
          ],
        ),
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
                        child: GestureDetector(
                          onTap: () async {
                            await chooseDialog();
                            setState(() {});
                          },
                          child: pickedImage == null
                              ? CircleAvatar(
                                  radius: 60,
                                  backgroundImage: NetworkImage(defaultGroup))
                              : CircleAvatar(
                                  radius: 60,
                                  backgroundImage: FileImage(pickedImage!),
                                ),
                        ),
                      ),
                      backgroundColor: light,
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
                      'Add / Remove users from this group:',
                      maxLines: 3,
                      style: GoogleFonts.montserrat(
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 12.0.w),
                      itemCount: allChats.length,
                      itemBuilder: (BuildContext ctx, int index) =>
                          buildUsers(allChats[index], context),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
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
