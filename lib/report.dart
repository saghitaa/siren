import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

// --- IMPORT BARU UNTUK PETA ---
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
// ------------------------------

import 'services/auth_service.dart';
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

  // --- VARIABEL PETA ---
  final MapController _mapController = MapController();
  LatLng _currentLocation = const LatLng(-6.9667, 110.4167); // Default: Semarang
  LatLng? _pickedLocation; // Lokasi yang dipilih user
  bool _hasLocation = false;
  // ---------------------

  final List<String> _reportTypes = [
    'Banjir',
    'Kebakaran',
    'Kecelakaan',
    'Pohon Tumbang',
    'Jalan Rusak',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _determinePosition(); // Coba ambil lokasi saat buka
  }

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  // Fungsi Cek GPS & Ambil Lokasi Saat Ini
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    // Ambil lokasi
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _pickedLocation = _currentLocation; // Otomatis pilih lokasi saat ini
      _hasLocation = true;
    });

    // Pindahkan kamera peta
    _mapController.move(_currentLocation, 15.0);
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
            // --- BACKGROUND ---
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

            // --- MAIN CONTENT ---
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildReportForm(),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ),

            // --- BOTTOM NAV ---
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
            // ... (Logo code sama) ...
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
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.warning),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SIREN', style: GoogleFonts.orbitron(color: const Color(0xFF1A2E35), fontSize: 16, letterSpacing: 4)),
                Text('Smart Integrated Report...', style: GoogleFonts.instrumentSans(color: const Color(0x99192D34), fontSize: 10)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('Buat Laporan', style: GoogleFonts.instrumentSans(color: const Color(0xFF1A2E35), fontSize: 20, fontWeight: FontWeight.w500)),
        Text('Tentukan lokasi kejadian di peta', style: GoogleFonts.instrumentSans(color: const Color(0x99192D34), fontSize: 14)),
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
          side: BorderSide(width: 1.16, color: Colors.white.withValues(alpha: 0.80)),
          borderRadius: BorderRadius.circular(24),
        ),
        shadows: const [BoxShadow(color: Color(0x0C000000), blurRadius: 6, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Dropdown Jenis Laporan
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
                hint: Text('Pilih jenis laporan', style: GoogleFonts.instrumentSans(color: const Color(0xFF1A2E35), fontSize: 14)),
                isExpanded: true,
                items: _reportTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type, style: GoogleFonts.instrumentSans(color: const Color(0xFF1A2E35))),
                  );
                }).toList(),
                onChanged: (newValue) => setState(() => _selectedReportType = newValue),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 2. INPUT PETA (LEAFLET)
          Text('Titik Lokasi Kejadian:', style: GoogleFonts.instrumentSans(color: const Color(0x99192D34), fontSize: 12)),
          const SizedBox(height: 8),
          Container(
            height: 200, // Tinggi Peta
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x334ADEDE), width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _currentLocation,
                      initialZoom: 15.0,
                      onTap: (tapPosition, point) {
                        // User tap peta -> Pindah marker
                        setState(() {
                          _pickedLocation = point;
                          _hasLocation = true;
                        });
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.siren',
                      ),
                      if (_pickedLocation != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _pickedLocation!,
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  // Tombol Reset Lokasi ke GPS
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: FloatingActionButton.small(
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.my_location, color: Colors.blue),
                      onPressed: _determinePosition,
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (_pickedLocation != null)
            Text(
              "Koordinat: ${_pickedLocation!.latitude.toStringAsFixed(5)}, ${_pickedLocation!.longitude.toStringAsFixed(5)}",
              style: GoogleFonts.instrumentSans(fontSize: 10, color: Colors.grey),
            ),
          const SizedBox(height: 16),

          // 3. Input Lokasi Text (Optional / Detail)
          TextField(
            controller: _locationController,
            style: GoogleFonts.instrumentSans(color: const Color(0xFF1A2E35)),
            decoration: InputDecoration(
              hintText: 'Detail Lokasi (cth: Depan Alfamart)',
              hintStyle: GoogleFonts.instrumentSans(color: const Color(0x66192D34)),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.60),
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0x334ADEDE))),
            ),
          ),
          const SizedBox(height: 16),

          // 4. Deskripsi
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            style: GoogleFonts.instrumentSans(color: const Color(0xFF1A2E35)),
            decoration: InputDecoration(
              hintText: 'Deskripsi kejadian...',
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.60),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0x334ADEDE))),
            ),
          ),
          const SizedBox(height: 24),

          // 5. Tombol Submit
          InkWell(
            onTap: _isSubmitting ? null : _submitReport,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: ShapeDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFB3FFD5), Color(0xFF28CFD7)]),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                shadows: const [BoxShadow(color: Color(0x4C4ADEDE), blurRadius: 12, offset: Offset(0, 6))],
              ),
              child: Center(
                child: _isSubmitting
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('Kirim Laporan', style: GoogleFonts.instrumentSans(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- NAVIGASI ---
  Widget _buildBottomNav() {
    // ... (Kode navbar sama seperti file asli, copy-paste jika perlu atau biarkan struktur ini)
    // Untuk mempersingkat jawaban, saya asumsikan kode _buildBottomNav sama persis.
    // Jika error, ambil dari file report.dart sebelumnya.
    const int activeIndex = 2;

    return Container(
      width: double.infinity,
      height: 90,
      decoration: const BoxDecoration(
        color: Color(0xCCFFFFFF),
        border: Border(top: BorderSide(width: 1.16, color: Color(0x334ADEDE))),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double slotWidth = constraints.maxWidth / 3;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: slotWidth,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pushReplacement(PageRouteBuilder(pageBuilder: (_,__,___) => const ForumScreen(), transitionsBuilder: (_,a,__,c) => FadeTransition(opacity: a, child: c))),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.forum_outlined, color: const Color(0x7F192D34)), Text('Forum', style: GoogleFonts.instrumentSans(fontSize: 11, color: const Color(0x7F192D34)))]),
                    ),
                  ),
                  SizedBox(
                    width: slotWidth,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pushReplacement(PageRouteBuilder(pageBuilder: (_,__,___) => const DashboardScreen(), transitionsBuilder: (_,a,__,c) => FadeTransition(opacity: a, child: c))),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.grid_view_outlined, color: const Color(0x7F192D34)), Text('Dashboard', style: GoogleFonts.instrumentSans(fontSize: 11, color: const Color(0x7F192D34)))]),
                    ),
                  ),
                  SizedBox(width: slotWidth, child: SizedBox()), // Placeholder for active tab
                ],
              ),
              Positioned(
                top: -25,
                left: slotWidth * activeIndex + slotWidth / 2 - 30,
                child: Container(
                  width: 60, height: 60,
                  decoration: const ShapeDecoration(color: Color(0xCCFFFFFF), shape: CircleBorder(), shadows: [BoxShadow(color: Color(0x19000000), blurRadius: 15, offset: Offset(0, 10))]),
                  child: Container(
                    margin: const EdgeInsets.all(5),
                    decoration: const ShapeDecoration(color: Color(0x89A3E42F), shape: CircleBorder()),
                    child: const Icon(Icons.assignment_outlined, color: Color(0xFF1A2E35)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _submitReport() async {
    // 1. Validasi Input Dasar
    if (_selectedReportType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih jenis laporan terlebih dahulu.')),
      );
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon isi deskripsi kejadian.')),
      );
      return;
    }

    // 2. Validasi Lokasi (Pencegah Error Null Check Operator)
    if (_pickedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tunggu sebentar, sedang mengambil lokasi GPS... atau ketuk peta.')),
      );
      // Coba ambil lokasi lagi jika null
      _determinePosition();
      return;
    }

    // 3. Validasi User Login (Pencegah Error Hot Restart)
    // Cek apakah user ada di memori. Jika null, paksa logout/login ulang.
    final user = AuthService.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesi habis. Silakan Logout dan Login kembali.')),
      );
      return;
    }

    // --- MULAI PROSES KIRIM ---
    HapticFeedback.lightImpact();
    setState(() => _isSubmitting = true);

    try {
      // Menyiapkan teks lokasi
      String finalLocationText = _locationController.text.trim();
      if (finalLocationText.isEmpty && _pickedLocation != null) {
        finalLocationText = "${_pickedLocation!.latitude}, ${_pickedLocation!.longitude}";
      }

      await _reportService.createReport(
        reportType: _selectedReportType!,
        description: _descriptionController.text.trim(),
        locationText: finalLocationText,
        // Karena sudah dicek di langkah 2, _pickedLocation DIJAMIN tidak null di sini
        lat: _pickedLocation!.latitude,
        lng: _pickedLocation!.longitude,
      );

      if (!mounted) return;

      // Reset Form
      setState(() {
        _isSubmitting = false;
        _selectedReportType = null;
        _pickedLocation = null; // Opsional: reset marker atau biarkan
        _descriptionController.clear();
        _locationController.clear();
      });

      // Ambil lokasi lagi untuk persiapan laporan berikutnya
      _determinePosition();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Laporan berhasil dikirim!')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      // Tampilkan error tanpa bikin aplikasi crash
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim: $e'), backgroundColor: Colors.red),
      );
    }
  }
}