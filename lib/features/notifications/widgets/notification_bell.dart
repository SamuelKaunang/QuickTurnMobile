import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/qt_colors.dart';
import '../../chat/chat_screen.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

/// Bell button (with unread badge) that opens the in-app notification panel.
///
/// Drop it into any AppBar/header. Self-contained: it fetches its own data and
/// manages the unread count. Matches the website's notification dropdown
/// (rose header, "Notifications" title, close button, empty state).
class NotificationBell extends StatefulWidget {
  /// Foreground color for the bell icon, so it can sit on light or dark headers.
  final Color iconColor;

  const NotificationBell({super.key, this.iconColor = QTColors.textPrimary});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  final NotificationService _service = NotificationService();
  List<NotificationItem> _items = [];
  bool _loading = true;

  // Authoritative unread count from the backend (the first page of [_items]
  // may not contain every unread notification).
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      _service.getNotifications(),
      _service.getUnreadCount(),
    ]);
    if (!mounted) return;
    setState(() {
      _items = results[0] as List<NotificationItem>;
      _unreadCount = results[1] as int;
      _loading = false;
    });
  }

  Future<void> _openPanel() async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Notifications',
      barrierColor: Colors.black.withOpacity(0.15),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (ctx, _, __) {
        return SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 70, right: 16, left: 16),
              child: _NotificationPanel(
                items: _items,
                loading: _loading,
                onMarkAllRead: _markAllRead,
                onTapItem: _onTapItem,
              ),
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim, _, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOut);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            alignment: Alignment.topRight,
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  Future<void> _markAllRead() async {
    if (_unreadCount == 0) return;
    setState(() {
      _items = _items.map((n) => n.copyWith(isRead: true)).toList();
      _unreadCount = 0;
    });
    await _service.markAllAsRead();
  }

  Future<void> _onTapItem(NotificationItem item) async {
    if (!item.isRead) {
      setState(() {
        _items = _items
            .map((n) => n.id == item.id ? n.copyWith(isRead: true) : n)
            .toList();
        if (_unreadCount > 0) _unreadCount--;
      });
      // Trust the server's authoritative count when it answers.
      final serverCount = await _service.markAsRead(item.id);
      if (mounted && serverCount != null) {
        setState(() => _unreadCount = serverCount);
      }
    }
    if (!mounted) return;
    Navigator.of(context).pop(); // close the panel

    // Minimal deep-link routing; extend per category as needed.
    // NEW_MESSAGE carries the chat partner id in relatedEntityId, but
    // ChatScreen currently opens the contact list rather than a specific thread.
    if (item.category == NotificationCategory.chat) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ChatScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 1,
          shadowColor: Colors.black.withOpacity(0.06),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _openPanel,
            child: SizedBox(
              width: 48,
              height: 48,
              child: Icon(
                Icons.notifications_none_rounded,
                color: widget.iconColor,
                size: 24,
              ),
            ),
          ),
        ),
        if (_unreadCount > 0)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              decoration: BoxDecoration(
                color: QTColors.brandPrimary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Text(
                  _unreadCount > 9 ? '9+' : '$_unreadCount',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _NotificationPanel extends StatelessWidget {
  final List<NotificationItem> items;
  final bool loading;
  final VoidCallback onMarkAllRead;
  final ValueChanged<NotificationItem> onTapItem;

  const _NotificationPanel({
    required this.items,
    required this.loading,
    required this.onMarkAllRead,
    required this.onTapItem,
  });

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.6;
    final hasUnread = items.any((n) => !n.isRead);

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 360,
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
              decoration: const BoxDecoration(
                color: QTColors.brandLight,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Text(
                    'Notifications',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: QTColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  if (hasUnread)
                    TextButton(
                      onPressed: onMarkAllRead,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Mark all read',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: QTColors.brandPrimary,
                        ),
                      ),
                    ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.close,
                          size: 18, color: QTColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(child: _body(context)),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: QTColors.brandPrimary,
            ),
          ),
        ),
      );
    }

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none_rounded,
                size: 44, color: QTColors.slate300),
            const SizedBox(height: 12),
            Text(
              'No notifications yet',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: QTColors.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: items.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: QTColors.slate100),
      itemBuilder: (ctx, i) => _tile(ctx, items[i]),
    );
  }

  Widget _tile(BuildContext context, NotificationItem item) {
    final color = _categoryColor(item.category);
    final timeLabel = item.timeAgo ??
        (item.createdAt != null ? _relativeTime(item.createdAt!) : null);
    return InkWell(
      onTap: () => onTapItem(item),
      child: Container(
        color: item.isRead ? Colors.white : QTColors.brandLight.withOpacity(0.4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_categoryIcon(item.category), size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight:
                          item.isRead ? FontWeight.w600 : FontWeight.w800,
                      color: QTColors.textPrimary,
                    ),
                  ),
                  if (item.message.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: QTColors.textSecondary,
                      ),
                    ),
                  ],
                  if (timeLabel != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      timeLabel,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: QTColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!item.isRead)
              Container(
                margin: const EdgeInsets.only(left: 8, top: 4),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: QTColors.brandPrimary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  static IconData _categoryIcon(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.chat:
        return Icons.chat_bubble_outline_rounded;
      case NotificationCategory.project:
        return Icons.folder_outlined;
      case NotificationCategory.application:
        return Icons.person_add_alt_1_outlined;
      case NotificationCategory.review:
        return Icons.star_outline_rounded;
      case NotificationCategory.general:
        return Icons.notifications_active_outlined;
    }
  }

  static Color _categoryColor(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.chat:
        return QTColors.info;
      case NotificationCategory.project:
        return QTColors.brandPrimary;
      case NotificationCategory.application:
        return QTColors.accentBeginner;
      case NotificationCategory.review:
        return QTColors.accentIntermediate;
      case NotificationCategory.general:
        return QTColors.brandPrimary;
    }
  }

  static String _relativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${time.day}/${time.month}/${time.year}';
  }
}
