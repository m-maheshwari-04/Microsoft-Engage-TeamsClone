/// Notes model
/// keep related information of a note together
///
class NotesModel {
  int? id;
  late String title;
  late String content;
  late bool isImportant;
  late DateTime date;

  NotesModel(
      {this.id,
      required this.title,
      required this.content,
      required this.isImportant,
      required this.date});

  NotesModel.fromMap(Map<String, dynamic> map) {
    this.id = map['_id'];
    this.title = map['title'];
    this.content = map['content'];
    this.date = DateTime.parse(map['date']);
    this.isImportant = map['isImportant'] == 1 ? true : false;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': this.id,
      'title': this.title,
      'content': this.content,
      'isImportant': this.isImportant == true ? 1 : 0,
      'date': this.date.toIso8601String()
    };
  }
}
