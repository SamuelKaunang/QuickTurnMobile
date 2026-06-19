import 'dart:math' as math;

import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../models/project_model.dart';

/// Outcome of a nearby-projects lookup. Carries enough information for the UI
/// to distinguish success, an empty result, and the various error states
/// (network failure, unauthenticated, server error).
class NearbyProjectsResult {
  final bool success;
  final String? message;
  final List<Project> projects;
  final bool unauthenticated;

  const NearbyProjectsResult({
    required this.success,
    this.message,
    this.projects = const [],
    this.unauthenticated = false,
  });
}

/// Outcome of a create-project request. Mirrors [NearbyProjectsResult] so the
/// UI can react uniformly to success, validation/server errors, and an expired
/// session.
class CreateProjectResult {
  final bool success;
  final String? message;
  final Project? project;
  final bool unauthenticated;

  const CreateProjectResult({
    required this.success,
    this.message,
    this.project,
    this.unauthenticated = false,
  });
}

class ProjectService {
  final DioClient _client = DioClient();

  /// Create a new project (UMKM/Client only).
  ///
  /// Calls `POST /api/projects` through the shared [DioClient] (JWT + base URL
  /// handled there). All location fields ([city], [address], [latitude],
  /// [longitude]) are optional to match the backend — they are only sent when
  /// provided, so a remote project without a location still posts cleanly.
  /// When set, latitude/longitude let the project surface on the Talent
  /// "Nearby Projects" map.
  Future<CreateProjectResult> createProject({
    required String title,
    required String category,
    String? description,
    String? brief,
    num? budget,
    String? deadline,
    String? duration,
    String? complexity,
    List<String> skills = const [],
    String? city,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final data = <String, dynamic>{
        'title': title,
        'category': category,
      };

      // Only attach optional fields when the user actually filled them in, so
      // we never overwrite backend defaults with empty values.
      if (description != null && description.isNotEmpty) {
        data['description'] = description;
      }
      if (brief != null && brief.isNotEmpty) data['briefText'] = brief;
      if (budget != null) data['budget'] = budget;
      if (deadline != null && deadline.isNotEmpty) data['deadline'] = deadline;
      if (duration != null && duration.isNotEmpty) {
        data['estimatedDuration'] = duration;
      }
      if (complexity != null && complexity.isNotEmpty) {
        data['complexity'] = complexity;
      }
      if (skills.isNotEmpty) data['requiredSkills'] = skills.join(', ');

      // Optional location block (matches the backend's optional fields).
      if (city != null && city.isNotEmpty) data['city'] = city;
      if (address != null && address.isNotEmpty) data['address'] = address;
      if (latitude != null) data['latitude'] = latitude;
      if (longitude != null) data['longitude'] = longitude;

      final response = await _client.dio.post('/api/projects', data: data);

      final responseData = response.data;
      if (responseData is Map && responseData['success'] == true) {
        final projectJson = responseData['data'];
        return CreateProjectResult(
          success: true,
          message: responseData['message']?.toString() ??
              'Proyek berhasil dibuat',
          project: projectJson is Map<String, dynamic>
              ? Project.fromJson(projectJson)
              : null,
        );
      }

      return CreateProjectResult(
        success: false,
        message: (responseData is Map ? responseData['message'] : null)
                ?.toString() ??
            'Gagal membuat proyek',
      );
    } on DioException catch (e) {
      final isAuthError = e.response?.statusCode == 401;
      return CreateProjectResult(
        success: false,
        unauthenticated: isAuthError,
        message: isAuthError
            ? 'Sesi berakhir. Silakan login kembali.'
            : (e.response?.data is Map ? e.response?.data['message'] : null)
                    ?.toString() ??
                'Terjadi kesalahan jaringan',
      );
    } catch (e) {
      return CreateProjectResult(
        success: false,
        message: 'Terjadi kesalahan: $e',
      );
    }
  }

  /// Fetch open projects near a coordinate, within [radiusKm] kilometres.
  ///
  /// Calls `GET /api/projects/nearby?lat={lat}&lng={lng}&radiusKm={radiusKm}`
  /// through the shared [DioClient] (which injects the JWT automatically and
  /// resolves the base URL — Azure by default, or the local emulator host when
  /// overridden via `--dart-define=API_BASE_URL`).
  Future<NearbyProjectsResult> getNearbyProjects(
    double lat,
    double lng,
    int radiusKm,
  ) async {
    try {
      final response = await _client.dio.get(
        '/api/projects/nearby',
        queryParameters: {
          'lat': lat,
          'lng': lng,
          'radiusKm': radiusKm,
        },
      );

      final responseData = response.data;
      if (responseData is Map &&
          responseData['success'] == true &&
          responseData['data'] != null) {
        final list = _parseProjectList(responseData['data']);
        final directResult = NearbyProjectsResult(
          success: true,
          message: responseData['message']?.toString(),
          projects: list,
        );

        if (list.isNotEmpty) return directResult;

        // A deployed backend can expose /nearby before its location query or
        // database migration is fully active. Verify an empty server result
        // against the regular feed, whose coordinates can be filtered locally.
        final fallback = await _getNearbyFromAllProjects(lat, lng, radiusKm);
        return fallback.success ? fallback : directResult;
      }

      return _getNearbyFromAllProjects(
        lat,
        lng,
        radiusKm,
        originalMessage:
            (responseData is Map ? responseData['message'] : null)?.toString(),
      );
    } on DioException catch (e) {
      final isAuthError = e.response?.statusCode == 401;
      if (isAuthError) {
        return const NearbyProjectsResult(
          success: false,
          unauthenticated: true,
          message: 'Sesi berakhir. Silakan login kembali.',
        );
      }

      // The deployed backend may not yet expose /api/projects/nearby. The
      // regular project feed is older and stable, so use it as a compatibility
      // source and calculate distance on-device.
      return _getNearbyFromAllProjects(
        lat,
        lng,
        radiusKm,
        originalMessage:
            (e.response?.data is Map ? e.response?.data['message'] : null)
                ?.toString(),
      );
    } catch (e) {
      return NearbyProjectsResult(
        success: false,
        message: 'Terjadi kesalahan: $e',
      );
    }
  }

  Future<NearbyProjectsResult> _getNearbyFromAllProjects(
    double lat,
    double lng,
    int radiusKm, {
    String? originalMessage,
  }) async {
    try {
      final response = await _client.dio.get('/api/projects');
      final responseData = response.data;
      if (responseData is Map && responseData['success'] == true) {
        final projects = _parseProjectList(responseData['data']);
        return NearbyProjectsResult(
          success: true,
          projects: filterNearbyProjects(projects, lat, lng, radiusKm),
        );
      }

      return NearbyProjectsResult(
        success: false,
        message: originalMessage ??
            (responseData is Map ? responseData['message'] : null)?.toString() ??
            'Gagal memuat proyek terdekat',
      );
    } on DioException catch (e) {
      final isAuthError = e.response?.statusCode == 401;
      return NearbyProjectsResult(
        success: false,
        unauthenticated: isAuthError,
        message: isAuthError
            ? 'Sesi berakhir. Silakan login kembali.'
            : originalMessage ??
                (e.response?.data is Map
                        ? e.response?.data['message']
                        : null)
                    ?.toString() ??
                'Terjadi kesalahan jaringan',
      );
    } catch (_) {
      return NearbyProjectsResult(
        success: false,
        message: originalMessage ?? 'Gagal memuat proyek terdekat',
      );
    }
  }

  static List<Project> _parseProjectList(dynamic data) {
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((item) => Project.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  /// Filters projects with coordinates to [radiusKm] and orders nearest first.
  /// Kept public so the distance fallback can be verified without HTTP calls.
  static List<Project> filterNearbyProjects(
    Iterable<Project> projects,
    double lat,
    double lng,
    int radiusKm,
  ) {
    final nearby = <Project>[];
    for (final project in projects) {
      if (!project.hasValidLocation) continue;
      final distance = _distanceKm(
        lat,
        lng,
        project.latitude!,
        project.longitude!,
      );
      if (distance <= radiusKm) {
        nearby.add(project.withDistanceKm(distance));
      }
    }
    nearby.sort((a, b) => a.distanceKm!.compareTo(b.distanceKm!));
    return nearby;
  }

  static double _distanceKm(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const earthRadiusKm = 6371.0;
    final dLat = _radians(lat2 - lat1);
    final dLng = _radians(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_radians(lat1)) *
            math.cos(_radians(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return earthRadiusKm * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  static double _radians(double degrees) => degrees * math.pi / 180;

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

  /// Get finishing status (including finishingLink / file uploaded by student)
  Future<Map<String, dynamic>> getFinishingStatus(int projectId) async {
    try {
      final response = await _client.dio.get('/api/projects/$projectId/finish-status');
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Gagal mengambil status penyerahan',
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
