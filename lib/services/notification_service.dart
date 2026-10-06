// Dart imports:
import "dart:developer";

// Package imports:
import "package:device_info_plus/device_info_plus.dart";
import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter_local_notifications/flutter_local_notifications.dart";

// Project imports:
import "../main.dart";
import '../imports.dart';

const String _channelId = "getithk_notifications";
const String _channelName = "GetItHK Notifications";
const String _channelDesc = "notification_channel";

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> shouldListenNotification() async {
    if (kIsWeb) return;
    await _instance._setup();
    await _instance._initLocal();
  }

  static Future<String?> getToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (_) {
      return null;
    }
  }

  static Future<void> deleteToken() async {
    try {
      await FirebaseMessaging.instance.deleteToken();
    } catch (_) {
      // Ignore — a Firebase/push failure must never block logout.
    }
  }

  Future<void> _setup() async {
    try {
      await requestNotificationPermission();

      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );

      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) notificationMessageHandle(initial.data);

      FirebaseMessaging.onMessage.listen(_messageHandler);
      FirebaseMessaging.onBackgroundMessage(_messageHandler);
      FirebaseMessaging.onMessageOpenedApp.listen(
        (m) => notificationMessageHandle(m.data),
      );
    } catch (e) {
      log("NotificationService setup error: $e");
    }
  }

  Future<void> _initLocal() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings("ic_notification"),
      iOS: DarwinInitializationSettings(),
    );

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        if (response.notificationResponseType ==
                NotificationResponseType.selectedNotification &&
            response.payload != null) {
          notificationMessageHandle(json.decode(response.payload!));
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  Future<void> sendLocalNotification(
    int id,
    String title,
    String body,
    String payload,
  ) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        color: Theme.of(NavigationService.context).colorScheme.primary,
        importance: Importance.max,
        priority: Priority.high,
        sound: const RawResourceAndroidNotificationSound('notification_sound'),
      ),
      iOS: const DarwinNotificationDetails(sound: 'notification_sound.mp3'),
    );

    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }
}

@pragma('vm:entry-point')
Future<void> _messageHandler(RemoteMessage message) async {
  log("_messageHandler: ${jsonEncode(message.toMap())}");
  NavigationService.context.read<AppController>().getUser();

  // TODO(getithk): handle each notification `type` here.

  // iOS auto-displays `notification` payloads in both foreground and background.
  // Android only auto-displays in background — in foreground we must render it.
  if (Platform.isIOS && message.notification != null) return;

  await NotificationService().sendLocalNotification(
    message.hashCode,
    message.notification?.title ?? message.data["title"] ?? "",
    message.notification?.body ?? message.data["body"] ?? "",
    json.encode(message.data),
  );
}

void notificationMessageHandle(Map<String, dynamic> data) {
  log("notificationMessageHandle: $data");
  NavigationService.context.read<AppController>().getUser();

  // TODO(getithk): route to the right page based on data["type"].
}

Future<bool> requestNotificationPermission() async {
  if (kIsWeb) return false;

  if (Platform.isIOS) {
    final current = await FirebaseMessaging.instance.getNotificationSettings();
    if (current.authorizationStatus == AuthorizationStatus.authorized) {
      return true;
    }
    final requested = await FirebaseMessaging.instance.requestPermission();
    return requested.authorizationStatus == AuthorizationStatus.authorized;
  }

  final android = await DeviceInfoPlugin().androidInfo;
  if (android.version.sdkInt < 33) return true;

  final plugin = FlutterLocalNotificationsPlugin()
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  if (plugin == null) return false;

  if (await plugin.areNotificationsEnabled() == true) return true;
  return await plugin.requestNotificationsPermission() == true;
}
