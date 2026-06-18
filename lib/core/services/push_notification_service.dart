import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../network/dio_client.dart';
import '../../features/chat/chat_screen.dart';

/// Handler pesan saat aplikasi berada di background / terminated.
///
/// Harus berupa top-level function (bukan method instance) dan diberi anotasi
/// `@pragma('vm:entry-point')` agar tidak di-tree-shake oleh compiler, karena
/// dijalankan pada isolate terpisah oleh Firebase.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Di isolate background kita tidak bisa mengakses state UI. Cukup catat log;
  // sistem (Android/iOS) yang akan menampilkan notifikasi dari payload `notification`.
  debugPrint('Handling background message: ${message.messageId}');
}

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  /// Navigator key global supaya bisa melakukan navigasi dari luar widget tree
  /// (misalnya ketika notifikasi di-tap). Wajib dipasang di [MaterialApp].
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  FirebaseMessaging? _fcmInstance;
  FlutterLocalNotificationsPlugin? _localNotifInstance;

  FirebaseMessaging get _fcm {
    _fcmInstance ??= FirebaseMessaging.instance;
    return _fcmInstance!;
  }

  FlutterLocalNotificationsPlugin get _localNotif {
    _localNotifInstance ??= FlutterLocalNotificationsPlugin();
    return _localNotifInstance!;
  }

  final DioClient _dioClient = DioClient();

  Future<void> initialize() async {
    if (kIsWeb) {
      debugPrint(
          "PushNotificationService: Web platform detected. Skipping initialization.");
      return;
    }

    // 1. Minta izin notifikasi (Android 13+ & iOS)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted notification permissions');
    }

    // 2. Setup Local Notification Channel (Android Foreground)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _localNotif.initialize(
      settings: initializationSettings,
      // Tap pada local notification (foreground) -> navigasi via payload.
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          try {
            final data = jsonDecode(payload) as Map<String, dynamic>;
            _handleMessageNavigation(data);
          } catch (e) {
            debugPrint("Gagal parsing payload notifikasi: $e");
          }
        }
      },
    );

    // 3. Daftarkan handler background/terminated.
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 4. Tangani pesan ketika aplikasi sedang aktif (Foreground)
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
          // Bawa data payload supaya tap-nya bisa diarahkan ke halaman tujuan.
          payload: jsonEncode(message.data),
        );
      }
    });

    // 5. Tangani ketika notifikasi di-tap dari background (app masih hidup).
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("Notification tapped (background): ${message.data}");
      _handleMessageNavigation(message.data);
    });

    // 6. Tangani ketika app dibuka dari kondisi terminated lewat tap notifikasi.
    final RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      debugPrint("Notification tapped (terminated): ${initialMessage.data}");
      _handleMessageNavigation(initialMessage.data);
    }
  }

  /// Navigasi dinamis berdasarkan field `type` pada payload notifikasi.
  void _handleMessageNavigation(Map<String, dynamic> data) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      debugPrint("Navigator belum siap, navigasi dilewati.");
      return;
    }

    // Backend mengirim `type` berupa nama enum (mis. NEW_MESSAGE) di payload FCM.
    final type = (data['type']?.toString() ?? '').toUpperCase();
    if (type == 'NEW_MESSAGE') {
      navigator.push(
        MaterialPageRoute(builder: (_) => const ChatScreen()),
      );
    } else {
      // Tipe lain belum punya tujuan khusus; cukup catat.
      debugPrint("Tipe notifikasi belum dirutekan: $type");
    }
  }

  /// Registrasi Token Perangkat ke Database Backend
  Future<void> registerDeviceToken() async {
    if (kIsWeb) {
      debugPrint(
          "PushNotificationService: Web platform detected. Skipping token registration.");
      return;
    }
    try {
      String? token = await _fcm.getToken();
      if (token != null) {
        debugPrint("Device Token: $token");
        await _dioClient.dio.post(
          '/api/users/device-token',
          data: {'deviceToken': token},
        );
      }

      // Token bisa berubah; pastikan backend selalu update.
      _fcm.onTokenRefresh.listen((newToken) async {
        try {
          await _dioClient.dio.post(
            '/api/users/device-token',
            data: {'deviceToken': newToken},
          );
        } catch (e) {
          debugPrint("Gagal update token refresh ke backend: $e");
        }
      });
    } catch (e) {
      debugPrint("Gagal registrasi token ke backend: $e");
    }
  }
}
