import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/qt_colors.dart';
import '../../core/widgets/qt_toast.dart';
import '../projects/services/project_service.dart';

class ActiveProjectsScreen extends StatefulWidget {
  const ActiveProjectsScreen({super.key});
  @override
  State<ActiveProjectsScreen> createState() => _ActiveProjectsScreenState();
}

class _ActiveProjectsScreenState extends State<ActiveProjectsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _ongoing = [];
  List<Map<String, dynamic>> _completed = [];
  List<Map<String, dynamic>> _rejected = [];
  final Map<int, Map<String, dynamic>?> _reviews = {};

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final list = await ProjectService().getParticipatingProjects();
      
      // Normalize status / application-status (uppercase + trim) so a casing
      // quirk from the backend can't drop a CLOSED project out of the
      // completed list and hide the "Leave Review" button.
      String st(Map<String, dynamic> p) => (p['status'] ?? '').toString().trim().toUpperCase();
      String appSt(Map<String, dynamic> p) => (p['myApplicationStatus'] ?? '').toString().trim().toUpperCase();

      final ongoingList = list.where((p) => appSt(p) == 'APPROVED' && (st(p) == 'ONGOING' || st(p) == 'DONE')).toList();
      final completedList = list.where((p) => appSt(p) == 'APPROVED' && st(p) == 'CLOSED').toList();
      final rejectedList = list.where((p) => appSt(p) == 'REJECTED').toList();

      // For each completed project, fetch my review
      for (final p in completedList) {
        final projectId = _asInt(p['id']);
        final res = await ProjectService().getMyReview(projectId);
        if (res['success'] == true && res['data'] != null) {
          _reviews[projectId] = res['data'];
        } else {
          _reviews[projectId] = null;
        }
      }

      if (mounted) {
        setState(() {
          _ongoing = ongoingList;
          _completed = completedList;
          _rejected = rejectedList;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Defensive int parsing: the backend may send `id` / `rating` as an int, a
  /// double, a numeric string, or omit it entirely (null). A raw `as int` cast
  /// crashes the whole screen with "type 'Null' is not a subtype of type 'int'".
  static int _asInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  String _formatBudgetDouble(dynamic amount) {
    if (amount == null) return "0";
    final numVal = double.tryParse(amount.toString()) ?? 0.0;
    if (numVal >= 1000000) {
      return "${(numVal / 1000000).toStringAsFixed(1)}M";
    } else if (numVal >= 1000) {
      return "${(numVal / 1000).toStringAsFixed(0)}K";
    }
    return numVal.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: QTColors.bgPrimary,
        body: Center(
          child: CircularProgressIndicator(color: QTColors.brandPrimary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: QTColors.bgPrimary,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadProjects,
          color: QTColors.brandPrimary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Active Projects", style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text("Manage your ongoing work and submissions", style: GoogleFonts.plusJakartaSans(color: QTColors.textSecondary)),
                const SizedBox(height: 32),
                _section("🔵 Ongoing Projects", QTColors.info),
                const SizedBox(height: 16),
                if (_ongoing.isEmpty) _empty("No ongoing projects."),
                ..._ongoing.map((p) => _ongoingCard(p)),
                const SizedBox(height: 32),
                _section("✅ Completed Projects", QTColors.accentBeginner),
                const SizedBox(height: 16),
                if (_completed.isEmpty) _empty("No completed projects."),
                ..._completed.map((p) => _completedCard(p)),
                const SizedBox(height: 32),
                _section("❌ Rejected Applications", QTColors.error),
                const SizedBox(height: 16),
                if (_rejected.isEmpty) _empty("No rejected applications."),
                ..._rejected.map((p) => _rejectedCard(p)),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _section(String title, Color color) => Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w700, color: color));

  Widget _empty(String t) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Text(t, style: GoogleFonts.plusJakartaSans(color: QTColors.textMuted, fontStyle: FontStyle.italic)),
      );

  Widget _ongoingCard(Map<String, dynamic> p) {
    final status = (p["status"] ?? "").toString().trim().toUpperCase();
    final isSubmitted = (status == "DONE");
    final submissionRejected = (p["latestSubmissionStatus"] ?? "").toString().trim().toUpperCase() == "REJECTED";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: QTColors.info.withOpacity(0.1), borderRadius: BorderRadius.circular(999)),
                child: Text(
                  isSubmitted ? "SUBMITTED" : "ONGOING",
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: QTColors.info),
                ),
              ),
              const Spacer(),
              const Icon(Icons.work, color: QTColors.info),
            ],
          ),
          const SizedBox(height: 16),
          Text(p["title"] ?? "", style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text("Budget: Rp ${_formatBudgetDouble(p["budget"])}", style: GoogleFonts.plusJakartaSans(color: QTColors.textSecondary)),
          if (submissionRejected) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: QTColors.error.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: QTColors.error.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("⚠ Previous submission rejected", style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: QTColors.error)),
                  const SizedBox(height: 6),
                  Text(p["latestSubmissionFeedback"] ?? "", style: GoogleFonts.plusJakartaSans(fontSize: 13, color: QTColors.textSecondary)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showBrief(p),
                  icon: const Icon(Icons.attach_file, size: 18),
                  label: const Text("View Brief"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: isSubmitted ? null : () => _showSubmit(p),
                  child: Text(
                    isSubmitted
                        ? "Awaiting Review"
                        : (submissionRejected ? "Resubmit Work" : "Submit Work"),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _completedCard(Map<String, dynamic> p) {
    final projectId = _asInt(p["id"]);
    final myReview = _reviews[projectId];
    final finishedDate = p["finishedAt"] != null ? p["finishedAt"].toString().split('T')[0] : 'N/A';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: QTColors.accentBeginner.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: QTColors.accentBeginner.withOpacity(0.1), borderRadius: BorderRadius.circular(999)),
                child: Text("COMPLETED", style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: QTColors.accentBeginner)),
              ),
              const Spacer(),
              const Icon(Icons.check_circle, color: QTColors.accentBeginner),
            ],
          ),
          const SizedBox(height: 16),
          Text(p["title"] ?? "", style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text("Completed: $finishedDate", style: GoogleFonts.plusJakartaSans(color: QTColors.textSecondary)),
          const SizedBox(height: 20),
          if (myReview != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: QTColors.warning.withOpacity(0.08), borderRadius: BorderRadius.circular(14)),
              child: Column(
                children: [
                  Text("✅ You rated this client", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text("★" * _asInt(myReview["rating"]), style: const TextStyle(color: Colors.amber, fontSize: 24)),
                  if (myReview["comment"] != null && myReview["comment"].toString().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      '"${myReview["comment"]}"',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, fontStyle: FontStyle.italic, color: QTColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showReview(p),
                style: ElevatedButton.styleFrom(backgroundColor: QTColors.warning, foregroundColor: Colors.black),
                child: const Text("Leave Review"),
              ),
            ),
        ],
      ),
    );
  }

  Widget _rejectedCard(Map<String, dynamic> p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: QTColors.error.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: QTColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(999)),
                child: Text("REJECTED", style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: QTColors.error)),
              ),
              const Spacer(),
              Icon(Icons.cancel, color: QTColors.error),
            ],
          ),
          const SizedBox(height: 16),
          Text(p["title"] ?? "", style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w700, color: QTColors.slate400)),
          const SizedBox(height: 8),
          Text("Budget: Rp ${_formatBudgetDouble(p["budget"])}", style: GoogleFonts.plusJakartaSans(color: QTColors.textSecondary)),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: QTColors.error.withOpacity(0.06), borderRadius: BorderRadius.circular(12)),
            child: Text(
              "Application not selected.",
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: QTColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showBrief(Map<String, dynamic> p) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Project Brief", style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              Text(p["title"] ?? "", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 8),
              Text("Kategori: ${p["category"] ?? 'N/A'}", style: GoogleFonts.plusJakartaSans(color: QTColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 4),
              Text("Deadline: ${p["deadline"] ?? 'N/A'}", style: GoogleFonts.plusJakartaSans(color: QTColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 12),
              Text("Deskripsi Proyek:", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 4),
              Text(p["description"] ?? "Tidak ada deskripsi.", style: GoogleFonts.plusJakartaSans(color: QTColors.textSecondary, fontSize: 13, height: 1.4)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSubmit(Map<String, dynamic> p) {
    final linkCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text("Submit Work", style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w700))),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(controller: linkCtrl, decoration: const InputDecoration(hintText: "Drive / GitHub / Figma link")),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (linkCtrl.text.trim().isEmpty) {
                        QTToast.show(context, title: "Validasi Gagal", message: "Link tidak boleh kosong.", type: QTToastType.warning);
                        return;
                      }
                      final res = await ProjectService().submitFinishing(
                        projectId: p['id'],
                        finishingLink: linkCtrl.text.trim(),
                      );
                      if (res['success'] == true) {
                        QTToast.show(context, title: "Sukses! 🎉", message: "Pekerjaan berhasil dikirimkan.", type: QTToastType.success);
                        Navigator.pop(context);
                        _loadProjects();
                      } else {
                        QTToast.show(context, title: "Gagal Kirim", message: res['message'] ?? "Terjadi kesalahan.", type: QTToastType.error);
                      }
                    },
                    child: const Text("Submit Work"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showReview(Map<String, dynamic> p) {
    int rating = 5;
    final reviewCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, ss) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Leave Review", style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                Text(p["title"] ?? "", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 16)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (i) => IconButton(
                      onPressed: () => ss(() => rating = i + 1),
                      icon: Icon(i < rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 36),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(controller: reviewCtrl, maxLines: 4, decoration: const InputDecoration(hintText: "Write your review...")),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final res = await ProjectService().submitReview(
                        projectId: p['id'],
                        rating: rating,
                        comment: reviewCtrl.text,
                      );
                      if (res['success'] == true) {
                        QTToast.show(context, title: "Ulasan Terkirim! ⭐", message: "Terima kasih atas penilaian Anda.", type: QTToastType.success);
                        Navigator.pop(ctx);
                        _loadProjects();
                      } else {
                        QTToast.show(context, title: "Gagal Mengulas", message: res['message'] ?? "Terjadi kesalahan.", type: QTToastType.error);
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: QTColors.warning, foregroundColor: Colors.black),
                    child: const Text("Submit Review"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
