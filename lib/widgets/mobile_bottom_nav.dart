import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MobileBottomNav extends StatelessWidget {

  final int currentIndex;
  final Function(int) onTap;

  const MobileBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return BottomNavigationBar(
      currentIndex: currentIndex,

      onTap: onTap,

      selectedItemColor:
      AppColors.brand,

      unselectedItemColor:
      AppColors.slate500,

      items: const [

        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Browse',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.work),
          label: 'Projects',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.message),
          label: 'Messages',
        ),
      ],
    );
  }
}