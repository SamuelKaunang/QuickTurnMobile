import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/qt_colors.dart';
import '../dashboard/talent_dashboard_screen.dart';
import '../dashboard/umkm_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;
  bool showForgotPassword = false;

  // Forgot password flow state
  int forgotStep = 0; // 0=email, 1=OTP, 2=reset password
  final forgotEmailController = TextEditingController();
  final List<TextEditingController> otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> otpFocusNodes =
      List.generate(6, (_) => FocusNode());
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    forgotEmailController.dispose();
    for (final c in otpControllers) {
      c.dispose();
    }
    for (final f in otpFocusNodes) {
      f.dispose();
    }
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: QTColors.bgPrimary,
        child: Stack(
          children: [
            // Dark gradient header
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.4,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      QTColors.darkBase,
                      QTColors.darkSurface,
                      Color(0xFF1A0D20),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -60,
                      right: -30,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              QTColors.brandPrimary.withOpacity(0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -80,
                      left: -50,
                      child: Container(
                        width: 180,
                        height: 180,
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
                  ],
                ),
              ),
            ),

            // Content
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Header area
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 16, 28, 0),
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
                          const SizedBox(height: 28),
                          Text(
                            "Selamat Datang\nKembali! 👋",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Masuk ke akunmu untuk melanjutkan.",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              color: QTColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Form card (glassmorphism-like)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 40,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: showForgotPassword
                          ? _buildForgotPasswordFlow()
                          : _buildLoginForm(),
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

  Widget _buildLoginForm() {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email
          _label("Email"),
          const SizedBox(height: 8),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: "name@example.com",
              prefixIcon: Icon(Icons.email_outlined,
                  color: QTColors.textMuted),
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
          _label("Password"),
          const SizedBox(height: 8),
          TextFormField(
            controller: passwordController,
            obscureText: obscurePassword,
            decoration: InputDecoration(
              hintText: "Masukkan password",
              prefixIcon: const Icon(Icons.lock_outline,
                  color: QTColors.textMuted),
              suffixIcon: IconButton(
                onPressed: () =>
                    setState(() => obscurePassword = !obscurePassword),
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: QTColors.textMuted,
                ),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) {
                return "Masukkan password";
              }
              return null;
            },
          ),

          const SizedBox(height: 12),

          // Forgot password link
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => setState(() {
                showForgotPassword = true;
                forgotStep = 0;
              }),
              child: Text(
                "Forgot password?",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: QTColors.brandPrimary,
                ),
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Login button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: QTColors.brandPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: QTColors.brandPrimary.withOpacity(0.3),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      "Login",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 20),

          // Divider
          Row(
            children: [
              Expanded(child: Divider(color: QTColors.slate200)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "atau",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: QTColors.textMuted,
                  ),
                ),
              ),
              Expanded(child: Divider(color: QTColors.slate200)),
            ],
          ),

          const SizedBox(height: 20),

          // Google sign-in
          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.g_mobiledata, size: 28),
              label: Text(
                "Masuk dengan Google",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: QTColors.textPrimary,
                side: BorderSide(color: QTColors.slate200),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPasswordFlow() {
    switch (forgotStep) {
      case 0:
        return _forgotStepEmail();
      case 1:
        return _forgotStepOTP();
      case 2:
        return _forgotStepReset();
      default:
        return _forgotStepEmail();
    }
  }

  Widget _forgotStepEmail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => showForgotPassword = false),
              child: const Icon(Icons.arrow_back, size: 22),
            ),
            const SizedBox(width: 12),
            Text(
              "Reset Password",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "Masukkan email yang terdaftar untuk menerima kode verifikasi.",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: QTColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 28),
        _label("Email"),
        const SizedBox(height: 8),
        TextFormField(
          controller: forgotEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: "name@example.com",
            prefixIcon:
                Icon(Icons.email_outlined, color: QTColors.textMuted),
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () => setState(() => forgotStep = 1),
            child: Text(
              "Kirim Kode Verifikasi",
              style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Widget _forgotStepOTP() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => forgotStep = 0),
              child: const Icon(Icons.arrow_back, size: 22),
            ),
            const SizedBox(width: 12),
            Text(
              "Verifikasi OTP",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "Masukkan 6 digit kode yang dikirim ke email Anda.",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: QTColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),

        // OTP input boxes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 46,
              height: 56,
              child: TextFormField(
                controller: otpControllers[index],
                focusNode: otpFocusNodes[index],
                textAlign: TextAlign.center,
                maxLength: 1,
                keyboardType: TextInputType.number,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
                decoration: InputDecoration(
                  counterText: "",
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  filled: true,
                  fillColor: QTColors.bgTertiary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: QTColors.brandPrimary,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty && index < 5) {
                    otpFocusNodes[index + 1].requestFocus();
                  }
                  if (value.isEmpty && index > 0) {
                    otpFocusNodes[index - 1].requestFocus();
                  }
                },
              ),
            );
          }),
        ),

        const SizedBox(height: 32),

        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () => setState(() => forgotStep = 2),
            child: Text(
              "Verifikasi",
              style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700),
            ),
          ),
        ),

        const SizedBox(height: 16),

        Center(
          child: TextButton(
            onPressed: () {},
            child: Text(
              "Kirim ulang kode",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: QTColors.brandPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _forgotStepReset() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => forgotStep = 1),
              child: const Icon(Icons.arrow_back, size: 22),
            ),
            const SizedBox(width: 12),
            Text(
              "Password Baru",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "Buat password baru untuk akun Anda.",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: QTColors.textSecondary,
          ),
        ),
        const SizedBox(height: 28),
        _label("Password Baru"),
        const SizedBox(height: 8),
        TextFormField(
          controller: newPasswordController,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: "Masukkan password baru",
            prefixIcon:
                Icon(Icons.lock_outline, color: QTColors.textMuted),
          ),
        ),
        const SizedBox(height: 20),
        _label("Konfirmasi Password Baru"),
        const SizedBox(height: 8),
        TextFormField(
          controller: confirmNewPasswordController,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: "Ulangi password baru",
            prefixIcon:
                Icon(Icons.lock_outline, color: QTColors.textMuted),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Password berhasil diubah! Silakan login."),
                ),
              );
              setState(() {
                showForgotPassword = false;
                forgotStep = 0;
              });
            },
            child: Text(
              "Reset Password",
              style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: QTColors.textPrimary,
      ),
    );
  }

  void _login() {
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    // Simulate login - determine role based on email pattern for demo
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => isLoading = false);

      final email = emailController.text.toLowerCase();

      // Demo: if email contains "umkm" or "client", go to UMKM dashboard
      if (email.contains("umkm") || email.contains("client")) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const UmkmDashboardScreen(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const TalentDashboardScreen(),
          ),
        );
      }
    });
  }
}
