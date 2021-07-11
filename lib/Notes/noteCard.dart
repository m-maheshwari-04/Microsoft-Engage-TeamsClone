import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:team_clone/Notes/models.dart';
import 'package:team_clone/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// UI of each note (NotesPage)
class NoteCardComponent extends StatelessWidget {
  NoteCardComponent({required this.noteData, required this.onTapAction});

  final NotesModel noteData;
  final Function(NotesModel noteData) onTapAction;

  @override
  Widget build(BuildContext context) {
    String neatDate = DateFormat.yMd().add_jm().format(noteData.date);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.h), color: light),
      child: Material(
        borderRadius: BorderRadius.circular(12.h),
        clipBehavior: Clip.antiAlias,
        color: light,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            onTapAction(noteData);
          },
          child: Container(
            padding: EdgeInsets.all(12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${noteData.title.trim().length <= 20 ? noteData.title.trim() : noteData.title.trim().substring(0, 20) + '...'}',
                  style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: noteData.isImportant
                          ? FontWeight.w800
                          : FontWeight.normal),
                ),
                Container(
                  margin: EdgeInsets.only(top: 8.h),
                  child: Text(
                    '${noteData.content.trim().split('\n').first.length <= 30 ? noteData.content.trim().split('\n').first : noteData.content.trim().split('\n').first.substring(0, 30) + '...'}',
                    style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: isDark ? Colors.grey.shade100 : Colors.black38),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 12.h),
                  alignment: Alignment.centerRight,
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.flag,
                          size: 16,
                          color: noteData.isImportant
                              ? primary
                              : Colors.transparent),
                      Spacer(),
                      Text(
                        '$neatDate',
                        textAlign: TextAlign.right,
                        style: GoogleFonts.montserrat(
                            fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxShadow buildBoxShadow(Color color, BuildContext context) {
    if (isDark) {
      return BoxShadow(
          color: noteData.isImportant == true
              ? Colors.black.withAlpha(100)
              : Colors.black.withAlpha(10),
          blurRadius: 8,
          offset: Offset(0, 8));
    }
    return BoxShadow(
        color: noteData.isImportant == true
            ? color.withAlpha(60)
            : color.withAlpha(25),
        blurRadius: 8,
        offset: Offset(0, 8));
  }
}
