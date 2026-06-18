import 'package:flutter/foundation.dart';

import '../../../core/network/dio_client.dart';
import '../models/notification_model.dart';

/// REST access for in-app notifications, matching the QuickTurn backend
/// (`NotificationController`, base path `/api/notifications`).
///
/// Backend specifics handled here:
///   - GET  /api/notifications?page&size  -> Spring `Page` (data under `content`)
///   - GET  /api/notifications/count       -> unread count
///   - PATCH /api/notifications/{id}/read  -> mark one (no body) -> {unreadCount}
///   - PATCH /api/notifications/read-all   -> mark all  (no body) -> {unreadCount}
/// Notification endpoints are NOT wrapped in the `{success, data}` envelope.
///
/// Every call fails soft (returns empty / null) so the UI can degrade to the
/// "No notifications yet" state instead of throwing.
class NotificationService {
  final DioClient _client = DioClient();

  /// First page of notifications (read + unread). The backend returns a Spring
  /// `Page`, so items live under `content`.
  Future<List<NotificationItem>> getNotifications({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _client.dio.get(
        '/api/notifications',
        queryParameters: {'page': page, 'size': size},
      );
      final data = response.data;
      // Page envelope -> `content`; tolerate a plain list just in case.
      final list = data is Map ? data['content'] : data;
      if (list is List) {
        return list
            .whereType<Map<String, dynamic>>()
            .map(NotificationItem.fromJson)
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      return [];
    }
  }

  /// Accurate unread count (the first page may not contain every unread item).
  Future<int> getUnreadCount() async {
    try {
      final response = await _client.dio.get('/api/notifications/count');
      return _extractCount(response.data);
    } catch (e) {
      debugPrint('Error fetching unread count: $e');
      return 0;
    }
  }

  /// Marks one notification read. Returns the server's new unread count, or
  /// null on failure.
  Future<int?> markAsRead(String id) async {
    try {
      final response = await _client.dio.patch('/api/notifications/$id/read');
      return _extractCount(response.data);
    } catch (e) {
      debugPrint('Error marking notification $id as read: $e');
      return null;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      await _client.dio.patch('/api/notifications/read-all');
      return true;
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
      return false;
    }
  }

  /// The count endpoints may return a bare number or an object carrying
  /// `unreadCount`/`count`. Parse both shapes.
  int _extractCount(dynamic data) {
    if (data is int) return data;
    if (data is num) return data.toInt();
    if (data is Map) {
      final raw = data['unreadCount'] ?? data['count'] ?? data['data'];
      if (raw is num) return raw.toInt();
      return int.tryParse(raw?.toString() ?? '') ?? 0;
    }
    return int.tryParse(data?.toString() ?? '') ?? 0;
  }
}
