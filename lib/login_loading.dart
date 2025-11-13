import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'choose.dart'; // Navigates to ChooseScreen

class LoginLoadingScreen extends StatefulWidget {
  const LoginLoadingScreen({super.key});

  @override
  State<LoginLoadingScreen> createState() => _LoginLoadingScreenState();
}

class _LoginLoadingScreenState extends State<LoginLoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _dotController;

  @override
  void initState() {
    super.initState();
    // Re-using the loading dot animation from splash.dart
    _dotController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  void _navigateToChooseScreen() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const ChooseScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation.drive(CurveTween(curve: Curves.easeIn)),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _navigateToChooseScreen, // Tap anywhere to continue
        child: Container(
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
              Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x664ADEDE), Color(0x66A3E42F)],
                        ),
                        border: Border.all(
                            color: const Color(0x80FFFFFF), width: 1),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x19000000),
                            blurRadius: 15,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Image.network(
                            "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/aLLDYhj5gp/kk805w1s_expires_30_days.png",
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      "SIREN",
                      style: GoogleFonts.orbitron(
                        fontSize: 32,
                        fontWeight: FontWeight.normal,
                        letterSpacing: 9.6,
                        color: const Color(0xFF1A2E35),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Sedang masuk ke akun anda...", // Loading text
                      textAlign: TextAlign.center,
                      style: GoogleFonts.instrumentSans(
                        fontSize: 15,
                        color: const Color(0xB31A2E35),
                        fontWeight: FontWeight.normal,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 48),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _loadingDot(0),
                        const SizedBox(width: 8),
                        _loadingDot(0.2),
                        const SizedBox(width: 8),
                        _loadingDot(0.4),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _loadingDot(double delay) {
    return AnimatedBuilder(
      animation: _dotController,
      builder: (_, __) {
        double t = (_dotController.value + delay) % 1.0;
        double scale = (t < 0.4)
            ? 1 + 0.2 * (t / 0.4)
            : (t < 0.8)
                ? 1.2 - 0.2 * ((t - 0.4) / 0.4)
                : 1;
        double opacity = (t < 0.4)
            ? 0.7 + 0.3 * (t / 0.4)
            : (t < 0.8)
                ? 1 - 0.3 * ((t - 0.4) / 0.4)
                : 0.7;
        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: 13,
              height: 13,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                    colors: [Color(0xFF4ADEDE), Color(0xFFA3E42F)]),
              ),
            ),
          ),
        );
      },
    );
  }
}