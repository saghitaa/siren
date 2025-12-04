import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart'; // Import Wajib

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // --- STATE DATA ---
  bool _isEmergencyNotifEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences(); // Load data saat halaman dibuka
  }

  // 1. Fungsi Memuat Data Tersimpan
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isEmergencyNotifEnabled = prefs.getBool('notif_darurat') ?? true;
      _isLoading = false;
    });
  }

  // 2. Fungsi Menyimpan Data
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_darurat', _isEmergencyNotifEnabled);

    if (!mounted) return;

    // Feedback visual
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Pengaturan berhasil disimpan!"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );

    // Tunggu sebentar lalu tutup halaman
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFE0EBF0),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE0EBF0),
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
            // --- BACKGROUND DECORATION ---
            Positioned(
              left: 91.99, top: -72.96,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Opacity(
                  opacity: 0.59,
                  child: Container(
                    width: 420.76, height: 420.76,
                    decoration: const ShapeDecoration(
                      gradient: LinearGradient(begin: Alignment(0.00, 0.00), end: Alignment(1.00, 1.00), colors: [Color(0xFF4ADEDE), Color(0xFFA3E42F)]),
                      shape: OvalBorder(),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: -119.99, top: 602.08,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Opacity(
                  opacity: 0.40,
                  child: Container(
                    width: 349.98, height: 349.98,
                    decoration: const ShapeDecoration(
                      gradient: LinearGradient(begin: Alignment(0.00, 0.00), end: Alignment(1.00, 1.00), colors: [Color(0xFFA3E42F), Color(0xFF4ADEDE)]),
                      shape: OvalBorder(),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildHeader(context),
                      const SizedBox(height: 32),

                      // Notifikasi
                      _buildSectionContainer(
                        title: 'Notifikasi',
                        children: [
                          _buildToggleTile(
                            title: 'Notifikasi Darurat',
                            subtitle: 'Terima pemberitahuan untuk laporan darurat',
                            value: _isEmergencyNotifEnabled,
                            onChanged: (val) {
                              setState(() => _isEmergencyNotifEnabled = val);
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildGenericTile(
                            title: 'Suara Pemberitahuan',
                            trailing: const Icon(Icons.chevron_right_rounded, color: Color(0x99192D34)),
                            onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Menu Suara belum tersedia"))),
                          ),
                          const SizedBox(height: 16),
                          _buildGenericTile(
                            title: 'Getaran',
                            trailing: const Icon(Icons.chevron_right_rounded, color: Color(0x99192D34)),
                            onTap: () => HapticFeedback.vibrate(), // Test getaran
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // BAGIAN TAMPILAN TELAH DIHAPUS DI SINI

                      // Tentang
                      _buildSectionContainer(
                        title: 'Tentang',
                        children: [
                          _buildGenericTile(
                            title: 'Versi Aplikasi',
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('SIREN v1.0.0', style: GoogleFonts.instrumentSans(color: const Color(0xFF1A2E35), fontSize: 14, fontWeight: FontWeight.w400)),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: const Color(0x19A3E42F), borderRadius: BorderRadius.circular(4)),
                                  child: Text('Terbaru', style: GoogleFonts.instrumentSans(color: const Color(0xFF1A2E35), fontSize: 10, fontWeight: FontWeight.w500)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),
                      _buildSaveButton(),
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

  // --- WIDGET HELPERS ---

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.60), borderRadius: BorderRadius.circular(14)),
            child: Container(
              decoration: ShapeDecoration(shape: RoundedRectangleBorder(side: const BorderSide(width: 1.15, color: Color(0x4C4ADEDE)), borderRadius: BorderRadius.circular(14))),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF1A2E35)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text('Pengaturan', style: GoogleFonts.instrumentSans(color: const Color(0xFF1A2E35), fontSize: 20, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildSectionContainer({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: ShapeDecoration(
        color: Colors.white.withOpacity(0.80),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        shadows: const [BoxShadow(color: Color(0x334ADEDE), blurRadius: 32, offset: Offset(0, 8), spreadRadius: 0)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.instrumentSans(color: const Color(0xFF1A2E35), fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          Container(width: double.infinity, height: 1, color: const Color(0x264ADEDE)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildToggleTile({required String title, required String subtitle, required bool value, required ValueChanged<bool> onChanged}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.instrumentSans(color: const Color(0xFF1A2E35), fontSize: 14, fontWeight: FontWeight.w500)),
              Text(subtitle, style: GoogleFonts.instrumentSans(color: const Color(0x99192D34), fontSize: 11)),
            ],
          ),
        ),
        GestureDetector(
          onTap: () { HapticFeedback.lightImpact(); onChanged(!value); },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 48, height: 28,
            decoration: ShapeDecoration(
              gradient: value ? const LinearGradient(colors: [Color(0xFFB3FFD5), Color(0xFF28CFD7)]) : const LinearGradient(colors: [Color(0xFFE0E0E0), Color(0xFFBDBDBD)]),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Stack(children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                left: value ? 22 : 2, top: 2,
                child: Container(width: 24, height: 24, decoration: const ShapeDecoration(color: Colors.white, shape: CircleBorder(), shadows: [BoxShadow(color: Color(0x19000000), blurRadius: 4, offset: Offset(0, 2))])),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildGenericTile({required String title, required Widget trailing, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent, // Agar area kosong tetap bisa diklik
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.instrumentSans(color: const Color(0xFF1A2E35), fontSize: 14, fontWeight: FontWeight.w500)),
          trailing,
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        _savePreferences(); // Panggil fungsi simpan
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        height: 58,
        decoration: ShapeDecoration(
          gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFB3FFD5), Color(0xFF28CFD7)]),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          shadows: const [BoxShadow(color: Color(0x4C4ADEDE), blurRadius: 8, offset: Offset(0, 4), spreadRadius: 0)],
        ),
        child: Center(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.all(1.15),
            decoration: ShapeDecoration(color: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            child: Center(
              child: Text('Simpan Pengaturan', textAlign: TextAlign.center, style: GoogleFonts.instrumentSans(color: const Color(0xFF1A2E35), fontSize: 16, fontWeight: FontWeight.w500)),
            ),
          ),
        ),
      ),
    );
  }
}