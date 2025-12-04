import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'services/auth_service.dart';
import 'models/user_model.dart';
import 'services/database_service.dart'; // Tambahkan ini

class ResponderProfileScreen extends StatefulWidget {
  const ResponderProfileScreen({super.key});

  @override
  State<ResponderProfileScreen> createState() => _ResponderProfileScreenState();
}

class _ResponderProfileScreenState extends State<ResponderProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controller Text
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;

  // State Foto & User
  User? _currentUser;
  String? _currentPhotoPath;
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  bool _isEditing = false;

  // Opsi Jenis Responder
  final List<String> _responderTypes = [
    'Polisi',
    'Pemadam Kebakaran',
    'Administrasi',
    'Tenaga Kesehatan',
    'Tenaga Ahli',
    'Responder' // Default fallback
  ];
  String _selectedResponderType = 'Responder';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _locationController = TextEditingController(text: 'Gunungpati, Kota Semarang');
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // --- LOAD DATA PETUGAS ---
  Future<void> _loadUserData() async {
    // Ambil user dari AuthService (Memori)
    User? user = AuthService.instance.currentUser;

    // Pastikan kita punya data terbaru dari DB (terutama jika status berubah di tempat lain)
    if (user != null) {
       await DatabaseService.instance.init();
       final dbUser = await DatabaseService.instance.getUserById(int.tryParse(user.id) ?? 0);
       if (dbUser != null) {
         user = dbUser; 
         // Opsional: Update AuthService jika DB lebih baru (biasanya diurus AuthService sih)
       }
    }

    _currentUser = user;

    if (_currentUser != null) {
      if (!mounted) return;
      setState(() {
        _nameController.text = _currentUser!.displayName;
        _emailController.text = _currentUser!.email;
        _phoneController.text = _currentUser!.phone;
        _currentPhotoPath = _currentUser!.profileImageUrl;

        // Coba cocokkan role user dengan dropdown
        String currentRole = _currentUser!.role;
        String roleCap = currentRole.isNotEmpty
            ? "${currentRole[0].toUpperCase()}${currentRole.substring(1)}"
            : 'Responder';

        // Perbaiki format jika role di DB "Polisi" tapi di list "polisi" atau sebaliknya
        // Kita cari yang match insensitive
        final match = _responderTypes.firstWhere(
            (t) => t.toLowerCase() == roleCap.toLowerCase(), 
            orElse: () => 'Responder'
        );

        _selectedResponderType = match;
      });
    }
  }

  // --- GANTI FOTO ---
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

  // --- SIMPAN PROFIL (DIPERBAIKI) ---
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Memanggil updateProfile di AuthService
        await AuthService.instance.updateProfile(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          photoPath: _pickedImage?.path,
          contacts: _currentUser?.contacts, // Pertahankan kontak lama

          // PERBAIKAN UTAMA: Kirim role yang dipilih dalam format lowercase
          role: _selectedResponderType.toLowerCase(),
        );

        setState(() {
          _isEditing = false;
          if (_pickedImage != null) {
            _currentPhotoPath = _pickedImage!.path;
            _pickedImage = null;
          }
        });

        if (!mounted) return;
        _showSnack("Profil Petugas diperbarui!", isError: false);
        _loadUserData(); // Refresh data lokal agar tampilan terupdate

      } catch (e) {
        _showSnack("Gagal update: $e", isError: true);
      }
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FA),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5F9FA),
              Color(0xFFF0F9FF),
              Color(0xFFE8F8F5),
            ],
          ),
        ),
        child: Stack(
          children: [
            _backgroundBlur(),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _topBar(context),
                      const SizedBox(height: 24),
                      _avatarCard(),
                      const SizedBox(height: 24),
                      _personalInfoSection(),
                      const SizedBox(height: 24),
                      _responderTypeSection(),
                      const SizedBox(height: 32),

                      // Tombol Simpan (Hanya muncul saat mode Edit)
                      if (_isEditing) _saveButton(),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _backgroundBlur() {
    return Stack(
      children: [
        Positioned(
          left: 91.99,
          top: -72.97,
          child: Opacity(
            opacity: 0.59,
            child: Container(
              width: 420.76,
              height: 420.76,
              decoration: ShapeDecoration(
                gradient: const LinearGradient(
                  begin: Alignment(0.00, 0.00),
                  end: Alignment(1.00, 1.00),
                  colors: [Color(0xFF4ADEDE), Color(0xFFA3E42F)],
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(38741600),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: -119.99,
          top: 602.10,
          child: Opacity(
            opacity: 0.40,
            child: Container(
              width: 349.98,
              height: 349.98,
              decoration: ShapeDecoration(
                gradient: const LinearGradient(
                  begin: Alignment(1.00, 0.00),
                  end: Alignment(0.00, 1.00),
                  colors: [Color(0xFFA3E42F), Color(0xFF4ADEDE)],
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(38741600),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _topBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 43.98,
                height: 43.98,
                decoration: ShapeDecoration(
                  color: Colors.white.withOpacity(0.60),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 1.15, color: Color(0x4C4ADEDE)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  shadows: const [BoxShadow(color: Color(0x19000000), blurRadius: 4, offset: Offset(0, 2))],
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF1A2E35)),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Profil Responder',
              style: GoogleFonts.instrumentSans(
                color: const Color(0xFF1A2E35),
                fontSize: 20,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ],
        ),
        // Tombol Edit / Batal
        IconButton(
          onPressed: () {
            setState(() {
              _isEditing = !_isEditing;
              if (!_isEditing) _loadUserData(); // Reset data jika batal
            });
          },
          icon: Icon(
            _isEditing ? Icons.close : Icons.edit,
            color: const Color(0xFF1A2E35),
          ),
        ),
      ],
    );
  }

  Widget _avatarCard() {
    ImageProvider? imageProvider;
    if (_pickedImage != null) {
      imageProvider = FileImage(_pickedImage!);
    } else if (_currentPhotoPath != null && _currentPhotoPath!.isNotEmpty) {
      imageProvider = FileImage(File(_currentPhotoPath!));
    }

    return Center(
      child: Stack(
        children: [
          Container(
            width: 119.99,
            height: 119.99,
            decoration: ShapeDecoration(
              color: Colors.white.withOpacity(0),
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 1.15, color: Color(0x4C4ADEDE)),
                borderRadius: BorderRadius.circular(24),
              ),
              shadows: const [BoxShadow(color: Color(0x334ADEDE), blurRadius: 12, offset: Offset(0, 4))],
            ),
            child: Padding(
              padding: const EdgeInsets.all(1.15),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: imageProvider != null
                    ? Image(image: imageProvider, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: Colors.grey[300], child: const Icon(Icons.person, size: 60, color: Colors.grey)))
                    : Container(color: Colors.grey[300], child: const Icon(Icons.person, size: 60, color: Colors.grey)),
              ),
            ),
          ),
          // Ikon Kamera (Hanya muncul saat Edit)
          if (_isEditing)
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 47.99,
                  height: 47.99,
                  decoration: ShapeDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment(0.50, 0.00),
                      end: Alignment(0.50, 1.00),
                      colors: [Color(0xFF4ADEDE), Color(0xFFA3E42F)],
                    ),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(width: 1.15, color: Colors.white),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    shadows: const [BoxShadow(color: Color(0x4C4ADEDE), blurRadius: 8, offset: Offset(0, 4))],
                  ),
                  child: const Icon(Icons.camera_alt_rounded, size: 22, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _personalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Informasi Responder',
            style: GoogleFonts.instrumentSans(
              color: const Color(0xFF1A2E35),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ),
        _buildTextField("Nama Pengguna", _nameController, Icons.person_outline_rounded),
        const SizedBox(height: 12),
        _buildTextField("Email", _emailController, Icons.mail_outline_rounded, keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 12),
        _buildTextField("Nomor Telepon", _phoneController, Icons.phone_outlined, keyboardType: TextInputType.phone),
        const SizedBox(height: 12),
        _buildTextField("Lokasi", _locationController, Icons.location_on_outlined),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 17.14, left: 17.14, right: 17.14, bottom: 11),
      decoration: ShapeDecoration(
        color: _isEditing ? Colors.white : Colors.white.withOpacity(0.70),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1.15,
            color: _isEditing ? const Color(0xFF007AFF) : const Color(0x264ADEDE),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        shadows: const [BoxShadow(color: Color(0x0C000000), blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.instrumentSans(
              color: const Color(0x99192D34),
              fontSize: 11,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Icon(
                  icon,
                  size: 18,
                  color: const Color(0x99192D34),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  enabled: _isEditing,
                  keyboardType: keyboardType,
                  style: GoogleFonts.instrumentSans(
                    color: const Color(0xFF192D34).withOpacity(0.75),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Tidak boleh kosong' : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _responderTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Jenis Responder',
            style: GoogleFonts.instrumentSans(
              color: const Color(0xFF1A2E35),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 9.15),
          decoration: ShapeDecoration(
            color: _isEditing ? Colors.white : Colors.white.withOpacity(0.95),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1.15,
                color: _isEditing ? const Color(0xFF007AFF) : const Color(0x4C4ADEDE),
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            shadows: const [BoxShadow(color: Color(0x26000000), blurRadius: 24, offset: Offset(0, 8))],
          ),
          child: DropdownButtonHideUnderline(
            child: IgnorePointer(
              ignoring: !_isEditing,
              child: DropdownButton<String>(
                value: _selectedResponderType,
                isExpanded: true,
                icon: const Icon(
                  Icons.expand_more_rounded,
                  color: Color(0xFF1A2E35),
                ),
                borderRadius: BorderRadius.circular(16),
                items: _responderTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: Icon(
                              Icons.shield_outlined,
                              size: 18,
                              color: Color(0x99192D34),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            type,
                            style: GoogleFonts.instrumentSans(
                              color: const Color(0xFF1A2E35),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _selectedResponderType = value;
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE7000B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6,
          shadowColor: const Color(0x4C4ADEDE),
        ),
        child: Text(
          'Simpan Perubahan',
          style: GoogleFonts.instrumentSans(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}