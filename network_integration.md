# Rencana Integrasi Jaringan (Dio + Flutter Secure Storage + WebSockets)

Dokumen ini berisi panduan dan implementasi konkret untuk menghubungkan aplikasi Flutter Anda dengan backend Spring Boot, mengintegrasikan JWT Token secara aman, dan mengaktifkan obrolan real-time.

---

## 1. Konfigurasi Dependensi (`pubspec.yaml`)

Tambahkan dependensi berikut ke dalam file `pubspec.yaml` proyek Flutter Anda:

```yaml
dependencies:
  flutter:
    sdk: flutter
  # REST API Client (Menggantikan http)
  dio: ^5.4.0
  # WebSocket STOMP Client
  stomp_dart_client: ^2.1.1
  # Penyimpanan Kredensial Terenkripsi (JWT Token)
  flutter_secure_storage: ^9.0.0
  # Penyimpanan Pengaturan Lokal (Non-sensitif)
  shared_preferences: ^2.2.3
```

---

## 2. Penyimpanan Kredensial (Token & Sesi)

Kita menggunakan pendekatan keamanan berlapis:
1. **`flutter_secure_storage`**: Digunakan untuk menyimpan `jwt_token` (Access Token) karena dienkripsi di Keychain (iOS) atau Keystore (Android).
2. **`shared_preferences`**: Digunakan untuk data non-sensitif (seperti `user_role`, status `is_first_open`, atau preferensi tema).

---

## 3. Implementasi REST API Client (`DioClient`)

Buat file network client terpusat yang otomatis menyematkan JWT Token pada setiap *request* yang membutuhkan otorisasi.

```dart
// lib/core/network/dio_client.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late Dio dio;
  final _storage = const FlutterSecureStorage();

  factory DioClient() => _instance;

  DioClient._internal() {
    dio = Dio(BaseOptions(
      // 10.0.2.2 adalah localhost jika Anda menjalankan aplikasi di Android Emulator.
      // Jika menggunakan iOS Simulator atau device fisik, ubah menjadi IP komputer Anda.
      baseUrl: 'http://10.0.2.2:8080', 
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      contentType: 'application/json',
    ));

    // Menambahkan Interceptor untuk otomatisasi JWT Token
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Jangan kirim token jika memanggil endpoint register atau login
          if (!options.path.contains('/api/auth/login') && 
              !options.path.contains('/api/auth/register')) {
            final String? token = await _storage.read(key: 'jwt_token');
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Global Error Handler (Misalnya Token kedaluwarsa / 401 Unauthorized)
          if (e.response?.statusCode == 401) {
            print("Sesi berakhir (401 Unauthorized). Harap login ulang.");
            // Hubungkan ke auth BLoC untuk memicu fungsi logout otomatis di aplikasi Anda
          }
          return handler.next(e);
        },
      ),
    );
  }
}
```

---

## 4. Implementasi WebSocket Manager (`stomp_dart_client`)

Gunakan *raw WebSocket* endpoint `/ws-raw` (bukan `/ws` yang membutuhkan SockJS) untuk berkomunikasi dua arah pada fitur chat.

```dart
// lib/core/network/websocket_manager.dart
import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class WebSocketManager {
  static final WebSocketManager _instance = WebSocketManager._internal();
  StompClient? stompClient;
  final _storage = const FlutterSecureStorage();

  factory WebSocketManager() => _instance;
  WebSocketManager._internal();

  /// Memulai koneksi WebSocket STOMP
  Future<void> connect({
    required int currentUserId,
    required Function(Map<String, dynamic> message) onMessageReceived,
  }) async {
    final String? token = await _storage.read(key: 'jwt_token');

    stompClient = StompClient(
      config: StompConfig(
        url: 'ws://10.0.2.2:8080/ws-raw', // Raw WebSocket khusus client non-browser
        onConnect: (StompFrame frame) {
          print('WebSocket connected successfully.');

          // Subscribe ke channel pesan masuk berdasarkan ID user yang login
          stompClient!.subscribe(
            destination: '/topic/public/$currentUserId',
            callback: (StompFrame frame) {
              if (frame.body != null) {
                final Map<String, dynamic> message = jsonDecode(frame.body!);
                onMessageReceived(message);
              }
            },
          );
        },
        stompConnectHeaders: token != null ? {'Authorization': 'Bearer $token'} : null,
        webSocketConnectHeaders: token != null ? {'Authorization': 'Bearer $token'} : null,
        onWebSocketError: (dynamic error) => print("WebSocket Error: $error"),
        onDisconnect: (frame) => print("WebSocket disconnected."),
      ),
    );

    stompClient!.activate();
  }

  /// Mengirim chat message
  void sendChatMessage({
    required int senderId,
    required int recipientId,
    required String content,
  }) {
    if (stompClient != null && stompClient!.isActive) {
      final Map<String, dynamic> payload = {
        'senderId': senderId,
        'recipientId': recipientId,
        'content': content,
        'attachmentUrl': null,
        'attachmentType': null,
        'originalFilename': null,
        'fileSize': 0,
      };

      stompClient!.send(
        destination: '/app/chat.sendMessage',
        body: jsonEncode(payload),
      );
    } else {
      print("Gagal mengirim pesan: Koneksi WebSocket tidak aktif.");
    }
  }

  /// Memutuskan koneksi WebSocket
  void disconnect() {
    stompClient?.deactivate();
    stompClient = null;
  }
}
```

---

## 5. Integrasi State Management (BLoC / Cubit)

Saat mengintegrasikan dengan UI:
1. **Login Sukses**: Simpan token menggunakan `FlutterSecureStorage` -> arahkan ke Dashboard.
2. **Masuk Chat Screen**: Inisialisasi `WebSocketManager().connect(currentUserId: ..., onMessageReceived: ...)` di event `initState` or BLoC initialization.
3. **Menerima Pesan**: Update state BLoC saat callback `onMessageReceived` terpanggil.
4. **Keluar Chat Screen / Logout**: Panggil `WebSocketManager().disconnect()` untuk menjaga performa koneksi server.
