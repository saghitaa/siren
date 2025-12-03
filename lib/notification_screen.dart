import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/report_model.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Report> _myReports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMyReports();
  }

  Future<void> _loadMyReports() async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    final allReports = await DatabaseService.instance.getAllReports();
    // Filter laporan milik user ini
    final myReports = allReports.where((r) => r.userId == user.id).toList();

    // Urutkan dari yang terbaru
    myReports.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (mounted) {
      setState(() {
        _myReports = myReports;
        _isLoading = false;
      });
    }
  }

  String _getStatusMessage(String status) {
    if (status == 'Belum ditanggapi' || status == 'SOS_SENT') {
      return 'Laporan terkirim. Menunggu respon petugas.';
    } else if (status == 'Proses' || status == 'Menanggapi') {
      return 'Petugas sedang menuju lokasi / menangani laporan.';
    } else if (status == 'Selesai') {
      return 'Penanganan laporan telah selesai.';
    } else {
      return 'Status terkini: $status';
    }
  }

  Color _getStatusColor(String status) {
    if (status == 'Belum ditanggapi' || status == 'SOS_SENT') {
      return const Color(0xFFFFB400); // Kuning
    } else if (status == 'Proses' || status == 'Menanggapi') {
      return const Color(0xFF28CFD7); // Biru Tosca
    } else if (status == 'Selesai') {
      return const Color(0xFF2ECC71); // Hijau
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1A2E35)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifikasi & Status',
          style: GoogleFonts.instrumentSans(
            color: const Color(0xFF1A2E35),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _myReports.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.notifications_off_outlined,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada notifikasi',
                        style: GoogleFonts.instrumentSans(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _myReports.length,
                  itemBuilder: (context, index) {
                    final report = _myReports[index];
                    return _buildNotificationItem(report);
                  },
                ),
    );
  }

  Widget _buildNotificationItem(Report report) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0C000000), blurRadius: 8, offset: Offset(0, 4))
        ],
        border: Border(
          left: BorderSide(width: 4, color: _getStatusColor(report.status)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris 1: Judul dan Waktu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                report.type == 'SOS'
                    ? 'PANGGILAN DARURAT'
                    : report.reportType ?? 'Laporan',
                style: GoogleFonts.instrumentSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: report.type == 'SOS'
                      ? Colors.red
                      : const Color(0xFF1A2E35),
                ),
              ),
              Text(
                "${report.createdAt.hour}:${report.createdAt.minute.toString().padLeft(2, '0')}",
                style:
                    GoogleFonts.instrumentSans(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Baris 2: Pesan Status
          Text(
            _getStatusMessage(report.status),
            style: GoogleFonts.instrumentSans(
              fontSize: 14,
              color: const Color(0xFF1A2E35),
            ),
          ),
          const SizedBox(height: 8),

          // Baris 3: Deskripsi Laporan (Isi)
          if (report.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                "\"${report.description}\"",
                style: GoogleFonts.instrumentSans(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // Baris 4: Lokasi (TAMBAHAN BARU)
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 14, color: Color(0xFF28CFD7)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  (report.lat != null && report.lng != null)
                      ? "${report.lat}, ${report.lng}"
                      : "Lokasi tidak tersedia",
                  style: GoogleFonts.instrumentSans(
                    fontSize: 12,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}