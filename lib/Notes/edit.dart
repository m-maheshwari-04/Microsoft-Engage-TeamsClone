import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:team_clone/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'database.dart';
import 'models.dart';

/// Implements a flutter widget that renders the editing/new note screen
class EditNotePage extends StatefulWidget {
  /// function passed to get latest data from database
  final Function() triggerRefetch;

  /// Used when we are editing a note
  final NotesModel? existingNote;
  EditNotePage({required this.triggerRefetch, this.existingNote});

  @override
  _EditNotePageState createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  /// Used to check if any changes are made
  bool isModified = false;
  bool isNoteNew = true;
  FocusNode titleFocus = FocusNode();
  FocusNode contentFocus = FocusNode();

  NotesModel? currentNote;
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  @override
  void initState() {
    super.initState();

    /// Editing a note or creating a new note
    if (widget.existingNote == null) {
      currentNote = NotesModel(
          content: '', title: '', date: DateTime.now(), isImportant: false);
      isNoteNew = true;
    } else {
      currentNote = widget.existingNote;
      isNoteNew = false;
    }
    titleController.text = currentNote!.title;
    contentController.text = currentNote!.content;
  }

  /// UI of Editing screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: dark,
        appBar: AppBar(
          elevation: 0.4,
          title: Text(
            'Note',
            style: GoogleFonts.montserrat(),
          ),
          actions: <Widget>[
            Spacer(),
            IconButton(
              tooltip: 'Mark note as important',
              icon: Icon(
                  currentNote!.isImportant ? Icons.flag : Icons.outlined_flag),
              onPressed: titleController.text.trim().isNotEmpty &&
                      contentController.text.trim().isNotEmpty
                  ? toggleImportant
                  : null,
            ),
            IconButton(
              tooltip: 'Delete',
              icon: Icon(Icons.delete_outline),
              onPressed: () {
                handleDelete();
              },
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              width: isModified ? 105.w : 0,
              height: 42,
              curve: Curves.decelerate,
              child: RaisedButton.icon(
                color: primary,
                textColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(80),
                        bottomLeft: Radius.circular(80))),
                icon: Icon(
                  Icons.done,
                  color: Colors.white,
                ),
                label: Text(
                  'SAVE',
                  style: GoogleFonts.montserrat(
                      letterSpacing: 1, color: Colors.white),
                ),
                onPressed: handleSave,
              ),
            )
          ],
        ),
        body: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                cursorColor: isDark ? Colors.white70 : Colors.black87,
                focusNode: titleFocus,
                autofocus: true,
                controller: titleController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                onSubmitted: (text) {
                  titleFocus.unfocus();
                  FocusScope.of(context).requestFocus(contentFocus);
                },
                onChanged: (value) {
                  setState(() {
                    isModified = true;
                  });
                },
                textInputAction: TextInputAction.next,
                style: GoogleFonts.montserrat(
                    fontSize: 32, fontWeight: FontWeight.w700),
                decoration: InputDecoration.collapsed(
                  hintText: 'Enter a title',
                  hintStyle: GoogleFonts.montserrat(
                      color: Colors.grey.shade400,
                      fontSize: 32,
                      fontWeight: FontWeight.w700),
                  border: InputBorder.none,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                cursorColor: isDark ? Colors.white70 : Colors.black87,
                focusNode: contentFocus,
                controller: contentController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                onChanged: (value) {
                  setState(() {
                    isModified = true;
                  });
                },
                style: GoogleFonts.montserrat(
                    fontSize: 18, fontWeight: FontWeight.w500),
                decoration: InputDecoration.collapsed(
                  hintText: 'Start typing...',
                  hintStyle: GoogleFonts.montserrat(
                      color: Colors.grey.shade400,
                      fontSize: 18,
                      fontWeight: FontWeight.w500),
                  border: InputBorder.none,
                ),
              ),
            )
          ],
        ));
  }

  /// Note is saved in database
  void handleSave() async {
    setState(() {
      currentNote!.title = titleController.text;
      currentNote!.content = contentController.text;
      print('Hey there ${currentNote!.content}');
    });
    if (isNoteNew) {
      var latestNote = await NotesDatabaseService.db.addNoteInDB(currentNote!);
      setState(() {
        currentNote = latestNote;
      });
    } else {
      await NotesDatabaseService.db.updateNoteInDB(currentNote!);
    }
    setState(() {
      isNoteNew = false;
      isModified = false;
    });
    widget.triggerRefetch();
    titleFocus.unfocus();
    contentFocus.unfocus();
    contentFocus.unfocus();
  }

  void toggleImportant() {
    setState(() {
      currentNote!.isImportant = !currentNote!.isImportant;
    });
  }

  /// Delete note from database
  void handleDelete() async {
    if (isNoteNew) {
      Navigator.pop(context);
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              backgroundColor: light,
              title: Text('Delete Note'),
              content: Text('This note will be deleted permanently'),
              actions: <Widget>[
                FlatButton(
                  child: Text('CANCEL',
                      style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w500, letterSpacing: 1)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text('DELETE',
                      style: GoogleFonts.montserrat(
                          color: primary,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1)),
                  onPressed: () async {
                    await NotesDatabaseService.db.deleteNoteInDB(currentNote!);
                    widget.triggerRefetch();
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
    }
  }
}
