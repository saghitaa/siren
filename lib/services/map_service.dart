import 'package:geocoding/geocoding.dart';

import '../models/report_model.dart';
import 'database_service.dart';

/// Layanan untuk kebutuhan peta:
/// - Membaca laporan yang memiliki koordinat (lat/lng) dari SQLite
/// - Melakukan reverse geocoding (lat/lng -> alamat teks)
class MapService {
  MapService._internal();

  static final MapService instance = MapService._internal();

  /// Mengambil semua laporan yang memiliki koordinat untuk ditampilkan di peta.
  Future<List<Report>> getReportsWithLocation() async {
    final all = await DatabaseService.instance.getAllReports();
    return all
        .where((r) => r.latitude != null && r.longitude != null)
        .toList();
  }

  /// Mengubah koordinat menjadi alamat teks (Bahasa Indonesia sebisanya,
  /// tergantung data dari provider geocoding).
  Future<String> reverseGeocode(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) {
        return 'Alamat tidak ditemukan';
      }

      final p = placemarks.first;
      final bagian = <String>[];
      if (p.street != null && p.street!.isNotEmpty) bagian.add(p.street!);
      if (p.subLocality != null && p.subLocality!.isNotEmpty) {
        bagian.add(p.subLocality!);
      }
      if (p.locality != null && p.locality!.isNotEmpty) bagian.add(p.locality!);
      if (p.administrativeArea != null && p.administrativeArea!.isNotEmpty) {
        bagian.add(p.administrativeArea!);
      }
      if (p.postalCode != null && p.postalCode!.isNotEmpty) {
        bagian.add(p.postalCode!);
      }

      if (bagian.isEmpty) {
        return 'Alamat tidak diketahui';
      }

      return bagian.join(', ');
    } catch (_) {
      return 'Alamat tidak dapat dimuat';
    }
  }
}


