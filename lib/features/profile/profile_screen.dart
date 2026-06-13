import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/qt_colors.dart';
import '../auth/services/auth_service.dart';
import '../auth/landing_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String role; // "TALENT" or "CLIENT"
  const ProfileScreen({super.key, required this.role});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final formKey = GlobalKey<FormState>();
  File? profileImage;
  bool showDeleteModal = false;
  bool showReportModal = false;
  String deletePhrase = "";
  final deleteCtrl = TextEditingController();
  String expectedPhrase = "DELETE-MY-ACCOUNT-7X9K";
  bool isLoading = true;
  bool isSaving = false;

  // Talent fields
  final nameCtrl = TextEditingController();
  final headlineCtrl = TextEditingController();
  final bioCtrl = TextEditingController();
  final uniCtrl = TextEditingController();
  final expCtrl = TextEditingController();
  final skillCtrl = TextEditingController();
  final locCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final portfolioCtrl = TextEditingController();
  final linkedinCtrl = TextEditingController();
  final githubCtrl = TextEditingController();
  String availability = "Full-time";

  // Client fields
  final bizNameCtrl = TextEditingController();
  final taglineCtrl = TextEditingController();
  final aboutCtrl = TextEditingController();
  final companyCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final websiteCtrl = TextEditingController();
  final igCtrl = TextEditingController();
  final ytCtrl = TextEditingController();
  final fbCtrl = TextEditingController();

  // Report fields
  String reportType = "BUG";
  final reportSubjectCtrl = TextEditingController();
  final reportDescCtrl = TextEditingController();

  bool get isTalent => widget.role == "TALENT";

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() async {
    setState(() => isLoading = true);
    
    // Fetch dynamic confirmation phrase in parallel
    AuthService().getDeleteConfirmation().then((phrase) {
      if (mounted) {
        setState(() {
          expectedPhrase = phrase;
        });
      }
    });

    final res = await AuthService().getProfile();
    if (res['success'] == true && res['data'] != null) {
      final data = res['data'];
      if (mounted) {
        setState(() {
          if (isTalent) {
            nameCtrl.text = data['nama'] ?? '';
            headlineCtrl.text = data['headline'] ?? '';
            bioCtrl.text = data['bio'] ?? '';
            uniCtrl.text = data['university'] ?? '';
            expCtrl.text = data['yearsExperience'] != null ? data['yearsExperience'].toString() : '';
            availability = data['availability'] ?? 'Full-time';
            
            final skills = data['skills'];
            if (skills is List) {
              skillCtrl.text = skills.join(', ');
            } else {
              skillCtrl.text = skills ?? '';
            }
            
            locCtrl.text = data['location'] ?? '';
            phoneCtrl.text = data['phone'] ?? '';
            portfolioCtrl.text = data['portfolioUrl'] ?? '';
            linkedinCtrl.text = data['linkedinUrl'] ?? '';
            githubCtrl.text = data['githubUrl'] ?? '';
          } else {
            bizNameCtrl.text = data['nama'] ?? '';
            taglineCtrl.text = data['headline'] ?? '';
            aboutCtrl.text = data['bio'] ?? '';
            companyCtrl.text = data['university'] ?? '';
            addressCtrl.text = data['address'] ?? '';
            phoneCtrl.text = data['phone'] ?? '';
            websiteCtrl.text = data['businessWebsite'] ?? '';
            igCtrl.text = data['instagramUrl'] ?? '';
            ytCtrl.text = data['youtubeUrl'] ?? '';
            fbCtrl.text = data['facebookUrl'] ?? '';
          }
          isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _saveProfile() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => isSaving = true);

    Map<String, dynamic> body = {};
    if (isTalent) {
      final expVal = int.tryParse(expCtrl.text.trim()) ?? 0;
      body = {
        'nama': nameCtrl.text.trim(),
        'headline': headlineCtrl.text.trim(),
        'bio': bioCtrl.text.trim(),
        'university': uniCtrl.text.trim(),
        'yearsExperience': expVal,
        'availability': availability,
        'skills': skillCtrl.text.trim(),
        'location': locCtrl.text.trim(),
        'phone': phoneCtrl.text.trim(),
        'portfolioUrl': portfolioCtrl.text.trim(),
        'linkedinUrl': linkedinCtrl.text.trim(),
        'githubUrl': githubCtrl.text.trim(),
      };
    } else {
      body = {
        'nama': bizNameCtrl.text.trim(),
        'headline': taglineCtrl.text.trim(),
        'bio': aboutCtrl.text.trim(),
        'university': companyCtrl.text.trim(),
        'address': addressCtrl.text.trim(),
        'phone': phoneCtrl.text.trim(),
        'businessWebsite': websiteCtrl.text.trim(),
        'instagramUrl': igCtrl.text.trim(),
        'youtubeUrl': ytCtrl.text.trim(),
        'facebookUrl': fbCtrl.text.trim(),
      };
    }

    final res = await AuthService().updateProfile(body);
    setState(() => isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res['message'] ?? 'Profil disimpan')),
    );
  }

  void _deleteAccount() async {
    setState(() => showDeleteModal = false);
    setState(() => isLoading = true);

    final res = await AuthService().deleteAccount();
    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res['message'] ?? 'Akun dihapus')),
    );

    if (res['success'] == true) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LandingScreen()),
        (route) => false,
      );
    }
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: "Crop Image",
          lockAspectRatio: true,
        )
      ],
    );
    if (cropped != null) setState(() => profileImage = File(cropped.path));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: QTColors.bgPrimary,
        body: Center(
          child: CircularProgressIndicator(color: QTColors.brandPrimary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: QTColors.bgPrimary,
      body: Stack(
        children: [
          // Glow
          Positioned(
            top: -180,
            left: -80,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: QTColors.brandPrimary.withOpacity(0.08),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Profile header
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: QTColors.bgTertiary,
                              ),
                              child: const Icon(Icons.arrow_back, size: 20),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: pickImage,
                          child: Stack(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(28),
                                  gradient: const LinearGradient(
                                    colors: [QTColors.brandPrimary, QTColors.brandDark],
                                  ),
                                ),
                                padding: const EdgeInsets.all(3),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(25),
                                  child: profileImage != null
                                      ? Image.file(profileImage!, fit: BoxFit.cover)
                                      : Container(
                                          color: Colors.white,
                                          child: const Icon(
                                            Icons.person,
                                            size: 50,
                                            color: QTColors.slate400,
                                          ),
                                        ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: QTColors.brandPrimary,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 3),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          isTalent ? nameCtrl.text : bizNameCtrl.text,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: QTColors.brandPrimary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            isTalent ? "TALENT" : "CLIENT",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: QTColors.brandPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(child: _miniStat("Projects", "12")),
                            const SizedBox(width: 10),
                            Expanded(child: _miniStat("Rating", "5.0")),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => setState(() => showReportModal = true),
                                icon: const Icon(Icons.flag, size: 18),
                                label: const Text("Report Problem"),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  await AuthService().logout();
                                  if (mounted) {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const LandingScreen(),
                                      ),
                                      (route) => false,
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: QTColors.error.withOpacity(0.1),
                                  foregroundColor: QTColors.error,
                                  elevation: 0,
                                ),
                                icon: const Icon(Icons.logout, size: 18),
                                label: const Text("Logout"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Form
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isTalent ? "Edit Talent Profile" : "Edit Business Profile",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (isTalent) ..._talentFields() else ..._clientFields(),
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: isSaving ? null : _saveProfile,
                                  icon: isSaving
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.save, size: 18),
                                  label: Text(
                                    isSaving ? "Saving..." : "Save Changes",
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton.icon(
                                onPressed: () => setState(() => showDeleteModal = true),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: QTColors.error,
                                  side: const BorderSide(color: QTColors.error),
                                ),
                                icon: const Icon(Icons.delete, size: 18),
                                label: const Text("Delete"),
                              ),
                            ],
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showDeleteModal) _deleteModal(),
          if (showReportModal) _reportModal(),
        ],
      ),
    );
  }

  List<Widget> _talentFields() => [
        _section(
          "Personal Info",
          Icons.person,
          [
            _field("Full Name", nameCtrl),
            _field("Headline", headlineCtrl),
            _field("Bio", bioCtrl, lines: 4),
          ],
        ),
        _section(
          "Education",
          Icons.school,
          [
            _field("University", uniCtrl),
            _field("Experience", expCtrl),
            DropdownButtonFormField<String>(
              value: availability.isEmpty ? "Full-time" : availability,
              items: ["Full-time", "Part-time", "Freelance"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => availability = v!),
              decoration: const InputDecoration(labelText: "Availability"),
            ),
          ],
        ),
        _section(
          "Skills",
          Icons.code,
          [_field("Skills (comma separated)", skillCtrl)],
        ),
        _section(
          "Contact",
          Icons.phone,
          [_field("Location", locCtrl), _field("Phone", phoneCtrl)],
        ),
        _section(
          "Links",
          Icons.language,
          [
            _field("Portfolio URL", portfolioCtrl),
            _field("LinkedIn", linkedinCtrl),
            _field("GitHub", githubCtrl),
          ],
        ),
      ];

  List<Widget> _clientFields() => [
        _section(
          "Business Info",
          Icons.store,
          [
            _field("Business Name", bizNameCtrl),
            _field("Tagline", taglineCtrl),
            _field("About", aboutCtrl, lines: 4),
          ],
        ),
        _section(
          "Details",
          Icons.info,
          [
            _field("Company", companyCtrl),
            _field("Address", addressCtrl),
            _field("Phone", phoneCtrl),
          ],
        ),
        _section(
          "Online Presence",
          Icons.language,
          [
            _field("Website", websiteCtrl),
            _field("Instagram", igCtrl),
            _field("YouTube", ytCtrl),
            _field("Facebook", fbCtrl),
          ],
        ),
      ];

  Widget _section(String title, IconData icon, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: QTColors.brandPrimary, size: 20),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children.expand((w) => [w, const SizedBox(height: 14)]),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {int lines = 1}) =>
      TextFormField(
        controller: ctrl,
        maxLines: lines,
        decoration: InputDecoration(labelText: label),
      );

  Widget _miniStat(String label, String value) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: QTColors.bgTertiary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: QTColors.brandPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: QTColors.textSecondary,
              ),
            ),
          ],
        ),
      );

  Widget _deleteModal() => Material(
        color: Colors.black54,
        child: Center(
          child: Container(
            width: 350,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 56,
                  color: QTColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  "Delete Account",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Type the phrase below to confirm:",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(color: QTColors.textSecondary),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: QTColors.error.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    expectedPhrase,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      color: QTColors.error,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: deleteCtrl,
                  onChanged: (v) => setState(() => deletePhrase = v),
                  decoration: const InputDecoration(
                    hintText: "Type confirmation phrase...",
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => showDeleteModal = false),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: deletePhrase == expectedPhrase ? _deleteAccount : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: QTColors.error,
                          disabledBackgroundColor: QTColors.error.withOpacity(0.3),
                        ),
                        child: const Text(
                          "Delete",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

  Widget _reportModal() => Material(
        color: Colors.black54,
        child: Center(
          child: Container(
            width: 380,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.flag, color: QTColors.info),
                      const SizedBox(width: 10),
                      Text(
                        "Report Problem",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => setState(() => showReportModal = false),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: reportType,
                    items: [
                      "BUG",
                      "CONTRACT_ISSUE",
                      "USER_COMPLAINT",
                      "PAYMENT_ISSUE",
                      "OTHER"
                    ]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => reportType = v!),
                    decoration: const InputDecoration(labelText: "Report Type"),
                  ),
                  const SizedBox(height: 14),
                  _field("Subject", reportSubjectCtrl),
                  const SizedBox(height: 14),
                  _field("Description", reportDescCtrl, lines: 4),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.image, size: 18),
                    label: const Text("Upload Screenshot"),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => showReportModal = false),
                          child: const Text("Cancel"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() => showReportModal = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Report submitted!")),
                            );
                          },
                          child: const Text("Submit"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
