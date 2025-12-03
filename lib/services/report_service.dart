import '../models/report_model.dart';
import 'database_service.dart';
import 'auth_service.dart';

/// Service untuk operasi laporan (SQLite Version).
class ReportService {
  ReportService._internal();
  static final ReportService instance = ReportService._internal();

  /// Membuat laporan baru.
  Future<int> createReport({
    required String reportType, // jenis/kategori laporan
    required String description,
    String? locationText,
    double? lat,
    double? lng,
  }) async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      throw Exception('User belum login');
    }

    final report = Report(
      type: 'regular',
      userId: user.id,
      userName: user.displayName,
      description: description,
      lat: lat,
      lng: lng,
      reportType: reportType,
      status: 'Belum ditanggapi',
      createdAt: DateTime.now(),
    );

    return await DatabaseService.instance.insertReport(report);
  }

  /// Update status laporan (Simulasi update lokal).
  Future<void> updateReportStatus(
    String reportId, {
    required String status, 
    String? responderId,
    String? responderName,
    String? responseMessage,
  }) async {
    // TODO: Implement update query di DatabaseService
    // Untuk saat ini, kita hanya mencatat log
    print('Update report $reportId status to $status by $responderName');
  }

  /// Get semua laporan (Future, bukan Stream).
  Future<List<Report>> getAllReports() async {
    return await DatabaseService.instance.getAllReports();
  }

  /// Get laporan milik user tertentu.
  Future<List<Report>> getUserReports(String userId) async {
    // TODO: Tambahkan filter by user_id di DatabaseService
    final allReports = await DatabaseService.instance.getAllReports();
    return allReports.where((r) => r.userId == userId).toList();
  }
}
