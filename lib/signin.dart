import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'login.dart';
import 'signin_loading.dart';
import 'services/auth_service.dart'; // <--- THIS WAS MISSING

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isButtonEnabled = false;
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateForm() {
    String? passwordError;
    String? confirmPasswordError;

    final bool fieldsFull = _nameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty;

    if (_passwordController.text.isNotEmpty &&
        _passwordController.text.length < 6) {
      passwordError = 'Minimal 6 karakter';
    }

    if (_confirmPasswordController.text.isNotEmpty &&
        _passwordController.text != _confirmPasswordController.text) {
      confirmPasswordError = 'Kata sandi tidak cocok';
    }

    final bool isFormValid =
        fieldsFull && passwordError == null && confirmPasswordError == null;

    setState(() {
      _isButtonEnabled = isFormValid;
      _passwordError = passwordError;
      _confirmPasswordError = confirmPasswordError;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE0EBF0), Color(0xFFF0F9FF), Color(0xFFE8F8F5)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: -48,
              top: 726,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Opacity(
                  opacity: 0.59,
                  child: Container(
                    width: 493,
                    height: 367,
                    decoration: ShapeDecoration(
                      color: const Color(0x331A2E35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(38835400),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: -84,
              top: -169,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Opacity(
                  opacity: 0.59,
                  child: Container(
                    width: 558,
                    height: 283,
                    decoration: ShapeDecoration(
                      color: const Color(0x704ADEDE),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(38835400)),
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),
                      Container(
                        width: 74,
                        height: 74,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0x4C4ADEDE), Color(0x5FA3E42F)],
                          ),
                          border: Border.all(
                              color: const Color(0xB2FFFFFF), width: 1.16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              'assets/images/siren.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.warning, color: Colors.orange);
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "SIREN",
                        style: GoogleFonts.orbitron(
                          fontSize: 22,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 6,
                          color: const Color(0xFF1A2E35),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Smart Integrated Report and Emergency Network",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.instrumentSans(
                          fontSize: 12,
                          color: const Color(0x99192D34),
                          letterSpacing: 0.28,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        "Buat Akun",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.instrumentSans(
                          color: const Color(0xFF1A2E35),
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(
                        controller: _nameController,
                        label: "Nama Pengguna",
                        hint: "Masukkan nama anda",
                        icon: Icons.person_outline_rounded,
                        textInputAction: TextInputAction.next,
                      ),
                      _buildTextField(
                        controller: _emailController,
                        label: "Alamat Email",
                        hint: "Masukkan email anda",
                        icon: Icons.alternate_email_rounded,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      _buildPasswordTextField(
                        controller: _passwordController,
                        label: "Kata Sandi",
                        hint: "Buat kata sandi",
                        isObscured: _isPasswordObscured,
                        helperText: "Minimal 6 karakter",
                        errorText: _passwordError,
                        textInputAction: TextInputAction.next,
                        onToggleVisibility: () {
                          setState(() {
                            _isPasswordObscured = !_isPasswordObscured;
                          });
                        },
                      ),
                      _buildPasswordTextField(
                        controller: _confirmPasswordController,
                        label: "Konfirmasi Kata Sandi",
                        hint: "Konfirmasi kata sandi anda",
                        isObscured: _isConfirmPasswordObscured,
                        errorText: _confirmPasswordError,
                        textInputAction: TextInputAction.done,
                        onToggleVisibility: () {
                          setState(() {
                            _isConfirmPasswordObscured =
                            !_isConfirmPasswordObscured;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      // --- FIXED BUTTON ---
                      GestureDetector(
                        onTap: _isButtonEnabled
                            ? () async {
                          // 1. Tampilkan loading
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Mendaftarkan akun...')),
                          );

                          // 2. Panggil AuthService untuk simpan ke SQLite
                          final bool success = await AuthService.instance.signUpWithEmail(
                            email: _emailController.text.trim(),
                            password: _passwordController.text.trim(),
                            name: _nameController.text.trim(),
                            phone: "081234567890",
                            role: "warga",
                          );

                          if (!context.mounted) return;

                          if (success) {
                            // 3. Jika Sukses, Navigasi ke Loading
                            Navigator.of(context).pushReplacement(
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) =>
                                const SignInLoadingScreen(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return FadeTransition(
                                    opacity: animation.drive(CurveTween(curve: Curves.easeIn)),
                                    child: child,
                                  );
                                },
                              ),
                            );
                          } else {
                            // 4. Jika Gagal
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Gagal mendaftar. Email mungkin sudah terpakai.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                            : null,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: _isButtonEnabled
                                  ? [
                                const Color(0xE5B3FFD5),
                                const Color(0xE528CFD8)
                              ]
                                  : [
                                const Color(0xFFB0B0B0),
                                const Color(0xFF909090)
                              ],
                            ),
                            boxShadow: _isButtonEnabled
                                ? const [
                              BoxShadow(
                                color: Color(0x19000000),
                                blurRadius: 15,
                                offset: Offset(0, 10),
                                spreadRadius: -3,
                              ),
                            ]
                                : null,
                          ),
                          child: Text(
                            "DAFTAR",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.instrumentSans(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.85,
                            ),
                          ),
                        ),
                      ),
                      // --- END FIXED BUTTON ---
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(child: _buildDivider()),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text(
                              "ATAU",
                              style: GoogleFonts.instrumentSans(
                                color: const Color(0x7F192D34),
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Expanded(child: _buildDivider()),
                        ],
                      ),
                      const SizedBox(height: 24),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                              const LoginScreen(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                return FadeTransition(
                                  opacity: animation
                                      .drive(CurveTween(curve: Curves.easeIn)),
                                  child: child,
                                );
                              },
                              transitionDuration:
                              const Duration(milliseconds: 300),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: ShapeDecoration(
                            color: const Color(0x66FFFFFF),
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                  color: Color(0x99FFFFFF), width: 1.16),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            shadows: const [
                              BoxShadow(
                                color: Color(0x19000000),
                                blurRadius: 3,
                                offset: Offset(0, 1),
                                spreadRadius: 0,
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Sudah memiliki akun?",
                                style: GoogleFonts.instrumentSans(
                                  color: const Color(0xB2192D34),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Masuk",
                                style: GoogleFonts.instrumentSans(
                                  color: const Color(0xFF1A2E35),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.done,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.instrumentSans(
            color: const Color(0xFF1A2E35),
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.15,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          style: GoogleFonts.instrumentSans(color: const Color(0xFF1A2E35)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.instrumentSans(
              color: const Color(0x66192D34),
              fontSize: 16,
            ),
            prefixIcon: Icon(icon, color: const Color(0x99192D34), size: 20),
            filled: true,
            fillColor: const Color(0xCCFFFFFF),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
              const BorderSide(color: Color(0x334ADEDE), width: 1.16),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
              const BorderSide(color: Color(0x334ADEDE), width: 1.16),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
              const BorderSide(color: Color(0xFF4ADEDE), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPasswordTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isObscured,
    required VoidCallback onToggleVisibility,
    TextInputAction textInputAction = TextInputAction.done,
    String? helperText,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.instrumentSans(
            color: const Color(0xFF1A2E35),
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.15,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isObscured,
          textInputAction: textInputAction,
          style: GoogleFonts.instrumentSans(color: const Color(0xFF1A2E35)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.instrumentSans(
              color: const Color(0x66192D34),
              fontSize: 16,
            ),
            helperText: helperText,
            helperStyle: GoogleFonts.instrumentSans(color: const Color(0x99192D34)),
            errorText: errorText,
            errorStyle: GoogleFonts.instrumentSans(color: Colors.red.shade700),
            prefixIcon: const Icon(Icons.lock_outline_rounded,
                color: Color(0x99192D34), size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: const Color(0x99192D34),
              ),
              onPressed: onToggleVisibility,
            ),
            filled: true,
            fillColor: const Color(0xCCFFFFFF),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
              const BorderSide(color: Color(0x334ADEDE), width: 1.16),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
              const BorderSide(color: Color(0x334ADEDE), width: 1.16),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
              const BorderSide(color: Color(0xFF4ADEDE), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 2,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Colors.transparent,
            Color(0x331A2E35),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(38835400),
      ),
    );
  }
}