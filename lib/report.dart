import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

import 'dashboard.dart';
import 'forum.dart';
import 'services/report_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ReportService _reportService = ReportService.instance;
  String? _selectedReportType;
  bool _isSubmitting = false;

  final List<String> _reportTypes = [
    'Banjir',
    'Kebakaran',
    'Kecelakaan',
    'Pohon Tumbang',
    'Jalan Rusak',
    'Lainnya',
  ];

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0EBF0),
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
            // --- BACKGROUND BLURS ---
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
                    decoration: const ShapeDecoration(
                      color: Color(0x331A2E35),
                      shape: OvalBorder(),
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
                    decoration: const ShapeDecoration(
                      color: Color(0x704ADEDE),
                      shape: OvalBorder(),
                    ),
                  ),
                ),
              ),
            ),

            // --- MAIN CONTENT ---
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20), // matches Dashboard & Forum
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildReportForm(),
                      const SizedBox(height: 120), // space above navbar
                    ],
                  ),
                ),
              ),
            ),

            // --- TWIN BOTTOM NAVBAR (ACTIVE = REPORTS, RIGHT) ---
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomNav(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 47,
              height: 47,
              decoration: ShapeDecoration(
                gradient: const LinearGradient(
                  begin: Alignment(0.50, 0.00),
                  end: Alignment(0.50, 1.00),
                  colors: [Color(0x4C4ADEDE), Color(0x5FA3E42F)],
                ),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1.16, color: Color(0xB2FFFFFF)),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
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
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SIREN',
                  style: GoogleFonts.orbitron(
                    color: const Color(0xFF1A2E35),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 4,
                  ),
                ),
                Text(
                  'Smart Integrated Report...',
                  style: GoogleFonts.instrumentSans(
                    color: const Color(0x99192D34),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Laman Laporan',
          style: GoogleFonts.instrumentSans(
            color: const Color(0xFF1A2E35),
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Laporkan langsung!',
          style: GoogleFonts.instrumentSans(
            color: const Color(0x99192D34),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildReportForm() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: ShapeDecoration(
        color: Colors.white.withValues(alpha: 0.70),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1.16,
            color: Colors.white.withValues(alpha: 0.80),
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 6,
            offset: Offset(0, 4),
            spreadRadius: 0,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: ShapeDecoration(
              color: Colors.white.withValues(alpha: 0.60),
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 1.16, color: Color(0x334ADEDE)),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedReportType,
                hint: Text(
                  'Pilih jenis laporan',
                  style: GoogleFonts.instrumentSans(
                    color: const Color(0xFF1A2E35),
                    fontSize: 14,
                  ),
                ),
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF1A2E35)),
                items: _reportTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(
                      type,
                      style: GoogleFonts.instrumentSans(
                        color: const Color(0xFF1A2E35),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedReportType = newValue;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _locationController,
            style: GoogleFonts.instrumentSans(
              color: const Color(0xFF1A2E35),
            ),
            decoration: InputDecoration(
              hintText: 'Lokasi lengkap',
              hintStyle: GoogleFonts.instrumentSans(
                color: const Color(0x99192D34),
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.60),
              prefixIcon: const Icon(
                Icons.location_on_outlined,
                color: Color(0x99192D34),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Deskripsi',
            style: GoogleFonts.instrumentSans(
              color: const Color(0x99192D34),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            maxLines: 5,
            style: GoogleFonts.instrumentSans(color: const Color(0xFF1A2E35)),
            decoration: InputDecoration(
              hintText: 'Jelaskan detail kejadian...',
              hintStyle: GoogleFonts.instrumentSans(
                color: const Color(0x66192D34),
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.60),
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
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              _buildMediaButton('Foto', Icons.camera_alt_outlined),
              const SizedBox(width: 8),
              _buildMediaButton('Video', Icons.videocam_outlined),
              const SizedBox(width: 8),
              _buildMediaButton('Audio', Icons.mic_none_outlined),
            ],
          ),
          const SizedBox(height: 24),

          InkWell(
            onTap: _isSubmitting ? null : _submitReport,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: ShapeDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFB3FFD5), Color(0xFF28CFD7)],
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                shadows: const [
                  BoxShadow(
                    color: Color(0x4C4ADEDE),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                    spreadRadius: -2,
                  )
                ],
              ),
              child: Center(
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Buat Laporan',
                        style: GoogleFonts.instrumentSans(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaButton(String label, IconData icon) {
    return Expanded(
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 52,
          decoration: ShapeDecoration(
            color: Colors.white.withValues(alpha: 0.60),
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1.16, color: Color(0x334ADEDE)),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFF1A2E35), size: 20),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.instrumentSans(
                  color: const Color(0xB2192D34),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- TWIN NAVBAR: ACTIVE = REPORTS (RIGHT SLOT) ---
  Widget _buildBottomNav() {
    const int activeIndex = 2; // 0=Forum, 1=Dashboard, 2=Reports

    return Container(
      width: double.infinity,
      height: 90,
      decoration: const BoxDecoration(
        color: Color(0xCCFFFFFF),
        border: Border(
          top: BorderSide(width: 1.16, color: Color(0x334ADEDE)),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, -4),
            spreadRadius: 0,
          )
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double slotWidth = constraints.maxWidth / 3;

          IconData activeIcon;
          switch (activeIndex) {
            case 0:
              activeIcon = Icons.forum_outlined;
              break;
            case 1:
              activeIcon = Icons.grid_view_outlined;
              break;
            case 2:
            default:
              activeIcon = Icons.assignment_outlined;
          }

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: slotWidth,
                    child: _buildBottomNavItem(
                      icon: Icons.forum_outlined,
                      label: 'Forum',
                      isActive: activeIndex == 0,
                      onTap: () {
                        if (activeIndex == 0) return;
                        Navigator.of(context).pushReplacement(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const ForumScreen(),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: slotWidth,
                    child: _buildBottomNavItem(
                      icon: Icons.grid_view_outlined,
                      label: 'Dashboard',
                      isActive: activeIndex == 1,
                      onTap: () {
                        if (activeIndex == 1) return;
                        Navigator.of(context).pushReplacement(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const DashboardScreen(),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: slotWidth,
                    child: _buildBottomNavItem(
                      icon: Icons.assignment_outlined,
                      label: 'Reports',
                      isActive: activeIndex == 2,
                      onTap: () {
                        // already here
                      },
                    ),
                  ),
                ],
              ),

              // Lime donut on active tab
              Positioned(
                top: -25,
                left: slotWidth * activeIndex + slotWidth / 2 - 30,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: const ShapeDecoration(
                    color: Color(0xCCFFFFFF),
                    shape: CircleBorder(),
                    shadows: [
                      BoxShadow(
                        color: Color(0x19000000),
                        blurRadius: 15,
                        offset: Offset(0, 10),
                        spreadRadius: -3,
                      )
                    ],
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(5),
                    decoration: const ShapeDecoration(
                      color: Color(0x89A3E42F),
                      shape: CircleBorder(),
                    ),
                    child: Icon(
                      activeIcon,
                      color: const Color(0xFF1A2E35),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final Color color =
        isActive ? const Color(0xFF1A2E35) : const Color(0x7F192D34);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.only(top: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: ShapeDecoration(
                color:
                    isActive ? const Color(0x11A3E42F) : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              // hide icon when active – donut draws it
              child: isActive
                  ? const SizedBox.shrink()
                  : Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 4),
            if (!isActive)
              Text(
                label,
                style: GoogleFonts.instrumentSans(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              )
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReport() async {
    if (_selectedReportType == null ||
        _locationController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lengkapi jenis laporan, lokasi, dan deskripsi terlebih dahulu.'),
        ),
      );
      return;
    }

    HapticFeedback.lightImpact();
    setState(() => _isSubmitting = true);

    try {
      await _reportService.createReport(
        reportType: _selectedReportType!,
        description: _descriptionController.text.trim(),
        locationText: _locationController.text.trim(),
        lat: null, // TODO: integrate dengan GPS jika perlu
        lng: null,
      );

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
        _selectedReportType = null;
      });
      _locationController.clear();
      _descriptionController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan berhasil dikirim. Responder menerima notifikasi tugas baru.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengirim laporan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
