# Panduan Integrasi WebSocket (STOMP) QuickTurn Mobile

Dokumen ini menjelaskan spesifikasi dan panduan integrasi WebSocket antara aplikasi mobile Flutter dengan backend Spring Boot untuk fitur Chat Real-time.

---

## 1. Spesifikasi Endpoint & Broker

Berdasarkan konfigurasi backend (`WebSocketConfig.java` dan `ChatController.java`), berikut adalah alamat dan tujuan yang **wajib** digunakan:

| Tipe Alur | Spesifikasi | Keterangan |
| :--- | :--- | :--- |
| **Koneksi WebSocket** | `ws://10.0.2.2:8080/ws-raw` | Menggunakan `/ws-raw` karena mobile menggunakan raw WebSocket (tanpa SockJS). |
| **Subscribe (Menerima Pesan)**| `/topic/public/{userId}` | Gantilah `{userId}` dengan ID pengguna yang sedang login untuk menerima pesan masuk. |
| **Publish (Mengirim Pesan)** | `/app/chat.sendMessage` | Destination untuk mengirim pesan ke server. |
| **Subscribe Error (Opsional)** | `/topic/errors/{userId}` | Menerima pemberitahuan jika terjadi kegagalan pengiriman pesan di server. |

> [!NOTE]
> Alamat `10.0.2.2` digunakan khusus untuk emulator Android bawaan Android Studio guna mengakses `localhost` komputer host. Jika menggunakan perangkat fisik (HP asli) atau iOS Simulator, sesuaikan dengan IP lokal komputer Anda (contoh: `192.168.1.50`).

---

## 2. Struktur Data Payload (JSON)

Format JSON yang dikirimkan ke `/app/chat.sendMessage` harus cocok dengan kelas `ChatMessageDTO` di backend:

```json
{
  "senderId": 1,
  "recipientId": 2,
  "content": "Halo, ini pesan uji coba!",
  "attachmentUrl": null,
  "attachmentType": null,
  "originalFilename": null,
  "fileSize": 0
}
```

---

## 3. Implementasi Dart / Flutter (`stomp_dart_client`)

Berikut adalah contoh kelas helper `WebSocketService` di Flutter yang sudah disesuaikan dengan konfigurasi backend Anda:

```dart
import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  StompClient? _stompClient;
  final _storage = const FlutterSecureStorage();

  factory WebSocketService() => _instance;
  WebSocketService._internal();

  /// Menghubungkan ke server WebSocket
  Future<void> connect({
    required int currentUserId,
    required Function(Map<String, dynamic> message) onMessageReceived,
  }) async {
    // Ambil JWT token dari storage untuk keamanan (jika backend melakukan validasi handshake)
    final String? token = await _storage.read(key: 'jwt_token');

    _stompClient = StompClient(
      config: StompConfig(
        url: 'ws://10.0.2.2:8080/ws-raw', // Endpoint khusus mobile tanpa SockJS
        onConnect: (StompFrame frame) {
          print('WebSocket Connected!');

          // Berlangganan ke topik publik milik user saat ini
          _stompClient!.subscribe(
            destination: '/topic/public/$currentUserId',
            callback: (StompFrame frame) {
              if (frame.body != null) {
                final Map<String, dynamic> messageData = jsonDecode(frame.body!);
                onMessageReceived(messageData);
              }
            },
          );

          // (Opsional) Berlangganan ke topik error
          _stompClient!.subscribe(
            destination: '/topic/errors/$currentUserId',
            callback: (StompFrame frame) {
              if (frame.body != null) {
                print("WebSocket Error dari Server: ${frame.body}");
              }
            },
          );
        },
        stompConnectHeaders: token != null ? {'Authorization': 'Bearer $token'} : null,
        webSocketConnectHeaders: token != null ? {'Authorization': 'Bearer $token'} : null,
        onWebSocketError: (dynamic error) => print("WS Connection Error: $error"),
        onDisconnect: (frame) => print("WebSocket Disconnected."),
      ),
    );

    _stompClient!.activate();
  }

  /// Mengirim pesan ke pengguna lain
  void sendChatMessage({
    required int senderId,
    required int recipientId,
    required String content,
    String? attachmentUrl,
    String? attachmentType,
    String? originalFilename,
    int fileSize = 0,
  }) {
    if (_stompClient != null && _stompClient!.isActive) {
      final Map<String, dynamic> payload = {
        'senderId': senderId,
        'recipientId': recipientId,
        'content': content,
        'attachmentUrl': attachmentUrl,
        'attachmentType': attachmentType,
        'originalFilename': originalFilename,
        'fileSize': fileSize,
      };

      _stompClient!.send(
        destination: '/app/chat.sendMessage',
        body: jsonEncode(payload),
      );
    } else {
      print("Gagal mengirim pesan: WebSocket belum aktif.");
    }
  }

  /// Memutuskan koneksi WebSocket (Panggil saat logout atau menghapus controller)
  void disconnect() {
    _stompClient?.deactivate();
    _stompClient = null;
  }
}
```
