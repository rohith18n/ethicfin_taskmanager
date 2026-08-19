import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../constants/app_constants.dart';
import '../../features/tasks/domain/entities/task_entity.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('FCM Background message received: ${message.messageId}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Request notification permissions
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      debugPrint('FCM User granted permission: ${settings.authorizationStatus}');

      // 2. Initialize Local Notifications Plugin
      const androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInitSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidInitSettings,
        iOS: iosInitSettings,
      );

      await _localNotificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint('Notification clicked with payload: ${response.payload}');
        },
      );

      // 3. Create Android High-Importance Notification Channel
      const androidNotificationChannel = AndroidNotificationChannel(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        description: AppConstants.notificationChannelDescription,
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
      );

      await _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidNotificationChannel);

      // 4. Foreground FCM Listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('FCM Foreground message received: ${message.notification?.title}');
        final notification = message.notification;

        if (notification != null) {
          showNotification(
            id: message.hashCode,
            title: notification.title ?? 'EthicFin Task Update',
            body: notification.body ?? '',
            payload: message.data.toString(),
          );
        }
      });

      // 5. App Opened from Notification
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('App opened via FCM notification: ${message.data}');
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint('NotificationService initialization notice: $e');
    }
  }

  Future<String?> getFCMToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        debugPrint('====================================');
        debugPrint('[FCM REGISTRATION TOKEN]:\n$token');
        debugPrint('====================================');
      }
      return token;
    } catch (e) {
      debugPrint('Failed to retrieve FCM token: $e');
      return null;
    }
  }

  Future<void> saveTokenToUser(String userId) async {
    try {
      final token = await getFCMToken();
      if (token != null) {
        await FirebaseFirestore.instance
            .collection(AppConstants.firestoreUsersCollection)
            .doc(userId)
            .set({
          'fcmToken': token,
          'lastActive': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Failed to save FCM token to Firestore: $e');
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      channelDescription: AppConstants.notificationChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  Future<void> scheduleTaskDueReminder(TaskEntity task) async {
    try {
      final timeUntilDue = task.dueDate.difference(DateTime.now());
      if (timeUntilDue.isNegative || task.isCompleted) return;

      // For instant feedback in task manager, trigger notification confirmation
      showNotification(
        id: task.id.hashCode,
        title: 'Task Created: ${task.title}',
        body: 'Priority: ${task.priority.displayName} • Due ${task.dueDate.day}/${task.dueDate.month}',
        payload: task.id,
      );
    } catch (e) {
      debugPrint('Failed to schedule task reminder: $e');
    }
  }
}
