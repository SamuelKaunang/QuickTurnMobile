import 'package:flutter/material.dart';
import 'core/theme/qt_theme.dart';
import 'features/auth/landing_screen.dart';

void main() {
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