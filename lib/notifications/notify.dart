import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';

class Notify {
  static Future<bool> instantNotify() async {
    final AwesomeNotifications awesomeNotifications = AwesomeNotifications();
    return awesomeNotifications.createNotification(

      content: NotificationContent(
          id: Random().nextInt(2),
          title: "Instant Delivery",
          body: "Notification that delivers instantly on trigger.",
          channelKey: 'instant_notification',),
    );
  }
  static Future<bool> scheduleNotification() async {
    final AwesomeNotifications awesomeNotifications = AwesomeNotifications();
    return awesomeNotifications.createNotification(
      schedule: NotificationCalendar(
        day:9,
        month:12,
        year:2024,
        hour:22,
        minute:35,
      ),
      content: NotificationContent(
        id: Random().nextInt(2),
        title: "Schedule Delivery",
        body: "Notification that delivers instantly on trigger.",
        channelKey: 'scheduled_notification',),
    );
  }
}
