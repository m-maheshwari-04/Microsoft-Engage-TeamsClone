import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:team_clone/Notes/database.dart';
import 'package:team_clone/Notes/edit.dart';
import 'package:team_clone/constants.dart';
import 'models.dart';

/// Implements a flutter widget that renders the view note screen
class ViewNotePage extends StatefulWidget {
  /// function passed to get latest data from database
  final Function() triggerRefetch;

  /// Used when we are editing a note
  final NotesModel currentNote;
  ViewNotePage({required this.triggerRefetch, required this.currentNote});

  @override
  _ViewNotePageState createState() => _ViewNotePageState();
}

class _ViewNotePageState extends State<ViewNotePage> {
  /// UI for viewing a note
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
              icon: Icon(widget.currentNote.isImportant
                  ? Icons.flag
                  : Icons.outlined_flag),
              onPressed: () {
                toggleImportant();
              },
            ),
            IconButton(
              tooltip: 'Delete',
              icon: Icon(Icons.delete_outline),
              onPressed: handleDelete,
            ),
            IconButton(
              tooltip: 'Edit',
              icon: Icon(Icons.edit),
              onPressed: handleEdit,
            ),
          ],
        ),
        body: ListView(
          physics: BouncingScrollPhysics(),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                  left: 24.0, right: 24.0, top: 40.0, bottom: 16),
              child: Text(
                widget.currentNote.title,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w700,
                  fontSize: 36,
                ),
                overflow: TextOverflow.visible,
                softWrap: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Text(
                DateFormat.yMd().add_jm().format(widget.currentNote.date),
                style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w500, color: Colors.grey.shade500),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 24.0, top: 36, bottom: 24, right: 24),
              child: Text(
                widget.currentNote.content,
                style: GoogleFonts.montserrat(
                    fontSize: 18, fontWeight: FontWeight.w500),
              ),
            )
          ],
        ));
  }

  void handleSave() async {
    await NotesDatabaseService.db.updateNoteInDB(widget.currentNote);
    widget.triggerRefetch();
  }

  void toggleImportant() {
    setState(() {
      widget.currentNote.isImportant = !widget.currentNote.isImportant;
    });
    handleSave();
  }

  void handleEdit() {
    Navigator.pop(context);
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => EditNotePage(
                existingNote: widget.currentNote,
                triggerRefetch: widget.triggerRefetch,
              )),
    );
  }

  void handleDelete() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                  await NotesDatabaseService.db
                      .deleteNoteInDB(widget.currentNote);
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
