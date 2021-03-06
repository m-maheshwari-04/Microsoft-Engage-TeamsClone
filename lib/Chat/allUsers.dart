import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chat.dart';
import 'package:team_clone/constants.dart';
import 'user_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'avatar.dart';

/// UI for selecting a user from all available users
class AllUsers extends StatefulWidget {
  @override
  _AllUsersState createState() => _AllUsersState();
}

class _AllUsersState extends State<AllUsers> {
  TextEditingController searchController = TextEditingController();
  List chats = [];
  List allChats = [];

  Widget buildAllUsers(UserModel user, BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        String hash;
        if (currentUser!.uid.compareTo(user.uid) < 0) {
          hash = currentUser!.uid + user.uid;
        } else {
          hash = user.uid + currentUser!.uid;
        }
        hash = hash.toUpperCase();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Chat(
              user: user,
              hash: hash,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: light,
        ),
        padding: EdgeInsets.symmetric(vertical: 4.0.h,horizontal: 8.w),
        margin: EdgeInsets.only(bottom: 4.h),
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
                  style:GoogleFonts.montserrat(fontSize: 15.0, fontWeight: FontWeight.w400),
                ),
                SizedBox(height: 2.0),
                Text(user.id,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                        color: Colors.grey,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w200))
              ],
            )),
            SizedBox(width: 8.0),
          ],
        ),
      ),
    );
  }

  String formatTime(String time) {
    return time.substring(time.length - 2);
  }

  @override
  void initState() {
    super.initState();
    getChats();
  }

  /// Set all users list
  void getChats() async {
    chats.clear();
    allChats.clear();

    allUsers.forEach((key, value) {
      if (currentUser!.uid != key) chats.add(value);
    });
    allChats = List.from(chats);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: dark,
        appBar: AppBar(title: Text('New Chat',style: GoogleFonts.montserrat(),)),
        body: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                decoration: BoxDecoration(
                    color: light, borderRadius: BorderRadius.circular(30.0)),
                child: Row(
                  children: <Widget>[
                    Container(
                        padding: EdgeInsets.all(6.0),
                        decoration: BoxDecoration(
                            color:dark, shape: BoxShape.circle),
                        child: Icon(
                          Icons.search,
                          size: 16.0,
                        )),
                    SizedBox(width: 12.0),
                    Expanded(
                      child: TextField(
                        cursorColor: isDark?Colors.white70:Colors.black87,
                        controller: searchController,
                        onChanged: (value) {
                          if (value.isEmpty || value.length == 0) {
                            chats = List.from(allChats);
                          } else {
                            chats.clear();
                            allChats.forEach((element) {
                              if (element.id
                                      .toString()
                                      .toLowerCase()
                                      .startsWith(value.toLowerCase()) ||
                                  element.name
                                      .toString()
                                      .toLowerCase()
                                      .startsWith(value.toLowerCase())) {
                                chats.add(element);
                              }
                            });
                          }
                          setState(() {});
                        },
                        style: GoogleFonts.montserrat(fontSize: 16.0),
                        decoration: InputDecoration(
                            hintText: 'Search...',
                            hintStyle: GoogleFonts.montserrat(),
                            filled: false,
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 4.0, vertical: 12.0)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                itemCount: chats.length,
                itemBuilder: (BuildContext ctx, int index) =>
                    buildAllUsers(chats[index], context),
              ),
            )
          ],
        ),
      ),
    );
  }
}
