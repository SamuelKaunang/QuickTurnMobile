import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/qt_colors.dart';
import '../models/project_model.dart';
import '../services/project_service.dart';

/// Possible states while resolving the user's location before any project
/// fetch can happen.
enum _LocationStatus {
  loadingLocation,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  locationError,
  ready,
}

/// "Nearby" mode of the Browse Projects screen: resolves the user's location
/// (or a Bandung test fallback), shows an OpenStreetMap map with markers, a
/// radius filter, and a list of nearby projects. Self-contained so the host
/// screen only has to drop it into its scroll view.
class NearbyProjectsView extends StatefulWidget {
  const NearbyProjectsView({super.key});

  @override
  State<NearbyProjectsView> createState() => _NearbyProjectsViewState();
}

class _NearbyProjectsViewState extends State<NearbyProjectsView> {
  static const LatLng _bandung = LatLng(-6.9, 107.6);
  static const List<int> _radiusOptions = [5, 10, 25];

  final ProjectService _service = ProjectService();
  final MapController _mapController = MapController();

  _LocationStatus _locationStatus = _LocationStatus.loadingLocation;
  LatLng? _center;
  bool _usingTestLocation = false;

  int _radiusKm = 10;

  bool _loadingProjects = false;
  String? _projectsError;
  bool _unauthenticated = false;
  List<Project> _projects = [];
  int? _selectedProjectId;

  @override
  void initState() {
    super.initState();
    _useDeviceLocation();
  }

  // ---------------------------------------------------------------------------
  // Location handling
  // ---------------------------------------------------------------------------

  Future<void> _useDeviceLocation() async {
    setState(() {
      _locationStatus = _LocationStatus.loadingLocation;
      _usingTestLocation = false;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _set(() => _locationStatus = _LocationStatus.serviceDisabled);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        _set(() => _locationStatus = _LocationStatus.permissionDeniedForever);
        return;
      }
      if (permission == LocationPermission.denied) {
        _set(() => _locationStatus = _LocationStatus.permissionDenied);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
      _onLocationResolved(
        LatLng(position.latitude, position.longitude),
        isTest: false,
      );
    } catch (_) {
      _set(() => _locationStatus = _LocationStatus.locationError);
    }
  }

  /// Bandung test fallback used for local backend testing (lat -6.9, lng 107.6).
  void _useBandungFallback() {
    _onLocationResolved(_bandung, isTest: true);
  }

  void _onLocationResolved(LatLng center, {required bool isTest}) {
    if (!mounted) return;
    setState(() {
      _center = center;
      _usingTestLocation = isTest;
      _locationStatus = _LocationStatus.ready;
    });
    _moveMap();
    _fetchProjects();
  }

  // ---------------------------------------------------------------------------
  // Projects fetching
  // ---------------------------------------------------------------------------

  Future<void> _fetchProjects() async {
    final center = _center;
    if (center == null) return;

    setState(() {
      _loadingProjects = true;
      _projectsError = null;
      _unauthenticated = false;
      _selectedProjectId = null;
    });

    final result = await _service.getNearbyProjects(
      center.latitude,
      center.longitude,
      _radiusKm,
    );

    if (!mounted) return;
    setState(() {
      _loadingProjects = false;
      if (result.success) {
        _projects = result.projects;
      } else {
        _projects = [];
        _projectsError = result.message ?? 'Gagal memuat proyek terdekat';
        _unauthenticated = result.unauthenticated;
      }
    });
  }

  void _changeRadius(int radius) {
    if (radius == _radiusKm) return;
    setState(() => _radiusKm = radius);
    _moveMap();
    _fetchProjects();
  }

  // ---------------------------------------------------------------------------
  // Map helpers
  // ---------------------------------------------------------------------------

  double get _zoomForRadius {
    switch (_radiusKm) {
      case 5:
        return 13.0;
      case 25:
        return 10.5;
      case 10:
      default:
        return 12.0;
    }
  }

  void _moveMap() {
    final center = _center;
    if (center == null) return;
    // Defer until after the current frame so the map is laid out.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        _mapController.move(center, _zoomForRadius);
      } catch (_) {
        // Controller not attached yet; the FlutterMap initialCenter covers it.
      }
    });
  }

  void _set(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  Project? _selectedProject() {
    if (_selectedProjectId == null) return null;
    for (final p in _projects) {
      if (p.id == _selectedProjectId) return p;
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (_locationStatus != _LocationStatus.ready || _center == null) {
      return _locationStateView();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_usingTestLocation) _testLocationBanner(),
        _radiusFilter(),
        const SizedBox(height: 16),
        _mapSection(),
        const SizedBox(height: 20),
        _resultsHeader(),
        const SizedBox(height: 16),
        _projectsSection(),
      ],
    );
  }

  // ----- Location states -----------------------------------------------------

  Widget _locationStateView() {
    switch (_locationStatus) {
      case _LocationStatus.loadingLocation:
        return _statusCard(
          icon: Icons.my_location,
          color: QTColors.info,
          title: 'Mendapatkan lokasimu...',
          message: 'Sebentar ya, kami sedang mencari posisimu.',
          showSpinner: true,
        );
      case _LocationStatus.serviceDisabled:
        return _statusCard(
          icon: Icons.location_disabled,
          color: QTColors.warning,
          title: 'Layanan lokasi nonaktif',
          message:
              'Aktifkan GPS / layanan lokasi perangkat, lalu coba lagi. Atau gunakan lokasi tes Bandung.',
          primaryLabel: 'Coba Lagi',
          onPrimary: _useDeviceLocation,
          showFallback: true,
        );
      case _LocationStatus.permissionDenied:
        return _statusCard(
          icon: Icons.location_off,
          color: QTColors.warning,
          title: 'Izin lokasi ditolak',
          message:
              'Kami butuh izin lokasi untuk menemukan proyek di sekitarmu. Beri izin lalu coba lagi.',
          primaryLabel: 'Minta Izin Lagi',
          onPrimary: _useDeviceLocation,
          showFallback: true,
        );
      case _LocationStatus.permissionDeniedForever:
        return _statusCard(
          icon: Icons.location_off,
          color: QTColors.error,
          title: 'Izin lokasi diblokir',
          message:
              'Izin lokasi diblokir permanen. Buka pengaturan aplikasi untuk mengaktifkannya, atau gunakan lokasi tes Bandung.',
          primaryLabel: 'Buka Pengaturan',
          onPrimary: () => Geolocator.openAppSettings(),
          showFallback: true,
        );
      case _LocationStatus.locationError:
        return _statusCard(
          icon: Icons.error_outline,
          color: QTColors.error,
          title: 'Gagal mendapatkan lokasi',
          message: 'Terjadi kesalahan saat mengambil lokasimu. Coba lagi.',
          primaryLabel: 'Coba Lagi',
          onPrimary: _useDeviceLocation,
          showFallback: true,
        );
      case _LocationStatus.ready:
        return const SizedBox.shrink();
    }
  }

  Widget _statusCard({
    required IconData icon,
    required Color color,
    required String title,
    required String message,
    bool showSpinner = false,
    String? primaryLabel,
    VoidCallback? onPrimary,
    bool showFallback = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16)],
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: showSpinner
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: color),
                  )
                : Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: QTColors.textSecondary,
              height: 1.5,
            ),
          ),
          if (primaryLabel != null) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: onPrimary,
                child: Text(
                  primaryLabel,
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
          if (showFallback) ...[
            const SizedBox(height: 12),
            _bandungFallbackButton(),
          ],
        ],
      ),
    );
  }

  Widget _bandungFallbackButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: _useBandungFallback,
        icon: const Icon(Icons.science_outlined, size: 18),
        label: Text(
          'Use Bandung Test Location',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: QTColors.textSecondary,
          side: const BorderSide(color: QTColors.slate300),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _testLocationBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: QTColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: QTColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.science_outlined, size: 18, color: QTColors.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Test mode: using Bandung location (-6.9, 107.6)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: QTColors.warning,
              ),
            ),
          ),
          GestureDetector(
            onTap: _useDeviceLocation,
            child: Text(
              'Use my location',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: QTColors.brandPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----- Radius filter --------------------------------------------------------

  Widget _radiusFilter() {
    return Row(
      children: [
        Icon(Icons.adjust, size: 18, color: QTColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          'Radius',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: QTColors.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        ..._radiusOptions.map((r) {
          final sel = _radiusKm == r;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text('$r km'),
              selected: sel,
              onSelected: (_) => _changeRadius(r),
              selectedColor: QTColors.brandPrimary,
              backgroundColor: Colors.white,
              showCheckmark: false,
              labelStyle: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: sel ? Colors.white : QTColors.textSecondary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
                side: BorderSide(color: sel ? QTColors.brandPrimary : QTColors.slate200),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ----- Map ------------------------------------------------------------------

  Widget _mapSection() {
    final center = _center!;
    final markers = <Marker>[
      // User / selected location marker
      Marker(
        point: center,
        width: 44,
        height: 44,
        child: _userMarker(),
      ),
      // Project markers
      ..._projects.where((p) => p.hasValidLocation).map((p) {
        final selected = p.id == _selectedProjectId;
        return Marker(
          point: LatLng(p.latitude!, p.longitude!),
          width: 44,
          height: 44,
          child: GestureDetector(
            onTap: () => setState(() => _selectedProjectId = p.id),
            child: _projectMarker(selected),
          ),
        );
      }),
    ];

    final selectedProject = _selectedProject();

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 300,
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: _zoomForRadius,
                minZoom: 3,
                maxZoom: 18,
                onTap: (_, __) => setState(() => _selectedProjectId = null),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.quickturn.quick_turn_mobile',
                  maxZoom: 19,
                ),
                MarkerLayer(markers: markers),
                const RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution('© OpenStreetMap contributors'),
                  ],
                ),
              ],
            ),
            if (selectedProject != null)
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: _markerPopupCard(selectedProject),
              ),
          ],
        ),
      ),
    );
  }

  Widget _userMarker() {
    return Container(
      decoration: BoxDecoration(
        color: QTColors.info.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: QTColors.info,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4)],
          ),
        ),
      ),
    );
  }

  Widget _projectMarker(bool selected) {
    final color = selected ? QTColors.brandDark : QTColors.brandPrimary;
    return Icon(
      Icons.location_on,
      color: color,
      size: selected ? 44 : 36,
      shadows: const [Shadow(color: Colors.black26, blurRadius: 4)],
    );
  }

  Widget _markerPopupCard(Project p) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 16)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  [if (p.category != null) p.category!, if (p.distanceKm != null) p.distanceLabel]
                      .join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: QTColors.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _selectedProjectId = null),
            icon: const Icon(Icons.close, size: 18, color: QTColors.textMuted),
          ),
        ],
      ),
    );
  }

  // ----- Results --------------------------------------------------------------

  Widget _resultsHeader() {
    final label = _loadingProjects
        ? 'Mencari proyek terdekat...'
        : '${_projects.length} proyek dalam $_radiusKm km';
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: QTColors.textSecondary,
      ),
    );
  }

  Widget _projectsSection() {
    if (_loadingProjects) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator(color: QTColors.brandPrimary)),
      );
    }

    if (_projectsError != null) {
      return _statusCard(
        icon: _unauthenticated ? Icons.lock_outline : Icons.cloud_off,
        color: QTColors.error,
        title: _unauthenticated ? 'Sesi berakhir' : 'Gagal memuat proyek',
        message: _projectsError!,
        primaryLabel: 'Coba Lagi',
        onPrimary: _fetchProjects,
      );
    }

    if (_projects.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16)],
        ),
        child: Column(
          children: [
            Icon(Icons.travel_explore, size: 40, color: QTColors.slate300),
            const SizedBox(height: 12),
            Text(
              'Belum ada proyek di sekitarmu',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Coba perbesar radius pencarian.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: QTColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _projects
          .map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _nearbyCard(p),
              ))
          .toList(),
    );
  }

  Widget _nearbyCard(Project p) {
    final selected = p.id == _selectedProjectId;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedProjectId = p.id);
        if (p.hasValidLocation) {
          _mapController.move(LatLng(p.latitude!, p.longitude!), _zoomForRadius + 1);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: selected
              ? Border.all(color: QTColors.brandPrimary, width: 1.5)
              : null,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (p.category != null)
                  _pill(p.category!, QTColors.info),
                const Spacer(),
                if (p.status != null)
                  _pill(p.status!, QTColors.statusColor(p.status!)),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              p.title,
              style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            if (p.description != null) ...[
              const SizedBox(height: 8),
              Text(
                p.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: QTColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
            const SizedBox(height: 14),
            // Distance — highlighted
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: QTColors.brandPrimary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.near_me, size: 16, color: QTColors.brandPrimary),
                  const SizedBox(width: 6),
                  Text(
                    p.distanceKm != null ? p.distanceLabel : 'Jarak tidak tersedia',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: QTColors.brandPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                if (p.budget != null)
                  _meta(Icons.payments_outlined, 'Rp ${_formatBudget(p.budget!)}', QTColors.accentBeginner),
                if (p.deadline != null)
                  _meta(Icons.schedule, p.deadline!, QTColors.warning),
                if (p.city != null)
                  _meta(Icons.location_city, p.city!, QTColors.info),
              ],
            ),
            if (p.address != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.place_outlined, size: 14, color: QTColors.textMuted),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      p.address!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: QTColors.textMuted),
                    ),
                  ),
                ],
              ),
            ],
            if (p.ownerName != null) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: QTColors.brandPrimary,
                    child: Text(
                      p.ownerName!.isNotEmpty ? p.ownerName![0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    p.ownerName!,
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _pill(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          text,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      );

  Widget _meta(IconData icon, String text, Color color) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      );

  String _formatBudget(double amount) {
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(0)}K';
    return amount.toStringAsFixed(0);
  }
}
