import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'services/database_service.dart'; // Import DatabaseService
import 'signin.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressCyan;
  late Animation<double> _progressGreen;
  late Animation<double> _progressFade;
  late AnimationController _dotOrbitController;
  late AnimationController _dotController;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp(); // Jalankan inisialisasi
  }

  void _setupAnimations() {
    _progressController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _progressCyan = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _progressController, curve: Curves.easeOut));
    _progressGreen = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _progressController, curve: const Interval(0.3, 1.0, curve: Curves.easeOut)));
    _progressFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _progressController, curve: const Interval(0.6, 1.0, curve: Curves.easeOut)));
    _dotController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
          ..repeat(reverse: true);
    _dotOrbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _progressController.forward();
    _startOrbitLoop();
  }

  Future<void> _initializeApp() async {
    // 1. Inisialisasi Database SQLite
    await DatabaseService.instance.init();

    // 2. Tunggu animasi splash screen selesai (opsional, tapi lebih smooth)
    await Future.delayed(const Duration(seconds: 3));

    // 3. Navigasi ke Halaman Sign-In
    if (mounted) { // Pastikan widget masih ada di tree
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const SignInScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation.drive(CurveTween(curve: Curves.easeIn)),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  Future<void> _startOrbitLoop() async {
    while (mounted) {
      await _dotOrbitController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _dotController.dispose();
    _dotOrbitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // GestureDetector dihapus, navigasi sekarang otomatis
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
            // ... (Kode UI lainnya tetap sama)
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
                  Stack(
                    clipBehavior: Clip.none,
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
                          border: Border.all(color: const Color(0x80FFFFFF), width: 1),
                          boxShadow: const [BoxShadow(color: Color(0x19000000), blurRadius: 15, offset: Offset(0, 4))],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Image.asset(
                              'assets/images/siren.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _dotOrbitController,
                          builder: (context, child) {
                            final RRect orbitRRect = RRect.fromRectAndRadius(
                              const Rect.fromLTWH(0, 0, 160, 160),
                              const Radius.circular(24),
                            );
                            final Path orbitPath = Path()..addRRect(orbitRRect);
                            final PathMetric pathMetric = orbitPath.computeMetrics().first;
                            final double pathLength = pathMetric.length;
                            final double limeDistance = _dotOrbitController.value * pathLength;
                            final Tangent? limeTangent = pathMetric.getTangentForOffset(limeDistance);
                            final Offset limePos = limeTangent?.position ?? Offset.zero;
                            final double cyanDistance = (_dotOrbitController.value + 0.5) % 1.0 * pathLength;
                            final Tangent? cyanTangent = pathMetric.getTangentForOffset(cyanDistance);
                            final Offset cyanPos = cyanTangent?.position ?? Offset.zero;
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(left: limePos.dx - 12, top: limePos.dy - 12, child: _decorativeDot(24, const Color(0xFFA3E42F))),
                                Positioned(left: cyanPos.dx - 8, top: cyanPos.dy - 8, child: _decorativeDot(16, const Color(0xFF4ADEDE))),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _animatedProgressBar(_progressCyan, 48, [const Color(0xFF4ADEDE), const Color(0x804ADEDE)]),
                      const SizedBox(width: 8),
                      _animatedProgressBar(_progressGreen, 32, [const Color(0xFFA3E42F), const Color(0x80A3E42F)]),
                      const SizedBox(width: 8),
                      _animatedProgressBar(_progressFade, 24, [const Color(0x804ADEDE), Colors.transparent]),
                    ],
                  ),
                  const SizedBox(height: 48),
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
                  SizedBox(
                    width: 290,
                    child: Text(
                      "Smart Integrated Report and Emergency Network",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.instrumentSans(
                        fontSize: 15,
                        color: const Color(0xB31A2E35),
                        fontWeight: FontWeight.normal,
                        letterSpacing: 0.3,
                      ),
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
    );
  }

  Widget _decorativeDot(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: const [BoxShadow(color: Color(0x19000000), blurRadius: 6, offset: Offset(0, 4))],
      ),
    );
  }

  Widget _animatedProgressBar(
      Animation<double> animation, double width, List<Color> colors) {
    return AnimatedBuilder(
        animation: animation,
        builder: (_, __) {
          final animationValue = animation.value.clamp(0.0, 1.0);
          return Container(
            width: width * animationValue,
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: LinearGradient(colors: colors),
            ),
          );
        });
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
