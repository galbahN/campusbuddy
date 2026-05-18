import 'package:campusbuddy/services/auth_service.dart';
import 'package:campusbuddy/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService().initialize();
  runApp(const CampusBuddyApp());
}

class CampusBuddyApp extends StatefulWidget {
  const CampusBuddyApp({super.key});

  @override
  State<CampusBuddyApp> createState() => _CampusBuddyAppState();
}

class _CampusBuddyAppState extends State<CampusBuddyApp>
    with WidgetsBindingObserver {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authService.setOnlineStatus(true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authService.setOnlineStatus(false);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _authService.setOnlineStatus(true);
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _authService.setOnlineStatus(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampusBuddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A73E8),
          primary: const Color(0xFF1A73E8),
          secondary: const Color(0xFF0D47A1),
          surface: const Color(0xFFFFFFFF),
          error: const Color(0xFFD32F2F),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
