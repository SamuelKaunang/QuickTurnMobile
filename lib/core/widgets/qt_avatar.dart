import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/network/dio_client.dart';
import '../theme/qt_colors.dart';

class QTAvatar extends StatelessWidget {
  final String? profileUrl;
  final String name;
  final double size;
  final bool? isOnline;
  final BorderRadius? borderRadius;
  final BoxBorder? border;

  const QTAvatar({
    super.key,
    required this.name,
    this.profileUrl,
    this.size = 48,
    this.isOnline,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().split(RegExp(r'\s+')).map((s) => s.isNotEmpty ? s[0] : '').take(2).join().toUpperCase();
    final bool isNetwork = profileUrl != null && (profileUrl!.startsWith('http') || profileUrl!.startsWith('/api/'));
    final String finalProfileUrl = isNetwork
        ? (profileUrl!.startsWith('http') ? profileUrl! : '${DioClient.baseUrl}${profileUrl!.startsWith('/') ? '' : '/'}$profileUrl')
        : '';

    final radius = borderRadius ?? BorderRadius.circular(999);

    Widget avatarContent = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: border,
        gradient: const LinearGradient(
          colors: [QTColors.brandPrimary, QTColors.brandDark],
        ),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: finalProfileUrl.isNotEmpty
            ? Image.network(
                finalProfileUrl,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildInitials(initials),
              )
            : _buildInitials(initials),
      ),
    );

    if (isOnline == null) {
      return avatarContent;
    }

    final double badgeSize = size * 0.26 < 10 ? 10 : size * 0.26;
    return Stack(
      children: [
        avatarContent,
        if (isOnline == true)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: badgeSize,
              height: badgeSize,
              decoration: BoxDecoration(
                color: QTColors.accentBeginner,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: badgeSize * 0.15 < 1.5 ? 1.5 : badgeSize * 0.15,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInitials(String initials) {
    return Center(
      child: Text(
        initials.isNotEmpty ? initials : '?',
        style: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontSize: size * 0.38,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
