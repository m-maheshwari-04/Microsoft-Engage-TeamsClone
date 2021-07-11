import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:team_clone/Notes/models.dart';

/// Database for storing user notes in device storage
class NotesDatabaseService {
  late String path;

  NotesDatabaseService._();

  static final NotesDatabaseService db = NotesDatabaseService._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await init();
    return _database!;
  }

  /// Initializing database if it is not already initialized
  init() async {
    String path = await getDatabasesPath();
    path = join(path, 'notes.db');

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
          'CREATE TABLE Notes (_id INTEGER PRIMARY KEY, title TEXT, content TEXT, date TEXT, isImportant INTEGER);');
      print('New table created at $path');
    });
  }

  /// getting all notes from database
  Future<List<NotesModel>> getNotesFromDB() async {
    final db = await database;
    List<NotesModel> notesList = [];
    List<Map<String, dynamic>> maps = await db.query('Notes',
        columns: ['_id', 'title', 'content', 'date', 'isImportant']);
    if (maps.length > 0) {
      maps.forEach((map) {
        notesList.add(NotesModel.fromMap(map));
      });
    }
    return notesList;
  }

  /// Update already existing notes
  updateNoteInDB(NotesModel updatedNote) async {
    final db = await database;
    await db.update('Notes', updatedNote.toMap(),
        where: '_id = ?', whereArgs: [updatedNote.id]);
    print('Note updated: ${updatedNote.title} ${updatedNote.content}');
  }

  /// Delete a note from database
  deleteNoteInDB(NotesModel noteToDelete) async {
    final db = await database;
    await db.delete('Notes', where: '_id = ?', whereArgs: [noteToDelete.id]);
    print('Note deleted');
  }

  /// Add new note
  Future<NotesModel> addNoteInDB(NotesModel newNote) async {
    final db = await database;
    if (newNote.title.trim().isEmpty) newNote.title = 'Untitled Note';
    int id = await db.transaction((transaction) {
      return transaction.rawInsert(
          'INSERT into Notes(title, content, date, isImportant) VALUES ("${newNote.title}", "${newNote.content}", "${newNote.date.toIso8601String()}", ${newNote.isImportant == true ? 1 : 0});');
    });
    newNote.id = id;
    return newNote;
  }
}
