import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../screens/auth/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/registration_screen.dart';
import '../../screens/client/client_dashboard.dart';
import '../../screens/shared/pandit_search_screen.dart';
import '../../screens/shared/pandit_profile_detail_screen.dart';
import '../../screens/shared/booking_scheduling_screen.dart';
import '../../screens/shared/video_call_screen.dart';
import '../../screens/shared/chat_screen.dart';
import '../../screens/shared/booking_history_screen.dart';
import '../../screens/shared/payment_wallet_screen.dart';
import '../../screens/shared/settings_screen.dart';
import '../../screens/client/ai_pandit_chat_screen.dart';
import '../../screens/client/ai_pandit_voice_call_screen.dart';
import '../../screens/client/wallet_recharge_screen.dart';
import '../../screens/shared/kundli_generation_screen.dart';
import '../../screens/shared/edit_profile_screen.dart';
import '../../screens/client/remedies_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
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
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegistrationScreen(),
      ),
      GoRoute(
        path: '/client/dashboard',
        builder: (context, state) => const ClientDashboard(),
      ),
      // Pandit search and profile routes (for clients to browse pandits)
      GoRoute(
        path: '/pandit/search',
        builder: (context, state) => const PanditSearchScreen(),
      ),
      GoRoute(
        path: '/pandit/profile/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PanditProfileDetailScreen(panditId: id);
        },
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
        path: '/chat/:bookingId',
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId']!;
          return ChatScreen(bookingId: bookingId);
        },
      ),
      GoRoute(
        path: '/bookings/history',
        builder: (context, state) => const BookingHistoryScreen(),
      ),
      GoRoute(
        path: '/payment/wallet',
        builder: (context, state) => const PaymentWalletScreen(),
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
        builder: (context, state) => const AIPanditChatScreen(),
      ),
      GoRoute(
        path: '/ai-pandit/voice-call',
        builder: (context, state) => const AIPanditVoiceCallScreen(),
      ),
      GoRoute(
        path: '/wallet/recharge',
        builder: (context, state) => const WalletRechargeScreen(),
      ),
      GoRoute(
        path: '/kundli/generation',
        builder: (context, state) {
          // Get parameters from query or use defaults
          final name = state.uri.queryParameters['name'] ?? 'User';
          final dob = state.uri.queryParameters['dob'];
          final place = state.uri.queryParameters['place'] ?? 'Unknown';
          final time = state.uri.queryParameters['time'] ?? '12:00';
          
          return KundliGenerationScreen(
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
    ],
  );
}

