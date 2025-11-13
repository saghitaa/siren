import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

class WarningInfo {
  final String title;
  final String description;
  final String timeAgo;
  final String distance;
  final IconData icon;
  final Color iconBackgroundColor;
  final Color borderColor;

  WarningInfo({
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.distance,
    required this.icon,
    required this.iconBackgroundColor,
    required this.borderColor,
  });
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<WarningInfo> warnings = [];
  int _selectedBottomNavIndex = 1;

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
            Positioned(
              left: -48,
              top: 726,
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
            Positioned(
              left: -84,
              top: -169,
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
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
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
                    side:
                        const BorderSide(width: 1.16, color: Color(0xB2FFFFFF)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Image.network(
                      "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/aLLDYhj5gp/kk805w1s_expires_30_days.png",
                      fit: BoxFit.contain,
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
                decoration: ShapeDecoration(
                  color: const Color(0x99FFFFFF),
                  shape: const OvalBorder(
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
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
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
                side:
                    const BorderSide(width: 1.16, color: Color(0x4C4ADEDE)),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: const Icon(
                Icons.person_outline,
                size: 40,
                color: Color(0x99192D34),
              ),
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
                    side:
                        const BorderSide(width: 1.16, color: Color(0x4C4ADEDE)),
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
            // TODO: Handle Emergency Button Tap
            print("Tombol Darurat Ditekan!");
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
              '${warnings.length} Laporan',
              style: GoogleFonts.instrumentSans(
                color: const Color(0x99192D34),
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        warnings.isEmpty
            ? _buildEmptyWarningCard()
            : ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: warnings.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildWarningCard(warnings[index]);
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

  Widget _buildWarningCard(WarningInfo warning) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: ShapeDecoration(
        color: const Color(0xB2FFFFFF),
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1.16, color: warning.borderColor),
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
              color: warning.iconBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Icon(warning.icon, color: const Color(0xFF1A2E35), size: 20),
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
                      warning.title,
                      style: GoogleFonts.instrumentSans(
                        color: const Color(0xFF1A2E35),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      warning.timeAgo,
                      style: GoogleFonts.instrumentSans(
                        color: const Color(0x99192D34),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  warning.description,
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
                      warning.distance,
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
          title: 'Peta Laporan',
          icon: Icons.map_outlined,
          iconBgColor: const Color(0x33A3E42F),
          color: const Color(0xFF1A2E35),
          onTap: () {
            HapticFeedback.lightImpact();
            // TODO: Navigate to Peta Laporan
          },
        ),
        const SizedBox(height: 8),
        _buildMenuCard(
          title: 'Pengaturan',
          icon: Icons.settings_outlined,
          iconBgColor: const Color(0x334ADEDE),
          color: const Color(0xFF1A2E35),
          onTap: () {
            HapticFeedback.lightImpact();
            // TODO: Navigate to Pengaturan
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
            // TODO: Handle Logout
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

  Widget _buildBottomNav() {
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
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildBottomNavItem(
                icon: Icons.forum_outlined,
                label: 'Forum',
                isSelected: _selectedBottomNavIndex == 0,
                onTap: () => setState(() => _selectedBottomNavIndex = 0),
              ),
              const SizedBox(width: 50),
              _buildBottomNavItem(
                icon: Icons.assignment_outlined,
                label: 'Reports',
                isSelected: _selectedBottomNavIndex == 2,
                onTap: () => setState(() => _selectedBottomNavIndex = 2),
              ),
            ],
          ),
          Positioned(
            top: -25,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => setState(() => _selectedBottomNavIndex = 1),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: ShapeDecoration(
                    color: _selectedBottomNavIndex == 1
                        ? const Color(0xCCFFFFFF)
                        : const Color(0x99FFFFFF),
                    shape: const CircleBorder(),
                    shadows: const [
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
                    decoration: ShapeDecoration(
                      color: _selectedBottomNavIndex == 1
                          ? const Color(0x89A3E42F)
                          : Colors.transparent,
                      shape: const CircleBorder(),
                    ),
                    child: Icon(
                      Icons.grid_view_outlined,
                      color: _selectedBottomNavIndex == 1
                          ? const Color(0xFF1A2E35)
                          : const Color(0x7F192D34),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final Color color =
        isSelected ? const Color(0xFF1A2E35) : const Color(0x7F192D34);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.only(top: 12.0),
        width: 70,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: ShapeDecoration(
                color:
                    isSelected ? const Color(0x11A3E42F) : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.instrumentSans(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}