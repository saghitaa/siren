import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/report_model.dart';
import 'firestore_service.dart';
import 'auth_service.dart';

/// Service untuk operasi laporan (create, update status, stream).
class ReportService {
  ReportService._internal();
  static final ReportService instance = ReportService._internal();

  /// Membuat laporan baru dengan status 'Belum ditanggapi'.
  Future<String> createReport({
    required String reportType, // jenis/kategori laporan
    required String description,
    String? locationText,
    double? lat,
    double? lng,
  }) async {
    final userId = AuthService.instance.currentUserId;
    if (userId == null) {
      throw Exception('User belum login');
    }

    // Ambil nama user dari Firestore (atau gunakan default)
    String userName = 'Pengguna';
    try {
      final userDoc = await FirestoreService.instance.userDoc(userId).get();
      if (userDoc.exists) {
        userName = userDoc.data()?['displayName'] ?? 'Pengguna';
      }
    } catch (_) {
      // Gunakan default jika gagal
    }

    final report = Report(
      type: 'regular',
      userId: userId,
      userName: userName,
      description: description,
      lat: lat,
      lng: lng,
      reportType: reportType,
      status: 'Belum ditanggapi',
      createdAt: DateTime.now(),
    );

    final docRef = await FirestoreService.instance.reports.add(report.toFirestore());
    return docRef.id;
  }

  /// Update status laporan (untuk responder).
  Future<void> updateReportStatus(
    String reportId, {
    required String status, // 'Proses' | 'Sudah ditanggapi'
    String? responderId,
    String? responderName,
    String? responseMessage,
  }) async {
    final updates = <String, dynamic>{
      'status': status,
      'respondedAt': FieldValue.serverTimestamp(),
    };

    if (responderId != null) updates['responderId'] = responderId;
    if (responderName != null) updates['responderName'] = responderName;
    if (responseMessage != null) updates['responseMessage'] = responseMessage;

    await FirestoreService.instance.reportDoc(reportId).update(updates);
  }

  /// Stream semua laporan (untuk responder dashboard).
  Stream<List<Report>> getAllReports() {
    return FirestoreService.instance.reports
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Report.fromFirestore(doc))
            .toList());
  }

  /// Stream laporan milik user tertentu (untuk warga).
  Stream<List<Report>> getUserReports(String userId) {
    return FirestoreService.instance.reports
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Report.fromFirestore(doc))
            .toList());
  }
}

