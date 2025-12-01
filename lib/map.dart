import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'models/report_model.dart';
import 'services/map_service.dart';

class MapScreen extends StatefulWidget {
  final bool isResponder;

  const MapScreen({
    super.key,
    this.isResponder = false,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const LatLng _defaultCenter = LatLng(-6.9667, 110.4167); // Semarang

  GoogleMapController? _controller;
  final Map<MarkerId, Marker> _markers = {};
  String? _alamatTerpilih;
  LatLng? _koordinatTerpilih;

  @override
  void initState() {
    super.initState();
    _muatLaporanKePeta();
  }

  Future<void> _muatLaporanKePeta() async {
    final reports = await MapService.instance.getReportsWithLocation();
    if (!mounted) return;

    final markers = <MarkerId, Marker>{};
    for (final r in reports) {
      final lat = r.latitude;
      final lng = r.longitude;
      if (lat == null || lng == null) continue;

      final markerId = MarkerId('laporan_${r.id ?? r.dibuatPada.millisecondsSinceEpoch}');
      markers[markerId] = Marker(
        markerId: markerId,
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(
          title: r.jenis,
          snippet: r.lokasiTeks ?? r.judul,
        ),
      );
    }

    setState(() {
      _markers.clear();
      _markers.addAll(markers);
    });

    if (reports.isNotEmpty) {
      final first = reports.first;
      if (first.latitude != null && first.longitude != null) {
        _controller?.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(first.latitude!, first.longitude!),
          ),
        );
      }
    }
  }

  Future<void> _onLongPress(LatLng latLng) async {
    final alamat = await MapService.instance.reverseGeocode(
      latLng.latitude,
      latLng.longitude,
    );

    if (!mounted) return;

    const markerId = MarkerId('terpilih');
    final marker = Marker(
      markerId: markerId,
      position: latLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: const InfoWindow(
        title: 'Lokasi Terpilih',
      ),
    );

    setState(() {
      _markers[markerId] = marker;
      _alamatTerpilih = alamat;
      _koordinatTerpilih = latLng;
    });

    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detail Lokasi Laporan',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                alamat,
                style: Theme.of(ctx).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              if (_koordinatTerpilih != null)
                Text(
                  'Koordinat: ${_koordinatTerpilih!.latitude.toStringAsFixed(5)}, '
                  '${_koordinatTerpilih!.longitude.toStringAsFixed(5)}',
                  style: Theme.of(ctx)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey[700]),
                ),
              const SizedBox(height: 12),
              const Text(
                'Tahan (long-press) di peta untuk memilih titik lain.\n'
                'Alamat ini dapat kamu pakai saat mengisi form laporan.',
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final judul = widget.isResponder ? 'Peta Laporan - Responder' : 'Peta Laporan - Warga';

    return Scaffold(
      appBar: AppBar(
        title: Text(judul),
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: _defaultCenter,
          zoom: 13,
        ),
        markers: Set<Marker>.of(_markers.values),
        onMapCreated: (controller) {
          _controller = controller;
        },
        onLongPress: _onLongPress,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
      ),
    );
  }
}


