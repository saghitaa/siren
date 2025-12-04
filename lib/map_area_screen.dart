import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
// FIX: Tambahkan 'hide Path' agar tidak bentrok dengan Path untuk menggambar segitiga
import 'package:latlong2/latlong.dart' hide Path;
import 'package:google_fonts/google_fonts.dart';

import 'models/report_model.dart';
import 'services/database_service.dart';

class MapAreaScreen extends StatefulWidget {
  const MapAreaScreen({super.key});

  @override
  State<MapAreaScreen> createState() => _MapAreaScreenState();
}

class _MapAreaScreenState extends State<MapAreaScreen> {
  List<Report> _allReports = [];
  bool _isLoading = true;

  // Default Lokasi: Semarang
  LatLng _center = const LatLng(-7.0504, 110.3986);
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadAllReports();
  }

  Future<void> _loadAllReports() async {
    setState(() => _isLoading = true);
    try {
      await DatabaseService.instance.init();
      final reports = await DatabaseService.instance.getAllReports();

      // Tampilkan SEMUA laporan yang punya lokasi
      final validReports = reports.where((r) => r.lat != null && r.lng != null).toList();

      if (validReports.isNotEmpty) {
        _center = LatLng(validReports.first.lat!, validReports.first.lng!);
      }

      if (!mounted) return;
      setState(() {
        _allReports = validReports;
        _isLoading = false;
      });

    } catch (e) {
      debugPrint("Error loading map data: $e");
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Peta Sebaran Laporan",
          style: GoogleFonts.instrumentSans(
              color: const Color(0xFF1A2E35),
              fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF1A2E35)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllReports,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _allReports.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map_outlined, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              "Belum ada data lokasi laporan",
              style: GoogleFonts.instrumentSans(color: Colors.grey),
            ),
          ],
        ),
      )
          : FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _center,
          initialZoom: 14.0,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.siren_app',
          ),
          MarkerLayer(
            markers: _allReports.map((report) {
              return _buildMarker(report);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Marker _buildMarker(Report report) {
    Color markerColor;
    IconData markerIcon;

    if (report.status == 'Selesai') {
      markerColor = Colors.green;
      markerIcon = Icons.check_circle;
    } else if (report.type == 'SOS') {
      markerColor = const Color(0xFFE7000B);
      markerIcon = Icons.sos;
    } else {
      markerColor = const Color(0xFF007AFF);
      markerIcon = Icons.warning_amber_rounded;
    }

    return Marker(
      width: 60.0,
      height: 60.0,
      point: LatLng(report.lat!, report.lng!),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _showReportDetail(report, markerColor);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: markerColor, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              padding: const EdgeInsets.all(6),
              child: Icon(
                markerIcon,
                color: markerColor,
                size: 24.0,
              ),
            ),
            // Menggunakan Path dari dart:ui (karena latlong2 Path disembunyikan)
            ClipPath(
              clipper: TriangleClipper(),
              child: Container(
                color: markerColor,
                height: 8,
                width: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDetail(Report report, Color color) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.place, color: color, size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.reportType ?? report.type,
                        style: GoogleFonts.instrumentSans(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        report.status,
                        style: GoogleFonts.instrumentSans(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 12
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 30),
            _detailRow(Icons.person, "Pelapor", report.userName),
            const SizedBox(height: 10),
            _detailRow(Icons.description, "Deskripsi", report.description),
            const SizedBox(height: 10),
            _detailRow(Icons.access_time, "Waktu", _formatTime(report.createdAt)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text("Tutup", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.instrumentSans(fontSize: 11, color: Colors.grey)),
              Text(value, style: GoogleFonts.instrumentSans(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }
}

class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}