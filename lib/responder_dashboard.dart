import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:io';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:audioplayers/audioplayers.dart';

import 'forum.dart';
import 'models/report_model.dart';
import 'responder_profile.dart';
import 'report_history_screen.dart';
import 'map_area_screen.dart';
import 'team_screen.dart';
import 'services/report_service.dart';
import 'services/sos_service.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'settings.dart';
import 'signin.dart';

class ResponderDashboardScreen extends StatefulWidget {
  const ResponderDashboardScreen({super.key});

  @override
  State<ResponderDashboardScreen> createState() =>
      _ResponderDashboardScreenState();
}

class _ResponderDashboardScreenState extends State<ResponderDashboardScreen> {
  int _selectedIndex = 1;
  int _availabilityIndex = 1; // Default Offline (1)
  bool _loadingReports = true;
  List<Report> _reports = [];
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Variabel Data User
  late String _displayName;
  late String _role;
  String? _photoProfilePath;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadReports();
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  // --- FUNGSI LOAD DATA USER (UPDATED) ---
  void _loadUserData() async {
    final user = AuthService.instance.currentUser;
    if (user != null) {
      // Pastikan DB siap dan ambil data user terbaru (termasuk status)
      await DatabaseService.instance.init();
      final updatedUser = await DatabaseService.instance.getUserById(int.tryParse(user.id) ?? 0);
      
      if (!mounted) return;
      
      setState(() {
        _displayName = user.displayName;
        _role = user.role.isEmpty ? 'Responder' : user.role;
        _photoProfilePath = user.profileImageUrl;
        
        // Ambil status dari DB yang baru di-query
        String status = updatedUser?.status ?? user.status;
        _availabilityIndex = (status == 'Online') ? 0 : 1;
      });
    } else {
      setState(() {
        _displayName = 'Petugas';
        _role = 'Responder';
        _photoProfilePath = null;
        _availabilityIndex = 1;
      });
    }
  }
  
  // --- UPDATE STATUS (Menggunakan AuthService) ---
  Future<void> _updateStatus(int index) async {
    if (_availabilityIndex == index) return; // Tidak berubah

    String newStatus = (index == 0) ? 'Online' : 'Offline';
    
    try {
      // PANGGIL LEWAT AUTHSERVICE AGAR KONSISTEN
      await AuthService.instance.updateUserStatus(newStatus);
      
      setState(() {
        _availabilityIndex = index;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Status diubah menjadi $newStatus"),
          duration: const Duration(seconds: 1),
          backgroundColor: newStatus == 'Online' ? Colors.green : Colors.grey,
        )
      );
    } catch (e) {
      debugPrint("Gagal update status: $e");
    }
  }

  Future<void> _loadReports() async {
    setState(() => _loadingReports = true);
    try {
      await DatabaseService.instance.init(); // Pastikan DB init
      final reports = await DatabaseService.instance.getAllReports();
      if (!mounted) return;

      final activeReports = reports.where((r) => r.status != 'Selesai').toList();

      setState(() {
        _reports = activeReports;
        _loadingReports = false;
      });

      _checkAndPlaySound(activeReports);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingReports = false);
    }
  }

  Future<void> _checkAndPlaySound(List<Report> reports) async {
    final now = DateTime.now();
    bool hasActiveSOS = reports.any((r) => r.type == 'SOS' && r.status == 'SOS_SENT' && now.difference(r.createdAt).inHours < 24);
    bool hasNewReport = reports.any((r) => r.type != 'SOS' && r.status == 'Belum ditanggapi' && now.difference(r.createdAt).inHours < 24);

    try {
      if (hasActiveSOS) {
        if (_audioPlayer.state != PlayerState.playing) {
          await _audioPlayer.stop();
          await _audioPlayer.setVolume(1.0);
          await _audioPlayer.setReleaseMode(ReleaseMode.loop);
          await _audioPlayer.play(AssetSource('sounds/sos_siren.mp3'));
        }
      } else if (hasNewReport) {
        if (_audioPlayer.state != PlayerState.playing) {
          await _audioPlayer.stop();
          await _audioPlayer.setVolume(1.0);
          await _audioPlayer.setReleaseMode(ReleaseMode.stop);
          await _audioPlayer.play(AssetSource('sounds/notif.mp3'));
        }
      } else {
        await _audioPlayer.stop();
      }
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
  }

  Future<void> _markReportAsCompleted(String reportId) async {
    final user = AuthService.instance.currentUser;
    try {
      await _audioPlayer.stop();
      await SOSService.instance.stopSiren();

      await DatabaseService.instance.updateReportStatus(
        int.parse(reportId),
        'Selesai',
        responderId: user?.id,
        responderName: user?.displayName,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Laporan berhasil diselesaikan!')));
      _loadReports();

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyelesaikan: $e')));
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
      case 'sos': return const Color(0xFFE7000B);
      case 'banjir': return const Color(0xFF007AFF);
      case 'kebakaran': return const Color(0xFFFF7043);
      default: return const Color(0xFF28CFD7);
    }
  }

  void _showMapDialog(BuildContext context, double lat, double lng, String title) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(padding: const EdgeInsets.all(16.0), child: Text("Lokasi: $title", style: GoogleFonts.instrumentSans(fontWeight: FontWeight.bold, fontSize: 16))),
            SizedBox(
              height: 300,
              width: double.infinity,
              child: FlutterMap(
                options: MapOptions(initialCenter: LatLng(lat, lng), initialZoom: 15.0),
                children: [
                  TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.example.siren'),
                  MarkerLayer(markers: [Marker(point: LatLng(lat, lng), width: 50, height: 50, child: const Icon(Icons.location_on, color: Colors.red, size: 50))]),
                ],
              ),
            ),
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Tutup"))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0EBF0),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFE0EBF0), Color(0xFFF0F9FF), Color(0xFFE8F8F5)])),
        child: Stack(
          children: [
            Positioned(left: -48, top: 726, child: ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50), child: Opacity(opacity: 0.59, child: Container(width: 493, height: 367, decoration: const BoxDecoration(color: Color(0x331A2E35), shape: BoxShape.circle))))),

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
                      _headerCard(context),
                      const SizedBox(height: 20),
                      _incidentHeader(),
                      const SizedBox(height: 12),
                      if (_loadingReports)
                        const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 32), child: CircularProgressIndicator()))
                      else if (_reports.isEmpty)
                        _buildEmptyIncidentCard()
                      else
                        ..._reports.map((report) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _incidentCard(report))),
                      const SizedBox(height: 20),
                      _availabilityCard(),
                      const SizedBox(height: 20),
                      _menuSection(),
                      const SizedBox(height: 30),
                      _logoutButton(),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _headerCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: ShapeDecoration(color: const Color(0xB2FFFFFF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(width: 1.16, color: Color(0xCCFFFFFF))), shadows: const [BoxShadow(color: Color(0x0C000000), blurRadius: 6, offset: Offset(0, 4))]),
      child: Column(children: [
        Row(children: [
          Container(width: 40, height: 40, decoration: ShapeDecoration(gradient: const LinearGradient(begin: Alignment(0.50, 0.00), end: Alignment(0.50, 1.00), colors: [Color(0x4C4ADEDE), Color(0x5FA3E42F)]), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(width: 1.16, color: Color(0xB2FFFFFF)))), child: Padding(padding: const EdgeInsets.all(6), child: Image.asset('assets/images/siren.png', fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => const Icon(Icons.warning, color: Colors.orange)))),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('SIREN', style: GoogleFonts.orbitron(color: const Color(0xFF1A2E35), fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 4)), Text('Smart Integrated Report...', style: GoogleFonts.instrumentSans(color: const Color(0x99192D34), fontSize: 10))]),
          const Spacer(),
          Container(width: 34, height: 34, decoration: const ShapeDecoration(color: Color(0x99FFFFFF), shape: OvalBorder(side: BorderSide(width: 1.16, color: Color(0x334ADEDE)))), child: const Icon(Icons.notifications_none_rounded, size: 18, color: Color(0xFF1A2E35))),
        ]),
        const SizedBox(height: 18),

        GestureDetector(
            onTap: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const ResponderProfileScreen()));
              _loadUserData();
            },
            child: Container(
                padding: const EdgeInsets.all(14),
                decoration: ShapeDecoration(color: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                child: Row(children: [
                  Stack(children: [
                    ClipRRect(borderRadius: BorderRadius.circular(16), child: Container(width: 52, height: 52, color: Colors.grey[200], child: _photoProfilePath != null && _photoProfilePath!.isNotEmpty ? Image.file(File(_photoProfilePath!), fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.person, size: 30, color: Colors.grey)) : const Icon(Icons.person, size: 30, color: Colors.grey))),
                    Positioned(right: 2, bottom: 2, child: Container(width: 12, height: 12, decoration: BoxDecoration(color: _availabilityIndex == 0 ? const Color(0xFF2ECC71) : Colors.grey, shape: BoxShape.circle, border: const Border.fromBorderSide(BorderSide(color: Colors.white, width: 2)))))
                  ]),
                  const SizedBox(width: 14),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_displayName, style: GoogleFonts.instrumentSans(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF1A2E35))),
                    const SizedBox(height: 6),
                    Row(children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: ShapeDecoration(gradient: const LinearGradient(begin: Alignment(0.50, 0.00), end: Alignment(0.50, 1.00), colors: [Color(0x334ADEDE), Color(0x33A3E42F)]), shape: RoundedRectangleBorder(side: const BorderSide(width: 1.16, color: Color(0x4C4ADEDE)), borderRadius: BorderRadius.circular(38835400))), child: Row(children: [const Icon(Icons.shield_outlined, size: 14, color: Color(0xFF1A2E35)), const SizedBox(width: 6), Text(_role, style: GoogleFonts.instrumentSans(fontSize: 12, color: const Color(0xFF1A2E35))) ]) )
                    ])
                  ])
                ])
            )
        )
      ]),
    );
  }

  Widget _incidentCard(Report report) {
    final color = _accentColor(report.jenis);
    final isHandling = report.status == 'Proses' || report.status == 'Menanggapi';
    final showAcceptButton = report.status == 'SOS_SENT' || report.status == 'Belum ditanggapi';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(color: isHandling ? Colors.white.withOpacity(0.9) : const Color(0xB2FFFFFF), shape: RoundedRectangleBorder(side: BorderSide(width: 1.16, color: color.withOpacity(0.3)), borderRadius: BorderRadius.circular(24))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: ShapeDecoration(color: color.withOpacity(0.1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(38))), child: Text(report.type == 'SOS' ? 'SOS ALERT' : report.jenis.toUpperCase(), style: GoogleFonts.orbitron(fontSize: 11, fontWeight: FontWeight.w700, color: color))),
            Text(_formatTime(report.createdAt), style: GoogleFonts.instrumentSans(fontSize: 12, color: const Color(0x991A2E35))),
          ]),
          const SizedBox(height: 12),
          Text(report.reportType ?? report.type, style: GoogleFonts.instrumentSans(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(report.description, style: GoogleFonts.instrumentSans(fontSize: 14)),
          const SizedBox(height: 12),
          Row(children: [const Icon(Icons.location_on_outlined, size: 16), const SizedBox(width: 4), Expanded(child: Text(report.lat != null ? '${report.lat}, ${report.lng}' : 'Lokasi tidak tersedia', style: GoogleFonts.instrumentSans(fontSize: 12)))]),
          if (report.lat != null)
            GestureDetector(onTap: () => _showMapDialog(context, report.lat!, report.lng!, report.jenis), child: Container(margin: const EdgeInsets.only(top: 8), padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)), child: const Text("Lihat Peta", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)))),
          const SizedBox(height: 16),
          Row(children: [
            if (showAcceptButton) Expanded(child: ElevatedButton(onPressed: () async { await _audioPlayer.stop(); await SOSService.instance.stopSiren(); if (report.id != null) await DatabaseService.instance.updateReportStatus(int.parse(report.id!), 'Proses', responderId: AuthService.instance.currentUser?.id, responderName: AuthService.instance.currentUser?.displayName); _loadReports(); }, style: ElevatedButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text("TERIMA & TANGGAPI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
            if (isHandling) ...[Expanded(child: ElevatedButton(onPressed: null, style: ElevatedButton.styleFrom(backgroundColor: color.withOpacity(0.5)), child: const Text("DITANGGAPI", style: TextStyle(color: Colors.white)))), const SizedBox(width: 8), Expanded(child: ElevatedButton(onPressed: () { if (report.id != null) _markReportAsCompleted(report.id!); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: const Text("SELESAI", style: TextStyle(color: Colors.white))))]
          ])
        ],
      ),
    );
  }

  Widget _incidentHeader() { return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Incident Live Feed', style: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1A2E35))), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: ShapeDecoration(color: const Color(0xFFE7000B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(38835400))), child: Row(children: [Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)), const SizedBox(width: 4), Text('LIVE', style: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white))]))]); }
  Widget _buildEmptyIncidentCard() { return Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xB2FFFFFF), borderRadius: BorderRadius.circular(24), border: Border.all(width: 1.16, color: const Color(0xCCFFFFFF))), child: Column(children: [const Icon(Icons.check_circle_outline, size: 48, color: Color(0xFF2ECC71)), const SizedBox(height: 12), Text('Semua Aman', style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF1A2E35))), const SizedBox(height: 4), Text('Tidak ada laporan darurat aktif saat ini.', textAlign: TextAlign.center, style: GoogleFonts.instrumentSans(fontSize: 14, color: const Color(0x991A2E35))) ])); }
  
  Widget _availabilityCard() { 
    return Container(
      padding: const EdgeInsets.all(16), 
      decoration: ShapeDecoration(color: const Color(0xB2FFFFFF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(width: 1.16, color: Color(0xCCFFFFFF)))), 
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Set Availability', style: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1A2E35))), 
        const SizedBox(height: 12), 
        Container(padding: const EdgeInsets.all(4), decoration: ShapeDecoration(color: const Color(0x0C1A2E35), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Row(children: [
          Expanded(child: GestureDetector(
            onTap: () => _updateStatus(0), // Set Online
            child: Container(height: 36, decoration: BoxDecoration(color: _availabilityIndex == 0 ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(10), boxShadow: _availabilityIndex == 0 ? [const BoxShadow(color: Color(0x0C000000), blurRadius: 4, offset: Offset(0, 2))] : []), alignment: Alignment.center, child: Text('Online', style: GoogleFonts.instrumentSans(fontSize: 14, fontWeight: _availabilityIndex == 0 ? FontWeight.w600 : FontWeight.w400, color: _availabilityIndex == 0 ? const Color(0xFF2ECC71) : const Color(0xFF1A2E35)))))), 
          Expanded(child: GestureDetector(
            onTap: () => _updateStatus(1), // Set Offline
            child: Container(height: 36, decoration: BoxDecoration(color: _availabilityIndex == 1 ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(10), boxShadow: _availabilityIndex == 1 ? [const BoxShadow(color: Color(0x0C000000), blurRadius: 4, offset: Offset(0, 2))] : []), alignment: Alignment.center, child: Text('Offline', style: GoogleFonts.instrumentSans(fontSize: 14, fontWeight: _availabilityIndex == 1 ? FontWeight.w600 : FontWeight.w400, color: _availabilityIndex == 1 ? const Color(0xFFE74C3C) : const Color(0xFF1A2E35))))))
        ]))
      ])); 
  }
  
  Widget _menuSection() { return Column(children: [Row(children: [Expanded(child: _menuTile(Icons.history, 'Riwayat', onTap: () { Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportHistoryScreen())); })), const SizedBox(width: 12), Expanded(child: _menuTile(Icons.group_outlined, 'Tim', onTap: () { Navigator.push(context, MaterialPageRoute(builder: (_) => const TeamScreen())); }))]), const SizedBox(height: 12), Row(children: [Expanded(child: _menuTile(Icons.map_outlined, 'Peta Area', onTap: () { Navigator.push(context, MaterialPageRoute(builder: (_) => const MapAreaScreen())); })), const SizedBox(width: 12), Expanded(child: _menuTile(Icons.settings_outlined, 'Pengaturan', onTap: () { Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())); }))])]); }
  Widget _menuTile(IconData icon, String label, {required VoidCallback onTap}) { return GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: Container(padding: const EdgeInsets.symmetric(vertical: 16), decoration: ShapeDecoration(color: const Color(0xB2FFFFFF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(width: 1.16, color: Color(0xCCFFFFFF)))), child: Column(children: [Icon(icon, color: const Color(0xFF1A2E35), size: 24), const SizedBox(height: 8), Text(label, style: GoogleFonts.instrumentSans(fontSize: 14, color: const Color(0xFF1A2E35)))]))); }
  Widget _logoutButton() { return SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () async { final bool? shouldLogout = await showDialog<bool>(context: context, builder: (context) => AlertDialog(backgroundColor: Colors.white, title: Text('Konfirmasi Keluar', style: GoogleFonts.instrumentSans(fontWeight: FontWeight.bold)), content: const Text('Apakah Anda yakin ingin keluar dari akun?'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal', style: TextStyle(color: Colors.grey))), TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Keluar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)))])); if (shouldLogout == true) { await _audioPlayer.stop(); await SOSService.instance.stopSiren(); await AuthService.instance.signOut(); if (!mounted) return; Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const SignInScreen()), (route) => false); } }, icon: const Icon(Icons.logout_rounded, color: Colors.redAccent), label: Text("KELUAR AKUN", style: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.redAccent, letterSpacing: 1.0)), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), side: const BorderSide(color: Colors.redAccent, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), backgroundColor: Colors.red.withOpacity(0.05)))); }
  Widget _buildBottomNav() { return Container(height: 84, decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE0EBF0)))), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_navItem(Icons.forum_outlined, "Forum", 0), _navItem(Icons.dashboard_rounded, "Dashboard", 1)])); }
  Widget _navItem(IconData icon, String label, int index) { final bool isSelected = _selectedIndex == index; return GestureDetector(onTap: () { if (index == 0) Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_, __, ___) => const ForumScreen(isResponder: true), transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c))); }, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: isSelected ? const Color(0xFF1A2E35) : const Color(0xFF1A2E35).withOpacity(0.4)), const SizedBox(height: 4), Text(label, style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, color: isSelected ? const Color(0xFF1A2E35) : const Color(0xFF1A2E35).withOpacity(0.4)))])); }
}