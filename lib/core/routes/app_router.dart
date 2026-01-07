import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/auth_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/registration_screen.dart';
import '../../screens/onboarding/category_selection_screen.dart';
import '../../screens/onboarding/birth_details_screen.dart';
import '../../screens/onboarding/pandit_selection_screen.dart';
import '../../screens/client/client_dashboard.dart';
import '../../screens/shared/booking_scheduling_screen.dart';
import '../../screens/shared/video_call_screen.dart';
import '../../screens/shared/chat_screen.dart';
import '../../screens/shared/booking_history_screen.dart';
import '../../screens/shared/payment_wallet_screen.dart';
import '../../screens/shared/settings_screen.dart';
import '../../screens/client/ai_pandit_chat_screen.dart';
import '../../screens/client/ai_pandit_voice_call_screen.dart';
import '../../screens/client/wallet_recharge_screen.dart';
import '../../screens/client/kundli/kundli_details_screen.dart';
import '../../screens/client/checkout_screen.dart';
import '../../screens/shared/edit_profile_screen.dart';
import '../../screens/client/remedies_screen.dart';
import '../../screens/client/all_ai_pandits_screen.dart';
import '../../screens/client/ai_pandit_profile_screen.dart';
import '../../screens/shared/service_report_screen.dart';
import '../../screens/auth/email_login_screen.dart';
import '../../screens/services/palm_reading_input_screen.dart';
import '../../screens/services/vastu_input_screen.dart';
import '../../screens/client/remedy_product_screen.dart';
import '../../screens/client/cart_screen.dart';
import '../../screens/client/checkout_screen.dart';
import '../../screens/client/custom_booking_screen.dart';
import '../../screens/shared/splash_screen.dart';
import '../../screens/client/kundli/create_kundli_screen.dart';
import '../../screens/client/order_history_screen.dart';
import '../../screens/client/order_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

final initialRouteProvider = Provider<String>((ref) => '/splash');

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final initialRoute = ref.watch(initialRouteProvider);
  
  // Create a listenable that notifies when auth state changes
  final authListenable = ValueNotifier<AsyncValue<User?>>(authState);
  ref.listen(authStateProvider, (_, next) {
      authListenable.value = next;
  });

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    refreshListenable: authListenable,
    redirect: (context, state) async {
      final isLoading = authState.isLoading;
      final hasError = authState.hasError;
      final user = authState.value;
      final isLoggedIn = user != null;
      final path = state.uri.path;
      
      debugPrint('Router: Path: $path, Loading: $isLoading, User: ${user?.uid}');

      // 1. Loading State -> Stay on Splash
      if (isLoading) {
        debugPrint('Router: Auth Loading -> Splash');
        return '/splash';
      }

      // 2. Error State -> Login (Safe fallback)
      if (hasError) {
        debugPrint('Router: Auth Error -> Login');
        return '/login';
      }

      // Definitions
      final isSplash = path == '/splash';
      final isLoggingIn = path == '/login' || 
                          path == '/login/email' || 
                          path == '/register';

      
      // 3. Logged In Logic
      if (isLoggedIn) {
        if (isSplash || isLoggingIn) {
          debugPrint('Router: Auth Validated -> Dashboard');
          return '/client/dashboard';
        }
        return null; 
      }

      // 4. Not Logged In Logic
      if (!isLoggedIn) {
        // Async check for manual persistence
        final prefs = await SharedPreferences.getInstance();
        final manualAuth = prefs.getBool('is_logged_in') ?? false;

        debugPrint('Router: Auth Lost. Manual Flag: $manualAuth');

        if (manualAuth) {
           // We have a manual flag but Firebase is null.
           // This means Firebase is either slow or the session is properly dead.
           // We redirect to Splash to let it spin/wait/retry (if implemented)
           // or simply to prevent "Login" screen flash if it's just slow.
           // But if it's dead-dead, we need a way to fail.
           
           // For now, if we are on splash, stay there so we don't loop endlessly 
           // between Splash -> Dashboard -> Splash.
           if (isSplash) return null;
           
           // If we are elsewhere, go to Splash
           return '/splash';
        }

        if (isLoggingIn) {
          return null; 
        }
        
        if (isSplash) {
          return null; 
        }

        debugPrint('Router: Unauth Access to $path -> Login');
        return '/login';
      }

      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    ),
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      // ... rest of routes ...
      GoRoute(
        path: '/category-selection',
        builder: (context, state) => const CategorySelectionScreen(),
      ),
      GoRoute(
        path: '/service-input/palm-reading',
        builder: (context, state) => const PalmReadingInputScreen(),
      ),
      GoRoute(
        path: '/service-input/vastu',
        builder: (context, state) => const VastuInputScreen(),
      ),
      GoRoute(
        path: '/birth-details',
        builder: (context, state) {
          final category = state.uri.queryParameters['category'];
          return BirthDetailsScreen(selectedCategory: category ?? '');
        },
      ),
      GoRoute(
        path: '/pandit-selection',
        builder: (context, state) {
          final category = state.uri.queryParameters['category'];
          return PanditSelectionScreen(selectedCategory: category ?? '');
        },
      ),
      GoRoute(
        path: '/login/email',
        builder: (context, state) => const EmailLoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegistrationScreen(),
      ),
      GoRoute(
        path: '/client/dashboard',
        builder: (context, state) => const ClientDashboard(),
      ),
      GoRoute(
        path: '/booking/schedule',
        builder: (context, state) {
          final panditId = state.uri.queryParameters['panditId'];
          final serviceType = state.uri.queryParameters['serviceType'];
          return BookingSchedulingScreen(
            panditId: panditId ?? '',
            serviceType: serviceType ?? '',
          );
        },
      ),
      GoRoute(
        path: '/call/video/:bookingId',
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId']!;
          return VideoCallScreen(bookingId: bookingId);
        },
      ),
      GoRoute(
        path: '/chat/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          // id can be either a booking ID or chat room ID
          return ChatScreen(bookingId: id);
        },
      ),
      GoRoute(
        path: '/bookings/history',
        builder: (context, state) => const BookingHistoryScreen(),
      ),
      GoRoute(
        path: '/client/wallet',
        builder: (context, state) => const WalletScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/ai-pandit/chat',
        builder: (context, state) {
          final panditId = state.uri.queryParameters['panditId'];
          return AIPanditChatScreen(panditId: panditId);
        },
      ),
      GoRoute(
        path: '/ai-pandit/voice-call',
        builder: (context, state) {
          final panditId = state.uri.queryParameters['panditId'];
          return AIPanditVoiceCallScreen(panditId: panditId);
        },
      ),
      GoRoute(
        path: '/ai-pandits/all',
        builder: (context, state) => const AllAIPanditsScreen(),
      ),
      GoRoute(
        path: '/ai-pandit/profile/:id',
        builder: (context, state) {
          final panditId = state.pathParameters['id']!;
          return AIPanditProfileScreen(panditId: panditId);
        },
      ),

      GoRoute(
        path: '/kundli/generation',
        builder: (context, state) {
          // Get parameters from query or use defaults
          final name = state.uri.queryParameters['name'] ?? 'User';
          final dob = state.uri.queryParameters['dob'];
          final place = state.uri.queryParameters['place'] ?? 'Unknown';
          final time = state.uri.queryParameters['time'] ?? '12:00';
          

          
          return KundliDetailsScreen(
            name: name,
            dateOfBirth: dob != null ? DateTime.parse(dob) : DateTime.now(),
            placeOfBirth: place,
            timeOfBirth: time,
          );
        },
      ),
      GoRoute(
        path: '/remedies',
        builder: (context, state) => const RemediesScreen(),
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/remedy/product',
        builder: (context, state) {
          final remedy = state.extra as Map<String, dynamic>;
          return RemedyProductScreen(remedy: remedy);
        },
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return CheckoutScreen(
            item: extra?['item'] as Map<String, dynamic>?,
            isDirectBuy: extra?['isDirectBuy'] as bool? ?? false,
          );
        },
      ),
      GoRoute(
        path: '/service/:type',
        builder: (context, state) {
          final type = state.pathParameters['type']!;
          final extra = state.extra as Map<String, dynamic>?;
          return ServiceReportScreen(
            title: extra?['title'] ?? type.toUpperCase(),
            report: extra?['report'] ?? 'Report not available',
          );
        },
      ),
      GoRoute(
        path: '/kundli/create',
        builder: (context, state) => const CreateKundliScreen(),
      ),
      GoRoute(
        path: '/booking/custom',
        builder: (context, state) => const CustomBookingScreen(),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrderHistoryScreen(),
      ),
      GoRoute(
        path: '/orders/:id',
        builder: (context, state) {
          final orderId = state.pathParameters['id']!;
          return OrderDetailScreen(orderId: orderId);
        },
      ),
    ],
  );
});


