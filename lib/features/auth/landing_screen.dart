import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/qt_colors.dart';
import '../../core/network/dio_client.dart';
import '../../core/services/notification_service.dart';
import '../dashboard/umkm_dashboard_screen.dart';
import '../dashboard/talent_dashboard_screen.dart';
import 'services/auth_service.dart';
import 'login_screen.dart';
import 'select_role_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  bool _checkingAuth = true;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _checkAuth();
  }

  void _checkAuth() async {
    try {
      final token = await DioClient().getToken();
      if (token != null) {
        final profileRes = await AuthService().getProfile();
        if (profileRes['success'] == true && profileRes['data'] != null) {
          // Register device for FCM Push Notifications
          NotificationService().registerDevice();
          
          final role = await DioClient().getUserRole() ?? profileRes['data']['role'] ?? 'MAHASISWA';
          if (!mounted) return;
          if (role == 'UMKM' || role == 'CLIENT') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const UmkmDashboardScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const TalentDashboardScreen()),
            );
          }
          return;
        }
      }
    } catch (e) {
      print('Auto login error: $e');
    }

    if (mounted) {
      setState(() {
        _checkingAuth = false;
      });
      _fadeController.forward();
      Future.delayed(const Duration(milliseconds: 300), () {
        _slideController.forward();
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingAuth) {
      return Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                QTColors.darkBase,
                QTColors.darkSurface,
                Color(0xFF1A0A1E),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(),
                const SizedBox(height: 32),
                const CircularProgressIndicator(
                  color: QTColors.brandPrimary,
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              QTColors.darkBase,
              QTColors.darkSurface,
              Color(0xFF1A0A1E),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Glow effect top-right
            Positioned(
              top: -120,
              right: -80,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      QTColors.brandPrimary.withOpacity(0.3),
                      QTColors.brandPrimary.withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Glow effect bottom-left
            Positioned(
              bottom: -100,
              left: -60,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      QTColors.brandPrimary.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Column(
                      children: [
                        const SizedBox(height: 60),

                        // Logo
                        _buildLogo(horizontal: true),

                        const SizedBox(height: 48),

                        // Headline
                        Text(
                          "Empowering your\ndigital future.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          "Platform micro-internship yang menghubungkan\nmahasiswa berbakat dengan UMKM Indonesia.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            color: QTColors.textMuted,
                            height: 1.6,
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Feature Grid
                        _buildFeatureGrid(),

                        const SizedBox(height: 56),

                        // CTA Buttons
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SelectRoleScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: QTColors.brandPrimary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 8,
                              shadowColor:
                                  QTColors.brandPrimary.withOpacity(0.4),
                            ),
                            child: Text(
                              "Mulai Sekarang",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(
                                color: Colors.white.withOpacity(0.3),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              "Sudah punya akun? Masuk",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo({bool horizontal = false}) {
    if (horizontal) {
      return Image.asset(
        "assets/images/1767079315838.png", // Wide logo banner
        height: 60,
        fit: BoxFit.contain,
      );
    }
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          "assets/images/1767079251996.png", // Square logo icon
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildFeatureGrid() {
    final features = [
      {
        "icon": Icons.bolt_rounded,
        "title": "Quick Start",
        "desc": "Temukan proyek dalam hitungan menit",
      },
      {
        "icon": Icons.verified_rounded,
        "title": "Verified Talents",
        "desc": "Mahasiswa terverifikasi dan berkualitas",
      },
      {
        "icon": Icons.trending_up_rounded,
        "title": "Real Impact",
        "desc": "Proyek nyata untuk portofolio nyata",
      },
      {
        "icon": Icons.people_alt_rounded,
        "title": "Grow Together",
        "desc": "Kolaborasi yang saling menguntungkan",
      },
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 0.95,
      children: features.map((f) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withOpacity(0.06),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [
                      QTColors.brandPrimary.withOpacity(0.2),
                      QTColors.brandPrimary.withOpacity(0.05),
                    ],
                  ),
                ),
                child: Icon(
                  f["icon"] as IconData,
                  color: QTColors.brandPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                f["title"] as String,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  f["desc"] as String,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: QTColors.textMuted,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
