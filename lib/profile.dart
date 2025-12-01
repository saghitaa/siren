import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'Christopher Bang';
  String _email = 'chris.bang@example.com';
  String _phone = '+62 812 3456 7890';
  String _location = 'Gunungpati, Kota Semarang';

  final List<Map<String, String>> _emergencyContacts = [
    {'label': 'Ma Fren - Budi Santoso', 'phone': '+62 811 2222 3333'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0EBF0),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE0EBF0), Color(0xFFF0F9FF), Color(0xFFE8F8F5)],
          ),
        ),
        child: Stack(
          children: [
            // BACKGROUND BLURS
            Positioned(
              left: 92,
              top: -73,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Opacity(
                  opacity: 0.59,
                  child: Container(
                    width: 421,
                    height: 421,
                    decoration: ShapeDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment(0, 0),
                        end: Alignment(1, 1),
                        colors: [Color(0xFF4ADEDE), Color(0xFFA3E42F)],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(99999),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: -120,
              top: 602,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Opacity(
                  opacity: 0.40,
                  child: Container(
                    width: 350,
                    height: 350,
                    decoration: ShapeDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment(1, 0),
                        end: Alignment(0, 1),
                        colors: [Color(0xFFA3E42F), Color(0xFF4ADEDE)],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(99999),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // MAIN CONTENT
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
                    _buildPersonalInfo(),
                    const SizedBox(height: 24),
                    _buildEmergencyContacts(),
                    const SizedBox(height: 24),
                    _buildSaveButton(),
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

  // TOP BAR
  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 44,
            height: 44,
            decoration: ShapeDecoration(
              color: Colors.white.withValues(alpha: 0.60),
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 1.15, color: Color(0x4C4ADEDE)),
                borderRadius: BorderRadius.circular(14),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x19000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: Color(0xFF1A2E35),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          "Profil Anda",
          style: GoogleFonts.instrumentSans(
            color: const Color(0xFF1A2E35),
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        )
      ],
    );
  }

  // AVATAR
  Widget _buildAvatar() {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 1.15, color: Color(0x4C4ADEDE)),
                borderRadius: BorderRadius.circular(24),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x334ADEDE),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.network(
                "https://placehold.co/200x200",
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            right: -4,
            bottom: -4,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {},
              child: Container(
                width: 48,
                height: 48,
                decoration: ShapeDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4ADEDE), Color(0xFFA3E42F)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 1.15, color: Colors.white),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x4C4ADEDE),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: const Icon(Icons.edit_rounded,
                    color: Color(0xFF1A2E35), size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // PERSONAL INFO
  Widget _buildPersonalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informasi Pribadi',
          style: GoogleFonts.instrumentSans(
            color: const Color(0xFF1A2E35),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),

        _infoCard("Nama Pengguna", Icons.person_outline, _name),
        const SizedBox(height: 12),
        _infoCard("Email", Icons.email_outlined, _email),
        const SizedBox(height: 12),
        _infoCard("Nomor Telepon", Icons.phone_outlined, _phone),
        const SizedBox(height: 12),
        _infoCard("Lokasi", Icons.location_on_outlined, _location),
      ],
    );
  }

  Widget _infoCard(String label, IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.fromLTRB(17, 17, 17, 12),
      decoration: ShapeDecoration(
        color: Colors.white.withValues(alpha: 0.70),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1.15, color: Color(0x264ADEDE)),
          borderRadius: BorderRadius.circular(16),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
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
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0x7F192D34)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: GoogleFonts.instrumentSans(
                    color: const Color(0x7F192D34),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // EMERGENCY CONTACTS
  Widget _buildEmergencyContacts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kontak Darurat',
          style: GoogleFonts.instrumentSans(
            color: const Color(0xFF1A2E35),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tambahkan kontak yang dapat dihubungi dalam keadaan darurat',
          style: GoogleFonts.instrumentSans(
            color: const Color(0x99192D34),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 16),

        // List of contacts
        Column(
          children: [
            for (int i = 0; i < _emergencyContacts.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _contactCard(
                  label: _emergencyContacts[i]['label']!,
                  phone: _emergencyContacts[i]['phone']!,
                  index: i,
                ),
              ),

            _addContactButton(),
          ],
        ),
      ],
    );
  }

  Widget _contactCard({
    required String label,
    required String phone,
    required int index,
  }) {
    return Container(
      height: 75,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: ShapeDecoration(
        color: Colors.white.withValues(alpha: 0.70),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1.15, color: Color(0x264ADEDE)),
          borderRadius: BorderRadius.circular(16),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.person_rounded,
              size: 20, color: Color(0x7F192D34)),
          const SizedBox(width: 16),

          // NAME + PHONE
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.instrumentSans(
                    color: const Color(0xFF1A2E35),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  phone,
                  style: GoogleFonts.instrumentSans(
                    color: const Color(0x99192D34),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // DELETE BUTTON
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _confirmDelete(index),
            child: Container(
              width: 40,
              height: 40,
              decoration: ShapeDecoration(
                color: const Color(0x19E7000B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Icon(
                Icons.delete_rounded,
                size: 20,
                color: Color(0xFFE7000B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // DELETE CONTACT CONFIRMATION
  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(
            'Hapus Kontak?',
            style: GoogleFonts.instrumentSans(
              color: const Color(0xFF1A2E35),
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Kontak darurat ini akan dihapus secara permanen.',
            style: GoogleFonts.instrumentSans(
              color: const Color(0x99192D34),
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal',
                  style: GoogleFonts.instrumentSans(
                      color: const Color(0xFF1A2E35))),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _emergencyContacts.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: Text(
                'Hapus',
                style: GoogleFonts.instrumentSans(
                  color: const Color(0xFFE7000B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ADD CONTACT BUTTON
  Widget _addContactButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: _showAddContactSheet,
      child: Container(
        height: 56,
        decoration: ShapeDecoration(
          gradient: const LinearGradient(
            colors: [Color(0x334ADEDE), Color(0x33A3E42F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(width: 1.15, color: Color(0x4C4ADEDE)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_rounded,
                size: 20, color: Color(0xFF1A2E35)),
            const SizedBox(width: 8),
            Text(
              'Tambah Kontak Darurat',
              style: GoogleFonts.instrumentSans(
                color: const Color(0xFF1A2E35),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ADD CONTACT POPUP
  void _showAddContactSheet() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0x22000000),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Tambah Kontak Darurat',
                  style: GoogleFonts.instrumentSans(
                    color: const Color(0xFF1A2E35),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Nama / Hubungan',
                  labelStyle: GoogleFonts.instrumentSans(
                    color: const Color(0x99192D34),
                    fontSize: 13,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Nomor Telepon',
                  labelStyle: GoogleFonts.instrumentSans(
                    color: const Color(0x99192D34),
                    fontSize: 13,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: const BorderSide(color: Color(0x334ADEDE)),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        'Batal',
                        style: GoogleFonts.instrumentSans(
                          color: const Color(0x99192D34),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF28CFD7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        if (nameCtrl.text.trim().isEmpty ||
                            phoneCtrl.text.trim().isEmpty) return;

                        setState(() {
                          _emergencyContacts.add({
                            'label': nameCtrl.text.trim(),
                            'phone': phoneCtrl.text.trim(),
                          });
                        });

                        Navigator.pop(ctx);
                      },
                      child: Text(
                        'Simpan',
                        style: GoogleFonts.instrumentSans(color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // SAVE BUTTON
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xCCE7000B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6,
        ),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perubahan disimpan')),
          );
        },
        child: Text(
          'Simpan Perubahan',
          style: GoogleFonts.instrumentSans(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
