import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

import 'forum.dart';
import 'models/report_model.dart';
import 'responder_profile.dart';
import 'services/report_service.dart';
import 'services/fcm_service.dart';
import 'services/auth_service.dart'; // Import AuthService
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
  List<Report> _reports = [];
  final ReportService _reportService = ReportService.instance;

  // Cache data user agar tidak panggil AuthService terus
  late String _displayName;
  late String _role;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadReports();
  }

  void _loadUserData() {
    final user = AuthService.instance.currentUser;
    _displayName = user?.displayName ?? 'Petugas'; // Fallback jika null
    _role = user?.role ?? 'Responder';
  }

  Future<void> _loadReports() async {
    setState(() => _loadingReports = true);
    try {
      final reports = await _reportService.getAllReports();
      if (!mounted) return;

      setState(() {
        _reports = reports;
        _loadingReports = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingReports = false);
    }
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
                onRefresh: _loadReports,
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
                          color: Colors.grey[200], // Placeholder color
                          child: const Icon(Icons.person, size: 30, color: Colors.grey),
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
                      // --- DYNAMIC NAME ---
                      Text(
                        _displayName, // Menggunakan data dari AuthService
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
                                // --- DYNAMIC ROLE ---
                                Text(
                                  _role, // Menggunakan data dari AuthService
                                  style: GoogleFonts.instrumentSans(
                                    fontSize: 12,
                                    color: const Color(0xFF1A2E35),
                                  ),
                                ),
                              ],
                            ),
                          )
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

  Widget _incidentHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Incident Live Feed',
          style: GoogleFonts.orbitron(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A2E35),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: ShapeDecoration(
            color: const Color(0xFFE7000B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(38835400),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
              Text(
                'LIVE',
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyIncidentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xB2FFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(width: 1.16, color: const Color(0xCCFFFFFF)),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle_outline,
              size: 48, color: Color(0xFF2ECC71)),
          const SizedBox(height: 12),
          Text(
            'Semua Aman',
            style: GoogleFonts.orbitron(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A2E35),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tidak ada laporan darurat aktif saat ini.',
            textAlign: TextAlign.center,
            style: GoogleFonts.instrumentSans(
              fontSize: 14,
              color: const Color(0x991A2E35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _incidentCard(Report report) {
    final color = _accentColor(report.jenis);
    final isSOS = report.type == 'SOS';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: const Color(0xB2FFFFFF),
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1.16, color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Tag + Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: ShapeDecoration(
                  color: color.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(38835400),
                  ),
                ),
                child: Text(
                  isSOS ? 'SOS ALERT' : report.jenis.toUpperCase(),
                  style: GoogleFonts.orbitron(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
              Text(
                _formatTime(report.createdAt),
                style: GoogleFonts.instrumentSans(
                  fontSize: 12,
                  color: const Color(0x991A2E35),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Title & Desc
          Text(
            report.reportType ?? (isSOS ? 'SOS Darurat' : 'Laporan'),
            style: GoogleFonts.instrumentSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A2E35),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            report.description,
            style: GoogleFonts.instrumentSans(
              fontSize: 14,
              color: const Color(0xB21A2E35),
            ),
          ),
          const SizedBox(height: 12),

          // Location snippet (optional)
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  report.lat != null ? '${report.lat}, ${report.lng}' : 'Lokasi tidak tersedia',
                  style: GoogleFonts.instrumentSans(
                    fontSize: 12,
                    color: const Color(0xFF1A2E35),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                // Acknowledge logic
                await FCMService.instance.acknowledgeReport(
                  reportId: report.id ?? '',
                  responderId: 'current_responder',
                  responderName: _displayName, // Use dynamic name
                );
                _showSnack('Laporan diterima. Segera menuju lokasi.');
                _loadReports(); // Refresh UI
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'TERIMA & TANGGAPI',
                style: GoogleFonts.orbitron(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _availabilityCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: const Color(0xB2FFFFFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(width: 1.16, color: Color(0xCCFFFFFF)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set Availability',
            style: GoogleFonts.orbitron(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A2E35),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: ShapeDecoration(
              color: const Color(0x0C1A2E35),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _availabilityIndex = 0);
                    },
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: _availabilityIndex == 0
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: _availabilityIndex == 0
                            ? [
                                const BoxShadow(
                                  color: Color(0x0C000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                )
                              ]
                            : [],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Online',
                        style: GoogleFonts.instrumentSans(
                          fontSize: 14,
                          fontWeight: _availabilityIndex == 0
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: _availabilityIndex == 0
                              ? const Color(0xFF2ECC71)
                              : const Color(0xFF1A2E35),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _availabilityIndex = 1);
                    },
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: _availabilityIndex == 1
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: _availabilityIndex == 1
                            ? [
                                const BoxShadow(
                                  color: Color(0x0C000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                )
                              ]
                            : [],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Offline',
                        style: GoogleFonts.instrumentSans(
                          fontSize: 14,
                          fontWeight: _availabilityIndex == 1
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: _availabilityIndex == 1
                              ? const Color(0xFFE74C3C)
                              : const Color(0xFF1A2E35),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _menuTile(Icons.history, 'Riwayat')),
            const SizedBox(width: 12),
            Expanded(child: _menuTile(Icons.group_outlined, 'Tim')),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _menuTile(Icons.map_outlined, 'Peta Area')),
            const SizedBox(width: 12),
            Expanded(child: _menuTile(Icons.settings_outlined, 'Pengaturan')),
          ],
        ),
      ],
    );
  }

  Widget _menuTile(IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        if (label == 'Pengaturan') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: ShapeDecoration(
          color: const Color(0xB2FFFFFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(width: 1.16, color: Color(0xCCFFFFFF)),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF1A2E35), size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.instrumentSans(
                fontSize: 14,
                color: const Color(0xFF1A2E35),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomNav() {
    return Container(
      height: 84,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0EBF0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.forum_outlined, "Forum", 0),
          _navItem(Icons.dashboard_rounded, "Dashboard", 1),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 0) {
          // Navigate to Forum
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const ForumScreen(isResponder: true), // Pass isResponder
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected
                ? const Color(0xFF1A2E35)
                : const Color(0xFF1A2E35).withOpacity(0.4),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.instrumentSans(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? const Color(0xFF1A2E35)
                  : const Color(0xFF1A2E35).withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}
