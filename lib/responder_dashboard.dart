import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'responder_profile.dart';
import 'splash.dart'; // GANTI ini kalau nama file splash kamu berbeda

class ResponderDashboardScreen extends StatefulWidget {
  const ResponderDashboardScreen({super.key});

  @override
  State<ResponderDashboardScreen> createState() =>
      _ResponderDashboardScreenState();
}

class _ResponderDashboardScreenState extends State<ResponderDashboardScreen> {
  // 0 = Forum, 1 = Dashboard (default)
  int _selectedIndex = 1;
  int _availabilityIndex = 0;

  final List<Map<String, dynamic>> _incidents = [
    {
      "title": "Kebakaran Rumah",
      "description": "Api membesar di rumah warga, butuh bantuan segera",
      "distance": "1.2 km",
      "time": "3m lalu",
      "severity": "Tinggi",
      "color": const Color(0xFFE7000B),
    },
    {
      "title": "Banjir Mendadak",
      "description": "Ketinggian air mencapai 50cm, warga memerlukan evakuasi",
      "distance": "2.8 km",
      "time": "8m lalu",
      "severity": "Tinggi",
      "color": const Color(0xFF007AFF),
    },
    {
      "title": "Kecelakaan Lalu Lintas",
      "description": "Tabrakan 2 kendaraan di persimpangan",
      "distance": "4.1 km",
      "time": "15m lalu",
      "severity": "Sedang",
      "color": const Color(0xFFFFB400),
    },
  ];

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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE0EBF0),
              Color(0xFFF0F9FF),
              Color(0xFFE8F8F5),
            ],
          ),
        ),
        child: Stack(
          children: [
            _backgroundBlurLikeOthers(),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _headerCard(context),
                    const SizedBox(height: 20),
                    _availabilityCard(),
                    const SizedBox(height: 20),
                    _quickActionsSection(),
                    const SizedBox(height: 20),
                    _menuSection(), // <── MENU BARU
                    const SizedBox(height: 20),
                    _incidentHeader(),
                    const SizedBox(height: 12),
                    ..._incidents
                        .map(
                          (data) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _incidentCard(data),
                          ),
                        )
                        .toList(),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _bottomNav(),
    );
  }

  // ───────────────── BACKGROUND BLUR
  Widget _backgroundBlurLikeOthers() {
    return Stack(
      children: [
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
                decoration: BoxDecoration(
                  color: const Color(0x704ADEDE),
                  borderRadius: BorderRadius.circular(38835400),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: -48,
          bottom: -60,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
            child: Opacity(
              opacity: 0.59,
              child: Container(
                width: 493,
                height: 367,
                decoration: BoxDecoration(
                  color: const Color(0x331A2E35),
                  borderRadius: BorderRadius.circular(38835400),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ───────────────── HEADER CARD
  Widget _headerCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: ShapeDecoration(
        color: Colors.white.withOpacity(0.96),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 18,
            offset: Offset(0, 10),
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
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
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
                  child: Image.network(
                    "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/aLLDYhj5gp/kk805w1s_expires_30_days.png",
                    fit: BoxFit.contain,
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
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
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
                              color: const Color(0xFFE7F8EC),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
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

  // ───────────────── AVAILABILITY
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
        color: Colors.white.withOpacity(0.96),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 6),
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
                        : Colors.white.withOpacity(0.95),
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

  // ───────────────── QUICK ACTIONS (boxed)
  Widget _quickActionsSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: ShapeDecoration(
        color: Colors.white.withOpacity(0.96),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aksi Cepat',
            style: GoogleFonts.instrumentSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1A2E35),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _quickActionCard(
                icon: Icons.map_outlined,
                title: 'Peta Laporan',
                onTap: () => _showSnack('Buka peta laporan responder.'),
              ),
              const SizedBox(width: 10),
              _quickActionCard(
                icon: Icons.history_rounded,
                title: 'Riwayat',
                onTap: () => _showSnack('Buka riwayat tanggapan.'),
              ),
              const SizedBox(width: 10),
              _quickActionCard(
                icon: Icons.group_outlined,
                title: 'Tim',
                onTap: () => _showSnack('Buka tim responder.'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: ShapeDecoration(
            color: const Color(0xF9FFFFFF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(
                width: 1.1,
                color: Color(0x264ADEDE),
              ),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F8F5),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Icon(icon,
                    size: 18, color: const Color(0xFF1A2E35)),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.instrumentSans(
                  fontSize: 11,
                  color: const Color(0xFF1A2E35),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────── MENU (PENGATURAN & KELUAR)
  Widget _menuSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: ShapeDecoration(
        color: Colors.white.withOpacity(0.96),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 6),
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
            onTap: () => _showSnack('Pengaturan responder akan ditambahkan.'),
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
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: const Color(0xF9FFFFFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(
              width: 1.1,
              color: Color(0x264ADEDE),
            ),
          ),
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

  // ───────────────── INCIDENTS
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
          '${_incidents.length} Laporan',
          style: GoogleFonts.instrumentSans(
            fontSize: 11,
            color: const Color(0x99192D34),
          ),
        ),
      ],
    );
  }

  Widget _incidentCard(Map<String, dynamic> data) {
    final Color accent = data["color"] as Color;
    final String severity = data["severity"] as String;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            width: 1.1,
            color: accent.withOpacity(0.3),
          ),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_fire_department_rounded,
                  size: 18, color: accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  data["title"] as String,
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
                  color: accent.withOpacity(0.12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: Text(
                  severity,
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
            data["description"] as String,
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
                data["distance"] as String,
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
                data["time"] as String,
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
                onTap: () => _showSnack('Membuka navigasi...'),
              ),
              const SizedBox(width: 8),
              _incidentActionButton(
                icon: Icons.play_arrow_rounded,
                label: 'Terima',
                textColor: Colors.white,
                borderColor: accent,
                fillColor: accent,
                onTap: () => _showSnack('Laporan diterima.'),
              ),
            ],
          ),
        ],
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

  // ───────────────── BOTTOM NAV (2 icons, donut sits over active one)
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
              _showSnack('Forum responder akan hadir di sini.');
            },
          ),
          _navItem(
            icon: Icons.grid_view_outlined,
            label: 'Dashboard',
            index: 1,
            onTap: () {
              // Already here
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
      // Donut style active
      return GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
          onTap();
        },
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
                  icon,
                  color: const Color(0xFF1A2E35),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Inactive
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        onTap();
      },
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
