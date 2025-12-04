import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/report_model.dart';
import 'services/database_service.dart';

class MapAreaScreen extends StatefulWidget {
  const MapAreaScreen({super.key});

  @override
  State<MapAreaScreen> createState() => _MapAreaScreenState();
}

class _MapAreaScreenState extends State<MapAreaScreen> {
  List<Report> _activeReports = [];
  bool _isLoading = true;

  // Default Lokasi: Semarang (Jawa Tengah)
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

      // Filter: Hanya tampilkan laporan yang punya koordinat & belum selesai
      final active = reports.where((r) =>
      r.lat != null &&
          r.lng != null &&
          r.status != 'Selesai'
      ).toList();

      if (active.isNotEmpty) {
        // Fokuskan peta ke lokasi laporan pertama
        _center = LatLng(active.first.lat!, active.first.lng!);
      }

      if (!mounted) return;
      setState(() {
        _activeReports = active;
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
          "Peta Area Insiden",
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
          : _activeReports.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map_outlined, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              "Tidak ada laporan aktif dengan lokasi",
              style: GoogleFonts.instrumentSans(color: Colors.grey),
            ),
          ],
        ),
      )
          : FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _center,
          initialZoom: 13.0,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all,
          ),
        ),
        children: [
          // 1. LAYER PETA (OpenStreetMap)
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.siren_app',
          ),

          // 2. LAYER MARKER
          MarkerLayer(
            markers: _activeReports.map((report) {
              final isSOS = report.type == 'SOS';
              final color = isSOS ? const Color(0xFFE7000B) : const Color(0xFF007AFF);

              return Marker(
                width: 60.0, // Ukuran diperbesar agar mudah ditekan
                height: 60.0,
                point: LatLng(report.lat!, report.lng!),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque, // Agar area transparan tetap bisa diklik
                  onTap: () {
                    _showReportDetail(report);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: color, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          isSOS ? Icons.sos : Icons.warning_amber_rounded,
                          color: color,
                          size: 28.0,
                        ),
                      ),
                      // Segitiga kecil di bawah marker (opsional, visual saja)
                      ClipPath(
                        clipper: TriangleClipper(),
                        child: Container(
                          color: color,
                          height: 8,
                          width: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // --- POPUP DETAIL ---
  void _showReportDetail(Report report) {
    final isSOS = report.type == 'SOS';
    final color = isSOS ? Colors.red : Colors.blue;

    showModalBottomSheet(
      context: context,
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
                Icon(isSOS ? Icons.warning : Icons.info, color: color, size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    report.reportType ?? report.type,
                    style: GoogleFonts.instrumentSans(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(report.status, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            const Divider(height: 30),
            _detailRow(Icons.person, "Pelapor", report.userName),
            const SizedBox(height: 12),
            _detailRow(Icons.description, "Deskripsi", report.description),
            const SizedBox(height: 12),
            _detailRow(Icons.access_time, "Waktu", _formatTime(report.createdAt)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.instrumentSans(fontSize: 12, color: Colors.grey)),
              Text(value, style: GoogleFonts.instrumentSans(fontSize: 16, fontWeight: FontWeight.w500)),
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