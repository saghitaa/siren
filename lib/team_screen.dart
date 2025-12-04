import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/user_model.dart';
import 'services/database_service.dart';
import 'services/auth_service.dart';
import 'chat_screen.dart'; // Import Chat Screen

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  bool _isLoading = true;
  Map<String, List<User>> _groupedResponders = {};
  Map<String, String> _onlineStatus = {};
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = AuthService.instance.currentUser?.id;
    _loadTeamData();
  }

  Future<void> _loadTeamData() async {
    try {
      await DatabaseService.instance.init();
      final allResponders = await DatabaseService.instance.getAllResponders();

      final Map<String, List<User>> grouped = {};
      final Map<String, String> status = {};

      for (var user in allResponders) {
        // Jangan tampilkan diri sendiri di list
        if (user.id == _currentUserId) continue;

        String role = user.role.trim();
        if (role.isEmpty) role = 'Lainnya';
        String roleKey = "${role[0].toUpperCase()}${role.substring(1).toLowerCase()}";

        if (!grouped.containsKey(roleKey)) {
          grouped[roleKey] = [];
        }
        grouped[roleKey]!.add(user);
        status[user.id] = user.status;
      }

      if (!mounted) return;
      setState(() {
        _groupedResponders = grouped;
        _onlineStatus = status;
        _isLoading = false;
      });

    } catch (e) {
      debugPrint("Error loading team: $e");
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FA),
      appBar: AppBar(
        title: Text(
          "Tim Responder",
          style: GoogleFonts.instrumentSans(
              color: const Color(0xFF1A2E35),
              fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A2E35)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _groupedResponders.isEmpty
          ? Center(child: Text("Belum ada anggota tim lain.", style: GoogleFonts.instrumentSans(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _groupedResponders.length,
              itemBuilder: (context, index) {
                String role = _groupedResponders.keys.elementAt(index);
                List<User> members = _groupedResponders[role]!;
                return _buildRoleSection(role, members);
              },
            ),
    );
  }

  Widget _buildRoleSection(String role, List<User> members) {
    int onlineCount = 0;
    int offlineCount = 0;
    for (var m in members) {
      if (_onlineStatus[m.id] == 'Online') {
        onlineCount++;
      } else {
        offlineCount++;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 8, bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
            ]
          ),
          child: Row(
            children: [
              _getRoleIcon(role),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role,
                      style: GoogleFonts.instrumentSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A2E35),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _statusBadge("Online", onlineCount, Colors.green),
                        const SizedBox(width: 8),
                        _statusBadge("Offline", offlineCount, Colors.grey),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        ...members.map((user) => _buildMemberCard(user)).toList(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _statusBadge(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1)
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            "$count $label",
            style: GoogleFonts.instrumentSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(User user) {
    final isOnline = _onlineStatus[user.id] == 'Online';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.blueGrey[50],
              backgroundImage: (user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty)
                  ? FileImage(File(user.profileImageUrl!))
                  : null,
              child: (user.profileImageUrl == null || user.profileImageUrl!.isEmpty)
                  ? const Icon(Icons.person, color: Colors.blueGrey)
                  : null,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: isOnline ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            )
          ],
        ),
        title: Text(
          user.displayName,
          style: GoogleFonts.instrumentSans(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          isOnline ? "Sedang Bertugas" : "Tidak Aktif",
          style: GoogleFonts.instrumentSans(
              color: isOnline ? Colors.green[700] : Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w500
          ),
        ),
        trailing: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF007AFF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.message_rounded, color: Color(0xFF007AFF), size: 20),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(receiver: user),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _getRoleIcon(String role) {
    IconData icon;
    Color color;

    switch (role.toLowerCase()) {
      case 'polisi': icon = Icons.local_police; color = Colors.blue[800]!; break;
      case 'pemadam kebakaran': icon = Icons.local_fire_department; color = Colors.orange[800]!; break;
      case 'tenaga kesehatan': icon = Icons.medical_services; color = Colors.red[700]!; break;
      case 'administrasi': icon = Icons.admin_panel_settings; color = Colors.teal; break;
      case 'tenaga ahli': icon = Icons.engineering; color = Colors.purple; break;
      default: icon = Icons.shield; color = Colors.grey[700]!;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}