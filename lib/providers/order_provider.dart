import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';
import '../services/backend_order_service.dart';

// Order Service Provider (Local Storage)
final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService();
});

// Backend Order Service Provider
final backendOrderServiceProvider = Provider<BackendOrderService>((ref) {
  return BackendOrderService();
});


// Orders List Provider - requires userId
final ordersProvider = FutureProvider.family<List<Order>, String>((ref, userId) async {
  final orderService = ref.read(orderServiceProvider);
  return await orderService.getOrders(userId);
});

// Single Order Provider
final orderDetailProvider = FutureProvider.family<Order?, String>((ref, orderId) async {
  final orderService = ref.read(orderServiceProvider);
  return await orderService.getOrderById(orderId);
});

// Filtered Orders Provider
enum OrderFilter { all, processing, shipped, delivered, cancelled }

final orderFilterProvider = StateProvider<OrderFilter>((ref) => OrderFilter.all);

final filteredOrdersProvider = Provider.family<AsyncValue<List<Order>>, String>((ref, userId) {
  final ordersAsync = ref.watch(ordersProvider(userId));
  final filter = ref.watch(orderFilterProvider);
  
  return ordersAsync.when(
    data: (orders) {
      List<Order> filtered;
      switch (filter) {
        case OrderFilter.all:
          filtered = orders;
          break;
        case OrderFilter.processing:
          filtered = orders.where((o) => 
            o.deliveryStatus == DeliveryStatus.processing || 
            o.deliveryStatus == DeliveryStatus.confirmed
          ).toList();
          break;
        case OrderFilter.shipped:
          filtered = orders.where((o) => 
            o.deliveryStatus == DeliveryStatus.shipped || 
            o.deliveryStatus == DeliveryStatus.outForDelivery
          ).toList();
          break;
        case OrderFilter.delivered:
          filtered = orders.where((o) => o.deliveryStatus == DeliveryStatus.delivered).toList();
          break;
        case OrderFilter.cancelled:
          filtered = orders.where((o) => o.deliveryStatus == DeliveryStatus.cancelled).toList();
          break;
      }
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
  );
});

// Order Stats Provider
class OrderStats {
  final int total;
  final int processing;
  final int shipped;
  final int delivered;
  
  OrderStats({
    required this.total,
    required this.processing,
    required this.shipped,
    required this.delivered,
  });
}

final orderStatsProvider = Provider.family<AsyncValue<OrderStats>, String>((ref, userId) {
  final ordersAsync = ref.watch(ordersProvider(userId));
  
  return ordersAsync.when(
    data: (orders) {
      return AsyncValue.data(OrderStats(
        total: orders.length,
        processing: orders.where((o) => 
          o.deliveryStatus == DeliveryStatus.processing || 
          o.deliveryStatus == DeliveryStatus.confirmed
        ).length,
        shipped: orders.where((o) => 
          o.deliveryStatus == DeliveryStatus.shipped || 
          o.deliveryStatus == DeliveryStatus.outForDelivery
        ).length,
        delivered: orders.where((o) => o.deliveryStatus == DeliveryStatus.delivered).length,
      ));
    },
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
  );
});
