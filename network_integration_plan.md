# Rencana Implementasi Integrasi Jaringan (Flutter & Spring Boot)

Dokumen ini berisi langkah-langkah implementasi teknis untuk menghubungkan aplikasi mobile Flutter dengan backend Spring Boot menggunakan pendekatan **Hybrid (REST API + WebSockets)** sesuai dengan arsitektur yang direncanakan.

---

## 1. Persiapan Dependensi (pubspec.yaml)

Langkah pertama adalah menambahkan pustaka (library) yang dibutuhkan ke dalam proyek Flutter Anda.

```yaml
dependencies:
  flutter:
    sdk: flutter
  # REST API Client (Utama)
  dio: ^5.4.0
  # WebSocket / STOMP Client (Untuk Real-time Chat)
  stomp_dart_client: ^1.0.0
  # Penyimpanan aman untuk JWT Token
  flutter_secure_storage: ^9.0.0
```

> [!IMPORTANT]
> Pastikan backend Spring Boot Anda sudah mengonfigurasi CORS (Cross-Origin Resource Sharing) yang mengizinkan origin dari perangkat mobile atau emulator.

---

## 2. Implementasi REST API (Menggunakan `dio`)

Gunakan REST API untuk **semua komunikasi standar** seperti Auth (Login/Register), CRUD Project, Pembaruan Profil, dan aksi lainnya.

### A. Konfigurasi `DioClient` dan Interceptors
Buat sebuah kelas *singleton* untuk mengatur koneksi dasar secara terpusat, mengatur *timeout*, dan membuat **Interceptor untuk JWT Token**. Ini memastikan Anda tidak perlu menyisipkan token secara manual di setiap request.

```dart
// lib/core/network/dio_client.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late Dio dio;
  final storage = const FlutterSecureStorage();

  // Singleton pattern
  factory DioClient() {
    return _instance;
  }

  DioClient._internal() {
    dio = Dio(BaseOptions(
      // Ganti dengan IP komputer Anda (misal: 192.168.1.x) atau URL server
      // Jika pakai emulator Android lokal, gunakan: 10.0.2.2:8080
      baseUrl: 'http://10.0.2.2:8080', 
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      contentType: 'application/json',
    ));

    // Mendaftarkan Interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Otomatis mengambil token dan menyisipkan ke Header Authorization
          String? token = await storage.read(key: 'jwt_token');
          if (token != null && options.path != '/api/auth/login') {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Tangani global error (contoh: Token Expired)
          if (e.response?.statusCode == 401) {
            // TODO: Arahkan paksa pengguna ke halaman Login atau lakukan Refresh Token
            print("Token expired. Harap login kembali.");
          }
          return handler.next(e);
        },
      ),
    );
  }
}
```

### B. Contoh Implementasi di Service Layer
Service layer bertugas murni memanggil endpoint.

```dart
// lib/features/dashboard/services/activity_service.dart
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class ActivityService {
  final DioClient _client = DioClient();

  Future<List<dynamic>> getRecentActivities() async {
    try {
      // Memanggil endpoint backend (Token JWT otomatis ditambahkan oleh Interceptor)
      final response = await _client.dio.get('/api/activities/recent');
      
      // Sesuaikan parsing data dengan struktur ApiResponse dari backend Anda
      return response.data['data']; 
    } catch (e) {
      // Tangani exception, bisa dilempar (throw) ke BLoC/UI
      throw Exception('Gagal memuat daftar aktivitas: ${e.toString()}');
    }
  }
}
```

---

## 3. Implementasi WebSockets (Menggunakan `stomp_dart_client`)

Gunakan WebSockets **hanya untuk fitur yang butuh pembaruan instan** seperti Chat Real-time.

### A. Konfigurasi `StompClient`
Buat pengelola koneksi WebSocket yang kompatibel dengan protokol STOMP milik Spring Boot.

```dart
// lib/core/network/websocket_manager.dart
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class WebSocketManager {
  static final WebSocketManager _instance = WebSocketManager._internal();
  StompClient? stompClient;
  final storage = const FlutterSecureStorage();

  factory WebSocketManager() {
    return _instance;
  }

  WebSocketManager._internal();

  Future<void> connect({required Function(Map<String, dynamic>) onMessageReceived}) async {
    String? token = await storage.read(key: 'jwt_token');

    stompClient = StompClient(
      config: StompConfig(
        // Endpoint WebSocket STOMP di Spring Boot. 
        // Ingat: gunakan ws:// bukan http://
        url: 'ws://10.0.2.2:8080/ws', 
        onConnect: (StompFrame frame) {
          print('Sukses terhubung ke WebSocket STOMP');
          
          // Berlangganan (Subscribe) ke channel untuk menerima pesan
          stompClient!.subscribe(
            destination: '/user/queue/messages', // Ganti sesuai konfigurasi backend Anda
            callback: (frame) {
              if (frame.body != null) {
                // Saat ada pesan masuk, panggil fungsi callback
                // onMessageReceived(jsonDecode(frame.body!));
                print("Ada pesan baru: ${frame.body}");
              }
            },
          );
        },
        // Menyisipkan JWT Token untuk autentikasi koneksi WebSocket
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
        onWebSocketError: (dynamic error) => print("Kesalahan WebSocket: $error"),
      ),
    );

    stompClient!.activate();
  }

  void sendMessage(String destination, String messageBody) {
    if (stompClient != null && stompClient!.isActive) {
      stompClient!.send(
        destination: destination, // contoh: '/app/chat.sendMessage'
        body: messageBody,
      );
    }
  }

  void disconnect() {
    stompClient?.deactivate();
  }
}
```

> [!TIP]
> **Manajemen Siklus Hidup (Lifecycle):** 
> - Aktifkan `WebSocketManager().connect()` hanya ketika pengguna masuk ke halaman utama/dashboard, atau khusus ketika masuk ke halaman daftar obrolan (Chat).
> - Pastikan selalu memanggil `disconnect()` saat pengguna menekan tombol *Logout* untuk menutup koneksi dan membebaskan sumber daya server.

---

## 4. Alur Integrasi Keseluruhan (BLoC -> Service -> API)

Untuk membuat aplikasi yang skalabel, kita memisahkan UI, State (BLoC), dan API:

1. **User Berinteraksi di UI**: Pengguna masuk ke halaman *Chat Room* lalu menekan tombol "Kirim Pesan".
2. **UI ke BLoC**: Tombol ditekan memanggil *Event* di BLoC (`chatBloc.add(SendMessageEvent(...))`).
3. **BLoC ke Service**: BLoC menangkap event dan memanggil `WebSocketManager.sendMessage()`. Jika itu pengiriman file, BLoC akan memanggil `ChatService.uploadAttachment()` yang menggunakan `DioClient`.
4. **Respon / Real-time Masuk**: Ketika pesan terkirim dan backend melempar kembali (broadcast) pesan ke tujuan (`onMessageReceived`), BLoC akan memancarkan (emit) State baru (`ChatUpdatedState`).
5. **UI Update Otomatis**: `BlocBuilder` di layar menangkap State baru ini dan secara instan me-render ulang daftar *bubble chat* untuk memunculkan pesan baru tanpa harus reload manual.
