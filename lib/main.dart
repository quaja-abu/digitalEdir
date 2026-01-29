import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:digitaledir/core/config/environment.dart';
import 'package:provider/provider.dart';
import 'package:digitaledir/app.dart';
import 'package:digitaledir/core/providers/auth_provider.dart';
import 'package:digitaledir/core/providers/edir_provider.dart';
import 'package:digitaledir/core/providers/contribution_provider.dart';
import 'package:digitaledir/core/providers/admin_provider.dart';
import 'package:digitaledir/core/providers/service_provider.dart';
import 'package:digitaledir/core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //
  // Initialize services
  await ServiceProvider.init();

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Demo notifications
  await notificationService.showWelcomeNotification();

  final tomorrow = DateTime.now().add(const Duration(days: 1));
  await notificationService.scheduleContributionReminder(tomorrow);
  if (kDebugMode) {
    print('🌍 API BASE URL: ${EnvironmentConfig.apiBaseUrl}');
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EdirProvider()),
        ChangeNotifierProvider(create: (_) => ContributionProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: const DigitalEdirApp(),
    ),
  );
}
