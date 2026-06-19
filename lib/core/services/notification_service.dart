import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../network/dio_client.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  /// Initialize Firebase Messaging and configure listeners
  Future<void> init() async {
    try {
      // Initialize Firebase (safely wrapped in try-catch so it won't crash if config is missing)
      await Firebase.initializeApp();
      print("Firebase initialized successfully.");

      // Request permissions
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('User granted notification permission: ${settings.authorizationStatus}');

      // Configure foreground notification presentation options
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Listen to token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        _registerTokenWithBackend(newToken);
      });

    } catch (e) {
      print("Firebase initialization skipped/failed (likely missing google-services.json): $e");
    }
  }

  /// Fetch the current device token and register it to the backend
  Future<void> registerDevice() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        print("FCM Device Token: $token");
        await _registerTokenWithBackend(token);
      }
    } catch (e) {
      print("Failed to get FCM Token: $e");
    }
  }

  /// Send the retrieved token to the Spring Boot backend
  Future<void> _registerTokenWithBackend(String token) async {
    try {
      final dio = DioClient().dio;
      final response = await dio.post(
        '/api/users/device-token',
        data: {'deviceToken': token},
      );
      if (response.statusCode == 200) {
        print("FCM Device Token successfully registered to backend.");
      } else {
        print("Failed to register FCM Device Token to backend: ${response.statusMessage}");
      }
    } catch (e) {
      print("Error registering FCM Device Token to backend: $e");
    }
  }
}
