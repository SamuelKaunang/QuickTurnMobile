import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/qt_theme.dart';
import 'features/auth/landing_screen.dart';
import 'core/services/push_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Jalankan inisialisasi push notification tanpa await agar tidak mem-block startup aplikasi
    PushNotificationService().initialize().catchError((e) {
      print("Gagal inisialisasi push notification: $e");
    });
  } catch (e) {
    print("Gagal inisialisasi Firebase: $e");
  }
  runApp(const QuickTurnApp());
}

class QuickTurnApp extends StatelessWidget {
  const QuickTurnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QuickTurn',
      theme: QTTheme.lightTheme,
      home: const LandingScreen(),
    );
  }
}