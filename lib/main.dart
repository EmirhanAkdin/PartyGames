import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/constants/colors.dart';
import 'core/services/service_locator.dart';
import 'core/services/theme_provider.dart';
import 'core/services/sound_service.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Backend Selection:
  // - LOCAL: Same device multiplayer (FREE, offline)
  // - WEBSOCKET: Real multiplayer on WiFi (Server running: http://192.168.1.117:3000)
  // - FIREBASE: Cloud multiplayer (requires Firebase setup)
  
  // 🏠 LOCAL MODE - Offline, aynı telefonda test (APK için)
  await ServiceLocator.initialize(useWebSocket: false);
  
  // 🎮 MULTIPLAYER MODE - Server çalışıyor! İki telefonda test için
  // await ServiceLocator.initialize(
  //   useWebSocket: true,
  //   serverUrl: 'http://192.168.1.117:3000', // ✅ Server aktif
  // );
  
  // Initialize services
  final themeProvider = ThemeProvider();
  await themeProvider.initialize();
  
  await SoundService().initialize();
  
  // Check first launch
  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = prefs.getBool('first_launch') ?? true;
  
  runApp(MyApp(
    themeProvider: themeProvider,
    isFirstLaunch: isFirstLaunch,
  ));
}

class MyApp extends StatelessWidget {
  final ThemeProvider themeProvider;
  final bool isFirstLaunch;

  const MyApp({
    super.key,
    required this.themeProvider,
    required this.isFirstLaunch,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: themeProvider,
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) => MaterialApp(
          title: 'Mini Oyunlar',
          debugShowCheckedModeBanner: false,
          themeMode: theme.themeMode,
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          home: _AppHome(isFirstLaunch: isFirstLaunch),
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: AppColors.backgroundColor,
      textTheme: GoogleFonts.poppinsTextTheme().apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: Colors.grey[100],
      textTheme: GoogleFonts.poppinsTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.grey[900],
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _AppHome extends StatefulWidget {
  final bool isFirstLaunch;

  const _AppHome({required this.isFirstLaunch});

  @override
  State<_AppHome> createState() => _AppHomeState();
}

class _AppHomeState extends State<_AppHome> {
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _showOnboarding = widget.isFirstLaunch;
  }

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_launch', false);
    setState(() => _showOnboarding = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_showOnboarding) {
      return OnboardingScreen(onComplete: _completeOnboarding);
    }
    return const HomeScreen();
  }
}

