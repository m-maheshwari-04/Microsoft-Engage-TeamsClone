import 'package:flutter/material.dart';
import 'chat.dart';
import 'package:team_clone/constants.dart';
import 'user_model.dart';
import 'avatar.dart';

class AllUsers extends StatefulWidget {
  @override
  _AllUsersState createState() => _AllUsersState();
}

class _AllUsersState extends State<AllUsers> {
  TextEditingController searchController = TextEditingController();
  List chats = [];
  List allChats = [];

  Widget buildRecentChat(UserModel user, BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        String hash;
        if (currentUser!.uid.compareTo(user.uid) < 0) {
          hash = currentUser!.uid + user.uid;
        } else {
          hash = user.uid + currentUser!.uid;
        }
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
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
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 2.0),
                Text(user.id,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400))
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
        backgroundColor: isDark ? dark : Colors.white,
        appBar: AppBar(title: Text('New Chat')),
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
                        style: TextStyle(
                            color: isDark ? light : Colors.white,
                            fontSize: 16.0),
                        decoration: InputDecoration(
                            hintText: 'Search...',
                            hintStyle: TextStyle(
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
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                itemCount: chats.length,
                itemBuilder: (BuildContext ctx, int index) =>
                    buildRecentChat(chats[index], context),
              ),
            )
          ],
        ),
      ),
    );
  }
}
