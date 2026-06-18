import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/qt_colors.dart';
import '../../core/widgets/qt_glass_card.dart';
import '../../core/widgets/qt_toast.dart';
import '../projects/post_project_screen.dart';
import '../chat/chat_screen.dart';
import '../profile/profile_screen.dart';
import '../auth/services/auth_service.dart';
import '../projects/services/project_service.dart';

class UmkmDashboardScreen extends StatefulWidget {
  const UmkmDashboardScreen({super.key});
  @override
  State<UmkmDashboardScreen> createState() => _UmkmDashboardScreenState();
}

class _UmkmDashboardScreenState extends State<UmkmDashboardScreen> {
  int currentIndex = 0;
  bool _isLoading = true;
  String _umkmName = "UMKM";
  List<Map<String, dynamic>> _myProjects = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final profileRes = await AuthService().getProfile();
      if (profileRes['success'] == true && profileRes['data'] != null) {
        _umkmName = profileRes['data']['nama'] ?? 'UMKM';
      }

      final projects = await ProjectService().getMyProjects();

      if (mounted) {
        setState(() {
          _myProjects = projects;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [
          _dashboardHome(),
          const ChatScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => setState(() => currentIndex = i),
        selectedItemColor: QTColors.brandPrimary,
        unselectedItemColor: QTColors.slate400,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Messages'),
        ],
      ),
    );
  }

  Widget _dashboardHome() {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: QTColors.bgPrimary,
        body: Center(
          child: CircularProgressIndicator(color: QTColors.brandPrimary),
        ),
      );
    }

    final activeProjectsCount = _myProjects.where((p) => {"ONGOING", "OPEN", "DONE"}.contains(_status(p))).length;
    final totalApplicantsCount = _myProjects.fold<int>(0, (sum, p) => sum + _asInt(p["applicantCount"]));
    final completedProjectsCount = _myProjects.where((p) => _status(p) == "CLOSED").length;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [QTColors.bgPrimary, QTColors.bgTertiary, QTColors.slate200],
        ),
      ),
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboardData,
          color: QTColors.brandPrimary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Top bar
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("Halo, $_umkmName! 👋", style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text("Kelola proyek dan talenta", style: GoogleFonts.plusJakartaSans(fontSize: 14, color: QTColors.textSecondary)),
                ])),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen(role: "CLIENT"))),
                  child: Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: const LinearGradient(colors: [QTColors.brandPrimary, QTColors.brandDark])),
                    child: const Icon(Icons.store, color: Colors.white, size: 24),
                  ),
                ),
              ]),
              const SizedBox(height: 24),

              // Welcome Banner with Post Project
              Container(
                width: double.infinity, padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(colors: [QTColors.brandPrimary, QTColors.brandDark]),
                  boxShadow: [BoxShadow(color: QTColors.brandPrimary.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 10))],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("Selamat Datang!", style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 6),
                  Text("$activeProjectsCount proyek aktif • $totalApplicantsCount pelamar menunggu", style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.white70)),
                  const SizedBox(height: 20),
                  SizedBox(width: double.infinity, child: ElevatedButton.icon(
                    onPressed: () async {
                      final posted = await Navigator.push(context, MaterialPageRoute(builder: (_) => const PostProjectScreen()));
                      if (posted == true) {
                        _loadDashboardData();
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: QTColors.brandPrimary, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    icon: const Icon(Icons.add, size: 20),
                    label: Text("Post Project", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                  )),
                ]),
              ),
              const SizedBox(height: 28),

              // Stats Grid
              Row(children: [
                Expanded(child: _stat("Total Projects", "${_myProjects.length}", Icons.folder_outlined, QTColors.brandPrimary)),
                const SizedBox(width: 10),
                Expanded(child: _stat("Completed", "$completedProjectsCount", Icons.check_circle_outline, QTColors.accentBeginner)),
                const SizedBox(width: 10),
                Expanded(child: _stat("Applicants", "$totalApplicantsCount", Icons.people_outline, QTColors.info)),
              ]),
              const SizedBox(height: 32),

              // My Projects (horizontal scroll)
              Text("My Projects", style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: _myProjects.isEmpty
                    ? Center(
                        child: Text(
                          "Belum ada proyek yang Anda buat",
                          style: GoogleFonts.plusJakartaSans(
                            color: QTColors.textMuted,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _myProjects.length,
                        itemBuilder: (ctx, i) => _projectCard(_myProjects[i]),
                      ),
              ),
              const SizedBox(height: 40),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _stat(String label, String value, IconData icon, Color color) {
    return QTGlassCard(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 38, height: 38, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 18)),
      const SizedBox(height: 10),
      Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w900)),
      const SizedBox(height: 2),
      Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: QTColors.textSecondary)),
    ]));
  }

  Widget _projectCard(Map<String, dynamic> p) {
    final status = _status(p);
    final color = QTColors.statusColor(status);
    return GestureDetector(
      onTap: () => _showProjectAction(p),
      child: Container(
        width: 250, margin: const EdgeInsets.only(right: 14), padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16)]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(999)),
              child: Text(status, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: color))),
            const Spacer(),
            Icon(Icons.chevron_right, color: QTColors.slate400),
          ]),
          const SizedBox(height: 16),
          Text(p["title"] ?? "", style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
          const Spacer(),
          Row(children: [
            Icon(Icons.payments_outlined, size: 14, color: QTColors.accentBeginner),
            const SizedBox(width: 4),
            Text("Rp ${_formatBudgetDouble(p["budget"])}", style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: QTColors.accentBeginner)),
            const Spacer(),
            Icon(Icons.people_outline, size: 14, color: QTColors.info),
            const SizedBox(width: 4),
            Text("${p["applicantCount"] ?? 0}", style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: QTColors.info)),
          ]),
        ]),
      ),
    );
  }

  /// Defensive int parsing: the backend may send numeric fields (applicantCount,
  /// rating, ...) as an int, a double, a numeric string, or omit them entirely
  /// (null). A raw `as int` cast throws "type 'Null' is not a subtype of type
  /// 'int'" and replaces the whole screen with the red error widget.
  /// Normalized project status (uppercased + trimmed) so gating against
  /// "OPEN"/"ONGOING"/"DONE"/"CLOSED" never breaks on a casing/whitespace
  /// quirk from the backend payload.
  static String _status(Map<String, dynamic> p) => (p["status"] ?? "").toString().trim().toUpperCase();

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

  void _showProjectAction(Map<String, dynamic> p) {
    final status = _status(p);
    bool isLoadingReview = (status == "CLOSED");
    Map<String, dynamic>? myReview;

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            if (isLoadingReview) {
              ProjectService().getMyReview(p['id']).then((res) {
                setModalState(() {
                  if (res['success'] == true && res['data'] != null) {
                    myReview = res['data'];
                  }
                  isLoadingReview = false;
                });
              });
              return const SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(color: QTColors.brandPrimary),
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).padding.bottom + 24),
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: QTColors.slate300, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),
                Text(p["title"] ?? "", style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: QTColors.statusColor(status).withOpacity(0.1), borderRadius: BorderRadius.circular(999)),
                  child: Text(status, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: QTColors.statusColor(status)))),
                const SizedBox(height: 20),
                Text("Budget: Rp ${_formatBudgetDouble(p["budget"])}", style: GoogleFonts.plusJakartaSans(color: QTColors.textSecondary)),
                const SizedBox(height: 24),
                if (status == "OPEN") ...[
                  SizedBox(width: double.infinity, child: ElevatedButton.icon(
                    onPressed: () { Navigator.pop(ctx); _showApplicants(p); },
                    icon: const Icon(Icons.people), label: const Text("View Applicants"))),
                ] else if (status == "ONGOING") ...[
                  Container(width: double.infinity, padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: QTColors.info.withOpacity(0.08), borderRadius: BorderRadius.circular(16)),
                    child: Row(children: [
                      Icon(Icons.hourglass_top, color: QTColors.info),
                      const SizedBox(width: 12),
                      Text("Waiting for Submission", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: QTColors.info)),
                    ])),
                ] else if (status == "DONE") ...[
                  SizedBox(width: double.infinity, child: ElevatedButton.icon(
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
                        _loadDashboardData();
                        // FR-05.1: after closing the project the UMKM must rate
                        // the talent — flow straight into the rating dialog so
                        // the review step isn't left stranded behind a re-tap.
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
                    icon: const Icon(Icons.check), label: const Text("Approve and Complete"))),
                ] else if (status == "CLOSED") ...[
                  if (myReview == null)
                    SizedBox(width: double.infinity, child: ElevatedButton.icon(
                      onPressed: () { Navigator.pop(ctx); _showRateDialog(p); },
                      style: ElevatedButton.styleFrom(backgroundColor: QTColors.warning, foregroundColor: Colors.black),
                      icon: const Icon(Icons.star), label: const Text("Rate Talent")))
                  else
                    Container(width: double.infinity, padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: QTColors.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                      child: Column(children: [
                        Text("You rated this talent", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
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
                      ])),
                ] else if (status == "OVERDUE") ...[
                  Container(width: double.infinity, padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: QTColors.error.withOpacity(0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: QTColors.error.withOpacity(0.3))),
                    child: Row(children: [
                      const Icon(Icons.warning_amber_rounded, color: QTColors.error),
                      const SizedBox(width: 12),
                      Expanded(child: Text("Proyek ini melewati batas waktu. Hanya dapat dilihat.", style: GoogleFonts.plusJakartaSans(fontSize: 13, color: QTColors.error))),
                    ])),
                ],
              ]),
            );
          }
        );
      },
    );
  }

  void _showApplicants(Map<String, dynamic> p) {
    List<Map<String, dynamic>>? applicants;
    bool isLoadingApps = true;

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          if (isLoadingApps) {
            ProjectService().getApplicants(p['id']).then((list) {
              setSheetState(() {
                applicants = list;
                isLoadingApps = false;
              });
            });
            return const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator(color: QTColors.brandPrimary)),
            );
          }

          return DraggableScrollableSheet(
            initialChildSize: 0.7, minChildSize: 0.4, maxChildSize: 0.9, expand: false,
            builder: (_, sc) => Padding(padding: const EdgeInsets.all(24), child: ListView(controller: sc, children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: QTColors.slate300, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Text("Applicants", style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              if (applicants == null || applicants!.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      "Belum ada pelamar untuk proyek ini",
                      style: GoogleFonts.plusJakartaSans(
                        color: QTColors.textMuted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                )
              else
                ...applicants!.map((a) => Container(
                  margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: QTColors.bgTertiary, borderRadius: BorderRadius.circular(20)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      CircleAvatar(backgroundColor: QTColors.brandPrimary, child: Text((a["studentName"] ?? "A")[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(a["studentName"] ?? "Anonymous", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                        Row(children: [const Icon(Icons.star, size: 14, color: Colors.amber), const SizedBox(width: 4), Text("${a["studentRating"] ?? 0.0}", style: GoogleFonts.plusJakartaSans(fontSize: 13, color: QTColors.textSecondary))]),
                      ])),
                    ]),
                    const SizedBox(height: 12),
                    Text(a["proposal"] ?? "", style: GoogleFonts.plusJakartaSans(fontSize: 13, color: QTColors.textSecondary, height: 1.5)),
                    const SizedBox(height: 8),
                    Text("Bid: Rp ${_formatBudgetDouble(a["bidAmount"])}", style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: QTColors.accentBeginner)),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(child: OutlinedButton(
                        onPressed: () async {
                          final res = await ProjectService().rejectApplicant(projectId: p['id'], applicationId: a['id']);
                          if (res['success'] == true) {
                            QTToast.show(
                              context,
                              title: "Pelamar Ditolak",
                              message: "Lamaran telah ditolak.",
                              type: QTToastType.warning,
                            );
                            setSheetState(() {
                              isLoadingApps = true;
                            });
                          } else {
                            QTToast.show(
                              context,
                              title: "Gagal Menolak",
                              message: res['message'] ?? "Gagal memproses penolakan.",
                              type: QTToastType.error,
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(foregroundColor: QTColors.slate500),
                        child: const Text("Reject"),
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: ElevatedButton(
                        onPressed: () async {
                          final res = await ProjectService().acceptApplicant(projectId: p['id'], applicationId: a['id']);
                          if (res['success'] == true) {
                            QTToast.show(
                              context,
                              title: "Pelamar Diterima! 🚀",
                              message: "Lamaran telah disetujui, proyek dimulai.",
                              type: QTToastType.success,
                            );
                            Navigator.pop(ctx);
                            _loadDashboardData();
                          } else {
                            QTToast.show(
                              context,
                              title: "Gagal Menerima",
                              message: res['message'] ?? "Gagal memproses penerimaan.",
                              type: QTToastType.error,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: QTColors.accentBeginner),
                        child: const Text("Accept"),
                      )),
                    ]),
                  ]),
                )),
            ])),
          );
        }
      ),
    );
  }

  void _showRateDialog(Map<String, dynamic> p) {
    int rating = 5;
    final reviewCtrl = TextEditingController();
    showDialog(context: context, builder: (_) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text("Rate Talent", style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) => IconButton(
          onPressed: () => ss(() => rating = i + 1),
          icon: Icon(i < rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 36)))),
        const SizedBox(height: 16),
        TextField(controller: reviewCtrl, maxLines: 4, decoration: const InputDecoration(hintText: "Write your review...")),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity, child: ElevatedButton(
          onPressed: () async {
            final res = await ProjectService().submitReview(projectId: p['id'], rating: rating, comment: reviewCtrl.text);
            if (res['success'] == true) {
              QTToast.show(
                context,
                title: "Ulasan Terkirim! ⭐",
                message: "Terima kasih atas ulasan Anda.",
                type: QTToastType.success,
              );
              Navigator.pop(ctx);
              _loadDashboardData();
            } else {
              QTToast.show(
                context,
                title: "Gagal Mengirim",
                message: res['message'] ?? "Gagal mengirim ulasan.",
                type: QTToastType.error,
              );
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: QTColors.warning, foregroundColor: Colors.black),
          child: const Text("Submit Review"))),
      ])),
    )));
  }
}
