import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {

  final Widget child;
  final EdgeInsets? padding;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),

      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 12,
          sigmaY: 12,
        ),

        child: Container(
          padding: padding ?? const EdgeInsets.all(20),

          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),

            borderRadius: BorderRadius.circular(20),

            border: Border.all(
              color: Colors.white.withOpacity(0.7),
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
              ),
            ],
          ),

          child: child,
        ),
      ),
    );
  }
}