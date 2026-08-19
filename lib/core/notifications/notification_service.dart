import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../../features/notes/domain/entities/note.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'smart_workspace_channel';
  static const String channelName = 'Smart Workspace Notifications';
  static const String channelDesc = 'Notifications for reminders and progress';

  static const String actionMarkDone = 'action_mark_done';

  Future<void> init() async {
    tz.initializeTimeZones();
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));

    // Android Initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS/macOS Initialization
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
          macOS: initializationSettingsDarwin,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
            final String? actionId = notificationResponse.actionId;
            final String? payload = notificationResponse.payload;

            if (actionId == actionMarkDone) {
              debugPrint(
                'Notification Action: Mark Done clicked for payload $payload',
              );
              // In a real app, you would dispatch a BLoC event to update the note status
            }
          },
    );

    // Request Android 13+ permissions
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestExactAlarmsPermission();
  }

  NotificationDetails _getNotificationDetails({
    String? channelId,
    String? channelName,
    String? channelDescription,
    List<AndroidNotificationAction>? actions,
    int? progress,
    int? maxProgress,
    bool showProgress = false,
  }) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId ?? NotificationService.channelId,
        channelName ?? NotificationService.channelName,
        channelDescription:
            channelDescription ?? NotificationService.channelDesc,
        importance: Importance.max,
        priority: Priority.high,
        actions: actions,
        showProgress: showProgress,
        maxProgress: maxProgress ?? 100,
        progress: progress ?? 0,
        indeterminate: showProgress && progress == null,
        onlyAlertOnce: showProgress,
      ),
      iOS: const DarwinNotificationDetails(),
      macOS: const DarwinNotificationDetails(),
    );
  }

  // 1. Daily Reminder
  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    // Schedule a reminder for the given time every day
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // ID 0 for daily reminder
      'Daily Sync',
      'Time to review your workspace and plan your day!',
      _nextInstanceOfTime(time.hour, time.minute),
      _getNotificationDetails(),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    debugPrint(
      'NotificationService: Scheduled daily reminder for ${time.hour}:${time.minute.toString().padLeft(2, '0')}',
    );
  }

  Future<void> cancelDailyReminder() async {
    await flutterLocalNotificationsPlugin.cancel(0);
    debugPrint('NotificationService: Cancelled daily reminder');
  }

  // 2. Note Reminder with Action Button
  Future<void> scheduleNoteReminder(Note note, DateTime scheduledDate) async {
    // We use a hash of the note ID to generate a unique integer ID for the notification
    final int notificationId = note.id.hashCode;

    final AndroidNotificationAction markDoneAction = AndroidNotificationAction(
      actionMarkDone,
      'Mark Done',
      showsUserInterface: true,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      'Reminder: ${note.title}',
      note.description.isNotEmpty
          ? note.description
          : 'You have a scheduled note reminder.',
      tz.TZDateTime.from(scheduledDate, tz.local),
      _getNotificationDetails(actions: [markDoneAction]),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: note.id,
    );

    debugPrint(
      'NotificationService: Scheduled note reminder for ${note.title} at $scheduledDate',
    );
  }

  // 3. Progress Notification
  Future<void> showProgressNotification(int progress, int maxProgress) async {
    const int progressNotificationId = 999;

    await flutterLocalNotificationsPlugin.show(
      progressNotificationId,
      'Syncing Workspace',
      'Downloading mock data...',
      _getNotificationDetails(
        showProgress: true,
        progress: progress,
        maxProgress: maxProgress,
      ),
    );

    if (progress >= maxProgress) {
      // Clear progress notification after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        flutterLocalNotificationsPlugin.cancel(progressNotificationId);
      });
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
