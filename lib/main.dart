import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'providers/theme_provider.dart';
import 'services/notification_service.dart';

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message received: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Add error handlers to catch any Flutter errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('Flutter Error: ${details.exception}');
    print('Stack trace: ${details.stack}');
  };
  
  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp();
    print('✅ Firebase initialized successfully');
  } catch (e, stackTrace) {
    print('❌ Firebase initialization error: $e');
    print('Stack trace: $stackTrace');
    // Continue anyway - app can work without Firebase in some cases
  }
  
  // Initialize Firebase Messaging background handler
  try {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (e) {
    print('⚠️ Firebase Messaging background handler error: $e');
  }
  
  // Initialize notification service with error handling
  try {
    final notificationService = NotificationService();
    await notificationService.initialize();
    print('✅ Notification service initialized successfully');
  } catch (e) {
    print('⚠️ Notification service initialization error: $e');
    // Continue anyway - notifications are not critical for app startup
  }
  
  print('🚀 Starting VedicMateApp...');
  
  runApp(
    const ProviderScope(
      child: VedicMateApp(),
    ),
  );
}

class VedicMateApp extends ConsumerWidget {
  const VedicMateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    try {
      final mode = ref.watch(themeModeProvider);
      return MaterialApp.router(
        title: 'Vedic Mate',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      );
    } catch (e, stackTrace) {
      print('❌ Error building VedicMateApp: $e');
      print('Stack trace: $stackTrace');
      // Return a simple error screen instead of crashing
      return MaterialApp(
        title: 'Vedic Mate',
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('App Initialization Error'),
                const SizedBox(height: 8),
                Text('$e', style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Try to restart
                    main();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}

