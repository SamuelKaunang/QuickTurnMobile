import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class ChatService {
  final DioClient _client = DioClient();

  /// Retrieve the list of active chat contacts
  Future<List<dynamic>> getContacts() async {
    try {
      final response = await _client.dio.get('/api/chat/contacts');
      final responseData = response.data;
      if (responseData['success'] == true && responseData['data'] != null) {
        return responseData['data'] as List<dynamic>;
      }
      return [];
    } catch (e) {
      print('Error fetching contacts: $e');
      return [];
    }
  }

  /// Retrieve conversation history with a specific user
  Future<List<dynamic>> getChatHistory(int contactId) async {
    try {
      // Trying with query parameter contactId or recipientId
      final response = await _client.dio.get(
        '/api/chat/history',
        queryParameters: {'contactId': contactId, 'recipientId': contactId},
      );
      final responseData = response.data;
      if (responseData['success'] == true && responseData['data'] != null) {
        return responseData['data'] as List<dynamic>;
      }
      return [];
    } catch (e) {
      print('Error fetching chat history: $e');
      return [];
    }
  }

  /// Initiate a new chat conversation with another user
  Future<Map<String, dynamic>> startChat(int userId) async {
    try {
      final response = await _client.dio.post(
        '/api/chat/start',
        data: {'userId': userId},
      );
      final responseData = response.data;
      return {
        'success': responseData['success'] == true,
        'message': responseData['message'],
        'data': responseData['data'],
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Gagal memulai chat',
      };
    }
  }

  /// Mark all unread messages from a contact as read
  Future<bool> markAsRead(int senderId) async {
    try {
      final response = await _client.dio.post(
        '/api/chat/mark-read',
        data: {'senderId': senderId},
      );
      return response.data['success'] == true;
    } catch (e) {
      print('Error marking messages as read: $e');
      return false;
    }
  }

  /// Upload an attachment in chat
  Future<Map<String, dynamic>> uploadAttachment(String filePath) async {
    try {
      final fileName = filePath.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await _client.dio.post(
        '/api/chat/upload',
        data: formData,
      );

      final responseData = response.data;
      if (responseData['success'] == true && responseData['data'] != null) {
        return {
          'success': true,
          'url': responseData['data']['url'],
          'fileName': responseData['data']['fileName'],
          'fileSize': responseData['data']['fileSize'],
        };
      }
      return {
        'success': false,
        'message': responseData['message'] ?? 'Gagal mengunggah berkas',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Gagal mengunggah berkas',
      };
    }
  }
}
