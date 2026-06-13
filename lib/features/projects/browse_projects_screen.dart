import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/qt_colors.dart';
import 'services/project_service.dart';

class BrowseProjectsScreen extends StatefulWidget {
  const BrowseProjectsScreen({super.key});
  @override
  State<BrowseProjectsScreen> createState() => _BrowseProjectsScreenState();
}

class _BrowseProjectsScreenState extends State<BrowseProjectsScreen> {
  final searchCtrl = TextEditingController();
  String selectedCategory = "All";
  final categories = ["All", "IT / Web", "Desain", "Marketing", "Video", "Writing"];
  bool _isLoading = true;
  List<Map<String, dynamic>> _projects = [];

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final list = await ProjectService().getAllProjects();
      if (mounted) setState(() { _projects = list; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _fmtBudget(dynamic a) {
    if (a == null) return "0";
    final v = double.tryParse(a.toString()) ?? 0;
    if (v >= 1000000) return "${(v / 1000000).toStringAsFixed(1)}M";
    if (v >= 1000) return "${(v / 1000).toStringAsFixed(0)}K";
    return v.toStringAsFixed(0);
  }

  String _fmtComplexity(dynamic c) {
    if (c == null) return "Beginner";
    final s = c.toString().toUpperCase();
    if (s.contains("BEGINNER")) return "Beginner";
    if (s.contains("INTERMEDIATE")) return "Intermediate";
    if (s.contains("EXPERT")) return "Expert";
    return c.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: QTColors.bgPrimary,
        body: Center(child: CircularProgressIndicator(color: QTColors.brandPrimary)),
      );
    }

    final filtered = _projects.where((p) {
      final matchSearch = (p["title"] ?? "").toString().toLowerCase().contains(searchCtrl.text.toLowerCase());
      final matchCat = selectedCategory == "All" || p["category"] == selectedCategory;
      return matchSearch && matchCat;
    }).toList();

    return Scaffold(
      backgroundColor: QTColors.bgPrimary,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadProjects,
          color: QTColors.brandPrimary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Browse Projects", style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text("Find projects that match your skills", style: GoogleFonts.plusJakartaSans(color: QTColors.textSecondary)),
              const SizedBox(height: 24),
              TextField(controller: searchCtrl, onChanged: (_) => setState(() {}),
                decoration: InputDecoration(hintText: "Search projects...", prefixIcon: const Icon(Icons.search, color: QTColors.textMuted),
                  filled: true, fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
              const SizedBox(height: 16),
              SizedBox(height: 42, child: ListView(scrollDirection: Axis.horizontal, children: categories.map((c) {
                final sel = selectedCategory == c;
                return Padding(padding: const EdgeInsets.only(right: 8), child: FilterChip(
                  label: Text(c), selected: sel, onSelected: (_) => setState(() => selectedCategory = c),
                  selectedColor: QTColors.brandPrimary, checkmarkColor: Colors.white, backgroundColor: Colors.white,
                  labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: sel ? Colors.white : QTColors.textSecondary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999), side: BorderSide(color: sel ? QTColors.brandPrimary : QTColors.slate200))));
              }).toList())),
              const SizedBox(height: 24),
              Text("${filtered.length} Results", style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: QTColors.textSecondary)),
              const SizedBox(height: 16),
              if (filtered.isEmpty)
                Center(child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Text("Tidak ada proyek ditemukan", style: GoogleFonts.plusJakartaSans(color: QTColors.textMuted, fontStyle: FontStyle.italic)),
                ))
              else
                ...filtered.map((p) => Padding(padding: const EdgeInsets.only(bottom: 16), child: _projectCard(p))),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _projectCard(Map<String, dynamic> p) {
    final complexity = _fmtComplexity(p["complexity"]);
    final ownerName = p["ownerName"] ?? p["owner"]?["nama"] ?? "Unknown";
    final ownerRating = p["owner"]?["averageRating"] ?? "0";
    final skills = p["requiredSkills"]?.toString().split(",").map((s) => s.trim()).where((s) => s.isNotEmpty).toList() ?? [];
    final hasApplied = p["hasApplied"] == true;

    return GestureDetector(
      onTap: () => _showDetail(p),
      child: Container(padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16)]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: QTColors.info.withOpacity(0.1), borderRadius: BorderRadius.circular(999)),
              child: Text(p["category"] ?? "", style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: QTColors.info))),
            const SizedBox(width: 8),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: QTColors.complexityColor(complexity).withOpacity(0.1), borderRadius: BorderRadius.circular(999)),
              child: Text(complexity, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: QTColors.complexityColor(complexity)))),
            const Spacer(),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: (hasApplied ? QTColors.warning : QTColors.accentBeginner).withOpacity(0.1), borderRadius: BorderRadius.circular(999)),
              child: Text(hasApplied ? "APPLIED" : "OPEN", style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: hasApplied ? QTColors.warning : QTColors.accentBeginner))),
          ]),
          const SizedBox(height: 14),
          Text(p["title"] ?? "", style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(p["description"] ?? "", style: GoogleFonts.plusJakartaSans(fontSize: 13, color: QTColors.textSecondary, height: 1.5), maxLines: 2, overflow: TextOverflow.ellipsis),
          if (skills.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(spacing: 6, runSpacing: 6, children: skills.map((s) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: QTColors.info.withOpacity(0.06), borderRadius: BorderRadius.circular(999)),
              child: Text(s, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: QTColors.info)))).toList()),
          ],
          const SizedBox(height: 16),
          Row(children: [
            _meta(Icons.payments_outlined, "Rp ${_fmtBudget(p["budget"])}", QTColors.accentBeginner),
            const SizedBox(width: 12),
            _meta(Icons.schedule, p["deadline"]?.toString().split("T")[0] ?? "N/A", QTColors.warning),
            const SizedBox(width: 12),
            _meta(Icons.people_outline, "${p["applicantCount"] ?? 0} applied", QTColors.info),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            CircleAvatar(radius: 14, backgroundColor: QTColors.brandPrimary,
              child: Text(ownerName.toString().isNotEmpty ? ownerName.toString()[0] : "?", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
            const SizedBox(width: 8),
            Text(ownerName.toString(), style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(width: 6),
            Icon(Icons.star, size: 14, color: Colors.amber),
            Text(" $ownerRating", style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: QTColors.textSecondary)),
          ]),
        ])),
    );
  }

  Widget _meta(IconData icon, String text, Color color) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: color), const SizedBox(width: 4),
      Flexible(child: Text(text, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: color), overflow: TextOverflow.ellipsis)),
    ]);
  }

  void _showDetail(Map<String, dynamic> p) {
    final complexity = _fmtComplexity(p["complexity"]);
    final ownerName = p["ownerName"] ?? p["owner"]?["nama"] ?? "Unknown";
    final ownerRating = p["owner"]?["averageRating"] ?? "0";
    final skills = p["requiredSkills"]?.toString().split(",").map((s) => s.trim()).where((s) => s.isNotEmpty).toList() ?? [];
    final hasApplied = p["hasApplied"] == true;

    showModalBottomSheet(context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85, minChildSize: 0.5, maxChildSize: 0.95, expand: false,
        builder: (_, sc) => Padding(padding: const EdgeInsets.all(24), child: ListView(controller: sc, children: [
          Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: QTColors.slate300, borderRadius: BorderRadius.circular(2)))),
          Text(p["title"] ?? "", style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _pill(p["category"] ?? "", QTColors.info),
            _pill(complexity, QTColors.complexityColor(complexity)),
            _pill(hasApplied ? "APPLIED" : "OPEN", hasApplied ? QTColors.warning : QTColors.accentBeginner),
          ]),
          const SizedBox(height: 20),
          Text(p["description"] ?? "", style: GoogleFonts.plusJakartaSans(fontSize: 15, color: QTColors.textSecondary, height: 1.7)),
          const SizedBox(height: 24),
          _infoRow(Icons.payments_outlined, "Budget", "Rp ${_fmtBudget(p["budget"])}", QTColors.accentBeginner),
          _infoRow(Icons.schedule, "Deadline", p["deadline"]?.toString().split("T")[0] ?? "N/A", QTColors.warning),
          _infoRow(Icons.timelapse, "Duration", p["estimatedDuration"] ?? "N/A", QTColors.info),
          _infoRow(Icons.people_outline, "Applicants", "${p["applicantCount"] ?? 0} people", QTColors.brandPrimary),
          const SizedBox(height: 20),
          if (skills.isNotEmpty) ...[
            Text("Required Skills", style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: skills.map((s) => Chip(label: Text(s))).toList()),
            const SizedBox(height: 24),
          ],
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: QTColors.bgTertiary, borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              CircleAvatar(backgroundColor: QTColors.brandPrimary, child: Text(ownerName.toString().isNotEmpty ? ownerName.toString()[0] : "?", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(ownerName.toString(), style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                Row(children: [const Icon(Icons.star, size: 14, color: Colors.amber), Text(" $ownerRating", style: GoogleFonts.plusJakartaSans(fontSize: 13, color: QTColors.textSecondary))]),
              ]),
            ])),
          const SizedBox(height: 28),
          if (hasApplied)
            Container(width: double.infinity, height: 54, alignment: Alignment.center,
              decoration: BoxDecoration(color: QTColors.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
              child: Text("Already Applied ✓", style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: QTColors.warning)))
          else
            SizedBox(width: double.infinity, height: 54, child: ElevatedButton(
              onPressed: () { Navigator.pop(ctx); _showApply(p); },
              child: Text("Apply Now", style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700)))),
        ]))),
    );
  }

  Widget _pill(String t, Color c) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(999)),
    child: Text(t, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: c)));

  Widget _infoRow(IconData icon, String label, String value, Color color) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [
      Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 18)),
      const SizedBox(width: 12),
      Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: QTColors.textSecondary)),
      const Spacer(),
      Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700)),
    ]));
  }

  void _showApply(Map<String, dynamic> p) {
    final proposalCtrl = TextEditingController();
    final bidCtrl = TextEditingController(text: "${p["budget"] ?? ""}");
    showDialog(context: context, builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(padding: const EdgeInsets.all(24), child: SingleChildScrollView(child: Column(
        mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text("Submit Application", style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w700))),
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
          ]),
          const SizedBox(height: 20),
          TextField(controller: proposalCtrl, maxLines: 6, decoration: const InputDecoration(hintText: "Your proposal - explain why you're the right fit...")),
          const SizedBox(height: 16),
          TextField(controller: bidCtrl, keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: "Bid Amount (Rp)", prefixIcon: Icon(Icons.payments_outlined, color: QTColors.textMuted))),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, height: 54, child: ElevatedButton(
            onPressed: () async {
              if (proposalCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Proposal tidak boleh kosong")));
                return;
              }
              final bid = double.tryParse(bidCtrl.text) ?? 0;
              if (bid <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bid amount harus lebih dari 0")));
                return;
              }
              final res = await ProjectService().applyProject(
                projectId: p['id'],
                proposal: proposalCtrl.text.trim(),
                bidAmount: bid,
              );
              if (res['success'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Application submitted!")));
                Navigator.pop(context);
                _loadProjects();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? "Gagal melamar")));
              }
            },
            child: Text("Submit Application", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)))),
        ])))));
  }
}
