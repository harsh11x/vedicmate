import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../screens/auth/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/registration_screen.dart';
import '../../screens/client/client_dashboard.dart';
import '../../screens/pandit/pandit_dashboard.dart';
import '../../screens/shared/pandit_search_screen.dart';
import '../../screens/shared/pandit_profile_detail_screen.dart';
import '../../screens/shared/booking_scheduling_screen.dart';
import '../../screens/shared/video_call_screen.dart';
import '../../screens/shared/chat_screen.dart';
import '../../screens/shared/booking_history_screen.dart';
import '../../screens/shared/payment_wallet_screen.dart';
import '../../screens/admin/admin_dashboard.dart';
import '../../screens/pandit/pandit_verification_screen.dart';
import '../../screens/pandit/blocked_account_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
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
      GoRoute(
        path: '/pandit/dashboard',
        builder: (context, state) => const PanditDashboard(),
      ),
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
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboard(),
      ),
      GoRoute(
        path: '/pandit/verification',
        builder: (context, state) => const PanditVerificationScreen(),
      ),
      GoRoute(
        path: '/pandit/blocked',
        builder: (context, state) => const BlockedAccountScreen(),
      ),
    ],
  );
}

