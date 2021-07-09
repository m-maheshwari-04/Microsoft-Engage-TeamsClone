import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:team_clone/Notes/noteCard.dart';
import 'package:team_clone/Notes/database.dart';
import 'package:team_clone/Notes/view.dart';
import 'package:team_clone/constants.dart';
import 'edit.dart';
import 'models.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  bool isFlagOn = false;
  List<NotesModel> notesList = [];
  TextEditingController searchController = TextEditingController();

  bool isSearchEmpty = true;

  notesFromDB() async {
    var fetchedNotes = await NotesDatabaseService.db.getNotesFromDB();
    notesList = fetchedNotes;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    NotesDatabaseService.db.init();
    notesFromDB();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ? dark : Colors.white,
      appBar: AppBar(title: Text('Notes',style: GoogleFonts.montserrat()), actions: <Widget>[
        GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();

            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) =>
                      EditNotePage(triggerRefetch: notesFromDB)),
            );
          },
          child: Container(
            margin: EdgeInsets.all(6),
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
              border: Border.all(width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.add,
                  size: 14,
                ),
                Text(
                  'Add new note',
                  style: GoogleFonts.montserrat(fontSize: 14),
                )
              ],
            ),
          ),
        ),
      ]),
      body: Column(
        children: [
          searchFilter(),
          Container(
            padding: EdgeInsets.all(8.h),
            alignment: Alignment.center,
            child: isFlagOn
                ? Text('Only showing notes marked important'.toUpperCase(),
                    style:GoogleFonts.montserrat(
                        fontSize: 12,
                        color: isDark ? Colors.white : light,
                        fontWeight: FontWeight.w500))
                : Container(),
          ),
          notesList.length == 0
              ? Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        child: SizedBox(
                          height: 200.h,
                          child: Image(
                            image: AssetImage('images/notes.png'),
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                      ),
                      Text(
                        "No notes available, Create a new note!",
                        style: GoogleFonts.montserrat(
                            fontStyle: FontStyle.normal,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : Expanded(
                  child: ListView(
                    physics: BouncingScrollPhysics(),
                    children: <Widget>[
                      ...notesListBuilder(),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget searchFilter() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              setState(() {
                isFlagOn = !isFlagOn;
              });
            },
            child: Container(
              height: 45.h,
              width: 45.w,
              child: Icon(
                isFlagOn ? Icons.flag : Icons.flag_outlined,
                color: isFlagOn ? light : Colors.grey.shade500,
              ),
              decoration: BoxDecoration(
                  color: isFlagOn ? Colors.white : Colors.transparent,
                  border: Border.all(
                    width: isFlagOn ? 0 : 1,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(18))),
            ),
          ),
          Expanded(
            child: Padding(
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
                          handleSearch(value);
                        },
                        style: GoogleFonts.montserrat(
                            color: isDark ? light : Colors.white,
                            fontSize: 16.0),
                        decoration: InputDecoration(
                            hintText: 'Search...',
                            hintStyle: GoogleFonts.montserrat(
                              color: isDark ? light : Colors.white,
                            ),
                            filled: false,
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 4.0, vertical: 12.0)),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: isSearchEmpty
                            ? Colors.transparent
                            : isDark
                                ? dark
                                : Colors.white,
                      ),
                      onPressed: cancelSearch,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> notesListBuilder() {
    List<Widget> noteComponentsList = [];
    notesList.sort((a, b) {
      return b.date.compareTo(a.date);
    });
    if (searchController.text.isNotEmpty) {
      notesList.forEach((note) {
        if (note.title
                .toLowerCase()
                .contains(searchController.text.toLowerCase()) ||
            note.content
                .toLowerCase()
                .contains(searchController.text.toLowerCase()))
          noteComponentsList.add(NoteCardComponent(
            noteData: note,
            onTapAction: openNoteToRead,
          ));
      });
      return noteComponentsList;
    }
    if (isFlagOn) {
      notesList.forEach((note) {
        if (note.isImportant)
          noteComponentsList.add(NoteCardComponent(
            noteData: note,
            onTapAction: openNoteToRead,
          ));
      });
    } else {
      notesList.forEach((note) {
        noteComponentsList.add(NoteCardComponent(
          noteData: note,
          onTapAction: openNoteToRead,
        ));
      });
    }
    return noteComponentsList;
  }

  void handleSearch(String value) {
    if (value.isNotEmpty) {
      setState(() {
        isSearchEmpty = false;
      });
    } else {
      setState(() {
        isSearchEmpty = true;
      });
    }
  }

  openNoteToRead(NotesModel noteData) async {
    await Future.delayed(Duration(milliseconds: 230), () {});
    FocusScope.of(context).unfocus();

    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) =>
              ViewNotePage(triggerRefetch: notesFromDB, currentNote: noteData)),
    );

    await Future.delayed(Duration(milliseconds: 300), () {});
  }

  void cancelSearch() {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      searchController.clear();
      isSearchEmpty = true;
    });
  }
}
