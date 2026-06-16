import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../network/dio_client.dart';

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();
  final DioClient _dioClient = DioClient();

  Future<void> initialize() async {
    if (kIsWeb) {
      print("PushNotificationService: Web platform detected. Skipping initialization.");
      return;
    }

    // 1. Minta izin notifikasi (Android 13+ & iOS)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted notification permissions');
    }

    // 2. Setup Local Notification Channel (Android Foreground)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _localNotif.initialize(settings: initializationSettings);

    // 3. Tangani pesan ketika aplikasi sedang aktif (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        _localNotif.show(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              'quickturn_push_channel',
              'QuickTurn Push Notifications',
              channelDescription: 'Channel for QuickTurn push notifications',
              importance: Importance.max,
              priority: Priority.high,
              icon: android.smallIcon,
            ),
          ),
        );
      }
    });

    // 4. Tangani ketika notifikasi di-tap dari background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Notification tapped: ${message.data}");
      // TODO: Navigasi dinamis berdasarkan data payload
    });
  }

  /// Registrasi Token Perangkat ke Database Backend
  Future<void> registerDeviceToken() async {
    if (kIsWeb) {
      print("PushNotificationService: Web platform detected. Skipping token registration.");
      return;
    }
    try {
      String? token = await _fcm.getToken();
      if (token != null) {
        print("Device Token: $token");
        await _dioClient.dio.post(
          '/api/users/device-token',
          data: {'deviceToken': token},
        );
      }
    } catch (e) {
      print("Gagal registrasi token ke backend: $e");
    }
  }
}
