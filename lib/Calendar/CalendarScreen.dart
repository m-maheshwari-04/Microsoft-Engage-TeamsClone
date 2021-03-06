import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:team_clone/Calendar/AddTask.dart';
import 'package:team_clone/Calendar/CalendarConstants.dart';
import '../constants.dart';

/// Implements a flutter widget that renders the Calendar screen
///
/// - Calendar
/// - Selected day tasks
class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  var curDate = DateTime.now();
  int date = 1;
  int month = 1;
  int year = 2021;

  List l = [];

  @override
  void initState() {
    super.initState();
    date = curDate.day;
    month = curDate.month;
    year = curDate.year;

    setListDates();
  }

  /// used to set dates according to the weekday
  void setListDates() {
    l.clear();
    int firstDay = DateTime(year, month, 1).weekday;
    int daysInMonth = DateTime(year, month + 1, 0).day;
    if (date > daysInMonth) {
      date = daysInMonth;
    }
    int i = 1;
    while (i <= firstDay) {
      l.add('');
      i++;
    }
    for (i = 1; i <= daysInMonth; i++) {
      l.add(i);
    }
    i = 15;
    while (i > 0) {
      l.add('');
      i--;
    }
  }

  /// UI of each date on calendar
  Widget eachDate(var calenderDate) {
    int numDate = -1;
    if (calenderDate != '') numDate = calenderDate;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (numDate != -1) date = numDate;
        });
      },
      onLongPress: () async {
        await showDialog<bool>(
            context: (context),
            builder: (context) {
              return AddTask(
                date: date,
                month: month,
                year: year,
              );
            });
        setState(() {});
      },
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          width: 32.w,
          height: 26.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(date == numDate ? 8 : 0),
            color: date == numDate ? primary : Colors.transparent,
          ),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              calenderDate.toString(),
              style: GoogleFonts.montserrat(
                fontSize: 14.sp,
                color: date == numDate
                    ? Colors.white
                    : isDark
                        ? Colors.white
                        : Colors.black,
                fontWeight: date == numDate ? FontWeight.w400 : FontWeight.w200,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Dates
  Widget eachRow(int i) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (int date = 1; date <= 7; date++) eachDate(l[date + i * 7]),
      ],
    );
  }

  /// Weekdays
  Widget weekHeader(var weekName) {
    return Container(
      width: 40.w,
      child: Align(
        alignment: Alignment.center,
        child: Text(
          weekName,
          style: GoogleFonts.montserrat(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget monthlyDates() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            for (int i = 0; i < week.length; i++) weekHeader(week[i]),
          ],
        ),
        Divider(
          color: isDark ? Colors.white70 : Colors.black12,
          indent: 50,
          endIndent: 50,
        ),
        for (int i = 0; i < 6; i++) eachRow(i),
      ],
    );
  }

  /// Dropdown for selecting month and year
  Widget monthYear() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 48.w, right: 12.w),
          child: DropdownButton<String>(
            value: months[month - 1],
            menuMaxHeight: 300.h,
            dropdownColor: light,
            iconEnabledColor: isDark ? Colors.white : Colors.black,
            items: months.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: GoogleFonts.montserrat(fontSize: 20),
                ),
              );
            }).toList(),
            onChanged: (value) {
              month = months.indexOf(value!) + 1;
              setListDates();
              setState(() {});
            },
          ),
        ),
        DropdownButton<String>(
          value: years[year - 2021],
          menuMaxHeight: 300.h,
          dropdownColor: light,
          iconEnabledColor: isDark ? Colors.white : Colors.black,
          items: years.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: new Text(
                value,
                style: GoogleFonts.montserrat(fontSize: 20),
              ),
            );
          }).toList(),
          onChanged: (value) {
            year = 2021 + years.indexOf(value!);
            setListDates();
            setState(() {});
          },
        )
      ],
    );
  }

  Widget calender() {
    return Container(
      padding: EdgeInsets.all(10.h),
      child: Card(
        elevation: 18.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: light,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 6.h),
          child: Column(
            children: <Widget>[
              monthYear(),
              SizedBox(
                height: 8.h,
              ),
              monthlyDates(),
            ],
          ),
        ),
      ),
    );
  }

  Widget eachTask(name, profession, time) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10.h)), color: light),
      child: ListTile(
        leading: Container(
          width: 5.w,
          color: primary,
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              name,
              style: GoogleFonts.montserrat(fontSize: 16),
            ),
            Text(
              time,
              style: GoogleFonts.montserrat(fontSize: 16),
            )
          ],
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              profession,
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w200),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: dark,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            calender(),
            Container(
              padding: EdgeInsets.only(left: 24.w, bottom: 15.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(
                    curDate.day == date &&
                            curDate.month == month &&
                            curDate.year == year
                        ? "Today"
                        : "$date ${months[month - 1]} $year",
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "____________________________________________                             ",
                    style: GoogleFonts.montserrat(
                        fontSize: 4, fontWeight: FontWeight.w400),
                  ),
                  GestureDetector(
                      onTap: () async {
                        await showDialog<bool>(
                            context: (context),
                            builder: (context) {
                              return AddTask(
                                date: date,
                                month: month,
                                year: year,
                              );
                            });
                        setState(() {});
                      },
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: primary),
                        child: Icon(Icons.add, size: 25, color: Colors.white),
                      )),
                ],
              ),
            ),
            tasks[DateTime(year, month, date).toString()] == null
                ? Column(
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.only(left: 40.w, right: 40.w, top: 16.h),
                        child: Image(
                          image: AssetImage('images/noWork.png'),
                          height: 120,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text('No tasks to show',
                            maxLines: 3,
                            softWrap: true,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(fontSize: 18)),
                      ),
                    ],
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount:
                          tasks[DateTime(year, month, date).toString()].length,
                      itemBuilder: (context, i) {
                        return Container(
                          padding: EdgeInsets.only(top: 8),
                          child: eachTask(
                              tasks[DateTime(year, month, date).toString()][i]
                                  [2],
                              tasks[DateTime(year, month, date).toString()][i]
                                  [3],
                              "${tasks[DateTime(year, month, date).toString()][i][0].toString().padLeft(2, '0')}:${tasks[DateTime(year, month, date).toString()][i][1].toString().padLeft(2, '0')}"),
                        );
                      },
                    ),
                  )
          ],
        ),
      ),
    );
  }
}
