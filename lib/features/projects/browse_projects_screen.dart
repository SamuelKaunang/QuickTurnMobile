import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/qt_colors.dart';
import 'widgets/nearby_projects_view.dart';

/// Browse mode: the classic searchable list vs. the location-based nearby view.
enum BrowseMode { all, nearby }

class BrowseProjectsScreen extends StatefulWidget {
  /// When true the screen opens directly in [BrowseMode.nearby] — used by the
  /// dashboard "Nearby Projects" shortcut.
  final bool initialNearby;

  const BrowseProjectsScreen({super.key, this.initialNearby = false});
  @override
  State<BrowseProjectsScreen> createState() => _BrowseProjectsScreenState();
}

class _BrowseProjectsScreenState extends State<BrowseProjectsScreen> {
  final searchCtrl = TextEditingController();
  String selectedCategory = "All";
  final categories = ["All", "IT / Web", "Desain", "Marketing", "Video", "Writing"];

  late BrowseMode _mode = widget.initialNearby ? BrowseMode.nearby : BrowseMode.all;

  final projects = [
    {"title": "Build AI Dashboard UI", "category": "IT / Web", "description": "Need Flutter developer for AI dashboard system.", "budget": 3500000, "deadline": "5 Days", "duration": "2 Weeks", "complexity": "Intermediate", "skills": ["Flutter", "Firebase", "UI/UX"], "appliers": 24, "ownerRating": 4.8, "ownerName": "PT Digital Nusantara"},
    {"title": "Modern Brand Design", "category": "Desain", "description": "Need modern logo and branding system for startup.", "budget": 1500000, "deadline": "3 Days", "duration": "1 Week", "complexity": "Beginner", "skills": ["Figma", "Illustrator"], "appliers": 12, "ownerRating": 4.5, "ownerName": "Creative Studio"},
    {"title": "Social Media Campaign", "category": "Marketing", "description": "Create engaging social media content strategy.", "budget": 2000000, "deadline": "1 Week", "duration": "2 Weeks", "complexity": "Expert", "skills": ["Copywriting", "Analytics"], "appliers": 8, "ownerRating": 4.9, "ownerName": "Startup Hub"},
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = projects.where((p) {
      final matchSearch = p["title"].toString().toLowerCase().contains(searchCtrl.text.toLowerCase());
      final matchCat = selectedCategory == "All" || p["category"] == selectedCategory;
      return matchSearch && matchCat;
    }).toList();

    return Scaffold(
      backgroundColor: QTColors.bgPrimary,
      body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Browse Projects", style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(_mode == BrowseMode.all ? "Find projects that match your skills" : "Temukan proyek di sekitar lokasimu",
            style: GoogleFonts.plusJakartaSans(color: QTColors.textSecondary)),
          const SizedBox(height: 20),
          // Mode selector: All Projects | Nearby
          _modeSelector(),
          const SizedBox(height: 20),
          if (_mode == BrowseMode.all) ..._allProjectsContent(filtered)
          else const NearbyProjectsView(),
        ],
      ))),
    );
  }

  Widget _modeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: QTColors.slate100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        _modeTab("All Projects", Icons.grid_view_rounded, BrowseMode.all),
        _modeTab("Nearby", Icons.near_me_rounded, BrowseMode.nearby),
      ]),
    );
  }

  Widget _modeTab(String label, IconData icon, BrowseMode mode) {
    final sel = _mode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _mode = mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: sel ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: sel ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)] : null,
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 18, color: sel ? QTColors.brandPrimary : QTColors.textSecondary),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.plusJakartaSans(
              fontSize: 14, fontWeight: FontWeight.w700,
              color: sel ? QTColors.brandPrimary : QTColors.textSecondary)),
          ]),
        ),
      ),
    );
  }

  List<Widget> _allProjectsContent(List<Map<String, dynamic>> filtered) {
    return [
      // Search
      TextField(controller: searchCtrl, onChanged: (_) => setState(() {}),
        decoration: InputDecoration(hintText: "Search projects...", prefixIcon: const Icon(Icons.search, color: QTColors.textMuted),
          filled: true, fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
      const SizedBox(height: 16),
      // Category chips
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
      // Project list
      ...filtered.map((p) => Padding(padding: const EdgeInsets.only(bottom: 16), child: _projectCard(p))),
    ];
  }

  Widget _projectCard(Map<String, dynamic> p) {
    final complexity = p["complexity"] as String;
    return GestureDetector(
      onTap: () => _showDetail(p),
      child: Container(padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16)]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: QTColors.info.withOpacity(0.1), borderRadius: BorderRadius.circular(999)),
              child: Text(p["category"] as String, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: QTColors.info))),
            const SizedBox(width: 8),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: QTColors.complexityColor(complexity).withOpacity(0.1), borderRadius: BorderRadius.circular(999)),
              child: Text(complexity, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: QTColors.complexityColor(complexity)))),
            const Spacer(),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: QTColors.accentBeginner.withOpacity(0.1), borderRadius: BorderRadius.circular(999)),
              child: Text("OPEN", style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: QTColors.accentBeginner))),
          ]),
          const SizedBox(height: 14),
          Text(p["title"] as String, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(p["description"] as String, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: QTColors.textSecondary, height: 1.5), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 14),
          Wrap(spacing: 6, runSpacing: 6, children: (p["skills"] as List).map((s) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: QTColors.info.withOpacity(0.06), borderRadius: BorderRadius.circular(999)),
            child: Text(s, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: QTColors.info)))).toList()),
          const SizedBox(height: 16),
          Row(children: [
            _meta(Icons.payments_outlined, "Rp ${_fmt(p["budget"] as int)}", QTColors.accentBeginner),
            const SizedBox(width: 12),
            _meta(Icons.schedule, p["deadline"] as String, QTColors.warning),
            const SizedBox(width: 12),
            _meta(Icons.people_outline, "${p["appliers"]} applied", QTColors.info),
          ]),
          const SizedBox(height: 16),
          // Owner info
          Row(children: [
            CircleAvatar(radius: 14, backgroundColor: QTColors.brandPrimary,
              child: Text((p["ownerName"] as String)[0], style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
            const SizedBox(width: 8),
            Text(p["ownerName"] as String, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(width: 6),
            Icon(Icons.star, size: 14, color: Colors.amber),
            Text(" ${p["ownerRating"]}", style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: QTColors.textSecondary)),
          ]),
        ])),
    );
  }

  Widget _meta(IconData icon, String text, Color color) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: color), const SizedBox(width: 4),
      Text(text, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    ]);
  }

  String _fmt(int a) => a >= 1000000 ? "${(a / 1000000).toStringAsFixed(1)}M" : "$a";

  void _showDetail(Map<String, dynamic> p) {
    showModalBottomSheet(context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85, minChildSize: 0.5, maxChildSize: 0.95, expand: false,
        builder: (_, sc) => Padding(padding: const EdgeInsets.all(24), child: ListView(controller: sc, children: [
          Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: QTColors.slate300, borderRadius: BorderRadius.circular(2)))),
          Text(p["title"] as String, style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _pill(p["category"] as String, QTColors.info),
            _pill(p["complexity"] as String, QTColors.complexityColor(p["complexity"] as String)),
            _pill("OPEN", QTColors.accentBeginner),
          ]),
          const SizedBox(height: 20),
          Text(p["description"] as String, style: GoogleFonts.plusJakartaSans(fontSize: 15, color: QTColors.textSecondary, height: 1.7)),
          const SizedBox(height: 24),
          // Meta info cards
          _infoRow(Icons.payments_outlined, "Budget", "Rp ${p["budget"]}", QTColors.accentBeginner),
          _infoRow(Icons.schedule, "Deadline", p["deadline"] as String, QTColors.warning),
          _infoRow(Icons.timelapse, "Duration", p["duration"] as String, QTColors.info),
          _infoRow(Icons.people_outline, "Applicants", "${p["appliers"]} people", QTColors.brandPrimary),
          const SizedBox(height: 20),
          Text("Required Skills", style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: (p["skills"] as List).map((s) => Chip(label: Text(s))).toList()),
          const SizedBox(height: 24),
          // Owner
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: QTColors.bgTertiary, borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              CircleAvatar(backgroundColor: QTColors.brandPrimary, child: Text((p["ownerName"] as String)[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p["ownerName"] as String, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                Row(children: [const Icon(Icons.star, size: 14, color: Colors.amber), Text(" ${p["ownerRating"]}", style: GoogleFonts.plusJakartaSans(fontSize: 13, color: QTColors.textSecondary))]),
              ]),
            ])),
          const SizedBox(height: 28),
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
    final bidCtrl = TextEditingController(text: "${p["budget"]}");
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
            onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Application submitted!"))); },
            child: Text("Submit Application", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)))),
        ])))));
  }
}
