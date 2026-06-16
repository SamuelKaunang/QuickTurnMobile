import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/qt_colors.dart';

enum QTToastType { success, error, info, warning }

class QTToast {
  static void show(
    BuildContext context, {
    required String message,
    required String title,
    QTToastType type = QTToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    
    IconData icon;
    Color accentColor;
    
    switch (type) {
      case QTToastType.success:
        icon = Icons.check_circle_rounded;
        accentColor = QTColors.accentBeginner;
        break;
      case QTToastType.error:
        icon = Icons.error_rounded;
        accentColor = QTColors.error;
        break;
      case QTToastType.warning:
        icon = Icons.warning_rounded;
        accentColor = QTColors.warning;
        break;
      case QTToastType.info:
        icon = Icons.info_rounded;
        accentColor = QTColors.info;
        break;
    }

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, (1 - value) * -50),
                child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: accentColor.withOpacity(0.3), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: accentColor, size: 22),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: QTColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              message,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: QTColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    
    Future.delayed(duration, () {
      overlayEntry.remove();
    });
  }
}
