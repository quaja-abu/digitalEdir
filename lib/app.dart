import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:digitaledir/presentation/screens/splash_screen.dart';
import 'package:digitaledir/presentation/screens/onboarding_screen.dart';
import 'package:digitaledir/presentation/screens/auth_screen.dart';
import 'package:digitaledir/presentation/screens/otp_screen.dart';
import 'package:digitaledir/presentation/screens/home_screen.dart';
import 'package:digitaledir/presentation/screens/admin/admin_dashboard_screen.dart';
import 'package:digitaledir/core/providers/auth_provider.dart';
import 'package:digitaledir/core/theme/app_theme.dart';

class DigitalEdirApp extends StatefulWidget {
  const DigitalEdirApp({super.key});

  @override
  State<DigitalEdirApp> createState() => _DigitalEdirAppState();
}

class _DigitalEdirAppState extends State<DigitalEdirApp> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize auth provider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.initialize();

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        home: Scaffold(
          backgroundColor: AppTheme.primaryColor,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Colors.white,
                ),
                SizedBox(height: 20),
                Text(
                  'Initializing Digital Edir...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Digital Edir',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const SplashScreen(),
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/auth': (context) => const AuthScreen(),
        '/otp': (context) => const OTPScreen(email: '', phone: ''),
        '/home': (context) => const HomeScreen(),
        '/admin': (context) => const AdminDashboardScreen(),
        // Add other routes as needed
      },
      onGenerateRoute: (settings) {
        // Handle dynamic routes
        return null;
      },
    );
  }
}
