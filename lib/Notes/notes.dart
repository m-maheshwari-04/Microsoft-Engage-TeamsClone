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

/// Implements a flutter widget that renders the notes screen
///
/// - List of notes from database
/// - New note add
/// - Tap to view complete note
class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  bool isFlagOn = false;
  List<NotesModel> notesList = [];
  TextEditingController searchController = TextEditingController();

  bool isSearchEmpty = true;

  /// fetch notes from database
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
      backgroundColor: dark,
      appBar: AppBar(
        title: Text('Notes', style: GoogleFonts.montserrat()),
      ),

      /// For adding new note
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: primary,
        foregroundColor: primary,
        onPressed: () {
          FocusScope.of(context).unfocus();

          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) =>
                    EditNotePage(triggerRefetch: notesFromDB)),
          );
        },
      ),
      body: Column(
        children: [
          searchFilter(),
          Container(
            padding: EdgeInsets.all(8.h),
            alignment: Alignment.center,
            child: isFlagOn
                ? Text('Only showing notes marked important'.toUpperCase(),
                    style: GoogleFonts.montserrat(
                        fontSize: 12, fontWeight: FontWeight.w500))
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

  /// Search in notes present in database
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
                color: isFlagOn ? Colors.white : Colors.grey.shade500,
              ),
              decoration: BoxDecoration(
                  color: isFlagOn ? primary : Colors.transparent,
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
                    color: light, borderRadius: BorderRadius.circular(30.0)),
                child: Row(
                  children: <Widget>[
                    Container(
                        padding: EdgeInsets.all(6.0),
                        decoration:
                            BoxDecoration(color: dark, shape: BoxShape.circle),
                        child: Icon(
                          Icons.search,
                          size: 16.0,
                        )),
                    SizedBox(width: 12.0),
                    Expanded(
                      child: TextField(
                        cursorColor: isDark ? Colors.white70 : Colors.black87,
                        controller: searchController,
                        onChanged: (value) {
                          handleSearch(value);
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
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: isSearchEmpty
                            ? Colors.transparent
                            : isDark
                                ? Colors.white70
                                : Colors.black87,
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

  /// List of notes(search,flag)
  List<Widget> notesListBuilder() {
    List<Widget> noteComponentsList = [];
    notesList.sort((a, b) {
      return b.date.compareTo(a.date);
    });

    if (searchController.text.isNotEmpty) {
      /// Matching title or content with the search key provided by user
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
      /// Only important notes are returned
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
    FocusScope.of(context).unfocus();

    /// Navigate to View note screen
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) =>
              ViewNotePage(triggerRefetch: notesFromDB, currentNote: noteData)),
    );
  }

  void cancelSearch() {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      searchController.clear();
      isSearchEmpty = true;
    });
  }
}
