import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages WebSocket STOMP connections for real-time chat functionality.
/// Uses raw WebSocket endpoint (/ws-raw) compatible with non-browser clients.
class WebSocketManager {
  static final WebSocketManager _instance = WebSocketManager._internal();
  StompClient? stompClient;
  final _storage = const FlutterSecureStorage();

  factory WebSocketManager() => _instance;
  WebSocketManager._internal();

  /// Whether the WebSocket is currently connected
  bool get isConnected => stompClient != null && stompClient!.isActive;

  /// Connect to WebSocket STOMP server
  Future<void> connect({
    required int currentUserId,
    required Function(Map<String, dynamic> message) onMessageReceived,
    Function(String error)? onError,
  }) async {
    // Don't reconnect if already active
    if (isConnected) return;

    final String? token = await _storage.read(key: 'jwt_token');

    stompClient = StompClient(
      config: StompConfig(
        // Raw WebSocket endpoint for mobile (non-SockJS)
        url: 'wss://quickturn-api-bxcqfshtdtfjhaav.indonesiacentral-01.azurewebsites.net/ws-raw',
        onConnect: (StompFrame frame) {
          print('WebSocket connected successfully.');

          // Subscribe to incoming messages for this user
          stompClient!.subscribe(
            destination: '/topic/public/$currentUserId',
            callback: (StompFrame frame) {
              if (frame.body != null) {
                final Map<String, dynamic> message = jsonDecode(frame.body!);
                onMessageReceived(message);
              }
            },
          );

          // (Optional) Subscribe to error channel
          stompClient!.subscribe(
            destination: '/topic/errors/$currentUserId',
            callback: (StompFrame frame) {
              if (frame.body != null) {
                print("WebSocket server error: ${frame.body}");
                onError?.call(frame.body!);
              }
            },
          );
        },
        stompConnectHeaders: token != null ? {'Authorization': 'Bearer $token'} : null,
        webSocketConnectHeaders: token != null ? {'Authorization': 'Bearer $token'} : null,
        onWebSocketError: (dynamic error) {
          print("WebSocket connection error: $error");
          onError?.call(error.toString());
        },
        onDisconnect: (frame) => print("WebSocket disconnected."),
      ),
    );

    stompClient!.activate();
  }

  /// Send a chat message via STOMP
  void sendChatMessage({
    required int senderId,
    required int recipientId,
    required String content,
    String? attachmentUrl,
    String? attachmentType,
    String? originalFilename,
    int fileSize = 0,
  }) {
    if (stompClient != null && stompClient!.isActive) {
      final Map<String, dynamic> payload = {
        'senderId': senderId,
        'recipientId': recipientId,
        'content': content,
        'attachmentUrl': attachmentUrl,
        'attachmentType': attachmentType,
        'originalFilename': originalFilename,
        'fileSize': fileSize,
      };

      stompClient!.send(
        destination: '/app/chat.sendMessage',
        body: jsonEncode(payload),
      );
    } else {
      print("Failed to send message: WebSocket not connected.");
    }
  }

  /// Disconnect the WebSocket (call on logout or leaving chat)
  void disconnect() {
    stompClient?.deactivate();
    stompClient = null;
  }
}
