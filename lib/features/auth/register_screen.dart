import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/qt_colors.dart';
import '../../core/widgets/qt_toast.dart';
import 'login_screen.dart';
import 'services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  final String role;

  const RegisterScreen({super.key, required this.role});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirm = true;
  bool agreeTerms = false;
  bool isLoading = false;

  // Password strength
  int get passwordStrength {
    final pass = passwordController.text;
    if (pass.isEmpty) return 0;
    int score = 0;
    if (pass.length >= 8) score++;
    if (pass.contains(RegExp(r'[A-Z]'))) score++;
    if (pass.contains(RegExp(r'[0-9]'))) score++;
    if (pass.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;
    return score;
  }

  String get strengthLabel {
    switch (passwordStrength) {
      case 0:
        return "";
      case 1:
        return "Lemah";
      case 2:
        return "Sedang";
      case 3:
        return "Kuat";
      case 4:
        return "Sangat Kuat";
      default:
        return "";
    }
  }

  Color get strengthColor {
    switch (passwordStrength) {
      case 1:
        return QTColors.error;
      case 2:
        return QTColors.warning;
      case 3:
        return QTColors.accentBeginner;
      case 4:
        return QTColors.accentBeginner;
      default:
        return QTColors.slate300;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTalent = widget.role == "TALENT";

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              QTColors.darkBase,
              QTColors.darkSurface,
            ],
            stops: [0.0, 0.35],
          ),
        ),
        child: Stack(
          children: [
            // Glow
            Positioned(
              top: -50,
              right: -40,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      QTColors.brandPrimary.withOpacity(0.25),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Dark header
                    Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: Colors.white.withOpacity(0.08),
                              ),
                              child: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "Buat Akun\n${isTalent ? 'Mahasiswa' : 'UMKM'}",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: QTColors.brandPrimary.withOpacity(0.2),
                            ),
                            child: Text(
                              isTalent ? "🎓 Talent" : "🏪 Client",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: QTColors.brandPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // White form area
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(36),
                          topRight: Radius.circular(36),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(28, 36, 28, 40),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name
                              _buildLabel(isTalent
                                  ? "Nama Lengkap"
                                  : "Nama Bisnis"),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: nameController,
                                decoration: InputDecoration(
                                  hintText: isTalent
                                      ? "Masukkan nama lengkap"
                                      : "Masukkan nama bisnis",
                                  prefixIcon: Icon(
                                    isTalent
                                        ? Icons.person_outline
                                        : Icons.store_outlined,
                                    color: QTColors.textMuted,
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.length < 3) {
                                    return "Minimal 3 karakter";
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 22),

                              // Email
                              _buildLabel("Alamat Email"),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  hintText: "name@example.com",
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: QTColors.textMuted,
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || !v.contains("@")) {
                                    return "Masukkan email yang valid";
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 22),

                              // Password
                              _buildLabel("Password"),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: passwordController,
                                obscureText: obscurePassword,
                                onChanged: (_) => setState(() {}),
                                decoration: InputDecoration(
                                  hintText: "Buat password",
                                  prefixIcon: const Icon(
                                    Icons.lock_outline,
                                    color: QTColors.textMuted,
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () => setState(
                                        () => obscurePassword = !obscurePassword),
                                    icon: Icon(
                                      obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: QTColors.textMuted,
                                    ),
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.length < 6) {
                                    return "Minimal 6 karakter";
                                  }
                                  return null;
                                },
                              ),

                              // Password strength indicator
                              if (passwordController.text.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    ...List.generate(4, (i) {
                                      return Expanded(
                                        child: Container(
                                          height: 4,
                                          margin: EdgeInsets.only(
                                            right: i < 3 ? 6 : 0,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(2),
                                            color: i < passwordStrength
                                                ? strengthColor
                                                : QTColors.slate200,
                                          ),
                                        ),
                                      );
                                    }),
                                    const SizedBox(width: 12),
                                    Text(
                                      strengthLabel,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: strengthColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],

                              const SizedBox(height: 22),

                              // Confirm password
                              _buildLabel("Konfirmasi Password"),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: confirmPasswordController,
                                obscureText: obscureConfirm,
                                decoration: InputDecoration(
                                  hintText: "Ulangi password",
                                  prefixIcon: const Icon(
                                    Icons.lock_outline,
                                    color: QTColors.textMuted,
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () => setState(
                                        () => obscureConfirm = !obscureConfirm),
                                    icon: Icon(
                                      obscureConfirm
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: QTColors.textMuted,
                                    ),
                                  ),
                                ),
                                validator: (v) {
                                  if (v != passwordController.text) {
                                    return "Password tidak cocok";
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 24),

                              // Terms checkbox
                              Row(
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      value: agreeTerms,
                                      onChanged: (v) =>
                                          setState(() => agreeTerms = v!),
                                      activeColor: QTColors.brandPrimary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text.rich(
                                      TextSpan(
                                        text: "Saya menyetujui ",
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          color: QTColors.textSecondary,
                                        ),
                                        children: [
                                          TextSpan(
                                            text:
                                                "Syarat & Ketentuan",
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: QTColors.brandPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 32),

                              // Register button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: agreeTerms && !isLoading
                                      ? _register
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: QTColors.brandPrimary,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                        QTColors.brandPrimary
                                            .withOpacity(0.4),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child:
                                              CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : Text(
                                          "Daftar Akun",
                                          style:
                                              GoogleFonts.plusJakartaSans(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Already have account
                              Center(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const LoginScreen(),
                                      ),
                                    );
                                  },
                                  child: Text.rich(
                                    TextSpan(
                                      text: "Sudah punya akun? ",
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        color: QTColors.textSecondary,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: "Masuk",
                                          style:
                                              GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.w700,
                                            color: QTColors.brandPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: QTColors.textPrimary,
      ),
    );
  }

  void _register() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    
    // Map UI role to Backend role
    final backendRole = widget.role == "TALENT" ? "MAHASISWA" : "UMKM";

    final res = await AuthService().register(
      name: name,
      email: email,
      password: password,
      role: backendRole,
    );

    setState(() => isLoading = false);

    final isSuccess = res['success'] == true;
    QTToast.show(
      context,
      title: isSuccess ? "Registrasi Berhasil! 🎉" : "Registrasi Gagal",
      message: res['message'] ?? (isSuccess ? "Silakan masuk ke akun Anda." : "Terjadi kesalahan."),
      type: isSuccess ? QTToastType.success : QTToastType.error,
    );

    if (res['success'] == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    }
  }
}
