import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_clone/Calendar/notifications.dart';
import 'package:team_clone/Widget/Toast.dart';
import 'package:team_clone/constants.dart';

/// Dialog for adding new task
class AddTask extends StatefulWidget {
  final int date;
  final int month;
  final int year;

  AddTask({required this.year, required this.month, required this.date});

  @override
  _AddTaskState createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  TextEditingController _editingControllerTitle = TextEditingController();
  TextEditingController _editingControllerDescription = TextEditingController();
  DateTime _dateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  /// Add task dialog UI
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      elevation: 16.0.h,
      child: Container(
        padding: EdgeInsets.all(10),
        height: 400.h,
        decoration: BoxDecoration(
          color: light,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 40.w,
                  ),
                  Text(
                    'Add Task',
                    style: GoogleFonts.montserrat(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  FlatButton(
                    onPressed: saveTask,
                    child: Icon(Icons.done, size: 30.sp),
                  ),
                ],
              ),
            ),
            fieldName('Task Title'),
            fieldInput(_editingControllerTitle, 'Add Title'),
            fieldName('Description'),
            fieldInput(_editingControllerDescription, 'Add Description'),
            Padding(
              padding: EdgeInsets.only(top: 16.0.h, left: 10.0.w),
              child: Text(
                'Time',
                style: GoogleFonts.montserrat(
                  fontSize: 14.sp,
                ),
              ),
            ),
            buildTimePicker(),
          ],
        ),
      ),
    );
  }

  /// Title and description input fields
  Widget fieldInput(TextEditingController controller, String hint) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: TextField(
        controller: controller,
        cursorColor: isDark ? Colors.white70 : Colors.black87,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              GoogleFonts.montserrat(fontSize: 16.sp, color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
          isDense: true,
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          border:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        ),
        style: GoogleFonts.montserrat(
          fontSize: 18,
        ),
        textInputAction:
            hint == 'Add Title' ? TextInputAction.next : TextInputAction.done,
      ),
    );
  }

  Widget fieldName(String text) {
    return Padding(
      padding: EdgeInsets.only(top: 16.0, left: 10.0),
      child: Text(
        text,
        style: GoogleFonts.montserrat(
          fontSize: 14.sp,
        ),
      ),
    );
  }

  /// Adding task to calendar
  void saveTask() async {
    if (_editingControllerDescription.text.isEmpty ||
        _editingControllerTitle.text.isEmpty) {
      toast("Fill all the fields");
      return;
    }

    /// Setting notification for added task using local notications package
    taskReminder(
        _editingControllerTitle.text,
        _editingControllerDescription.text,
        widget.year,
        widget.month,
        widget.date,
        _dateTime.hour,
        _dateTime.minute);

    /// Using the task date as key for accessing it later
    DateTime taskDate = DateTime(widget.year, widget.month, widget.date);
    String taskKey = taskDate.toString();

    if (tasks[taskKey] != null) {
      tasks[taskKey]!.insert(0, [
        _dateTime.hour,
        _dateTime.minute,
        _editingControllerTitle.text,
        _editingControllerDescription.text,
      ]);
    } else {
      tasks[taskKey] = [
        [
          _dateTime.hour,
          _dateTime.minute,
          _editingControllerTitle.text,
          _editingControllerDescription.text,
        ]
      ];
    }

    /// Sorting tasks of a day according to their time
    tasks[taskKey].sort((List<Object> a, List<Object> b) {
      if (int.parse(a.elementAt(0).toString()) <
          int.parse(b.elementAt(0).toString())) {
        return -1;
      } else if (int.parse(a.elementAt(0).toString()) >
          int.parse(b.elementAt(0).toString())) {
        return 1;
      } else if (int.parse(a.elementAt(1).toString()) <
          int.parse(b.elementAt(0).toString())) {
        return -1;
      } else if (int.parse(a.elementAt(1).toString()) >
          int.parse(b.elementAt(0).toString())) {
        return 1;
      }
      return 0;
    });

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('tasks', json.encode(tasks));
    setState(() {});
    Navigator.of(context).pop();
  }

  /// Time picker
  Widget buildTimePicker() => SizedBox(
        height: 120,
        child: CupertinoTheme(
          data: CupertinoThemeData(
            brightness: isDark ? Brightness.dark : Brightness.light,
          ),
          child: CupertinoDatePicker(
            initialDateTime: _dateTime,
            mode: CupertinoDatePickerMode.time,
            minuteInterval: 1,
            onDateTimeChanged: (dateTime) =>
                setState(() => this._dateTime = dateTime),
          ),
        ),
      );
}
