import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

import 'forum.dart';
import 'models/report_model.dart';
import 'profile.dart';
import 'report.dart';
import 'services/database_service.dart';
import 'services/sos_service.dart';
import 'settings.dart';
import 'splash.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _loadingReports = true;
  List<Report> _reports = [];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    final data = await DatabaseService.instance.getAllReports();
    if (!mounted) return;
    setState(() {
      _reports = data;
      _loadingReports = false;
    });
  }

  String _formatTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} m lalu';
    if (diff.inHours < 24) return '${diff.inHours} j lalu';
    return '${diff.inDays} h lalu';
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
                        borderRadius: BorderRadius.circular(38835400),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // --- MAIN CONTENT (SAFEAREA + MATCHED HEADER SPACING) ---
            SafeArea(
              child: RefreshIndicator(
                onRefresh: _loadReports,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20), // matches ForumScreen
                        _buildAppBarContent(),
                        const SizedBox(height: 24),
                        _buildProfileHeader(),
                        const SizedBox(height: 24),
                        _buildEmergencyButton(),
                        const SizedBox(height: 24),
                        _buildWarningSection(),
                        const SizedBox(height: 24),
                        _buildMenuSection(),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // --- BOTTOM NAV (TWIN) ---
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

  Widget _buildAppBarContent() {
    // Same layout as ForumScreen for seamless header alignment
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const ShapeDecoration(
                color: Color(0x99FFFFFF),
                shape: OvalBorder(
                  side: BorderSide(width: 1.16, color: Color(0x334ADEDE)),
                ),
              ),
              child: const Icon(Icons.notifications_none_outlined,
                  color: Color(0xFF1A2E35), size: 22),
            ),
            Positioned(
              right: -3,
              top: -3,
              child: Container(
                width: 16,
                height: 16,
                decoration: const ShapeDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(0.50, 0.00),
                    end: Alignment(0.50, 1.00),
                    colors: [Color(0xFF4ADEDE), Color(0xFFA3E42F)],
                  ),
                  shape: OvalBorder(
                    side: BorderSide(width: 1.16, color: Colors.white),
                  ),
                ),
                child: Center(
                  child: Text(
                    '3',
                    style: GoogleFonts.instrumentSans(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const ProfileScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(17),
        decoration: ShapeDecoration(
          color: const Color(0xB2FFFFFF),
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1.16, color: Color(0xCCFFFFFF)),
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
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: ShapeDecoration(
                color: const Color(0xFFE0EBF0),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1.16, color: Color(0x4C4ADEDE)),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Icon(
                Icons.person_outline,
                size: 40,
                color: Color(0x99192D34),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nama Pengguna',
                  style: GoogleFonts.instrumentSans(
                    color: const Color(0xFF1A2E35),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: ShapeDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment(0.50, 0.00),
                      end: Alignment(0.50, 1.00),
                      colors: [Color(0x334ADEDE), Color(0x33A3E42F)],
                    ),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                          width: 1.16, color: Color(0x4C4ADEDE)),
                      borderRadius: BorderRadius.circular(38835400),
                    ),
                  ),
                  child: Text(
                    'Warga',
                    style: GoogleFonts.instrumentSans(
                      color: const Color(0xFF1A2E35),
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        color: Color(0x99192D34), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Gunungpati, Kota Semarang',
                      style: GoogleFonts.instrumentSans(
                        color: const Color(0x99192D34),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tombol Darurat',
          style: GoogleFonts.instrumentSans(
            color: const Color(0xFF1A2E35),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            // Panggil layanan SOS ketika tombol darurat ditekan.
            SOSService.instance.sendSOS(
              context: context,
              locationText: 'Lokasi tidak spesifik (contoh).',
            );
          },
          child: Container(
            width: double.infinity,
            height: 100,
            decoration: ShapeDecoration(
              color: const Color(0xFFE7000B),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: ShapeDecoration(
                    color: const Color(0x33FFFFFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Icon(Icons.sos_rounded,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  'Laporkan Keadaan Darurat!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.instrumentSans(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWarningSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Peringatan',
              style: GoogleFonts.instrumentSans(
                color: const Color(0xFF1A2E35),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${_reports.length} Laporan',
              style: GoogleFonts.instrumentSans(
                color: const Color(0x99192D34),
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_loadingReports)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_reports.isEmpty)
          _buildEmptyWarningCard()
        else
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _reports.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildReportCard(_reports[index]);
            },
          ),
      ],
    );
  }

  Widget _buildEmptyWarningCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: ShapeDecoration(
        color: const Color(0xB2FFFFFF),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1.16, color: Color(0x4CFFB400)),
          borderRadius: BorderRadius.circular(16),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 4,
            offset: Offset(0, 2),
            spreadRadius: 0,
          )
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            "Tidak ada peringatan terkini",
            style: GoogleFonts.instrumentSans(
              color: const Color(0xB2192D34),
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard(Report report) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: ShapeDecoration(
        color: const Color(0xB2FFFFFF),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1.16,
            color: report.type == 'SOS'
                ? const Color(0xFFE7000B)
                : const Color(0x4C4ADEDE),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 4,
            offset: Offset(0, 2),
            spreadRadius: 0,
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: ShapeDecoration(
              color: report.type == 'SOS'
                  ? const Color(0x19E7000B)
                  : const Color(0x33A3E42F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Icon(
              report.jenis == 'SOS'
                  ? Icons.sos_rounded
                  : Icons.warning_amber_rounded,
              color: const Color(0xFF1A2E35),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      report.reportType ?? report.type,
                      style: GoogleFonts.instrumentSans(
                        color: const Color(0xFF1A2E35),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _formatTime(report.createdAt),
                      style: GoogleFonts.instrumentSans(
                        color: const Color(0x99192D34),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  report.description,
                  style: GoogleFonts.instrumentSans(
                    color: const Color(0xB2192D34),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        color: Color(0x99192D34), size: 12),
                    const SizedBox(width: 4),
                    Text(
                      report.lat != null && report.lng != null 
                          ? '${report.lat}, ${report.lng}'
                          : 'Lokasi tidak disebutkan',
                      style: GoogleFonts.instrumentSans(
                        color: const Color(0x99192D34),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Menu',
          style: GoogleFonts.instrumentSans(
            color: const Color(0xFF1A2E35),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
      _buildMenuCard(
        title: 'Pengaturan',
        icon: Icons.settings_outlined,
        iconBgColor: const Color(0x334ADEDE), 
        color: const Color(0xFF1A2E35),
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const SettingsScreen(),
            ),
          );
        },
      ),
        const SizedBox(height: 8),
        _buildMenuCard(
          title: 'Keluar',
          icon: Icons.logout_outlined,
          iconBgColor: const Color(0x33FF6464),
          color: const Color(0xFFE7000B),
          onTap: () {
            HapticFeedback.lightImpact();
            // ⬇️ Logout: balik ke splash & bersihin semua route
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => const SplashScreen(),
              ),
              (route) => false,
            );
          },
        ),
      ],
    );
  }

  Widget _buildMenuCard({
    required String title,
    required IconData icon,
    required Color iconBgColor,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        width: double.infinity,
        padding: const EdgeInsets.all(17),
        decoration: ShapeDecoration(
          color: const Color(0x99FFFFFF),
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1.16, color: Color(0x264ADEDE)),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: ShapeDecoration(
                    color: iconBgColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.instrumentSans(
                    color: color,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Color(0xFF1A2E35), size: 16),
          ],
        ),
      ),
    );
  }

  // --- TWIN BOTTOM NAV: ACTIVE = DASHBOARD (CENTER) ---
  Widget _buildBottomNav() {
    const int activeIndex = 1; // 0=Forum, 1=Dashboard, 2=Reports

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
              activeIcon = Icons.assignment_outlined;
              break;
            default:
              activeIcon = Icons.grid_view_outlined;
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
                        // Already here
                      },
                    ),
                  ),
                  SizedBox(
                    width: slotWidth,
                    child: _buildBottomNavItem(
                      icon: Icons.assignment_outlined,
                      label: 'Laporan',
                      isActive: activeIndex == 2,
                      onTap: () {
                        if (activeIndex == 2) return;
                        Navigator.of(context).pushReplacement(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const ReportScreen(),
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
                ],
              ),

              // Active lime donut
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
              child: isActive
                  ? const SizedBox.shrink() //
                  : Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 4),
            // Hide label visually when active so the donut has no text under it
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
              const SizedBox(height: 0),
          ],
        ),
      ),
    );
  }
}
