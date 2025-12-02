import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

import 'forum.dart';
import 'models/report_model.dart';
import 'responder_profile.dart';
import 'services/report_service.dart';
import 'services/fcm_service.dart';
import 'settings.dart';
import 'splash.dart';


class ResponderDashboardScreen extends StatefulWidget {
  const ResponderDashboardScreen({super.key});

  @override
  State<ResponderDashboardScreen> createState() =>
      _ResponderDashboardScreenState();
}

class _ResponderDashboardScreenState extends State<ResponderDashboardScreen> {
  int _selectedIndex = 1; // 0 = Forum, 1 = Dashboard
  int _availabilityIndex = 0;
  bool _loadingReports = true;
  int _lastReportCount = 0;
  List<Report> _reports = [];
  final ReportService _reportService = ReportService.instance;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  void _loadReports() {
    _reportService.getAllReports().listen((reports) {
      if (!mounted) return;

      final newCount = reports.length;
      if (newCount > _lastReportCount && _lastReportCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ada laporan baru untuk responder. Segera cek!'),
          ),
        );
      }

      setState(() {
        _reports = reports;
        _loadingReports = false;
        _lastReportCount = newCount;
      });
    });
  }

  String _formatTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} m lalu';
    if (diff.inHours < 24) return '${diff.inHours} j lalu';
    return '${diff.inDays} h lalu';
  }

  Color _accentColor(String jenis) {
    switch (jenis.toLowerCase()) {
      case 'sos':
        return const Color(0xFFE7000B);
      case 'banjir':
        return const Color(0xFF007AFF);
      case 'kebakaran':
        return const Color(0xFFFF7043);
      default:
        return const Color(0xFF28CFD7);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
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
            SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  // Reload reports
                  _lastReportCount = 0;
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // 1. PROFILE CARD
                      _headerCard(context),
                      const SizedBox(height: 20),

                      // 2. LAPORAN DARURAT
                      _incidentHeader(),
                      const SizedBox(height: 12),
                      if (_loadingReports)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (_reports.isEmpty)
                        _buildEmptyIncidentCard()
                      else
                        ..._reports.map(
                          (report) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _incidentCard(report),
                          ),
                        ),
                      const SizedBox(height: 20),

                      // 3. AVAILABILITY STATUS
                      _availabilityCard(),
                      const SizedBox(height: 20),

                      // 4. MENU (LAST)
                      _menuSection(),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _bottomNav(),
    );
  }

  Widget _headerCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: ShapeDecoration(
        color: const Color(0xB2FFFFFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(width: 1.16, color: Color(0xCCFFFFFF)),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: ShapeDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment(0.50, 0.00),
                    end: Alignment(0.50, 1.00),
                    colors: [Color(0x4C4ADEDE), Color(0x5FA3E42F)],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(
                      width: 1.16,
                      color: Color(0xB2FFFFFF),
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Image.asset(
                    'assets/images/siren.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.warning, color: Colors.orange);
                    },
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
                    'Smart Integrated Report and Emergency',
                    style: GoogleFonts.instrumentSans(
                      color: const Color(0x99192D34),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                width: 34,
                height: 34,
                decoration: const ShapeDecoration(
                  color: Color(0x99FFFFFF),
                  shape: OvalBorder(
                    side: BorderSide(width: 1.16, color: Color(0x334ADEDE)),
                  ),
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  size: 18,
                  color: Color(0xFF1A2E35),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ResponderProfileScreen(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage("https://placehold.co/118x118"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2ECC71),
                            shape: BoxShape.circle,
                            border: Border.fromBorderSide(
                              BorderSide(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Christopher Bang',
                        style: GoogleFonts.instrumentSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1A2E35),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
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
                            child: Row(
                              children: [
                                const Icon(Icons.shield_outlined,
                                    size: 14, color: Color(0xFF1A2E35)),
                                const SizedBox(width: 6),
                                Text(
                                  'Polisi',
                                  style: GoogleFonts.instrumentSans(
                                    fontSize: 12,
                                    color: const Color(0xFF1A2E35),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.location_on_outlined,
                              size: 14, color: Color(0x99192D34)),
                          const SizedBox(width: 4),
                          Text(
                            'Gunungpati, Kota Semarang',
                            style: GoogleFonts.instrumentSans(
                              fontSize: 11,
                              color: const Color(0x99192D34),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _availabilityCard() {
    final List<String> labels = [
      'Tersedia',
      'Bertugas',
      'Menanggapi',
      'Tidak Tersedia',
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: ShapeDecoration(
        color: const Color(0xB2FFFFFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(width: 1.16, color: Color(0x4C4ADEDE)),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status Ketersediaan',
            style: GoogleFonts.instrumentSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1A2E35),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(labels.length, (index) {
              final bool active = _availabilityIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _availabilityIndex = index;
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: ShapeDecoration(
                    color: active
                        ? const Color(0xFF28CFD7)
                        : Colors.white.withValues(alpha: 0.95),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                      side: BorderSide(
                        color: active
                            ? Colors.transparent
                            : const Color(0xFFE0EBF0),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Text(
                    labels[index],
                    style: GoogleFonts.instrumentSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: active ? Colors.white : const Color(0xFF1A2E35),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _menuSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: ShapeDecoration(
        color: const Color(0xB2FFFFFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(width: 1.16, color: Color(0x4C4ADEDE)),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Menu',
            style: GoogleFonts.instrumentSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1A2E35),
            ),
          ),
          const SizedBox(height: 12),
          _menuCard(
            icon: Icons.settings_outlined,
            title: 'Pengaturan',
            color: const Color(0xFF1A2E35),
            iconBg: const Color(0x334ADEDE),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          _menuCard(
            icon: Icons.logout_rounded,
            title: 'Keluar',
            color: const Color(0xFFE7000B),
            iconBg: const Color(0x19E7000B),
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const SplashScreen(),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _menuCard({
    required IconData icon,
    required String title,
    required Color color,
    required Color iconBg,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(17),
        decoration: ShapeDecoration(
          color: const Color(0x99FFFFFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(
              width: 1.16,
              color: Color(0x264ADEDE),
            ),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.instrumentSans(
                  fontSize: 14,
                  color: color,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: Color(0xFF1A2E35)),
          ],
        ),
      ),
    );
  }

  Widget _incidentHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Laporan Darurat Aktif',
          style: GoogleFonts.instrumentSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1A2E35),
          ),
        ),
        Text(
          '${_reports.length} Laporan',
          style: GoogleFonts.instrumentSans(
            fontSize: 11,
            color: const Color(0x99192D34),
          ),
        ),
      ],
    );
  }

  Widget _incidentCard(Report report) {
    final Color accent = _accentColor(report.type);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: const Color(0xB2FFFFFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            width: 1.16,
            color: accent.withValues(alpha: 0.4),
          ),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                report.type == 'SOS'
                    ? Icons.sos_rounded
                    : Icons.local_fire_department_rounded,
                size: 18,
                color: accent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  report.reportType ?? report.type,
                  style: GoogleFonts.instrumentSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A2E35),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: ShapeDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: Text(
                  report.type,
                  style: GoogleFonts.instrumentSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            report.description,
            style: GoogleFonts.instrumentSans(
              fontSize: 12,
              color: const Color(0xB2192D34),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.place_outlined,
                  size: 13, color: Color(0x99192D34)),
              const SizedBox(width: 4),
              Text(
                report.lat != null && report.lng != null 
                    ? '${report.lat}, ${report.lng}'
                    : 'Lokasi tidak disebutkan',
                style: GoogleFonts.instrumentSans(
                  fontSize: 11,
                  color: const Color(0x99192D34),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.access_time_rounded,
                  size: 13, color: Color(0x99192D34)),
              const SizedBox(width: 4),
              Text(
                _formatTime(report.createdAt),
                style: GoogleFonts.instrumentSans(
                  fontSize: 11,
                  color: const Color(0x99192D34),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _incidentActionButton(
                icon: Icons.phone_in_talk_rounded,
                label: 'Hubungi',
                textColor: const Color(0xFF1A2E35),
                borderColor: const Color(0xFF28CFD7),
                onTap: () => _showSnack('Menghubungi pelapor...'),
              ),
              const SizedBox(width: 8),
              _incidentActionButton(
                icon: Icons.navigation_rounded,
                label: 'Navigasi',
                textColor: const Color(0xFF1A2E35),
                borderColor: const Color(0xFF28CFD7),
                onTap: () => _showSnack(
                    report.lat != null && report.lng != null 
                        ? 'Membuka navigasi ke ${report.lat}, ${report.lng}'
                        : 'Lokasi tidak tersedia'),
              ),
              const SizedBox(width: 8),
              _incidentActionButton(
                icon: Icons.play_arrow_rounded,
                label: 'Terima',
                textColor: Colors.white,
                borderColor: accent,
                fillColor: accent,
                onTap: () => _showSnack(
                    'Laporan "${report.reportType ?? report.type}" ditandai sebagai diterima.'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyIncidentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: ShapeDecoration(
        color: const Color(0xB2FFFFFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(width: 1.16, color: Color(0x4C4ADEDE)),
        ),
      ),
      child: Center(
        child: Text(
          'Belum ada laporan masuk.\nTarik ke bawah untuk memuat ulang.',
          textAlign: TextAlign.center,
          style: GoogleFonts.instrumentSans(
            color: const Color(0x99192D34),
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _incidentActionButton({
    required IconData icon,
    required String label,
    required Color textColor,
    required Color borderColor,
    Color? fillColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Ink(
          height: 36,
          decoration: ShapeDecoration(
            color: fillColor ?? Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
              side: BorderSide(color: borderColor, width: 1.2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: textColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.instrumentSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────── BOTTOM NAV (Responder: Forum + Dashboard)
Widget _bottomNav() {
  return Container(
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
        )
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _navItem(
          icon: Icons.forum_outlined,
          label: 'Forum',
          index: 0,
          onTap: () {
            setState(() {
              _selectedIndex = 0;
            });
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (_, animation, __) =>
                    const ForumScreen(isResponder: true),
                transitionsBuilder: (_, animation, __, child) =>
                    FadeTransition(opacity: animation, child: child),
              ),
            );
          },
        ),
        _navItem(
          icon: Icons.grid_view_outlined,
          label: 'Dashboard',
          index: 1,
          onTap: () {
            // already here, no navigation
            setState(() {
              _selectedIndex = 1;
            });
          },
        ),
      ],
    ),
  );
}

Widget _navItem({
  required IconData icon,
  required String label,
  required int index,
  required VoidCallback onTap,
}) {
  final bool active = _selectedIndex == index;

  if (active) {
    // donut style for the active item
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
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
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(5),
              decoration: const ShapeDecoration(
                color: Color(0x89A3E42F),
                shape: CircleBorder(),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF1A2E35),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // inactive item
  return InkWell(
    borderRadius: BorderRadius.circular(14),
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.only(top: 12),
      width: 70,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: ShapeDecoration(
              color: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Icon(
              icon,
              size: 24,
              color: const Color(0x7F192D34),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.instrumentSans(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: const Color(0x7F192D34),
            ),
          ),
        ],
      ),
    ),
  );
}
}