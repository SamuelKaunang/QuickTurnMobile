/// Domain model for a project returned by the backend.
///
/// Used by the "Nearby" mode of the Browse Projects screen. Parsing is
/// deliberately defensive: numeric fields may arrive as either `int` or
/// `double`, and most fields are nullable so a partially-populated record
/// (or an unexpected payload shape) never crashes the UI.
class Project {
  final int id;
  final String title;
  final String? description;
  final String? category;
  final double? budget;
  final String? deadline;
  final String? status;
  final String? ownerName;
  final int? ownerId;
  final String? city;
  final String? address;
  final double? latitude;
  final double? longitude;
  final double? distanceKm;

  const Project({
    required this.id,
    required this.title,
    this.description,
    this.category,
    this.budget,
    this.deadline,
    this.status,
    this.ownerName,
    this.ownerId,
    this.city,
    this.address,
    this.latitude,
    this.longitude,
    this.distanceKm,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: _toInt(json['id']) ?? 0,
      title: (json['title'] ?? '').toString(),
      description: json['description']?.toString(),
      category: json['category']?.toString(),
      budget: _toDouble(json['budget']),
      deadline: json['deadline']?.toString(),
      status: json['status']?.toString(),
      ownerName: json['ownerName']?.toString(),
      ownerId: _toInt(json['ownerId']),
      city: json['city']?.toString(),
      address: json['address']?.toString(),
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      distanceKm: _toDouble(json['distanceKm']),
    );
  }

  /// True when the project has usable coordinates to place a map marker.
  bool get hasValidLocation => latitude != null && longitude != null;

  Project withDistanceKm(double value) => Project(
        id: id,
        title: title,
        description: description,
        category: category,
        budget: budget,
        deadline: deadline,
        status: status,
        ownerName: ownerName,
        ownerId: ownerId,
        city: city,
        address: address,
        latitude: latitude,
        longitude: longitude,
        distanceKm: value,
      );

  /// Distance formatted for display, e.g. "1.24 km away".
  String get distanceLabel =>
      distanceKm == null ? '' : '${distanceKm!.toStringAsFixed(2)} km away';

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
