import 'package:flutter/material.dart';
import 'core/theme/qt_theme.dart';
import 'features/auth/landing_screen.dart';
import 'core/services/push_notification_service.dart';
import 'core/services/notification_service.dart';

// Entry point for the QuickTurn Mobile App
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // FCM Token Registration Service
  await NotificationService().init();

  try {
    // Local Push Notification Service
    PushNotificationService().initialize().catchError((e) {
      debugPrint("Gagal inisialisasi push notification: $e");
    });
  } catch (e) {
    debugPrint("Gagal inisialisasi Firebase: $e");
  }
  runApp(const QuickTurnApp());
}

class QuickTurnApp extends StatelessWidget {
  const QuickTurnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: PushNotificationService.navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'QuickTurn',
      theme: QTTheme.lightTheme,
      home: const LandingScreen(),
    );
  }
}