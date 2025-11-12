import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

void main() => runApp(const SplashScreenApp());

class SplashScreenApp extends StatelessWidget {
  const SplashScreenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

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

  late AnimationController _dotController;

  @override
  void initState() {
    super.initState();

    // Progress bar animations
    _progressController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _progressCyan = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _progressController, curve: Curves.easeOut));
    _progressGreen = Tween<double>(begin: 0.5, end: 1.5).animate(
        CurvedAnimation(
            parent: _progressController,
            curve: const Interval(0.3, 1.0, curve: Curves.easeOut)));
    _progressFade = Tween<double>(begin: 1, end: 2).animate(
        CurvedAnimation(
            parent: _progressController,
            curve: const Interval(0.6, 1.0, curve: Curves.easeOut)));

    _progressController.forward();

    // Loading dots animation
    _dotController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _progressController.dispose();
    _dotController.dispose();
    super.dispose();
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
            // Background blurred circle
            Positioned(
              top: -132,
              left: 76,
              child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(
                width: 420,
                height: 420,
                decoration:const BoxDecoration(
                  color: Color.fromRGBO(0, 255, 255, 0.075), 
                  shape: BoxShape.circle,
                ),
              ),
            ),
            ),

            // Main content
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo card
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
                          child: Image.network(
                            "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/aLLDYhj5gp/kk805w1s_expires_30_days.png",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // Decorative dots
                      Positioned(top: -6, right: 0, child: _decorativeDot(24, const Color(0xFFA3E42F))),
                      Positioned(bottom: -6, left: 0, child: _decorativeDot(16, const Color(0xFF4ADEDE))),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Animated progress bars
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

                  // App title using GoogleFonts Orbitron
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

                  // App description using GoogleFonts Instrument Sans
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

                  // Loading dots
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

  Widget _animatedProgressBar(Animation<double> animation, double width, List<Color> colors) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) => Container(
        width: width * animation.value,
        height: 6,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: LinearGradient(colors: colors),
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
                gradient: LinearGradient(colors: [Color(0xFF4ADEDE), Color(0xFFA3E42F)]),
              ),
            ),
          ),
        );
      },
    ); 
  }
}
