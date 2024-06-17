
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationsManager {
  static final NotificationsManager _instance = NotificationsManager._internal();
  factory NotificationsManager() => _instance;
  NotificationsManager._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
}




