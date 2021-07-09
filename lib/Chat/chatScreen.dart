import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:team_clone/Chat/allUsers.dart';
import 'chat.dart';
import 'package:team_clone/Chat/createGroup.dart';
import 'package:team_clone/constants.dart';
import 'user_model.dart';
import 'avatar.dart';

final _firestore = FirebaseFirestore.instance;

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController searchController = TextEditingController();
  List recentChats = [];
  List allRecentChats = [];
  bool createGroup = false;
  bool loader = false;

  Widget buildRecentChat(UserModel user, BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        String hash = user.uid;

        if (hash.length != 18) {
          if (currentUser!.uid.compareTo(user.uid) < 0) {
            hash = currentUser!.uid + user.uid;
          } else {
            hash = user.uid + currentUser!.uid;
          }
        }
        hash = hash.toUpperCase();
        print(hash);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Chat(
              user: user,
              hash: hash,
            ),
          ),
        ).then((value) => getChats());
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6.0.h),
        child: Row(
          children: [
            Avatar(url: user.imgUrl),
            SizedBox(width: 8.0.w),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style:GoogleFonts.montserrat(fontSize: 15.0, fontWeight: FontWeight.w400),
                ),
                SizedBox(height: 2.0.h),
                if (user.uid.length != 18)
                  Text(user.id,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(
                          color: Colors.grey,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w200))
              ],
            )),
            SizedBox(width: 8.0.w),
            Text(
              user.time != null ? chatTime(user.time!) : '',
              style:GoogleFonts.montserrat(fontSize: 12.0),
            )
          ],
        ),
      ),
    );
  }

  String chatTime(DateTime time) {
    return (time.day.toString() +
        ' ' +
        shortHandMonths[time.month - 1] +
        ' ' +
        formatTime('0' + time.hour.toString()) +
        ':' +
        formatTime('0' + time.minute.toString()));
  }

  String formatTime(String time) {
    return time.substring(time.length - 2);
  }

  @override
  void initState() {
    super.initState();
    getChats();
  }

  Future<void> getUsers() async {
    final users = await _firestore.collection('users').get();
    users.docs.forEach((element) {
      allUsers[element.id] = UserModel(
          uid: element['uid'],
          id: element['id'],
          imgUrl: element['img'],
          name: element['name'],
          token: element['token']);
    });
  }

  Future<void> getGroups() async {
    final groups = await _firestore.collection('group').get();
    groups.docs.forEach((element) {
      allGroups[element.id] = UserModel(
          uid: element['uid'],
          id: element['id'],
          imgUrl: element['img'],
          name: element['name'],
          members: element['members']);
    });
  }

  Future<void> getTime() async {
    final time = await _firestore.collection('chat').get();
    time.docs.forEach((element) {
      if (element.id.length == 18) {
        allTime[element.id] = element['time'];
      } else if ((element.id.startsWith(currentUser!.uid.toUpperCase()) ||
          element.id.endsWith(currentUser!.uid.toUpperCase()))) {
        String usr = '';
        if (element.id.startsWith(currentUser!.uid.toUpperCase())) {
          usr = element.id.substring(currentUser!.uid.length);
        } else {
          usr = element.id.substring(0, currentUser!.uid.length);
        }
        allTime[usr] = element['time'];
      }
    });
  }

  Future currentUserData() async {
    return await _firestore.collection('users').doc(currentUser!.uid).get();
  }

  Future<void> getChats() async {
    recentChats.clear();
    allUsers.clear();
    allRecentChats.clear();
    allGroups.clear();
    allTime.clear();

    setState(() {
      loader = true;
    });

    Future.wait([getUsers(), getGroups(), getTime(), currentUserData()])
        .then((List responses) async {
      final current = responses[3];

      if (current.data()!.containsKey('chats')) {
        current['chats'].forEach((element) {
          UserModel newUser = UserModel(
              uid: allUsers[element]!.uid,
              id: allUsers[element]!.id,
              imgUrl: allUsers[element]!.imgUrl,
              name: allUsers[element]!.name,
              time: allTime[element.toString().toUpperCase()] != null
                  ? DateTime.parse(allTime[element.toString().toUpperCase()]!)
                  : null,
              token: allUsers[element]!.token != null
                  ? allUsers[element]!.token
                  : null);

          recentChats.add(newUser);
        });
      }
      if (current.data()!.containsKey('groups')) {
        current['groups'].forEach((element) {
          UserModel newUser = UserModel(
              uid: allGroups[element]!.uid,
              id: allGroups[element]!.id,
              imgUrl: allGroups[element]!.imgUrl,
              name: allGroups[element]!.name,
              time: allTime[element.toString().toUpperCase()] != null
                  ? DateTime.parse(allTime[element.toString().toUpperCase()]!)
                  : null,
              members: allGroups[element]!.members);

          recentChats.add(newUser);
        });
      }

      recentChats.sort((a, b) {
        return b.time.compareTo(a.time);
      });
      allRecentChats = List.from(recentChats);
      setState(() {
        loader = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: isDark ? dark : Colors.white,
          floatingActionButton: SpeedDial(
              icon: Icons.add,
              iconTheme: IconThemeData(color: Colors.white),
              backgroundColor: light,
              children: [
                SpeedDialChild(
                  child: Icon(Icons.person_add, color: Colors.white),
                  backgroundColor: light,
                  onTap: () {
                    Navigator.push(context,
                            MaterialPageRoute(builder: (context) => AllUsers()))
                        .then((value) => getChats());
                  },
                ),
                SpeedDialChild(
                  child: Icon(Icons.group_add_rounded, color: Colors.white),
                  backgroundColor: light,
                  onTap: () {
                    Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CreateGroup()))
                        .then((value) => getChats());
                  },
                ),
              ]),
          body: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(
                      color: !isDark ? dark : Colors.white,
                      borderRadius: BorderRadius.circular(30.0)),
                  child: Row(
                    children: <Widget>[
                      Container(
                          padding: EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                              color: Color(0xfff3f2ee), shape: BoxShape.circle),
                          child: Icon(
                            Icons.search,
                            size: 16.0,
                            color: Theme.of(context).primaryColor,
                          )),
                      SizedBox(width: 12.0),
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          onChanged: (value) {
                            if (value.isEmpty || value.length == 0) {
                              recentChats = List.from(allRecentChats);
                            } else {
                              recentChats.clear();
                              allRecentChats.forEach((element) {
                                if (element.id
                                        .toString()
                                        .toLowerCase()
                                        .startsWith(value.toLowerCase()) ||
                                    element.name
                                        .toString()
                                        .toLowerCase()
                                        .startsWith(value.toLowerCase())) {
                                  recentChats.add(element);
                                }
                              });
                            }
                            setState(() {});
                          },
                          style: GoogleFonts.montserrat(
                              color: isDark ? light : Colors.white,
                              fontSize: 16.0),
                          decoration: InputDecoration(
                              hintText: 'Search...',
                              hintStyle:GoogleFonts.montserrat(
                                color: isDark ? light : Colors.white,
                              ),
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
              loader
                  ? Column(
                      children: [
                        SizedBox(
                          height: 200.h,
                        ),
                        Padding(
                          padding: EdgeInsets.all(30.0.h),
                          child: Container(
                            width: 70.0,
                            height: 70.0,
                            padding: EdgeInsets.all(5.0),
                            child: Center(
                                child: CircularProgressIndicator(
                              color: isDark ? Colors.white : light,
                            )),
                          ),
                        ),
                      ],
                    )
                  : recentChats.length == 0
                      ? Column(
                          children: [
                            Container(
                              margin: EdgeInsets.all(40.h),
                              child: Image(
                                height: 320.h,
                                image: AssetImage('images/noChat.png'),
                                fit: BoxFit.scaleDown,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 20.0),
                              child: Text(
                                "No messages yet,\n start the conversation!",
                                style: GoogleFonts.montserrat(
                                    fontStyle: FontStyle.normal,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        )
                      : Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 12.0),
                            itemCount: recentChats.length,
                            itemBuilder: (BuildContext ctx, int index) =>
                                buildRecentChat(recentChats[index], context),
                          ),
                        )
            ],
          )),
    );
  }
}
