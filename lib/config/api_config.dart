import '../core/config/env.dart';

/// API Configuration for Vedic Mate Backend
class ApiConfig {
  // Backend server URL - AWS Production
  // static const String baseUrl = 'https://15.207.36.26:3001/api';
  
  // For Localhost (Simulator):
  // static const String baseUrl = 'http://127.0.0.1:3001/api';

  // For Physical Device (Local Network):
  static const String baseUrl = '${EnvConfig.apiBaseUrl}/api';
  
  // API Endpoints
  static const String healthEndpoint = '/health';
  
  // Orders
  static const String ordersEndpoint = '/orders';
  static const String adminOrdersEndpoint = '/admin/orders';
  static const String orderStatsEndpoint = '/admin/orders/stats';
  
  // Products
  static const String productsEndpoint = '/products';
  static const String adminProductsEndpoint = '/admin/products';
  static const String productStatsEndpoint = '/admin/products/stats';
  
  // Wallet
  static const String walletBalanceEndpoint = '/wallet/balance';
  static const String walletAddEndpoint = '/wallet/add';
  static const String walletDeductEndpoint = '/wallet/deduct';
  static const String walletTransactionsEndpoint = '/wallet/transactions';
  
  // AI
  static const String aiChatEndpoint = '/ai-pandit/chat';
  static const String aiWelcomeEndpoint = '/ai/welcome';
  
  // Custom Requests (Puja/Havan Bookings)
  static const String customRequestsEndpoint = '/custom-requests';
  static const String adminCustomRequestsEndpoint = '/admin/custom-requests';
  static const String customRequestsStatsEndpoint = '/admin/custom-requests/stats';
  
  // Live Sessions (Video Call Havans)
  static const String liveSessionsEndpoint = '/live-sessions';
  static const String adminLiveSessionsEndpoint = '/admin/live-sessions';
  
  // Bookings History (Combined view)
  static const String bookingsEndpoint = '/bookings';
  
  // Full URLs
  static String get ordersUrl => '$baseUrl$ordersEndpoint';
  static String get productsUrl => '$baseUrl$productsEndpoint';
  static String get healthUrl => '$baseUrl$healthEndpoint';
  static String get customRequestsUrl => '$baseUrl$customRequestsEndpoint';
  static String get liveSessionsUrl => '$baseUrl$liveSessionsEndpoint';
  static String get bookingsUrl => '$baseUrl$bookingsEndpoint';
  
  static String orderDetailUrl(String orderId) => '$baseUrl$ordersEndpoint/$orderId';
  static String cancelOrderUrl(String orderId) => '$baseUrl$ordersEndpoint/$orderId/cancel';
  static String productDetailUrl(String productId) => '$baseUrl$productsEndpoint/$productId';
  static String customRequestDetailUrl(String id) => '$baseUrl$customRequestsEndpoint/$id';
  static String cancelCustomRequestUrl(String id) => '$baseUrl$customRequestsEndpoint/$id/cancel';
  static String liveSessionDetailUrl(String id) => '$baseUrl$liveSessionsEndpoint/$id';
  static String joinLiveSessionUrl(String id) => '$baseUrl$liveSessionsEndpoint/$id/join';
}
