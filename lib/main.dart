import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';


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
      theme: ThemeData(
        fontFamily: 'PlusJakartaSans',
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      home: const DashboardScreen(),
    );
  }
}