import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  // Initialize Supabase
  try {
    await Supabase.initialize(
      url: 'https://vbqqukcbbzwbzgpayleh.supabase.co',
      anonKey: 'sb_publishable_KGvaotK12Pp9gppGXmL-ww_pGcXKaZy',
    );
  } catch (e) {
    debugPrint('Supabase initialization error: $e');
  }

  runApp(
    const ProviderScope(
      child: VedicMateClientApp(),
    ),
  );
}

class VedicMateClientApp extends ConsumerWidget {
  const VedicMateClientApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Vedic Mate - Client',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: AppRouter.router,
    );
  }
}

