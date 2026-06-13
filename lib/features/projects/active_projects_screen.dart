import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/qt_colors.dart';

class ActiveProjectsScreen extends StatefulWidget {
  const ActiveProjectsScreen({super.key});
  @override
  State<ActiveProjectsScreen> createState() => _ActiveProjectsScreenState();
}

class _ActiveProjectsScreenState extends State<ActiveProjectsScreen> {
  final ongoing = [
    {"title": "AI Dashboard Development", "budget": 3500000, "status": "ONGOING", "submissionRejected": true, "feedback": "Please improve mobile responsiveness."},
    {"title": "Company Landing Page", "budget": 2200000, "status": "ONGOING", "submissionRejected": false},
  ];
  final completed = [
    {"title": "E-Commerce UI Design", "completedDate": "May 18, 2026", "reviewed": true, "rating": 5},
    {"title": "Restaurant Branding", "completedDate": "May 12, 2026", "reviewed": false},
  ];
  final rejected = [{"title": "Crypto Mobile App", "budget": 4000000}];

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: QTColors.bgPrimary, body: SafeArea(
      child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Active Projects", style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text("Manage your ongoing work and submissions", style: GoogleFonts.plusJakartaSans(color: QTColors.textSecondary)),
        const SizedBox(height: 32),
        _section("🔵 Ongoing Projects", QTColors.info),
        const SizedBox(height: 16),
        if (ongoing.isEmpty) _empty("No ongoing projects."),
        ...ongoing.map((p) => _ongoingCard(p)),
        const SizedBox(height: 32),
        _section("✅ Completed Projects", QTColors.accentBeginner),
        const SizedBox(height: 16),
        if (completed.isEmpty) _empty("No completed projects."),
        ...completed.map((p) => _completedCard(p)),
        const SizedBox(height: 32),
        _section("❌ Rejected Applications", QTColors.error),
        const SizedBox(height: 16),
        if (rejected.isEmpty) _empty("No rejected applications."),
        ...rejected.map((p) => _rejectedCard(p)),
        const SizedBox(height: 40),
      ]))));
  }

  Widget _section(String title, Color color) => Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w700, color: color));

  Widget _empty(String t) => Container(width: double.infinity, padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
    child: Text(t, style: GoogleFonts.plusJakartaSans(color: QTColors.textMuted, fontStyle: FontStyle.italic)));

  Widget _ongoingCard(Map<String, dynamic> p) {
    return Container(margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: QTColors.info.withOpacity(0.1), borderRadius: BorderRadius.circular(999)),
            child: Text("ONGOING", style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: QTColors.info))),
          const Spacer(), const Icon(Icons.work, color: QTColors.info),
        ]),
        const SizedBox(height: 16),
        Text(p["title"] as String, style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text("Budget: Rp ${p["budget"]}", style: GoogleFonts.plusJakartaSans(color: QTColors.textSecondary)),
        if (p["submissionRejected"] == true) ...[
          const SizedBox(height: 16),
          Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: QTColors.error.withOpacity(0.06), borderRadius: BorderRadius.circular(14), border: Border.all(color: QTColors.error.withOpacity(0.3))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("⚠ Previous submission rejected", style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: QTColors.error)),
              const SizedBox(height: 6),
              Text(p["feedback"] as String, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: QTColors.textSecondary)),
            ])),
        ],
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.attach_file, size: 18), label: const Text("View Brief"))),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton(onPressed: () => _showSubmit(p),
            child: Text(p["submissionRejected"] == true ? "Resubmit Work" : "Submit Work"))),
        ]),
      ]));
  }

  Widget _completedCard(Map<String, dynamic> p) {
    return Container(margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: QTColors.accentBeginner.withOpacity(0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: QTColors.accentBeginner.withOpacity(0.1), borderRadius: BorderRadius.circular(999)),
            child: Text("COMPLETED", style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: QTColors.accentBeginner))),
          const Spacer(), const Icon(Icons.check_circle, color: QTColors.accentBeginner),
        ]),
        const SizedBox(height: 16),
        Text(p["title"] as String, style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text("Completed: ${p["completedDate"]}", style: GoogleFonts.plusJakartaSans(color: QTColors.textSecondary)),
        const SizedBox(height: 20),
        if (p["reviewed"] == true)
          Container(width: double.infinity, padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: QTColors.warning.withOpacity(0.08), borderRadius: BorderRadius.circular(14)),
            child: Column(children: [
              Text("✅ You rated this client", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text("★" * (p["rating"] as int), style: const TextStyle(color: Colors.amber, fontSize: 24)),
            ]))
        else
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => _showReview(p),
            style: ElevatedButton.styleFrom(backgroundColor: QTColors.warning, foregroundColor: Colors.black),
            child: const Text("Leave Review"))),
      ]));
  }

  Widget _rejectedCard(Map<String, dynamic> p) {
    return Container(margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: QTColors.error.withOpacity(0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: QTColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(999)),
            child: Text("REJECTED", style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: QTColors.error))),
          const Spacer(), Icon(Icons.cancel, color: QTColors.error),
        ]),
        const SizedBox(height: 16),
        Text(p["title"] as String, style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w700, color: QTColors.slate400)),
        const SizedBox(height: 8),
        Text("Budget: Rp ${p["budget"]}", style: GoogleFonts.plusJakartaSans(color: QTColors.textSecondary)),
        const SizedBox(height: 16),
        Container(width: double.infinity, padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: QTColors.error.withOpacity(0.06), borderRadius: BorderRadius.circular(12)),
          child: Text("Application not selected.", textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: QTColors.error))),
      ]));
  }

  void _showSubmit(Map<String, dynamic> p) {
    final linkCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    showDialog(context: context, builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(padding: const EdgeInsets.all(24), child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Expanded(child: Text("Submit Work", style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w700))), IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close))]),
        const SizedBox(height: 20),
        TextField(controller: linkCtrl, decoration: const InputDecoration(hintText: "Drive / GitHub / Figma link")),
        const SizedBox(height: 16),
        TextField(controller: noteCtrl, maxLines: 4, decoration: const InputDecoration(hintText: "Submission notes")),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Work submitted!"))); }, child: const Text("Submit Work"))),
      ])))));
  }

  void _showReview(Map<String, dynamic> p) {
    int rating = 5;
    final reviewCtrl = TextEditingController();
    showDialog(context: context, builder: (_) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text("Leave Review", style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        Text(p["title"] as String, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) => IconButton(onPressed: () => ss(() => rating = i + 1),
          icon: Icon(i < rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 36)))),
        const SizedBox(height: 16),
        TextField(controller: reviewCtrl, maxLines: 4, decoration: const InputDecoration(hintText: "Write your review...")),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Review submitted!"))); },
          style: ElevatedButton.styleFrom(backgroundColor: QTColors.warning, foregroundColor: Colors.black), child: const Text("Submit Review"))),
      ])))));
  }
}
