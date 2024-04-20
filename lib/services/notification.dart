import 'package:sugar_sense/main.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class Notification{
  static Future<void> initializeNotification() async{
    await AwesomeNotifications().initialize(null, [
      NotificationChannel(channelGroupKey: 'High_importance_channel',channelKey: 'High_importance_channel', channelName: 'Basic notifications', channelDescription: 'Notification channel for basic tests', defaultColor:  Colors.red,ledColor: Colors.white,importance:NotificationImportance.Max,channelShowBadge: true,onlyAlertOnce: true,playSound: true,)
    ],);
  }
}