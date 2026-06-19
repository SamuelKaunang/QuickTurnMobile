import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/qt_colors.dart';
import '../../core/widgets/qt_toast.dart';
import '../../core/network/dio_client.dart';
import '../../widgets/glass_card.dart';
import '../projects/services/project_service.dart';
import '../chat/chat_screen.dart'; // for FullScreenImageViewer
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ClientMyProjectsScreen extends StatefulWidget {
  const ClientMyProjectsScreen({super.key});

  @override
  State<ClientMyProjectsScreen> createState() => _ClientMyProjectsScreenState();
}

class _ClientMyProjectsScreenState extends State<ClientMyProjectsScreen> {
  List<Map<String, dynamic>> _projects = [];
  bool _isLoading = true;
  String _selectedFilter = "ALL"; // ALL, OPEN, ONGOING, DONE, CLOSED

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() => _isLoading = true);
    try {
      final list = await ProjectService().getMyProjects();
      if (mounted) {
        setState(() {
          _projects = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _launchURL(String urlString) async {
    final String finalUrl = urlString.startsWith('http')
        ? urlString
        : '${DioClient.baseUrl}${urlString.startsWith('/') ? '' : '/'}$urlString';
    final Uri uri = Uri.parse(finalUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $finalUrl';
      }
    } catch (e) {
      debugPrint(e.toString());
      Clipboard.setData(ClipboardData(text: finalUrl));
      if (mounted) {
        QTToast.show(
          context,
          title: "Tautan Disalin",
          message: "Tidak dapat membuka tautan secara langsung. Tautan disalin ke papan klip.",
          type: QTToastType.warning,
        );
      }
    }
  }

  static String _status(Map<String, dynamic> p) => (p["status"] ?? "").toString().trim().toUpperCase();

  static int _asInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  List<Map<String, dynamic>> get _filteredProjects {
    if (_selectedFilter == "ALL") return _projects;
    return _projects.where((p) => _status(p) == _selectedFilter).toList();
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

  List<String> _extractUrls(String text) {
    final RegExp urlRegExp = RegExp(
      r'(https?:\/\/[^\s\)\(]+|\/api\/chat\/download\/[^\s\)\(]+)',
      caseSensitive: false,
    );
    final Iterable<RegExpMatch> matches = urlRegExp.allMatches(text);
    return matches.map((match) => match.group(0)!).toList();
  }

  void _showProjectDetails(Map<String, dynamic> p) {
    final status = _status(p);
    bool isLoadingReview = (status == "CLOSED");
    bool isLoadingSubmission = (status == "DONE" || status == "CLOSED");
    Map<String, dynamic>? myReview;
    Map<String, dynamic>? submissionData;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // Parallel loading of review and submission info if applicable
            if (isLoadingReview) {
              ProjectService().getMyReview(p['id']).then((res) {
                if (mounted) {
                  setModalState(() {
                    if (res['success'] == true && res['data'] != null) {
                      myReview = res['data'];
                    }
                    isLoadingReview = false;
                  });
                }
              });
            }

            if (isLoadingSubmission) {
              ProjectService().getFinishingStatus(p['id']).then((res) {
                if (mounted) {
                  setModalState(() {
                    if (res['success'] == true && res['data'] != null) {
                      submissionData = res['data'];
                    }
                    isLoadingSubmission = false;
                  });
                }
              });
            }

            if (isLoadingReview || isLoadingSubmission) {
              return const SizedBox(
                height: 250,
                child: Center(
                  child: CircularProgressIndicator(color: QTColors.brandPrimary),
                ),
              );
            }

            final String submissionText = submissionData != null ? (submissionData!['finishingLink'] ?? '') : '';
            final urls = _extractUrls(submissionText);

            return Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).padding.bottom + 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(color: QTColors.slate300, borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(p["title"] ?? "", style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: QTColors.statusColor(status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        status,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: QTColors.statusColor(status),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      p["description"] ?? "Tidak ada deskripsi.",
                      style: GoogleFonts.plusJakartaSans(color: QTColors.textSecondary, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Budget: Rp ${_formatBudgetDouble(p["budget"])}",
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: QTColors.accentBeginner),
                    ),
                    const SizedBox(height: 20),

                    // Submission information segment (Request #2)
                    if (status == "DONE" || status == "CLOSED") ...[
                      const Divider(),
                      const SizedBox(height: 16),
                      Text(
                        "Hasil Penyerahan Pekerjaan (Work Submission)",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: QTColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: QTColors.brandPrimary.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: QTColors.brandPrimary.withOpacity(0.1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              submissionText.isNotEmpty ? submissionText : "Tidak ada detail tautan dari talenta.",
                              style: GoogleFonts.plusJakartaSans(fontSize: 14, color: QTColors.textPrimary),
                            ),
                            if (urls.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(
                                "Tautan / Lampiran Berkas:",
                                style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: QTColors.textSecondary),
                              ),
                              const SizedBox(height: 8),
                              ...urls.map((url) {
                                final isImage = url.toLowerCase().contains('.png') ||
                                    url.toLowerCase().contains('.jpg') ||
                                    url.toLowerCase().contains('.jpeg') ||
                                    url.toLowerCase().contains('.webp') ||
                                    url.contains('/api/chat/download/');

                                if (isImage) {
                                  final String finalUrl = url.startsWith('http')
                                      ? url
                                      : '${DioClient.baseUrl}${url.startsWith('/') ? '' : '/'}$url';
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => FullScreenImageViewer(imagePath: url),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      height: 120,
                                      width: 200,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: QTColors.slate300),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          finalUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            color: Colors.grey[200],
                                            child: const Icon(Icons.broken_image, color: Colors.grey),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  return GestureDetector(
                                    onTap: () => _launchURL(url),
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: QTColors.slate300),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.attachment, color: QTColors.brandPrimary),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              url,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 12,
                                                color: QTColors.brandPrimary,
                                                decoration: TextDecoration.underline,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.open_in_new, size: 18, color: QTColors.brandPrimary),
                                            onPressed: () => _launchURL(url),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.copy, size: 18),
                                            onPressed: () {
                                              final String finalUrl = url.startsWith('http')
                                                  ? url
                                                  : '${DioClient.baseUrl}${url.startsWith('/') ? '' : '/'}$url';
                                              Clipboard.setData(ClipboardData(text: finalUrl));
                                              QTToast.show(
                                                context,
                                                title: "Tautan Disalin",
                                                message: "Tautan berhasil disalin.",
                                                type: QTToastType.success,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              }).toList(),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Action buttons based on status
                    if (status == "DONE") ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final res = await ProjectService().confirmFinishing(p['id']);
                            if (res['success'] == true) {
                              QTToast.show(
                                context,
                                title: "Proyek Selesai! 🎉",
                                message: "Pekerjaan proyek berhasil disetujui dan diselesaikan.",
                                type: QTToastType.success,
                              );
                              Navigator.pop(ctx);
                              _loadProjects();
                              _showRateDialog(p);
                            } else {
                              QTToast.show(
                                context,
                                title: "Gagal Mengonfirmasi",
                                message: res['message'] ?? "Gagal mengonfirmasi penyelesaian proyek.",
                                type: QTToastType.error,
                              );
                            }
                          },
                          icon: const Icon(Icons.check),
                          label: const Text("Setujui dan Selesaikan Proyek"),
                        ),
                      ),
                    ] else if (status == "CLOSED") ...[
                      if (myReview == null)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _showRateDialog(p);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: QTColors.warning,
                              foregroundColor: Colors.black,
                            ),
                            icon: const Icon(Icons.star),
                            label: const Text("Beri Rating Talenta"),
                          ),
                        )
                      else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: QTColors.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Text("Ulasan Anda untuk talenta ini:", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              Text("★" * _asInt(myReview!["rating"]), style: const TextStyle(color: Colors.amber, fontSize: 24)),
                              if (myReview!["comment"] != null && myReview!["comment"].toString().isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  '"${myReview!["comment"]}"',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                    color: QTColors.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ]
                            ],
                          ),
                        ),
                    ] else if (status == "ONGOING") ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: QTColors.info.withOpacity(0.08), borderRadius: BorderRadius.circular(16)),
                        child: Row(
                          children: [
                            Icon(Icons.hourglass_top, color: QTColors.info),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Proyek Sedang Berjalan. Menunggu talenta menyerahkan hasil pekerjaan.",
                                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: QTColors.info, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text("Tutup"),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showRateDialog(Map<String, dynamic> p) {
    int rating = 5;
    final commentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text("Beri Penilaian Talenta", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Bagaimana performa talenta dalam pengerjaan proyek ini?",
                style: GoogleFonts.plusJakartaSans(fontSize: 13, color: QTColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                    onPressed: () => setDialogState(() => rating = index + 1),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: "Tulis ulasan Anda tentang talenta ini...",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                final res = await ProjectService().submitReview(
                  projectId: p['id'],
                  rating: rating,
                  comment: commentCtrl.text.trim(),
                );
                if (res['success'] == true) {
                  QTToast.show(
                    context,
                    title: "Ulasan Terkirim",
                    message: "Terima kasih atas ulasan Anda.",
                    type: QTToastType.success,
                  );
                  Navigator.pop(ctx);
                  _loadProjects();
                } else {
                  QTToast.show(
                    context,
                    title: "Gagal Mengirim Ulasan",
                    message: res['message'] ?? "Terjadi kesalahan.",
                    type: QTToastType.error,
                  );
                }
              },
              child: const Text("Kirim"),
            ),
          ],
        ),
      ),
    );
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
                "Proyek Saya",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: QTColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Pantau perkembangan dan hasil pengerjaan proyek",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: QTColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _filterChip("ALL", "Semua"),
                    _filterChip("OPEN", "Mencari Talenta"),
                    _filterChip("ONGOING", "Berjalan"),
                    _filterChip("DONE", "Menunggu Persetujuan"),
                    _filterChip("CLOSED", "Selesai"),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Project List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: QTColors.brandPrimary))
                    : _filteredProjects.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.folder_open_outlined, size: 64, color: QTColors.slate400),
                                const SizedBox(height: 16),
                                Text(
                                  "Belum ada proyek dengan status ini",
                                  style: GoogleFonts.plusJakartaSans(
                                    color: QTColors.textSecondary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadProjects,
                            color: QTColors.brandPrimary,
                            child: ListView.builder(
                              itemCount: _filteredProjects.length,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemBuilder: (ctx, i) {
                                final p = _filteredProjects[i];
                                final status = _status(p);
                                final color = QTColors.statusColor(status);

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    side: BorderSide(color: color.withOpacity(0.2)),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(18),
                                    onTap: () => _showProjectDetails(p),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: color.withOpacity(0.08),
                                                  borderRadius: BorderRadius.circular(999),
                                                ),
                                                child: Text(
                                                  status,
                                                  style: GoogleFonts.plusJakartaSans(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: color,
                                                  ),
                                                ),
                                              ),
                                              const Spacer(),
                                              Icon(Icons.chevron_right, color: QTColors.slate400),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            p["title"] ?? "",
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: QTColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 14),
                                          Row(
                                            children: [
                                              Icon(Icons.payments_outlined, size: 14, color: QTColors.accentBeginner),
                                              const SizedBox(width: 4),
                                              Text(
                                                "Rp ${_formatBudgetDouble(p["budget"])}",
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: QTColors.accentBeginner,
                                                ),
                                              ),
                                              const Spacer(),
                                              Icon(Icons.people_outline, size: 14, color: QTColors.info),
                                              const SizedBox(width: 4),
                                              Text(
                                                "${p["applicantCount"] ?? 0} Pelamar",
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: QTColors.info,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterChip(String filter, String label) {
    final isSelected = _selectedFilter == filter;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = filter),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? QTColors.brandPrimary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? QTColors.brandPrimary : QTColors.slate200,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : QTColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
