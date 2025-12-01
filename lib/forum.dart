import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'dashboard.dart';
import 'report.dart';
import 'responder_dashboard.dart';

class ForumScreen extends StatefulWidget {
  final bool isResponder;

  const ForumScreen({
    super.key,
    this.isResponder = false,
  });

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final TextEditingController _postController = TextEditingController();
  final List<Map<String, dynamic>> _posts = [];

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

void _handlePost() {
  if (_postController.text.trim().isEmpty) return;

  setState(() {
    _posts.insert(0, {
      'name': 'Nama Pengguna',
      'time': 'Baru saja',
      'role': widget.isResponder ? 'Responder' : 'Warga', 
      'content': _postController.text.trim(),
      'replies': 0,
      'likes': 0,
      'profileImageUrl': null,
    });
    _postController.clear();
    FocusScope.of(context).unfocus();
  });
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
            Positioned(
              left: -48,
              top: 726,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Opacity(
                  opacity: 0.59,
                  child: Container(
                    width: 493,
                    height: 367,
                    decoration: const ShapeDecoration(
                      color: Color(0x331A2E35),
                      shape: OvalBorder(),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: -84,
              top: -169,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Opacity(
                  opacity: 0.59,
                  child: Container(
                    width: 558,
                    height: 283,
                    decoration: const ShapeDecoration(
                      color: Color(0x704ADEDE),
                      shape: OvalBorder(),
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildAppBarContent(),
                      const SizedBox(height: 24),
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildCreatePostCard(),
                      const SizedBox(height: 24),
                      ..._posts.map(
                        (post) => Column(
                          children: [
                            _buildForumPost(
                              name: post['name'],
                              time: post['time'],
                              role: post['role'],
                              content: post['content'],
                              replies: post['replies'],
                              likes: post['likes'],
                              profileImageUrl: post['profileImageUrl'],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child:
                  widget.isResponder ? _buildResponderBottomNav() : _buildBottomNav(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 47,
              height: 47,
              decoration: ShapeDecoration(
                gradient: const LinearGradient(
                  begin: Alignment(0.50, 0.00),
                  end: Alignment(0.50, 1.00),
                  colors: [Color(0x4C4ADEDE), Color(0x5FA3E42F)],
                ),
                shape: RoundedRectangleBorder(
                  side:
                      const BorderSide(width: 1.16, color: Color(0xB2FFFFFF)),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Image.network(
                    'https://storage.googleapis.com/tagjs-prod.appspot.com/v1/aLLDYhj5gp/kk805w1s_expires_30_days.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SIREN',
                  style: GoogleFonts.orbitron(
                    color: const Color(0xFF1A2E35),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 4,
                  ),
                ),
                Text(
                  'Smart Integrated Report...',
                  style: GoogleFonts.instrumentSans(
                    color: const Color(0x99192D34),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const ShapeDecoration(
                color: Color(0x99FFFFFF),
                shape: OvalBorder(
                  side: BorderSide(width: 1.16, color: Color(0x334ADEDE)),
                ),
              ),
              child: const Icon(
                Icons.notifications_none_outlined,
                color: Color(0xFF1A2E35),
                size: 22,
              ),
            ),
            Positioned(
              right: -3,
              top: -3,
              child: Container(
                width: 16,
                height: 16,
                decoration: const ShapeDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(0.50, 0.00),
                    end: Alignment(0.50, 1.00),
                    colors: [Color(0xFF4ADEDE), Color(0xFFA3E42F)],
                  ),
                  shape: OvalBorder(
                    side: BorderSide(width: 1.16, color: Colors.white),
                  ),
                ),
                child: Center(
                  child: Text(
                    '3',
                    style: GoogleFonts.instrumentSans(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Forum Komunitas',
          style: GoogleFonts.instrumentSans(
            color: const Color(0xFF1A2E35),
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Berbagi keresahan dan keluhan anda disini!',
          style: GoogleFonts.instrumentSans(
            color: const Color(0x99192D34),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildCreatePostCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white.withValues(alpha: 0.70),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1.16,
            color: Colors.white.withValues(alpha: 0.80),
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 6,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _postController,
            maxLines: 3,
            minLines: 1,
            style: GoogleFonts.instrumentSans(
              color: const Color(0xFF1A2E35),
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: 'Buat kiriman baru',
              hintStyle: GoogleFonts.instrumentSans(
                color: const Color(0x99192D34),
                fontSize: 14,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Icon(
                  Icons.add_a_photo_outlined,
                  color: Color(0xFF1A2E35),
                  size: 18,
                ),
              ),
              GestureDetector(
                onTap: _handlePost,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: ShapeDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment(0.50, 0.00),
                      end: Alignment(0.50, 1.00),
                      colors: [Color(0xFFB3FFD5), Color(0xFF28CFD7)],
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Color(0x4C4ADEDE),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildForumPost({
    required String name,
    required String time,
    required String role,
    required String content,
    required int replies,
    required int likes,
    String? profileImageUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white.withValues(alpha: 0.70),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1.16, color: Color(0x334ADEDE)),
          borderRadius: BorderRadius.circular(16),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 4,
            offset: Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: ShapeDecoration(
                  color: const Color(0xFFE0EBF0),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      width: 1.16,
                      color: Color(0x4C4ADEDE),
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: profileImageUrl != null
                      ? Image.network(
                          profileImageUrl,
                          fit: BoxFit.cover,
                        )
                      : const Icon(
                          Icons.person,
                          color: Color(0x99192D34),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.instrumentSans(
                            color: const Color(0xFF1A2E35),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          time,
                          style: GoogleFonts.instrumentSans(
                            color: const Color(0x99192D34),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      role,
                      style: GoogleFonts.instrumentSans(
                        color: const Color(0x7F192D34),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.instrumentSans(
              color: const Color(0xCC1A2E35),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.favorite_border_rounded,
                size: 16,
                color: Color(0x99192D34),
              ),
              const SizedBox(width: 6),
              Text(
                '$likes',
                style: GoogleFonts.instrumentSans(
                  color: const Color(0x99192D34),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 16,
                color: Color(0x99192D34),
              ),
              const SizedBox(width: 6),
              Text(
                '$replies replies',
                style: GoogleFonts.instrumentSans(
                  color: const Color(0x99192D34),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    const int activeIndex = 0; // warga: 0=Forum, 1=Dashboard, 2=Laporan

    return Container(
      width: double.infinity,
      height: 90,
      decoration: const BoxDecoration(
        color: Color(0xCCFFFFFF),
        border: Border(
          top: BorderSide(width: 1.16, color: Color(0x334ADEDE)),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, -4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double slotWidth = constraints.maxWidth / 3;

          IconData activeIcon;
          switch (activeIndex) {
            case 0:
              activeIcon = Icons.forum_outlined;
              break;
            case 1:
              activeIcon = Icons.grid_view_outlined;
              break;
            case 2:
              activeIcon = Icons.assignment_outlined;
              break;
            default:
              activeIcon = Icons.forum_outlined;
          }

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: slotWidth,
                    child: _buildBottomNavItem(
                      icon: Icons.forum_outlined,
                      label: 'Forum',
                      isActive: activeIndex == 0,
                      onTap: () {},
                    ),
                  ),
                  SizedBox(
                    width: slotWidth,
                    child: _buildBottomNavItem(
                      icon: Icons.grid_view_outlined,
                      label: 'Dashboard',
                      isActive: activeIndex == 1,
                      onTap: () {
                        if (activeIndex == 1) return;
                        Navigator.of(context).pushReplacement(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const DashboardScreen(),
                            transitionsBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                              child,
                            ) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: slotWidth,
                    child: _buildBottomNavItem(
                      icon: Icons.assignment_outlined,
                      label: 'Laporan',
                      isActive: activeIndex == 2,
                      onTap: () {
                        if (activeIndex == 2) return;
                        Navigator.of(context).pushReplacement(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const ReportScreen(),
                            transitionsBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                              child,
                            ) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              Positioned(
                top: -25,
                left: slotWidth * activeIndex + slotWidth / 2 - 30,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: const ShapeDecoration(
                    color: Color(0xCCFFFFFF),
                    shape: CircleBorder(),
                    shadows: [
                      BoxShadow(
                        color: Color(0x19000000),
                        blurRadius: 15,
                        offset: Offset(0, 10),
                        spreadRadius: -3,
                      ),
                    ],
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(5),
                    decoration: const ShapeDecoration(
                      color: Color(0x89A3E42F),
                      shape: CircleBorder(),
                    ),
                    child: Icon(
                      activeIcon,
                      color: const Color(0xFF1A2E35),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final Color color =
        isActive ? const Color(0xFF1A2E35) : const Color(0x7F192D34);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.only(top: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: ShapeDecoration(
                color: isActive ? const Color(0x11A3E42F) : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: isActive
                  ? const SizedBox.shrink()
                  : Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 4),
            if (!isActive)
              Text(
                label,
                style: GoogleFonts.instrumentSans(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              )
            else
              const SizedBox(height: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildResponderBottomNav() {
    const int activeIndex = 0; // 0 = Forum, 1 = Dashboard

    return Container(
      height: 90,
      decoration: const BoxDecoration(
        color: Color(0xCCFFFFFF),
        border: Border(
          top: BorderSide(width: 1.16, color: Color(0x334ADEDE)),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _responderNavItem(
            icon: Icons.forum_outlined,
            label: 'Forum',
            index: 0,
            activeIndex: activeIndex,
            onTap: () {},
          ),
          _responderNavItem(
            icon: Icons.grid_view_outlined,
            label: 'Dashboard',
            index: 1,
            activeIndex: activeIndex,
            onTap: () {
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (_, animation, __) =>
                      const ResponderDashboardScreen(),
                  transitionsBuilder: (_, animation, __, child) =>
                      FadeTransition(opacity: animation, child: child),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _responderNavItem({
    required IconData icon,
    required String label,
    required int index,
    required int activeIndex,
    required VoidCallback onTap,
  }) {
    final bool isActive = index == activeIndex;

    if (isActive) {
      return GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const ShapeDecoration(
                color: Color(0xCCFFFFFF),
                shape: CircleBorder(),
                shadows: [
                  BoxShadow(
                    color: Color(0x19000000),
                    blurRadius: 15,
                    offset: Offset(0, 10),
                    spreadRadius: -3,
                  ),
                ],
              ),
              child: Container(
                margin: const EdgeInsets.all(5),
                decoration: const ShapeDecoration(
                  color: Color(0x89A3E42F),
                  shape: CircleBorder(),
                ),
                child: const Icon(
                  Icons.forum_outlined,
                  color: Color(0xFF1A2E35),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: const Color(0x7F192D34)),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.instrumentSans(
                fontSize: 11,
                color: const Color(0x7F192D34),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
