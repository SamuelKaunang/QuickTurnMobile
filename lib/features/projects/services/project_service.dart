import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class ProjectService {
  final DioClient _client = DioClient();

  /// Get all open projects
  Future<List<Map<String, dynamic>>> getAllProjects() async {
    try {
      final response = await _client.dio.get('/api/projects');
      final res = response.data;
      if (res['success'] == true && res['data'] != null) {
        return List<Map<String, dynamic>>.from(res['data']);
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Get recommended projects for the logged-in student
  Future<List<Map<String, dynamic>>> getRecommendedProjects() async {
    try {
      final response = await _client.dio.get('/api/projects/recommendations');
      final res = response.data;
      if (res['success'] == true && res['data'] != null) {
        return List<Map<String, dynamic>>.from(res['data']);
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Get projects the student is participating in (applied / ongoing / completed)
  Future<List<Map<String, dynamic>>> getParticipatingProjects() async {
    try {
      final response = await _client.dio.get('/api/projects/participating');
      final res = response.data;
      if (res['success'] == true && res['data'] != null) {
        return List<Map<String, dynamic>>.from(res['data']);
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Get projects created by the logged-in UMKM/Client
  Future<List<Map<String, dynamic>>> getMyProjects() async {
    try {
      final response = await _client.dio.get('/api/projects/my-projects');
      final res = response.data;
      if (res['success'] == true && res['data'] != null) {
        return List<Map<String, dynamic>>.from(res['data']);
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Post a new project (UMKM only)
  Future<Map<String, dynamic>> postProject({
    required String title,
    required String description,
    required double budget,
    required String deadline,
    required String category,
  }) async {
    try {
      final response = await _client.dio.post(
        '/api/projects',
        data: {
          'title': title,
          'description': description,
          'budget': budget,
          'deadline': deadline,
          'category': category,
        },
      );
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Gagal membuat proyek',
        'error': e.response?.data?['error'],
        'email': e.response?.data?['email'],
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Apply to a project (Student only)
  Future<Map<String, dynamic>> applyProject({
    required int projectId,
    required String proposal,
    required double bidAmount,
  }) async {
    try {
      final response = await _client.dio.post(
        '/api/projects/$projectId/apply',
        data: {
          'proposal': proposal,
          'bidAmount': bidAmount,
        },
      );
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Gagal melamar proyek',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Get list of applicants for a specific project (UMKM only)
  Future<List<Map<String, dynamic>>> getApplicants(int projectId) async {
    try {
      final response = await _client.dio.get('/api/projects/$projectId/applicants');
      final res = response.data;
      if (res['success'] == true && res['data'] != null) {
        return List<Map<String, dynamic>>.from(res['data']);
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Accept an applicant for a project (UMKM only)
  Future<Map<String, dynamic>> acceptApplicant({
    required int projectId,
    required int applicationId,
  }) async {
    try {
      final response = await _client.dio.post(
        '/api/projects/$projectId/applicants/$applicationId/accept',
      );
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Gagal menerima pelamar',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Reject an applicant for a project (UMKM only)
  Future<Map<String, dynamic>> rejectApplicant({
    required int projectId,
    required int applicationId,
  }) async {
    try {
      final response = await _client.dio.post(
        '/api/projects/$projectId/applicants/$applicationId/reject',
      );
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Gagal menolak pelamar',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Submit work / finishing link (Student only)
  Future<Map<String, dynamic>> submitFinishing({
    required int projectId,
    required String finishingLink,
  }) async {
    try {
      final response = await _client.dio.post(
        '/api/projects/$projectId/finish',
        data: {
          'finishingLink': finishingLink,
        },
      );
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Gagal menyerahkan pekerjaan',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Confirm project finishing and close project (UMKM only)
  Future<Map<String, dynamic>> confirmFinishing(int projectId) async {
    try {
      final response = await _client.dio.post(
        '/api/projects/$projectId/finish/confirm',
      );
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Gagal mengonfirmasi penyelesaian',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Submit a review for a completed project (Both roles)
  Future<Map<String, dynamic>> submitReview({
    required int projectId,
    required int rating,
    required String comment,
  }) async {
    try {
      final response = await _client.dio.post(
        '/api/projects/$projectId/review',
        data: {
          'rating': rating,
          'comment': comment,
        },
      );
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Gagal mengirim ulasan',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Get user's review for a project (Both roles)
  Future<Map<String, dynamic>> getMyReview(int projectId) async {
    try {
      final response = await _client.dio.get('/api/projects/$projectId/my-review');
      return response.data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Get project brief & attachment (Only for accepted talents)
  Future<Map<String, dynamic>> getProjectBrief(int projectId) async {
    try {
      final response = await _client.dio.get('/api/projects/$projectId/brief');
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Gagal mengambil brief proyek',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Get active system announcements
  Future<List<Map<String, dynamic>>> getAnnouncements() async {
    try {
      final response = await _client.dio.get('/api/announcements');
      final res = response.data;
      if (res['success'] == true && res['data'] != null) {
        return List<Map<String, dynamic>>.from(res['data']);
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
