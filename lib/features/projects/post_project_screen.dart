import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/qt_colors.dart';

class PostProjectScreen extends StatefulWidget {
  const PostProjectScreen({super.key});
  @override
  State<PostProjectScreen> createState() => _PostProjectScreenState();
}

class _PostProjectScreenState extends State<PostProjectScreen> {
  int currentStep = 0;
  final titleCtrl = TextEditingController();
  final budgetCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final briefCtrl = TextEditingController();
  final skillCtrl = TextEditingController();
  String category = "IT / Web";
  String duration = "1 Week";
  String complexity = "Beginner";
  DateTime? deadline;
  List<String> skills = [];

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
          child: Row(children: List.generate(3, (i) => Expanded(child: Row(children: [
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
            if (currentStep > 0) Expanded(child: OutlinedButton(onPressed: () => setState(() => currentStep--), child: const Text("Back"))),
            if (currentStep > 0) const SizedBox(width: 12),
            Expanded(child: ElevatedButton(
              onPressed: () {
                if (currentStep < 2) { setState(() => currentStep++); }
                else { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Project posted!"))); }
              },
              child: Text(currentStep == 2 ? "Post Project" : "Next"))),
          ])),
      ]),
    );
  }

  Widget _buildStep() {
    switch (currentStep) {
      case 0: return _step1();
      case 1: return _step2();
      case 2: return _step3();
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
      DropdownButtonFormField<String>(initialValue: category, items: ["IT / Web", "Desain", "Marketing", "Video", "Writing"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
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
      DropdownButtonFormField<String>(initialValue: duration, items: ["1-3 hari", "1 Week", "2 Weeks", "3-4 Weeks", "1-2 Months", "3+ Months"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
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

  Widget _label(String t) => Text(t, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: QTColors.textPrimary));
}
