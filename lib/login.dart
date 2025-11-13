import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'signin.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
                            child: Image.network(
                              "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/aLLDYhj5gp/kk805w1s_expires_30_days.png",
                              fit: BoxFit.contain,
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
                        "Masuk",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.instrumentSans(
                          color: const Color(0xFF1A2E35),
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Silahkan masuk ke akun anda",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.instrumentSans(
                          color: const Color(0x99192D34),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(
                        label: "Alamat Email",
                        hint: "Masukkan email anda",
                        icon: Icons.alternate_email_rounded,
                      ),
                      _buildTextField(
                        label: "Kata Sandi",
                        hint: "Masukkan kata sandi anda",
                        icon: Icons.lock_outline_rounded,
                        obscureText: true,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // TODO: Handle forgot password
                          },
                          child: Text(
                            "Lupa kata sandi?",
                            style: GoogleFonts.instrumentSans(
                              color: const Color(0xFF1A2E35),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: InkWell(
                          onTap: () {
                            // TODO: Handle login logic (This button is correct)
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [Color(0xE5B3FFD5), Color(0xE528CFD8)],
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x19000000),
                                  blurRadius: 15,
                                  offset: Offset(0, 10),
                                  spreadRadius: -3,
                                ),
                              ],
                            ),
                            child: Text(
                              "MASUK",
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
                      ),
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
                                      const SignInScreen(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                // --- FIX: Changed to a smooth FadeTransition ---
                                return FadeTransition(
                                  opacity: animation
                                      .drive(CurveTween(curve: Curves.easeIn)),
                                  child: child,
                                );
                                // --- END OF FIX ---
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
                                "Belum memiliki akun?",
                                style: GoogleFonts.instrumentSans(
                                  color: const Color(0xB2192D34),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Buat akun",
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
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
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
          obscureText: obscureText,
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

  Widget _buildDivider() {
    return Container(
      height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            const Color(0x331A2E35),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(38835400),
      ),
    );
  }
}