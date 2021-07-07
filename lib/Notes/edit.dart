import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/painting.dart' as prefix0;
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:team_clone/constants.dart';
import 'database.dart';
import 'models.dart';

class EditNotePage extends StatefulWidget {
  final Function() triggerRefetch;
  final NotesModel? existingNote;
  EditNotePage({required this.triggerRefetch, this.existingNote});

  @override
  _EditNotePageState createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: isDark ? dark : Colors.white,
        appBar: AppBar(
          elevation: 0.4,
          backgroundColor: isDark ? dark : Colors.white,
          iconTheme: IconThemeData(color: !isDark ? dark : Colors.white),
          title: Text(
            'Note',
            style: TextStyle(color: !isDark ? dark : Colors.white),
          ),
          actions: <Widget>[
            Spacer(),
            IconButton(
              tooltip: 'Mark note as important',
              icon: Icon(
                  currentNote!.isImportant ? Icons.flag : Icons.outlined_flag),
              color: !isDark ? dark : Colors.white,
              onPressed: titleController.text.trim().isNotEmpty &&
                      contentController.text.trim().isNotEmpty
                  ? toggleImportant
                  : null,
            ),
            IconButton(
              tooltip: 'Delete',
              icon: Icon(Icons.delete_outline),
              color: !isDark ? dark : Colors.white,
              onPressed: () {
                handleDelete();
              },
            ),
            AnimatedContainer(
              margin: EdgeInsets.only(left: 10),
              duration: Duration(milliseconds: 200),
              width: isModified ? 100 : 0,
              height: 42,
              curve: Curves.decelerate,
              child: RaisedButton.icon(
                color: light,
                textColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(100),
                        bottomLeft: Radius.circular(100))),
                icon: Icon(
                  Icons.done,
                  color: Colors.white,
                ),
                label: Text(
                  'SAVE',
                  style: TextStyle(letterSpacing: 1),
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
                focusNode: contentFocus,
                controller: contentController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                onChanged: (value) {
                  setState(() {
                    isModified = true;
                  });
                },
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                decoration: InputDecoration.collapsed(
                  hintText: 'Start typing...',
                  hintStyle: TextStyle(
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
    Navigator.pop(context);
  }

  void toggleImportant() {
    setState(() {
      currentNote!.isImportant = !currentNote!.isImportant;
    });
    handleSave();
  }

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
              title: Text('Delete Note'),
              content: Text('This note will be deleted permanently'),
              actions: <Widget>[
                FlatButton(
                  child: Text('CANCEL',
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text('DELETE',
                      style: prefix0.TextStyle(
                          color: Colors.red.shade300,
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
