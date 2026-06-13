import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/qt_colors.dart';
import 'register_screen.dart';

class SelectRoleScreen extends StatefulWidget {
  const SelectRoleScreen({super.key});

  @override
  State<SelectRoleScreen> createState() => _SelectRoleScreenState();
}

class _SelectRoleScreenState extends State<SelectRoleScreen> {
  String? selectedRole;

  @override
  Widget build(BuildContext context) {
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
            // Glow
            Positioned(
              top: -80,
              left: -60,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      QTColors.brandPrimary.withOpacity(0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Colors.white.withOpacity(0.08),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.12),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    Text(
                      "Bergabung sebagai\nsiapa?",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      "Pilih peran yang paling sesuai dengan kebutuhanmu.",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        color: QTColors.textMuted,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Role Cards
                    _roleCard(
                      role: "TALENT",
                      icon: Icons.school_rounded,
                      title: "Mahasiswa (Talent)",
                      description:
                          "Temukan proyek magang terbaik untuk portofoliomu. Dapatkan pengalaman nyata dan bangun karir profesionalmu.",
                      isSelected: selectedRole == "TALENT",
                      onTap: () => setState(() => selectedRole = "TALENT"),
                    ),

                    const SizedBox(height: 18),

                    _roleCard(
                      role: "CLIENT",
                      icon: Icons.store_rounded,
                      title: "UMKM (Client)",
                      description:
                          "Temukan talenta mahasiswa unggulan untuk membantu bisnismu. Dapatkan solusi digital dengan biaya terjangkau.",
                      isSelected: selectedRole == "CLIENT",
                      onTap: () => setState(() => selectedRole = "CLIENT"),
                    ),

                    const SizedBox(height: 48),

                    // Continue button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: selectedRole != null ? 1.0 : 0.4,
                        child: ElevatedButton(
                          onPressed: selectedRole != null
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => RegisterScreen(
                                        role: selectedRole!,
                                      ),
                                    ),
                                  );
                                }
                              : null,
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Lanjutkan",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleCard({
    required String role,
    required IconData icon,
    required String title,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: isSelected
              ? QTColors.brandPrimary.withOpacity(0.12)
              : Colors.white.withOpacity(0.05),
          border: Border.all(
            color: isSelected
                ? QTColors.brandPrimary
                : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  colors: isSelected
                      ? [
                          QTColors.brandPrimary.withOpacity(0.3),
                          QTColors.brandPrimary.withOpacity(0.1),
                        ]
                      : [
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.04),
                        ],
                ),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? QTColors.brandPrimary
                    : QTColors.textMuted,
                size: 28,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : QTColors.slate300,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: QTColors.textMuted,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? QTColors.brandPrimary
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? QTColors.brandPrimary
                      : QTColors.textMuted,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
