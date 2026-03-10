import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'providers/theme_provider.dart';
import 'providers/font_scale_provider.dart';
import 'core/config/env.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'l10n/generated/app_localizations.dart';
import 'services/notification_service.dart';


import 'dart:io';

// Custom HttpOverrides to handle self-signed certificates
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // Trust the specific AWS IP for backend configured in EnvConfig
        return host == Uri.parse(EnvConfig.apiBaseUrl).host;
      };
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const AppInitializationWrapper());
}

class AppInitializationWrapper extends StatefulWidget {
  const AppInitializationWrapper({super.key});

  @override
  State<AppInitializationWrapper> createState() => _AppInitializationWrapperState();
}

class _AppInitializationWrapperState extends State<AppInitializationWrapper> {
  bool _isInitialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  static const Duration _initTimeout = Duration(seconds: 45);

  Future<void> _initialize() async {
    try {
      print('🚀 AppInit: Starting initialization...');
      WidgetsFlutterBinding.ensureInitialized();
      print('✅ AppInit: Flutter binding initialized');

      await _initializeServices();

      if (mounted) {
        setState(() => _isInitialized = true);
        print('✅ AppInit: All services initialized successfully!');
      }
    } catch (e, stackTrace) {
      print('❌ AppInit: CRITICAL ERROR -> $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        setState(() => _error = e.toString());
      }
    }
  }

  Future<void> _initializeServices() async {
    // 1. Firebase
    print('🔥 AppInit: Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(_initTimeout, onTimeout: () {
      throw Exception('Firebase initialization timed out. Check network connection.');
    });
    print('✅ AppInit: Firebase initialized');

    // 2. Supabase
    print('🗄️ AppInit: Initializing Supabase...');
    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      anonKey: EnvConfig.supabaseAnonKey,
    ).timeout(_initTimeout, onTimeout: () {
      throw Exception('Supabase initialization timed out. Check network connection.');
    });
    print('✅ AppInit: Supabase initialized');

    // 3. RevenueCat - Removed
    // PayU is initialized on demand.

    // 4. Notifications (often slow/hanging in simulator; skip if takes too long)
    print('🔔 AppInit: Initializing NotificationService...');
    try {
      await NotificationService.initialize()
          .timeout(const Duration(seconds: 15), onTimeout: () {
        throw Exception('NotificationService timed out (OK to skip in simulator)');
      });
      print('✅ AppInit: NotificationService initialized');
    } catch (e) {
      print('⚠️ AppInit: NotificationService error (non-fatal): $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show Error Screen if Init failed
    if (_error != null) {
      return MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Icon(Icons.error_outline, size: 64, color: Colors.red),
                   const SizedBox(height: 16),
                   const Text('Initialization Failed', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                   const SizedBox(height: 8),
                   Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                   const SizedBox(height: 24),
                   ElevatedButton(
                     onPressed: _initialize,
                     child: const Text('Retry'),
                   )
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Show Native-like Splash while initializing
    if (!_isInitialized) {
      return MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 220,
                  height: 220,
                  errorBuilder: (_, __, ___) => const Icon(Icons.star, size: 80, color: Colors.orange),
                ),
                const SizedBox(height: 24),
                const CircularProgressIndicator(color: Colors.orange),
              ],
            ),
          ),
        ),
      );
    }

    // App ready! Mount the Provider Scope
    return const ProviderScope(
      child: VedicMateClientApp(),
    );
  }
}

class VedicMateClientApp extends ConsumerWidget {
  const VedicMateClientApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final fontScale = ref.watch(fontScaleProvider);

    return MaterialApp.router(
      title: 'Vedic Mate - Client',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(fontScale)),
          child: child!,
        );
      },
      routerConfig: router,
      // Localization Support
      // locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
    );
  }
}
