import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/services/push_notification_service.dart';

class AuthService {
  final DioClient _client = DioClient();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    serverClientId: '635708064928-v3c58k8aunkmjcdt3taq3b2fe2cs9iih.apps.googleusercontent.com',
  );

  /// Login user and save the JWT token & role
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.dio.post(
        '/api/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final responseData = response.data;
      if (responseData['success'] == true && responseData['data'] != null) {
        final data = responseData['data'];
        final String token = data['accessToken'];
        final String role = data['role'] ?? 'MAHASISWA';
        
        // Save to secure storage via DioClient helper methods
        await _client.saveToken(token);
        await _client.saveUserRole(role);
        
        // Register device token for push notifications
        PushNotificationService().registerDeviceToken();
        
        // Return full data map
        return {
          'success': true,
          'message': responseData['message'] ?? 'Login successful',
          'role': role,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Login failed',
        };
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? 'Terjadi kesalahan jaringan';
      return {
        'success': false,
        'message': errorMsg,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  /// Register a new user
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role, // MAHASISWA or UMKM
  }) async {
    try {
      final response = await _client.dio.post(
        '/api/auth/register',
        data: {
          'nama': name,
          'email': email,
          'password': password,
          'role': role,
        },
      );

      final responseData = response.data;
      final nestedData = responseData is Map ? responseData['data'] : null;
      final registrationData = nestedData is Map ? nestedData : null;
      final registrationSucceeded = registrationData?['success'] == true ||
          (registrationData == null &&
              responseData is Map &&
              responseData['success'] == true);
      final message = registrationData?['message']?.toString() ??
          (responseData is Map ? responseData['message']?.toString() : null);

      if (registrationSucceeded) {
        return {
          'success': true,
          'message': message ?? 'Registrasi berhasil',
        };
      } else {
        return {
          'success': false,
          'message': message ?? 'Registrasi gagal',
        };
      }
    } on DioException catch (e) {
      final errorData = e.response?.data;
      final nestedData = errorData is Map ? errorData['data'] : null;
      final errorMsg =
          (nestedData is Map ? nestedData['message']?.toString() : null) ??
              (errorData is Map ? errorData['message']?.toString() : null) ??
              'Terjadi kesalahan jaringan';
      return {
        'success': false,
        'message': errorMsg,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  /// Verify email using the 6-digit OTP code received during registration
  Future<Map<String, dynamic>> verifyEmailOtp({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _client.dio.post(
        '/api/auth/verify-email',
        data: {
          'email': email,
          'code': code,
        },
      );

      final responseData = response.data;
      final nestedData = responseData is Map ? responseData['data'] : null;
      final authData = nestedData is Map ? nestedData : null;
      
      final isSuccess = responseData['success'] == true && authData != null;

      if (isSuccess) {
        final String token = authData['accessToken'];
        final String role = authData['role'] ?? 'MAHASISWA';
        
        // Save to secure storage
        await _client.saveToken(token);
        await _client.saveUserRole(role);
        
        // Register device token for push notifications
        PushNotificationService().registerDeviceToken();
        
        return {
          'success': true,
          'message': responseData['message'] ?? 'Email verified successfully!',
          'role': role,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Gagal memverifikasi email',
        };
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? 'Terjadi kesalahan jaringan';
      return {
        'success': false,
        'message': errorMsg,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  /// Resend verification OTP code
  Future<Map<String, dynamic>> resendVerificationOtp({
    required String email,
  }) async {
    try {
      final response = await _client.dio.post(
        '/api/auth/resend-verification-otp',
        data: {
          'email': email,
        },
      );
      final responseData = response.data;
      return {
        'success': responseData['success'] == true,
        'message': responseData['message'] ?? 'Kode verifikasi baru telah dikirim',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Gagal mengirim ulang kode verifikasi',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  /// Request a password reset OTP code
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await _client.dio.post(
        '/api/auth/forgot-password',
        data: {'email': email},
      );
      final responseData = response.data;
      return {
        'success': responseData['success'] == true,
        'message': responseData['message'] ?? 'OTP reset password telah dikirim',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Gagal mengirim OTP',
      };
    }
  }

  /// Verify the reset password OTP code
  Future<Map<String, dynamic>> verifyResetCode({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _client.dio.post(
        '/api/auth/verify-reset-code',
        data: {
          'code': code,
        },
      );
      final responseData = response.data;
      return {
        'success': responseData['success'] == true,
        'message': responseData['message'] ?? 'Verifikasi OTP berhasil',
        'resetToken': responseData['data']?['resetToken'],
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'OTP tidak valid atau kedaluwarsa',
      };
    }
  }

  /// Reset to new password
  Future<Map<String, dynamic>> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    try {
      final response = await _client.dio.post(
        '/api/auth/reset-password',
        data: {
          'resetToken': resetToken,
          'newPassword': newPassword,
        },
      );
      final responseData = response.data;
      return {
        'success': responseData['success'] == true,
        'message': responseData['message'] ?? 'Password berhasil diubah',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Gagal mengubah password',
      };
    }
  }

  /// Fetch profile of current logged-in user
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _client.dio.get('/api/users/profile');
      final responseData = response.data;
      if (responseData['success'] == true) {
        return {
          'success': true,
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Gagal memuat profil',
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Gagal memuat profil',
      };
    }
  }

  /// Logout user
  Future<void> logout() async {
    await _client.clearCredentials();
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _client.dio.put('/api/users/profile', data: data);
      final responseData = response.data;
      return {
        'success': responseData['success'] == true,
        'message': responseData['message'] ?? 'Profil berhasil diperbarui',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Gagal memperbarui profil',
      };
    }
  }

  /// Delete user account permanently
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final response = await _client.dio.delete('/api/users/account');
      final responseData = response.data;
      return {
        'success': responseData['success'] == true,
        'message': responseData['message'] ?? 'Akun berhasil dihapus',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Gagal menghapus akun',
      };
    }
  }

  /// Get delete account confirmation phrase
  Future<String> getDeleteConfirmation() async {
    try {
      final response = await _client.dio.get('/api/users/account/delete-confirmation');
      return response.data['data'] ?? 'DELETE-MY-ACCOUNT-7X9K';
    } catch (_) {
      return 'DELETE-MY-ACCOUNT-7X9K';
    }
  }

  /// Search users / talents
  Future<List<Map<String, dynamic>>> searchUsers(String query, {String? role}) async {
    try {
      final response = await _client.dio.get(
        '/api/users/search',
        queryParameters: {
          'query': query,
          if (role != null) 'role': role,
        },
      );
      final responseData = response.data;
      if (responseData['success'] == true && responseData['data'] != null) {
        final list = responseData['data'] as List;
        return list.map((item) => Map<String, dynamic>.from(item)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Get public profile of another user
  Future<Map<String, dynamic>> getPublicProfile(int userId) async {
    try {
      final response = await _client.dio.get('/api/users/profile/$userId');
      final responseData = response.data;
      if (responseData['success'] == true && responseData['data'] != null) {
        return Map<String, dynamic>.from(responseData['data']);
      }
      return {};
    } catch (_) {
      return {};
    }
  }

  /// Login via Google
  Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      // Disconnect previous session to allow account selection dialog
      try {
        await _googleSignIn.signOut();
      } catch (_) {}

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return {
          'success': false,
          'message': 'Login dibatalkan oleh pengguna',
        };
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        return {
          'success': false,
          'message': 'Gagal memperoleh token autentikasi Google',
        };
      }

      // Send idToken to Spring Boot Backend
      final response = await _client.dio.post(
        '/api/auth/google',
        data: {
          'idToken': idToken,
        },
      );

      final responseData = response.data;
      if (responseData['success'] == true && responseData['data'] != null) {
        final data = responseData['data'];
        final String token = data['accessToken'];
        final String role = data['role'] ?? 'MAHASISWA';
        
        await _client.saveToken(token);
        await _client.saveUserRole(role);
        
        PushNotificationService().registerDeviceToken();
        
        return {
          'success': true,
          'message': responseData['message'] ?? 'Login Google berhasil',
          'role': role,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Login Google gagal',
        };
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? 'Terjadi kesalahan jaringan ke server';
      return {
        'success': false,
        'message': errorMsg,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Autentikasi Google gagal: $e',
      };
    }
  }
}
