import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/qt_colors.dart';
import '../../core/widgets/qt_toast.dart';
import '../../core/widgets/qt_avatar.dart';
import '../../core/network/dio_client.dart';
import '../../widgets/glass_card.dart';
import '../auth/services/auth_service.dart';
import '../chat/services/chat_service.dart';

class ClientSearchUserScreen extends StatefulWidget {
  final Function(int) onNavigateToChat;

  const ClientSearchUserScreen({
    super.key,
    required this.onNavigateToChat,
  });

  @override
  State<ClientSearchUserScreen> createState() => _ClientSearchUserScreenState();
}

class _ClientSearchUserScreenState extends State<ClientSearchUserScreen> {
  final searchCtrl = TextEditingController();
  List<Map<String, dynamic>> results = [];
  bool isLoading = false;
  bool hasSearched = false;

  @override
  void initState() {
    super.initState();
    // Default search to show some popular/recent talents on load
    _performSearch("");
  }

  void _performSearch(String query) async {
    setState(() {
      isLoading = true;
      hasSearched = true;
    });

    try {
      final list = await AuthService().searchUsers(query, role: "MAHASISWA");
      if (mounted) {
        setState(() {
          results = list;
          isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _buildAvatar(Map<String, dynamic> user, {double size = 56}) {
    final String? profileUrl = user['profilePictureUrl'];
    final String name = user['nama'] ?? user['username'] ?? 'User';
    return QTAvatar(
      name: name,
      profileUrl: profileUrl,
      size: size,
    );
  }

  Widget _buildInitials(String initials, double size) {
    return Center(
      child: Text(
        initials.isNotEmpty ? initials : 'U',
        style: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showUserProfileDetails(Map<String, dynamic> searchUser) async {
    // Load full profile details from the getPublicProfile endpoint
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, sc) {
            return FutureBuilder<Map<String, dynamic>>(
              future: AuthService().getPublicProfile(searchUser['id']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(color: QTColors.brandPrimary),
                    ),
                  );
                }

                final profile = snapshot.data ?? searchUser;
                final name = profile['nama'] ?? 'Talenta';
                final headline = profile['headline'] ?? 'Professional Talent';
                final bio = profile['bio'] ?? 'Belum ada deskripsi biografi.';
                final uni = profile['university'] ?? 'Universitas';
                final location = profile['location'] ?? 'Indonesia';
                final rating = profile['averageRating']?.toString() ?? '0.0';
                final reviewsCount = profile['totalReviews'] ?? 0;
                final skills = profile['skills'] ?? '';
                final experience = profile['yearsExperience']?.toString() ?? '0';

                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: ListView(
                    controller: sc,
                    padding: const EdgeInsets.all(24),
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: QTColors.slate300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          _buildAvatar(profile, size: 72),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: QTColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  headline,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    color: QTColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      rating,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      " ($reviewsCount ulasan)",
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: QTColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                      Text(
                        "Tentang Talenta",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        bio,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: QTColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildDetailRow(Icons.school_outlined, "Edukasi", uni),
                      const SizedBox(height: 12),
                      _buildDetailRow(Icons.work_outline, "Pengalaman", "$experience Tahun"),
                      const SizedBox(height: 12),
                      _buildDetailRow(Icons.location_on_outlined, "Lokasi", location),
                      const SizedBox(height: 24),
                      Text(
                        "Keahlian (Skills)",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      skills.toString().isNotEmpty
                          ? Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: skills
                                  .toString()
                                  .split(',')
                                  .map((s) => s.trim())
                                  .where((s) => s.isNotEmpty)
                                  .map(
                                    (skill) => Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: QTColors.brandPrimary.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        skill,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: QTColors.brandPrimary,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            )
                          : Text(
                              "Tidak ada keahlian khusus terdaftar",
                              style: GoogleFonts.plusJakartaSans(
                                fontStyle: FontStyle.italic,
                                color: QTColors.textMuted,
                              ),
                            ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(ctx);
                                _initiateChatWithUser(profile['id'], name);
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              icon: const Icon(Icons.chat_bubble_outline),
                              label: Text(
                                "Mulai Chat",
                                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: Text(
                                "Tutup",
                                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: QTColors.brandPrimary, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: QTColors.textMuted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: QTColors.textPrimary,
              ),
            ),
          ],
        )
      ],
    );
  }

  void _initiateChatWithUser(int userId, String name) async {
    // Check if chat is allowed via the startChat validator
    final res = await ChatService().startChat(userId);
    if (res['success'] == true) {
      widget.onNavigateToChat(userId);
    } else {
      if (mounted) {
        QTToast.show(
          context,
          title: "Gagal Memulai Chat",
          message: "Anda hanya dapat mengirim pesan ke talenta yang terikat kontrak aktif (diterima) dengan Anda.",
          type: QTToastType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [QTColors.bgPrimary, QTColors.bgTertiary, QTColors.slate200],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Cari Talenta",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: QTColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Temukan mahasiswa terbaik untuk proyek Anda",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: QTColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),

              // Search Input field
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: TextField(
                        controller: searchCtrl,
                        onSubmitted: (val) => _performSearch(val.trim()),
                        decoration: InputDecoration(
                          hintText: "Cari nama, keahlian, atau headline...",
                          hintStyle: GoogleFonts.plusJakartaSans(color: QTColors.textMuted, fontSize: 14),
                          prefixIcon: const Icon(Icons.search, color: QTColors.brandPrimary),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _performSearch(searchCtrl.text.trim()),
                    child: Container(
                      height: 52,
                      width: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [QTColors.brandPrimary, QTColors.brandDark],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.tune_rounded, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Results
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: QTColors.brandPrimary),
                      )
                    : results.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off_outlined, size: 64, color: QTColors.slate400),
                                const SizedBox(height: 16),
                                Text(
                                  hasSearched ? "Tidak ada talenta yang ditemukan" : "Ketik sesuatu untuk mencari talenta",
                                  style: GoogleFonts.plusJakartaSans(
                                    color: QTColors.textSecondary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: results.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (ctx, i) {
                              final u = results[i];
                              final name = u['nama'] ?? u['username'] ?? 'User';
                              final headline = u['headline'] ?? 'Professional Talent';
                              final rating = u['averageRating'] != null ? u['averageRating'].toString() : '0.0';
                              final reviews = u['totalReviews'] ?? 0;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  side: BorderSide(color: QTColors.slate200.withOpacity(0.5)),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(18),
                                  onTap: () => _showUserProfileDetails(u),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        _buildAvatar(u, size: 56),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                name,
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16,
                                                  color: QTColors.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                headline,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 12,
                                                  color: QTColors.textSecondary,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  const Icon(Icons.star, color: Colors.amber, size: 14),
                                                  const SizedBox(width: 3),
                                                  Text(
                                                    rating,
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                      color: QTColors.textPrimary,
                                                    ),
                                                  ),
                                                  Text(
                                                    " ($reviews ulasan)",
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 11,
                                                      color: QTColors.textMuted,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          onPressed: () => _initiateChatWithUser(u['id'], name),
                                          icon: const Icon(Icons.chat_bubble_outline),
                                          color: QTColors.brandPrimary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
