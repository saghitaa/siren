import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:image_picker/image_picker.dart'; // Wajib ada di pubspec

import 'services/auth_service.dart';
import 'models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User? _currentUser;

  // Controllers untuk Edit
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  String _role = '';
  String _location = 'Indonesia';

  bool _isEditing = false;
  File? _pickedImage; // File gambar baru yang dipilih
  final ImagePicker _picker = ImagePicker();

  // List kontak untuk UI (Map<String, String>: {'label': 'Nama', 'phone': '08xx'})
  List<Map<String, String>> _emergencyContacts = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    _currentUser = AuthService.instance.currentUser;

    if (_currentUser != null) {
      setState(() {
        // Ambil data dari User Model
        _nameController.text = _currentUser!.displayName;
        _emailController.text = _currentUser!.email;
        _phoneController.text = _currentUser!.phone;
        _role = _currentUser!.role;

        // Mapping kontak dari database ke format tampilan UI
        int index = 1;
        _emergencyContacts = [];
        for (var contact in _currentUser!.contacts) {
          _emergencyContacts.add({
            'label': 'Kontak Darurat ${index++}', // Label default
            'phone': contact
          });
        }
      });
    }
  }

  // --- LOGIKA GANTI FOTO ---
  Future<void> _pickImage() async {
    if (!_isEditing) return;
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (picked != null) {
        setState(() {
          _pickedImage = File(picked.path);
        });
      }
    } catch (e) {
      debugPrint("Gagal ambil foto: $e");
    }
  }

  // --- LOGIKA SIMPAN PERUBAHAN KE DATABASE ---
  Future<void> _saveProfile() async {
    if (_currentUser == null) return;

    try {
      // Ambil hanya nomor telepon dari list UI untuk disimpan ke database
      List<String> updatedContacts = _emergencyContacts.map((e) => e['phone']!).toList();

      await AuthService.instance.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        photoPath: _pickedImage?.path,
        contacts: updatedContacts, // Kirim list kontak baru
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui!'), backgroundColor: Colors.green),
      );

      setState(() {
        _isEditing = false;
        _pickedImage = null; // Reset
      });

      _loadUserData(); // Muat ulang data setelah save

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal update: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // --- LOGIKA TAMBAH KONTAK ---
  void _showAddContactSheet() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Tambah Kontak Darurat', style: GoogleFonts.instrumentSans(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Nama / Hubungan',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Nomor Telepon',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (phoneCtrl.text.isNotEmpty) {
                      setState(() {
                        _emergencyContacts.add({
                          'label': nameCtrl.text.isEmpty ? 'Kontak Baru' : nameCtrl.text,
                          'phone': phoneCtrl.text,
                        });
                        _isEditing = true; // Masuk mode edit agar user save
                      });
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text("Tambah", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // --- LOGIKA HAPUS KONTAK ---
  void _deleteContact(int index) {
    setState(() {
      _emergencyContacts.removeAt(index);
      _isEditing = true; // Masuk mode edit
    });
  }

  @override
  Widget build(BuildContext context) {
    // Memastikan user ada sebelum menampilkan UI
    if (_currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("Anda belum login.")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE0EBF0),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFFE0EBF0), Color(0xFFF0F9FF), Color(0xFFE8F8F5)],
          ),
        ),
        child: Stack(
          children: [
            // Background decorations... (dibiarkan sama)
            Positioned(left: 92, top: -73, child: ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50), child: Opacity(opacity: 0.59, child: Container(width: 421, height: 421, decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF4ADEDE), Color(0xFFA3E42F)]), shape: BoxShape.circle))))),
            Positioned(left: -120, top: 602, child: ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50), child: Opacity(opacity: 0.40, child: Container(width: 350, height: 350, decoration: const ShapeDecoration(gradient: LinearGradient(begin: Alignment(1, 0), end: Alignment(0, 1), colors: [Color(0xFFA3E42F), Color(0xFF4ADEDE)]), shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(99999)))))))),

            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildTopBar(context),
                    const SizedBox(height: 32),
                    _buildAvatar(),
                    const SizedBox(height: 32),
                    // Wrap dalam Form untuk validasi dan memudahkan pengeditan
                    Form(child: Column(children: [
                      _buildPersonalInfo(),
                      const SizedBox(height: 24),
                      _buildEmergencyContacts(),
                    ])),
                    const SizedBox(height: 24),
                    if (_isEditing) _buildSaveButton(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1A2E35)),
        ),
        Text("Profil Anda", style: GoogleFonts.instrumentSans(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1A2E35))),
        // Tombol Edit
        IconButton(
          onPressed: () {
            setState(() {
              _isEditing = !_isEditing;
              if (!_isEditing) _loadUserData(); // Reset jika batal
            });
          },
          icon: Icon(_isEditing ? Icons.close : Icons.edit, color: const Color(0xFF1A2E35)),
        )
      ],
    );
  }

  Widget _buildAvatar() {
    ImageProvider? imageProvider;
    if (_pickedImage != null) {
      imageProvider = FileImage(_pickedImage!);
    } else if (_currentUser?.profileImageUrl != null && _currentUser!.profileImageUrl!.isNotEmpty) {
      imageProvider = FileImage(File(_currentUser!.profileImageUrl!));
    }

    return Center(
      child: Stack(
        children: [
          Container(
            width: 120, height: 120,
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]),
            child: ClipOval(
              child: imageProvider != null
                  ? Image(image: imageProvider, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.person, size: 60, color: Colors.grey))
                  : const Icon(Icons.person, size: 60, color: Colors.grey),
            ),
          ),
          if (_isEditing)
            Positioned(
              right: 0, bottom: 0,
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Color(0xFF007AFF), shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Informasi Pribadi', style: GoogleFonts.instrumentSans(color: const Color(0xFF1A2E35), fontSize: 16, fontWeight: FontWeight.w500)),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: const Color(0x194ADEDE), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0x4C4ADEDE))), child: Text(_role.toUpperCase(), style: GoogleFonts.instrumentSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF1A2E35))))
          ],
        ),
        const SizedBox(height: 16),

        _buildInfoField("Nama Pengguna", Icons.person_outline, _nameController),
        const SizedBox(height: 12),
        _buildInfoField("Email", Icons.email_outlined, _emailController),
        const SizedBox(height: 12),
        _buildInfoField("Nomor Telepon", Icons.phone_outlined, _phoneController),
        const SizedBox(height: 12),
        _infoCard("Lokasi", Icons.location_on_outlined, _location),
      ],
    );
  }

  Widget _buildInfoField(String label, IconData icon, TextEditingController controller) {
    if (_isEditing) {
      // MODE EDIT: Menggunakan TextField
      return TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF007AFF)),
          fillColor: Colors.white, filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        ),
      );
    } else {
      // MODE VIEW: Menggunakan Card Tampilan
      return _infoCard(label, icon, controller.text);
    }
  }

  Widget _infoCard(String label, IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.7), borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        Icon(icon, color: Colors.grey),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ])
      ]),
    );
  }

  Widget _buildEmergencyContacts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Kontak Darurat', style: GoogleFonts.instrumentSans(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        if (_emergencyContacts.isEmpty)
          const Text("Belum ada kontak darurat.", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
        else
          ..._emergencyContacts.asMap().entries.map((entry) {
            int idx = entry.key;
            var contact = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.7), borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    const Icon(Icons.phone, color: Colors.redAccent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(contact['label']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(contact['phone']!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ]),
                    ),
                    if (_isEditing)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteContact(idx), // Panggil fungsi hapus
                      )
                  ],
                ),
              ),
            );
          }),

        if (_isEditing)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: OutlinedButton.icon(
              onPressed: _showAddContactSheet, // Panggil popup tambah
              icon: const Icon(Icons.add),
              label: const Text("Tambah Kontak"),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: const BorderSide(color: Color(0xFF007AFF)),
              ),
            ),
          )
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF007AFF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        onPressed: _saveProfile,
        child: const Text('Simpan Perubahan', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}