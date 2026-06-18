/// A single in-app notification item.
///
/// Mirrors `NotificationDTO` from the backend. Note the backend quirks:
///   - the read flag is serialized as `read` (not `isRead`)
///   - the text body is `message` (not `body`)
///   - `type` is an enum string (e.g. "NEW_MESSAGE", "APPLICATION_RECEIVED")
///   - `relatedEntityType` + `relatedEntityId` carry the deep-link target
///   - `timeAgo` is a pre-formatted human string ("5 min ago")
/// All fields are parsed defensively (ids may be int/string/null).
class NotificationItem {
  final String id;
  final String title;
  final String message;

  /// Raw backend enum, e.g. "NEW_MESSAGE". Use [category] for icon/routing.
  final String type;
  final bool isRead;

  /// Entity this notification points to, e.g. "CHAT"/"PROJECT"/"SUBMISSION".
  final String? relatedEntityType;

  /// Id of the related entity (chat senderId, projectId, ...). May be null.
  final String? relatedEntityId;
  final DateTime? createdAt;

  /// Pre-formatted relative time from the backend ("5 min ago"). Preferred
  /// over computing locally when present.
  final String? timeAgo;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    this.relatedEntityType,
    this.relatedEntityId,
    this.createdAt,
    this.timeAgo,
  });

  /// Logical bucket used for icon + tap routing, derived from the backend enum.
  NotificationCategory get category {
    final t = type.toUpperCase();
    if (t == 'NEW_MESSAGE') return NotificationCategory.chat;
    if (t.startsWith('APPLICATION')) return NotificationCategory.application;
    if (t.startsWith('PROJECT') || t.startsWith('WORK')) {
      return NotificationCategory.project;
    }
    if (t == 'REVIEW_RECEIVED') return NotificationCategory.review;
    return NotificationCategory.general;
  }

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      title: title,
      message: message,
      type: type,
      isRead: isRead ?? this.isRead,
      relatedEntityType: relatedEntityType,
      relatedEntityId: relatedEntityId,
      createdAt: createdAt,
      timeAgo: timeAgo,
    );
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? 'Notification').toString(),
      message: (json['message'] ?? json['body'] ?? '').toString(),
      type: (json['type'] ?? 'GENERAL').toString(),
      // Backend serializes the flag as `read`; tolerate `isRead` too.
      isRead: json['read'] == true || json['isRead'] == true,
      relatedEntityType: json['relatedEntityType']?.toString(),
      relatedEntityId: json['relatedEntityId']?.toString(),
      createdAt: _parseDate(json['createdAt']),
      timeAgo: json['timeAgo']?.toString(),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime.tryParse(value.toString());
  }
}

enum NotificationCategory { chat, application, project, review, general }
