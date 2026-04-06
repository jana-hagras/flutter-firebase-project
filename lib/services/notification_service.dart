import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notes_app/main.dart';
import 'package:notes_app/views/screens/order.dart';

@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  final localNotifications = FlutterLocalNotificationsPlugin();
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const settings = InitializationSettings(android: androidSettings);
  await localNotifications.initialize(settings: settings);
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'channel_id', 'channel_name',
      description: 'channel_description', importance: Importance.max);
  await AndroidFlutterLocalNotificationsPlugin()
      .createNotificationChannel(channel);

  const androidDetails = AndroidNotificationDetails(
      'channel_id', 'channel.name',
      channelDescription: 'channel.description',
      importance: Importance.max,
      priority: Priority.high);
  const details = NotificationDetails(android: androidDetails);
  await localNotifications.show(
      id: message.hashCode,
      title: message.notification?.title ?? "No Title",
      body: message.notification?.body,
      notificationDetails: details);
  log("Background Message displayed: ${message.notification?.title}");
}

class SimpleFCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);
    await _messaging.requestPermission(alert: true, sound: true, badge: true);

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          log("Local Notification Tapped with payload: ${details.payload}");
          _handleNavigation(details.payload!);
        }
      },
    );
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'channel_id', 'channel_name',
        description: 'channel_description', importance: Importance.max);

    await AndroidFlutterLocalNotificationsPlugin()
        .createNotificationChannel(channel);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            alert: true, badge: true, sound: true);

    final token = await _messaging.getToken();
    log("FCM Token: $token");

    FirebaseMessaging.onMessage.listen((message) {
      log('Foreground Message received: ${message.notification?.title}');
      log('Data Payload Keys: ${message.data.keys.toList()}');

      final screen = message.data['screen'] ?? "";
      final id = message.data['id'] ?? "";

      _showNotification(
          title: message.notification?.title ?? "No Title",
          body: message.notification?.body ?? "",
          payload: "$screen|$id");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      log("onMessageOpenedApp triggered");
      final data = message.data;
      log("Opened App Data: $data");
      _handleNavigation("${data['screen'] ?? ''}|${data['id'] ?? ''}");
    });

    await _handleInitialMessage();
  }

  Future<void> _showNotification(
      {required String title, required String body, String? payload}) async {
    const androidDetails = AndroidNotificationDetails(
        'channel_id', 'channel.name',
        channelDescription: 'channel.description',
        importance: Importance.max,
        priority: Priority.high);
    const details = NotificationDetails(android: androidDetails);
    await _localNotifications.show(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: title,
        body: body,
        payload: payload,
        notificationDetails: details);
  }
}

void _handleNavigation(String payload) {
  log("Handling Navigation for payload: $payload");
  if (payload.isEmpty || payload == "|") return;

  final parts = payload.split('|');
  final screen = parts[0];
  final id = parts.length > 1 ? parts[1] : null;

  if (screen == "order") {
    log("Navigating to OrderScreen with ID: $id");
    navigatorKey.currentState?.push(MaterialPageRoute(
      builder: (_) => OrderScreen(orderId: id),
    ));
  } else {
    log("Unknown screen target in payload: $screen");
  }
}

Future<void> _handleInitialMessage() async {
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    log("getInitialMessage triggered");
    final data = initialMessage.data;
    log("Initial Message Data: $data");
    _handleNavigation("${data['screen'] ?? ''}|${data['id'] ?? ''}");
  }
}

void printFID() async {
  String? fid = await FirebaseMessaging.instance.getToken();
  debugPrint("Your FCM Installation ID: $fid");
}
