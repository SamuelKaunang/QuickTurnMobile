import 'package:flutter_test/flutter_test.dart';
import 'package:quick_turn_mobile/features/projects/models/project_model.dart';
import 'package:quick_turn_mobile/features/projects/services/project_service.dart';

void main() {
  group('ProjectService.filterNearbyProjects', () {
    test('filters by radius, excludes missing coordinates, and sorts by distance', () {
      const centerLat = -6.9175;
      const centerLng = 107.6191;
      const projects = [
        Project(
          id: 1,
          title: 'Closer project',
          latitude: -6.9225,
          longitude: 107.6191,
        ),
        Project(
          id: 2,
          title: 'Nearby project',
          latitude: -6.9275,
          longitude: 107.6191,
        ),
        Project(
          id: 3,
          title: 'Outside radius',
          latitude: -7.1175,
          longitude: 107.6191,
        ),
        Project(id: 4, title: 'No location'),
      ];

      final result = ProjectService.filterNearbyProjects(
        projects,
        centerLat,
        centerLng,
        10,
      );

      expect(result.map((project) => project.id), [1, 2]);
      expect(result.first.distanceKm, isNotNull);
      expect(result.first.distanceKm!, lessThan(result.last.distanceKm!));
    });
  });
}
