import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'glass_card.dart';

class StatCard extends StatelessWidget {

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Container(
            width: 48,
            height: 48,

            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius:
              BorderRadius.circular(12),
            ),

            child: Icon(
              icon,
              color: color,
            ),
          ),

          const SizedBox(height: 20),

          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: AppColors.slate900,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.slate500,
            ),
          ),
        ],
      ),
    );
  }
}