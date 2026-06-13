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
      if (brief != null && brief.isNotEmpty) data['brief'] = brief;
      if (budget != null) data['budget'] = budget;
      if (deadline != null && deadline.isNotEmpty) data['deadline'] = deadline;
      if (duration != null && duration.isNotEmpty) data['duration'] = duration;
      if (complexity != null && complexity.isNotEmpty) {
        data['complexity'] = complexity;
      }
      if (skills.isNotEmpty) data['skills'] = skills;

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
        final list = (responseData['data'] as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .map(Project.fromJson)
            .toList();
        return NearbyProjectsResult(
          success: true,
          message: responseData['message']?.toString(),
          projects: list,
        );
      }

      return NearbyProjectsResult(
        success: false,
        message: (responseData is Map ? responseData['message'] : null)
                ?.toString() ??
            'Gagal memuat proyek terdekat',
      );
    } on DioException catch (e) {
      final isAuthError = e.response?.statusCode == 401;
      return NearbyProjectsResult(
        success: false,
        unauthenticated: isAuthError,
        message: isAuthError
            ? 'Sesi berakhir. Silakan login kembali.'
            : (e.response?.data is Map
                    ? e.response?.data['message']
                    : null)
                ?.toString() ??
                'Terjadi kesalahan jaringan',
      );
    } catch (e) {
      return NearbyProjectsResult(
        success: false,
        message: 'Terjadi kesalahan: $e',
      );
    }
  }
}
