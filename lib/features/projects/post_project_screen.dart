import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import '../../core/theme/qt_colors.dart';
import '../../core/widgets/qt_toast.dart';
import 'services/project_service.dart';

class PostProjectScreen extends StatefulWidget {
  const PostProjectScreen({super.key});
  @override
  State<PostProjectScreen> createState() => _PostProjectScreenState();
}

class _PostProjectScreenState extends State<PostProjectScreen> {
  static const int _stepCount = 4;
  static const LatLng _bandung = LatLng(-6.9, 107.6);

  final ProjectService _service = ProjectService();
  final MapController _mapController = MapController();

  int currentStep = 0;
  final titleCtrl = TextEditingController();
  final budgetCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final briefCtrl = TextEditingController();
  final skillCtrl = TextEditingController();
  // Location inputs (optional — match the backend's optional location fields).
  final cityCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  String category = "IT / Web";
  String duration = "1 Week";
  String complexity = "Beginner";
  DateTime? deadline;
  List<String> skills = [];

  // Selected project location for the map marker. Null until the user picks a
  // point (tap / current location / Bandung test).
  LatLng? selectedLocation;
  bool _locating = false;
  bool _submitting = false;

  @override
  void dispose() {
    titleCtrl.dispose();
    budgetCtrl.dispose();
    descCtrl.dispose();
    briefCtrl.dispose();
    skillCtrl.dispose();
    cityCtrl.dispose();
    addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QTColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
        title: Text("Post Project", style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w700, color: QTColors.textPrimary)),
      ),
      body: Column(children: [
        // Step indicator
        Container(color: Colors.white, padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: Row(children: List.generate(_stepCount, (i) => Expanded(child: Row(children: [
            if (i > 0) Expanded(child: Container(height: 2, color: i <= currentStep ? QTColors.brandPrimary : QTColors.slate200)),
            Container(width: 32, height: 32,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: i <= currentStep ? QTColors.brandPrimary : QTColors.slate200),
              child: Center(child: Text("${i + 1}", style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700,
                color: i <= currentStep ? Colors.white : QTColors.textMuted)))),
          ])))),
        ),
        // Form
        Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: _buildStep())),
        // Nav buttons
        Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))]),
          child: Row(children: [
            if (currentStep > 0) Expanded(child: OutlinedButton(onPressed: _submitting ? null : () => setState(() => currentStep--), child: const Text("Back"))),
            if (currentStep > 0) const SizedBox(width: 12),
            Expanded(child: ElevatedButton(
              onPressed: _submitting ? null : _handleNext,
              child: _submitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : Text(currentStep == _stepCount - 1 ? "Post Project" : "Next"))),
          ])),
      ]),
    );
  }

  Future<void> _handleNext() async {
    if (currentStep < _stepCount - 1) {
      // Per-step validation before advancing (from main).
      if (currentStep == 0 && titleCtrl.text.trim().isEmpty) {
        _showSnack("Judul proyek tidak boleh kosong");
        return;
      }
      if (currentStep == 1) {
        if (budgetCtrl.text.trim().isEmpty) {
          _showSnack("Budget tidak boleh kosong");
          return;
        }
        if (deadline == null) {
          _showSnack("Pilih deadline terlebih dahulu");
          return;
        }
      }
      if (currentStep == 2 && descCtrl.text.trim().isEmpty) {
        _showSnack("Deskripsi proyek tidak boleh kosong");
        return;
      }
      setState(() => currentStep++);
    } else {
      // Final step (location) — create the project with its optional location.
      await _submitProject();
    }
  }

  Widget _buildStep() {
    switch (currentStep) {
      case 0: return _step1();
      case 1: return _step2();
      case 2: return _step3();
      case 3: return _step4();
      default: return _step1();
    }
  }

  Widget _step1() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("Informasi Dasar", style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      Text("Berikan informasi dasar tentang proyek.", style: GoogleFonts.plusJakartaSans(color: QTColors.textSecondary)),
      const SizedBox(height: 28),
      _label("Judul Proyek"),
      const SizedBox(height: 8),
      TextField(controller: titleCtrl, decoration: const InputDecoration(hintText: "e.g. Build AI Dashboard")),
      const SizedBox(height: 22),
      _label("Kategori"),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(value: category, items: ["IT / Web", "Desain", "Marketing", "Video", "Writing"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (v) => setState(() => category = v!)),
    ]);
  }

  Widget _step2() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("Budget & Waktu", style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w700)),
      const SizedBox(height: 28),
      _label("Budget (Rp)"),
      const SizedBox(height: 8),
      TextField(controller: budgetCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: "e.g. 3500000", prefixIcon: Icon(Icons.payments_outlined, color: QTColors.textMuted))),
      const SizedBox(height: 22),
      _label("Deadline"),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: () async {
          final d = await showDatePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
          if (d != null) setState(() => deadline = d);
        },
        child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: QTColors.bgTertiary, borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            const Icon(Icons.calendar_today, color: QTColors.textMuted, size: 20),
            const SizedBox(width: 12),
            Text(deadline != null ? "${deadline!.day}/${deadline!.month}/${deadline!.year}" : "Select date", style: GoogleFonts.plusJakartaSans(color: deadline != null ? QTColors.textPrimary : QTColors.textMuted)),
          ])),
      ),
      const SizedBox(height: 22),
      _label("Estimasi Durasi"),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(value: duration, items: ["1-3 hari", "1 Week", "2 Weeks", "3-4 Weeks", "1-2 Months", "3+ Months"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (v) => setState(() => duration = v!)),
      const SizedBox(height: 22),
      _label("Complexity"),
      const SizedBox(height: 8),
      Row(children: ["Beginner", "Intermediate", "Expert"].map((c) {
        final sel = complexity == c;
        return Expanded(child: GestureDetector(onTap: () => setState(() => complexity = c),
          child: Container(margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14),
              color: sel ? QTColors.complexityColor(c).withOpacity(0.12) : QTColors.bgTertiary,
              border: Border.all(color: sel ? QTColors.complexityColor(c) : Colors.transparent, width: 2)),
            child: Center(child: Text(c, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600,
              color: sel ? QTColors.complexityColor(c) : QTColors.textSecondary))))));
      }).toList()),
    ]);
  }

  Widget _step3() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("Detail Proyek", style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w700)),
      const SizedBox(height: 28),
      _label("Required Skills"),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: TextField(controller: skillCtrl, decoration: const InputDecoration(hintText: "e.g. Flutter"))),
        const SizedBox(width: 8),
        ElevatedButton(onPressed: () {
          if (skillCtrl.text.trim().isNotEmpty) { setState(() { skills.add(skillCtrl.text.trim()); skillCtrl.clear(); }); }
        }, style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)), child: const Icon(Icons.add)),
      ]),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, children: skills.map((s) => Chip(label: Text(s),
        deleteIcon: const Icon(Icons.close, size: 16), onDeleted: () => setState(() => skills.remove(s)))).toList()),
      const SizedBox(height: 22),
      _label("Deskripsi Proyek"),
      const SizedBox(height: 8),
      TextField(controller: descCtrl, maxLines: 5, decoration: const InputDecoration(hintText: "Jelaskan proyek secara detail...")),
      const SizedBox(height: 22),
      _label("Instruksi Kerja"),
      const SizedBox(height: 8),
      TextField(controller: briefCtrl, maxLines: 4, decoration: const InputDecoration(hintText: "Petunjuk detail untuk talent...")),
      const SizedBox(height: 22),
      OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.attach_file), label: const Text("Upload Attachment")),
    ]);
  }

  // ---------------------------------------------------------------------------
  // Step 4 — Project Location
  // ---------------------------------------------------------------------------

  Widget _step4() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("Lokasi Proyek", style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      Text("Atur lokasi proyek agar talent di sekitar dapat menemukannya. Opsional.",
        style: GoogleFonts.plusJakartaSans(color: QTColors.textSecondary, height: 1.5)),
      const SizedBox(height: 28),

      _label("Kota"),
      const SizedBox(height: 8),
      TextField(controller: cityCtrl, decoration: const InputDecoration(hintText: "e.g. Bandung", prefixIcon: Icon(Icons.location_city, color: QTColors.textMuted))),
      const SizedBox(height: 18),

      _label("Alamat"),
      const SizedBox(height: 8),
      TextField(controller: addressCtrl, decoration: const InputDecoration(hintText: "e.g. Dago, Bandung", prefixIcon: Icon(Icons.place_outlined, color: QTColors.textMuted))),
      const SizedBox(height: 22),

      _label("Pilih Titik di Peta"),
      const SizedBox(height: 6),
      Text("Ketuk peta untuk menempatkan penanda lokasi.",
        style: GoogleFonts.plusJakartaSans(fontSize: 12, color: QTColors.textMuted)),
      const SizedBox(height: 10),
      _mapPicker(),
      const SizedBox(height: 12),
      _locationButtons(),
      const SizedBox(height: 14),
      _coordReadout(),
    ]);
  }

  Widget _mapPicker() {
    final initial = selectedLocation ?? _bandung;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 260,
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: initial,
            initialZoom: 12,
            minZoom: 3,
            maxZoom: 18,
            onTap: (_, point) => _setLocation(point, moveMap: false),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.quickturn.quick_turn_mobile',
              maxZoom: 19,
            ),
            if (selectedLocation != null)
              MarkerLayer(markers: [
                Marker(
                  point: selectedLocation!,
                  width: 44,
                  height: 44,
                  child: const Icon(Icons.location_on, color: QTColors.brandPrimary, size: 40,
                    shadows: [Shadow(color: Colors.black26, blurRadius: 4)]),
                ),
              ]),
            const RichAttributionWidget(attributions: [
              TextSourceAttribution('© OpenStreetMap contributors'),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _locationButtons() {
    return Column(children: [
      SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton.icon(
          onPressed: _locating ? null : _useCurrentLocation,
          icon: _locating
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: QTColors.brandPrimary))
              : const Icon(Icons.my_location, size: 18),
          label: Text(_locating ? "Mendapatkan lokasi..." : "Use my current location",
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
          style: OutlinedButton.styleFrom(
            foregroundColor: QTColors.brandPrimary,
            side: const BorderSide(color: QTColors.brandPrimary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
      const SizedBox(height: 10),
      SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton.icon(
          onPressed: _useBandungTestLocation,
          icon: const Icon(Icons.science_outlined, size: 18),
          label: Text("Use Bandung Test Location",
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
          style: OutlinedButton.styleFrom(
            foregroundColor: QTColors.textSecondary,
            side: const BorderSide(color: QTColors.slate300),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
    ]);
  }

  Widget _coordReadout() {
    if (selectedLocation == null) {
      return Row(children: [
        const Icon(Icons.location_searching, size: 16, color: QTColors.textMuted),
        const SizedBox(width: 8),
        Text("Belum ada lokasi dipilih", style: GoogleFonts.plusJakartaSans(fontSize: 13, color: QTColors.textMuted)),
      ]);
    }
    final loc = selectedLocation!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: QTColors.brandPrimary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        const Icon(Icons.location_on, size: 18, color: QTColors.brandPrimary),
        const SizedBox(width: 10),
        Expanded(child: Text(
          "Lat ${loc.latitude.toStringAsFixed(5)}, Lng ${loc.longitude.toStringAsFixed(5)}",
          style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: QTColors.brandPrimary),
        )),
        GestureDetector(
          onTap: () => setState(() => selectedLocation = null),
          child: const Icon(Icons.close, size: 18, color: QTColors.textMuted),
        ),
      ]),
    );
  }

  // ---------------------------------------------------------------------------
  // Location handling
  // ---------------------------------------------------------------------------

  void _setLocation(LatLng point, {required bool moveMap}) {
    setState(() => selectedLocation = point);
    if (moveMap) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        try {
          _mapController.move(point, 13);
        } catch (_) {
          // Controller not attached yet; initialCenter covers it.
        }
      });
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _locating = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnack("Layanan lokasi nonaktif. Aktifkan GPS lalu coba lagi.");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showSnack("Izin lokasi ditolak. Gunakan peta atau lokasi tes Bandung.");
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      _setLocation(LatLng(position.latitude, position.longitude), moveMap: true);
    } catch (_) {
      _showSnack("Gagal mendapatkan lokasi. Coba lagi.");
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  /// Bandung test fallback for local fullstack testing (lat -6.9, lng 107.6).
  void _useBandungTestLocation() {
    if (cityCtrl.text.trim().isEmpty) cityCtrl.text = "Bandung";
    if (addressCtrl.text.trim().isEmpty) addressCtrl.text = "Bandung Test Location";
    _setLocation(_bandung, moveMap: true);
  }

  // ---------------------------------------------------------------------------
  // Submit
  // ---------------------------------------------------------------------------

  String? _validateLocation() {
    final loc = selectedLocation;
    // Guard against a half-filled coordinate pair. selectedLocation is always
    // set as a pair, but this keeps the contract explicit and future-proof.
    if (loc != null) {
      final lat = loc.latitude;
      final lng = loc.longitude;
      if (lat.isNaN || lng.isNaN) {
        return "Koordinat lokasi tidak valid.";
      }
      if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
        return "Koordinat lokasi di luar rentang yang valid.";
      }
    }
    return null;
  }

  String _formatDeadline(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return "${d.year}-$m-$day";
  }

  Future<void> _submitProject() async {
    if (titleCtrl.text.trim().isEmpty) {
      setState(() => currentStep = 0);
      _showSnack("Judul proyek wajib diisi.");
      return;
    }

    final locError = _validateLocation();
    if (locError != null) {
      _showSnack(locError);
      return;
    }

    setState(() => _submitting = true);

    final loc = selectedLocation;
    final budget = num.tryParse(budgetCtrl.text.trim());

    final result = await _service.createProject(
      title: titleCtrl.text.trim(),
      category: category,
      description: descCtrl.text.trim(),
      brief: briefCtrl.text.trim(),
      budget: budget,
      deadline: deadline != null ? _formatDeadline(deadline!) : null,
      duration: duration,
      complexity: complexity.toUpperCase(),
      skills: skills,
      city: cityCtrl.text.trim().isEmpty ? null : cityCtrl.text.trim(),
      address: addressCtrl.text.trim().isEmpty ? null : addressCtrl.text.trim(),
      latitude: loc?.latitude,
      longitude: loc?.longitude,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (result.success) {
      Navigator.pop(context, true);
      _showSnack(result.message ?? "Proyek berhasil dibuat!");
    } else {
      _showSnack(result.message ?? "Gagal membuat proyek.");
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    final isSuccess = message.toLowerCase().contains("berhasil") || message.toLowerCase().contains("success");
    final isWarning = message.toLowerCase().contains("kosong") || message.toLowerCase().contains("pilih") || message.toLowerCase().contains("wajib") || message.toLowerCase().contains("tidak valid");
    
    QTToast.show(
      context,
      title: isSuccess ? "Berhasil! 🎉" : (isWarning ? "Validasi" : "Info"),
      message: message,
      type: isSuccess ? QTToastType.success : (isWarning ? QTToastType.warning : QTToastType.error),
    );
  }

  Widget _label(String t) => Text(t, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: QTColors.textPrimary));
}
