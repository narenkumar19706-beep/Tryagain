import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'alert_store.dart';

class FcmService {
  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    "rrt_alerts",
    "RRT Alerts",
    description: "SOS alerts & emergency pushes",
    importance: Importance.max,
  );

  static Future<void> init() async {
    await FirebaseMessaging.instance.requestPermission();

    const androidInit = AndroidInitializationSettings("@mipmap/ic_launcher");
    const initSettings = InitializationSettings(android: androidInit);
    await _local.initialize(initSettings);

    final androidPlugin =
        _local.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_channel);

    FirebaseMessaging.onMessage.listen((RemoteMessage msg) async {
      _handleMessageData(msg);

      final title = msg.notification?.title ?? "RRT Alert";
      final body = msg.notification?.body ?? "New alert received";

      await _local.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    });
  }

  static void _handleMessageData(RemoteMessage msg) {
    final data = msg.data;

    final type = data["type"] ?? "";
    final sosId = data["sosId"] ?? "";

    if (type == "SOS_START") {
      final district = data["district"] ?? "";
      final phoneNumber = data["phoneNumber"] ?? "";
      final name = data["name"] ?? "";
      final address = data["address"] ?? "";
      final startedAtStr = data["startedAt"] ?? "";

      final latStr = data["lat"];
      final lngStr = data["lng"];

      final lat = (latStr == null || latStr.toString().isEmpty)
          ? null
          : double.tryParse(latStr.toString());
      final lng = (lngStr == null || lngStr.toString().isEmpty)
          ? null
          : double.tryParse(lngStr.toString());

      final startedAt = startedAtStr.isNotEmpty
          ? DateTime.tryParse(startedAtStr) ?? DateTime.now()
          : DateTime.now();

      AlertStore.upsertStart(
        sosId: sosId,
        district: district,
        phoneNumber: phoneNumber,
        name: name,
        address: address,
        lat: lat,
        lng: lng,
        startedAt: startedAt,
      );
    }

    if (type == "SOS_UPDATE") {
      final message = data["message"] ?? "";
      final atStr = data["at"] ?? "";
      final at = atStr.isNotEmpty
          ? DateTime.tryParse(atStr) ?? DateTime.now()
          : DateTime.now();

      if (message.trim().isNotEmpty) {
        AlertStore.addUpdate(sosId: sosId, message: message, at: at);
      }
    }

    if (type == "SOS_STOP") {
      if (sosId.isNotEmpty) {
        AlertStore.markStopped(sosId);
      }
    }
  }

  static Future<String?> token() async {
    return FirebaseMessaging.instance.getToken();
  }
}
