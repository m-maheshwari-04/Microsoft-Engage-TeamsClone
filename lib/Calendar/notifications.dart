import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../homeScreen.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Setting local notifications for tasks added to calendar
Future<void> taskReminder(String title, String description, int year, int month,
    int day, int startHour, int startMin) async {
  /// Initializing timezone
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

  /// Date-time of scheduled task
  tz.TZDateTime scheduleDate =
      tz.TZDateTime(tz.local, year, month, day, startHour, startMin);

  String _id = (month.toString()) +
      (day.toString()) +
      (startHour.toString()) +
      (startMin.toString());

  try {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        int.parse(_id),
        '$title',
        '$description',
        scheduleDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'id',
            'Calendar',
            'Tasks notifications',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  } catch (e) {
    print(e);
  }
}
