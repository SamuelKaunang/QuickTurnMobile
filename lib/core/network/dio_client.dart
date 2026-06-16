import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Centralized HTTP client for all REST API communication.
/// Uses Dio with interceptors for automatic JWT token injection.
class DioClient {
  static final DioClient _instance = DioClient._internal();
  late Dio dio;
  final _storage = const FlutterSecureStorage();

  factory DioClient() => _instance;

  /// Single source of truth for the API base URL.
  ///
  /// Defaults to the deployed Azure backend. For local development against the
  /// `feature/geoloc-backend` branch on an Android emulator, override it without
  /// touching code by running:
  ///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
  /// (10.0.2.2 is the emulator's alias for the host machine's localhost.)
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue:
        'https://quickturn-api-bxcqfshtdtfjhaav.indonesiacentral-01.azurewebsites.net',
  );

  DioClient._internal() {
    dio = Dio(BaseOptions(
      // QuickTurn API backend (see [baseUrl] above for local-override notes)
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      contentType: 'application/json',
    ));

    // Register JWT Token Interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Skip token injection for auth endpoints
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
          // Global error handler: token expired / unauthorized
          if (e.response?.statusCode == 401) {
            // TODO: Trigger force logout via auth BLoC/provider
            print("Session expired (401 Unauthorized). Please login again.");
          }
          return handler.next(e);
        },
      ),
    );
  }

  /// Read the stored JWT token
  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  /// Store JWT token securely
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  /// Store user role
  Future<void> saveUserRole(String role) async {
    await _storage.write(key: 'user_role', value: role);
  }

  /// Read stored user role
  Future<String?> getUserRole() async {
    return await _storage.read(key: 'user_role');
  }

  /// Clear all stored credentials (for logout)
  Future<void> clearCredentials() async {
    await _storage.deleteAll();
  }
}
