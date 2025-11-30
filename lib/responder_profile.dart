import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class ResponderProfileScreen extends StatefulWidget {
  const ResponderProfileScreen({super.key});

  @override
  State<ResponderProfileScreen> createState() => _ResponderProfileScreenState();
}

class _ResponderProfileScreenState extends State<ResponderProfileScreen> {
  final TextEditingController _nameController =
      TextEditingController(text: 'Christopher Bang');
  final TextEditingController _emailController =
      TextEditingController(text: 'chris.bang@example.com');
  final TextEditingController _phoneController =
      TextEditingController(text: '+62 812 3456 7890');
  final TextEditingController _locationController =
      TextEditingController(text: 'Gunungpati, Kota Semarang');

  final List<String> _responderTypes = [
    'Polisi',
    'Pemadam Kebakaran',
    'Administrasi',
    'Tenaga Kesehatan',
    'Tenaga Ahli',
  ];

  String? _selectedResponderType = 'Polisi';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

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
            colors: [
              Color(0xFFE0EBF0),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _topBar(),
                    const SizedBox(height: 32),
                    _avatarSection(),
                    const SizedBox(height: 24),
                    _personalInfoSection(),
                    const SizedBox(height: 24),
                    _emergencyContactsSection(),
                    const SizedBox(height: 24),
                    _saveButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────── BACKGROUND BLUR
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
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment(0.00, 0.00),
                  end: Alignment(1.00, 1.00),
                  colors: [Color(0xFF4ADEDE), Color(0xFFA3E42F)],
                ),
                borderRadius: BorderRadius.circular(38741600),
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
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment(1.00, 0.00),
                  end: Alignment(0.00, 1.00),
                  colors: [Color(0xFFA3E42F), Color(0xFF4ADEDE)],
                ),
                borderRadius: BorderRadius.circular(38741600),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ───────────────── TOP BAR
  Widget _topBar() {
    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 44,
            height: 44,
            decoration: ShapeDecoration(
              color: Colors.white.withOpacity(0.60),
              shape: RoundedRectangleBorder(
                side: const BorderSide(
                  width: 1.15,
                  color: Color(0x4C4ADEDE),
                ),
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
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 18, color: Color(0xFF1A2E35)),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          'Profil Responder',
          style: GoogleFonts.instrumentSans(
            color: const Color(0xFF1A2E35),
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ───────────────── AVATAR
  Widget _avatarSection() {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: ShapeDecoration(
          color: Colors.white.withOpacity(0),
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              width: 1.15,
              color: Color(0x4C4ADEDE),
            ),
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
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/118x118"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 4,
              bottom: 4,
              child: Container(
                width: 48,
                height: 48,
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
                  shadows: const [
                    BoxShadow(
                      color: Color(0x4C4ADEDE),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: const Icon(Icons.edit_rounded,
                    size: 20, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────── PERSONAL INFO + JENIS RESPONDER
  Widget _personalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informasi Responder',
          style: GoogleFonts.instrumentSans(
            color: const Color(0xFF1A2E35),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        _infoTextFieldCard(
          label: 'Nama Pengguna',
          icon: Icons.person_outline_rounded,
          controller: _nameController,
        ),
        const SizedBox(height: 12),
        _infoTextFieldCard(
          label: 'Email',
          icon: Icons.mail_outline_rounded,
          controller: _emailController,
        ),
        const SizedBox(height: 12),
        _infoTextFieldCard(
          label: 'Nomor Telepon',
          icon: Icons.phone_outlined,
          controller: _phoneController,
        ),
        const SizedBox(height: 12),
        _infoTextFieldCard(
          label: 'Lokasi',
          icon: Icons.location_on_outlined,
          controller: _locationController,
        ),
        const SizedBox(height: 16),
        _responderTypeDropdownCard(), // <- aligned card
      ],
    );
  }

  Widget _infoTextFieldCard({
    required String label,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 14),
      decoration: ShapeDecoration(
        color: Colors.white.withOpacity(0.70),
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1.15,
            color: Color(0x264ADEDE),
          ),
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
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0x99192D34)),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  style: GoogleFonts.instrumentSans(
                    color: const Color(0xFF1A2E35),
                    fontSize: 14,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ───────────────── JENIS RESPONDER DROPDOWN (aligned like other cards)
  Widget _responderTypeDropdownCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: ShapeDecoration(
        color: Colors.white.withOpacity(0.95),
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1.15,
            color: Color(0x4C4ADEDE),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Jenis Responder',
            style: GoogleFonts.instrumentSans(
              color: const Color(0xFF1A2E35),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 45,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: ShapeDecoration(
              gradient: const LinearGradient(
                begin: Alignment(0.50, 0.00),
                end: Alignment(0.50, 1.00),
                colors: [Color(0x334ADEDE), Color(0x33A3E42F)],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedResponderType,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF1A2E35),
                ),
                style: GoogleFonts.instrumentSans(
                  color: const Color(0xFF1A2E35),
                  fontSize: 14,
                ),
                items: _responderTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Row(
                      children: [
                        const Icon(Icons.circle, // placeholder bullet
                            size: 8, color: Color(0xFF1A2E35)),
                        const SizedBox(width: 8),
                        Text(type),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedResponderType = value;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────── EMERGENCY CONTACTS (static mock like your design)
  Widget _emergencyContactsSection() {
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
        const SizedBox(height: 6),
        Text(
          'Tambahkan kontak yang dapat dihubungi dalam keadaan darurat',
          style: GoogleFonts.instrumentSans(
            color: const Color(0x99192D34),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        _emergencyContactCard(
          title: 'Ayah - Budi Santoso',
          phone: '+62 811 2222 3333',
        ),
        const SizedBox(height: 8),
        _emergencyContactCard(
          title: 'Ibu - Siti Rahayu',
          phone: '+62 812 4444 5555',
        ),
        const SizedBox(height: 8),
        _emergencyContactCard(
          title: 'Kontak 3',
          phone: '+62 812 0000 0000',
        ),
        const SizedBox(height: 12),
        _addEmergencyContactButton(),
      ],
    );
  }

  Widget _emergencyContactCard({
    required String title,
    required String phone,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: ShapeDecoration(
        color: Colors.white.withOpacity(0.70),
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1.15,
            color: Color(0x264ADEDE),
          ),
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
          const Icon(Icons.person_outline_rounded,
              size: 20, color: Color(0x99192D34)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
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
          Container(
            width: 40,
            height: 40,
            decoration: ShapeDecoration(
              color: const Color(0x19E7000B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Icon(Icons.call_rounded,
                size: 18, color: Color(0xFFE7000B)),
          ),
        ],
      ),
    );
  }

  Widget _addEmergencyContactButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _showSnack('Tambah Kontak Darurat (mock-up)'),
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: ShapeDecoration(
          gradient: const LinearGradient(
            begin: Alignment(0.50, 0.00),
            end: Alignment(0.50, 1.00),
            colors: [Color(0x334ADEDE), Color(0x33A3E42F)],
          ),
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              width: 1.15,
              color: Color(0x4C4ADEDE),
            ),
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

  // ───────────────── SAVE BUTTON
  Widget _saveButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _showSnack('Perubahan profil responder disimpan.'),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: ShapeDecoration(
          color: const Color(0xCCE7000B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x4C4ADEDE),
              blurRadius: 12,
              offset: Offset(0, 6),
              spreadRadius: -2,
            )
          ],
        ),
        child: Center(
          child: Text(
            'Simpan Perubahan',
            style: GoogleFonts.instrumentSans(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
