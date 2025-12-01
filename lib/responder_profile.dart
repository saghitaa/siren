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

  String _selectedResponderType = 'Polisi';

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
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
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 43.98,
            height: 43.98,
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
                ),
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
          'Profil Responder',
          style: GoogleFonts.instrumentSans(
            color: const Color(0xFF1A2E35),
            fontSize: 20,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _avatarCard() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 119.99,
            height: 119.99,
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
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(1.15),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/118x118"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () {
                _showSnack('Fitur ubah foto akan ditambahkan nanti.');
              },
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
                  shadows: const [
                    BoxShadow(
                      color: Color(0x4C4ADEDE),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 22,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: GoogleFonts.instrumentSans(
          color: const Color(0xFF1A2E35),
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _personalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Informasi Responder'),
        const SizedBox(height: 8),
        _infoCard(
          label: 'Nama Pengguna',
          controller: _nameController,
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 12),
        _infoCard(
          label: 'Email',
          controller: _emailController,
          icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        _infoCard(
          label: 'Nomor Telepon',
          controller: _phoneController,
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        _infoCard(
          label: 'Lokasi',
          controller: _locationController,
          icon: Icons.location_on_outlined,
        ),
      ],
    );
  }

  Widget _infoCard({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 17.14,
        left: 17.14,
        right: 17.14,
        bottom: 11,
      ),
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
          ),
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
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: GoogleFonts.instrumentSans(
                    color: const Color(0xFF192D34).withOpacity(0.75),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
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

  Widget _responderTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Jenis Responder'),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 9.15),
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
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
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
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Icon(
                            Icons.shield_outlined,
                            size: 18,
                            color: const Color(0x99192D34),
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
      ],
    );
  }

  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          _showSnack('Perubahan profil responder disimpan.');
        },
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
