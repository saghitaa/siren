import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/forum_service.dart';
import '../services/report_service.dart';
import '../services/sos_service.dart';
import '../services/fcm_service.dart';

/// Provider untuk inject services ke UI (menggunakan InheritedWidget sederhana).
class AppStateProvider extends InheritedWidget {
  final AuthService authService;
  final ForumService forumService;
  final ReportService reportService;
  final SOSService sosService;
  final FCMService fcmService;

  const AppStateProvider({
    super.key,
    required super.child,
    required this.authService,
    required this.forumService,
    required this.reportService,
    required this.sosService,
    required this.fcmService,
  });

  static AppStateProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppStateProvider>();
  }

  @override
  bool updateShouldNotify(AppStateProvider oldWidget) {
    return false; // Services tidak berubah
  }
}

