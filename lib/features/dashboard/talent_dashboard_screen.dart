import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/qt_colors.dart';
import '../../core/widgets/qt_glass_card.dart';
import '../../core/widgets/qt_avatar.dart';
import '../projects/browse_projects_screen.dart';
import '../projects/active_projects_screen.dart';
import '../chat/chat_screen.dart';
import '../profile/profile_screen.dart';
import '../notifications/widgets/notification_bell.dart';
import '../auth/services/auth_service.dart';
import '../projects/services/project_service.dart';
import '../../core/network/dio_client.dart';

class TalentDashboardScreen extends StatefulWidget {
  const TalentDashboardScreen({super.key});

  @override
  State<TalentDashboardScreen> createState() => _TalentDashboardScreenState();
}

class _TalentDashboardScreenState extends State<TalentDashboardScreen> {
  int currentIndex = 0;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      _DashboardHome(
        onNavigate: (index) => setState(() => currentIndex = index),
        onOpenNearby: _openNearby,
      ),
      const BrowseProjectsScreen(),
      const ActiveProjectsScreen(),
      const ChatScreen(),
    ]);
  }

  /// Opens the Browse tab pre-selected to its "Nearby" mode. Rebuilding the
  /// Browse page with a fresh instance lets it initialise straight into nearby
  /// mode without any extra routing plumbing.
  void _openNearby() {
    setState(() {
      _pages[1] = const BrowseProjectsScreen(initialNearby: true);
      currentIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PopScope(
        canPop: currentIndex == 0,
        onPopInvoked: (didPop) {
          if (didPop) return;
          setState(() {
            currentIndex = 0;
          });
        },
        child: IndexedStack(
          index: currentIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => setState(() => currentIndex = index),
          selectedItemColor: QTColors.brandPrimary,
          unselectedItemColor: QTColors.slate400,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_rounded),
              activeIcon: Icon(Icons.search),
              label: 'Browse',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.work_outline_rounded),
              activeIcon: Icon(Icons.work),
              label: 'Projects',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'Messages',
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardHome extends StatefulWidget {
  final Function(int) onNavigate;
  final VoidCallback onOpenNearby;

  const _DashboardHome({required this.onNavigate, required this.onOpenNearby});

  @override
  State<_DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<_DashboardHome> {
  bool _isLoading = true;
  String _userName = "Talent";
  String? _profilePictureUrl;
  int _availableCount = 0;
  int _completedCount = 0;
  int _appliedCount = 0;
  List<Map<String, dynamic>> _recommendedProjects = [];
  List<Map<String, dynamic>> _announcements = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // 1. Fetch user profile
      final profileRes = await AuthService().getProfile();
      if (profileRes['success'] == true && profileRes['data'] != null) {
        _userName = profileRes['data']['nama'] ?? 'Talent';
        _profilePictureUrl = profileRes['data']['profilePictureUrl'];
      }

      // 2. Fetch projects
      final openProjects = await ProjectService().getAllProjects();
      final participating = await ProjectService().getParticipatingProjects();
      final recommendations = await ProjectService().getRecommendedProjects();
      final announcementsList = await ProjectService().getAnnouncements();

      final compCount = participating
          .where((p) => p['status'] == 'CLOSED' || p['status'] == 'DONE')
          .length;

      if (mounted) {
        setState(() {
          _availableCount = openProjects.length;
          _completedCount = compCount;
          _appliedCount = participating.length;
          _recommendedProjects = recommendations;
          _announcements = announcementsList;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatBudget(dynamic budget) {
    if (budget == null) return "0";
    final numVal = double.tryParse(budget.toString()) ?? 0.0;
    if (numVal >= 1000000) {
      return "${(numVal / 1000000).toStringAsFixed(1)}M";
    } else if (numVal >= 1000) {
      return "${(numVal / 1000).toStringAsFixed(0)}K";
    }
    return numVal.toStringAsFixed(0);
  }

  String _formatComplexity(dynamic comp) {
    if (comp == null) return "Beginner";
    final compStr = comp.toString().toUpperCase();
    if (compStr.contains("BEGINNER")) return "Beginner";
    if (compStr.contains("INTERMEDIATE")) return "Intermediate";
    if (compStr.contains("EXPERT")) return "Expert";
    return comp.toString();
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

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            QTColors.bgPrimary,
            QTColors.bgTertiary,
            QTColors.slate200,
          ],
        ),
      ),
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboardData,
          color: QTColors.brandPrimary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Halo, $_userName! 👋",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: QTColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Temukan proyek yang cocok untukmu",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: QTColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const NotificationBell(),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfileScreen(role: "TALENT"),
                          ),
                        ).then((_) => _loadDashboardData());
                      },
                      child: QTAvatar(
                        name: _userName,
                        profileUrl: _profilePictureUrl,
                        size: 48,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Welcome Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        QTColors.brandPrimary,
                        QTColors.brandDark,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: QTColors.brandPrimary.withOpacity(0.3),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome Back!",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Build your portfolio with real projects",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => widget.onNavigate(1),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: QTColors.brandPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.search, size: 20),
                          label: Text(
                            "Find Work",
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Nearby Projects shortcut
                GestureDetector(
                  onTap: widget.onOpenNearby,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: QTColors.brandPrimary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.near_me_rounded,
                            color: QTColors.brandPrimary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Nearby Projects",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Temukan proyek di sekitar lokasimu",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: QTColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: QTColors.textMuted,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                 const SizedBox(height: 8),

                // Stats Grid
                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        "Available Projects",
                        "$_availableCount",
                        Icons.work_outline,
                        QTColors.brandPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard(
                        "Completed",
                        "$_completedCount",
                        Icons.check_circle_outline,
                        QTColors.accentBeginner,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard(
                        "Applied",
                        "$_appliedCount",
                        Icons.send_outlined,
                        QTColors.info,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Recommended projects
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Rekomendasi Proyek",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => widget.onNavigate(1),
                      child: Text(
                        "Lihat Semua",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: QTColors.brandPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: _recommendedProjects.isEmpty
                      ? Center(
                          child: Text(
                            "Belum ada rekomendasi proyek",
                            style: GoogleFonts.plusJakartaSans(
                              color: QTColors.textMuted,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _recommendedProjects.length,
                          itemBuilder: (context, index) {
                            final p = _recommendedProjects[index];
                            return _recommendedCard(
                              p['title'] ?? 'No Title',
                              p['category'] ?? 'Category',
                              "Rp ${_formatBudget(p['budget'])}",
                              p['estimatedDuration'] ?? 'N/A',
                              _formatComplexity(p['complexity']),
                            );
                          },
                        ),
                ),

                const SizedBox(height: 32),

                // Latest Announcements
                Text(
                  "Latest Announcements",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),

                _announcements.isEmpty
                    ? QTGlassCard(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            "Belum ada pengumuman terbaru",
                            style: GoogleFonts.plusJakartaSans(
                              color: QTColors.textMuted,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      )
                    : QTGlassCard(
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _announcements.length,
                          separatorBuilder: (_, __) => Divider(color: QTColors.slate200, height: 24),
                          itemBuilder: (context, index) {
                            final ann = _announcements[index];
                            return _announcementItem(
                              ann['title'] ?? 'Announcement',
                              ann['content'] ?? '',
                              Icons.notifications_active_outlined,
                              QTColors.brandPrimary,
                            );
                          },
                        ),
                      ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return QTGlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: QTColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: QTColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _recommendedCard(
    String title,
    String category,
    String budget,
    String deadline,
    String complexity,
  ) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: QTColors.complexityColor(complexity).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  complexity,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: QTColors.complexityColor(complexity),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.payments_outlined, size: 14, color: QTColors.accentBeginner),
              const SizedBox(width: 4),
              Text(
                budget,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: QTColors.accentBeginner,
                ),
              ),
              const Spacer(),
              Icon(Icons.schedule, size: 14, color: QTColors.warning),
              const SizedBox(width: 4),
              Text(
                deadline,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: QTColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _announcementItem(
      String title, String subtitle, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: QTColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

}
