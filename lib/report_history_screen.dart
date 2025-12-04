import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/report_model.dart';
import 'services/database_service.dart';

class ReportHistoryScreen extends StatefulWidget {
  const ReportHistoryScreen({super.key});

  @override
  State<ReportHistoryScreen> createState() => _ReportHistoryScreenState();
}

class _ReportHistoryScreenState extends State<ReportHistoryScreen> {
  bool _isLoading = true;
  List<Report> _historyReports = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final reports = await DatabaseService.instance.getAllReports();
      // Tampilkan laporan yang statusnya bukan awal (Proses/Selesai)
      final history = reports.where((r) => r.status != 'SOS_SENT' && r.status != 'Belum ditanggapi').toList();

      if (!mounted) return;
      setState(() {
        _historyReports = history;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading history: $e");
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  String _formatTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} m lalu';
    if (diff.inHours < 24) return '${diff.inHours} j lalu';
    return '${diff.inDays} h lalu';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0EBF0),
      appBar: AppBar(
        title: Text("Riwayat Penanganan", style: GoogleFonts.instrumentSans(fontWeight: FontWeight.bold, color: const Color(0xFF1A2E35))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A2E35)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _historyReports.isEmpty
          ? Center(child: Text("Belum ada riwayat.", style: GoogleFonts.instrumentSans(color: Colors.grey)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _historyReports.length,
        itemBuilder: (ctx, index) => _buildCard(_historyReports[index]),
      ),
    );
  }

  Widget _buildCard(Report report) {
    final isSelesai = report.status == 'Selesai';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isSelesai ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
          child: Icon(
            isSelesai ? Icons.check : Icons.timelapse,
            color: isSelesai ? Colors.green : Colors.blue,
          ),
        ),
        title: Text(report.reportType ?? report.type, style: GoogleFonts.instrumentSans(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(report.description, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text("Status: ${report.status}", style: TextStyle(fontSize: 12, color: isSelesai ? Colors.green : Colors.blue)),
          ],
        ),
        trailing: Text(_formatTime(report.createdAt), style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ),
    );
  }
}