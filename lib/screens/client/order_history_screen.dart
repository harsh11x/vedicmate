import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredOrders = ref.watch(filteredOrdersProvider);
    final currentFilter = ref.watch(orderFilterProvider);
    final stats = ref.watch(orderStatsProvider);

    return Scaffold(
      backgroundColor: AppTheme.neutralSoft,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(ordersProvider);
        },
        color: AppTheme.primaryOrange,
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 140,
              floating: false,
              pinned: true,
              backgroundColor: AppTheme.white,
              elevation: 0,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.neutralSoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, color: AppTheme.neutralDark, size: 20),
                ),
                onPressed: () => context.pop(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16, right: 16),
                title: Text(
                  'Order History',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.neutralDark,
                        fontSize: 24,
                      ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryOrange,
                        AppTheme.yellowPrimary,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Stats Section
            SliverToBoxAdapter(
              child: stats.when(
                data: (data) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _StatCard(
                        title: 'Total',
                        count: data.total,
                        color: AppTheme.primaryOrange,
                        icon: Icons.shopping_bag,
                      ),
                      const SizedBox(width: 8),
                      _StatCard(
                        title: 'Processing',
                        count: data.processing,
                        color: Colors.orange,
                        icon: Icons.hourglass_top,
                      ),
                      const SizedBox(width: 8),
                      _StatCard(
                        title: 'Shipped',
                        count: data.shipped,
                        color: Colors.blue,
                        icon: Icons.local_shipping,
                      ),
                      const SizedBox(width: 8),
                      _StatCard(
                        title: 'Delivered',
                        count: data.delivered,
                        color: Colors.green,
                        icon: Icons.check_circle,
                      ),
                    ],
                  ),
                ),
                loading: () => const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

            // Filter Chips
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: OrderFilter.values.map((filter) {
                    final isSelected = currentFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(_getFilterLabel(filter)),
                        selected: isSelected,
                        onSelected: (selected) {
                          ref.read(orderFilterProvider.notifier).state = filter;
                        },
                        selectedColor: AppTheme.primaryOrange.withOpacity(0.2),
                        checkmarkColor: AppTheme.primaryOrange,
                        labelStyle: TextStyle(
                          color: isSelected ? AppTheme.primaryOrange : AppTheme.neutralDark,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        backgroundColor: AppTheme.white,
                        side: BorderSide(
                          color: isSelected ? AppTheme.primaryOrange : AppTheme.forestBackground,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Orders List
            filteredOrders.when(
              data: (orders) {
                if (orders.isEmpty) {
                  return SliverFillRemaining(
                    child: _EmptyState(
                      filter: currentFilter,
                      onShopNow: () => context.push('/remedies'),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final order = orders[index];
                        return _OrderCard(
                          order: order,
                          onTap: () => context.push('/orders/${order.id}'),
                        );
                      },
                      childCount: orders.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryOrange),
                ),
              ),
              error: (error, _) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error loading orders', style: GoogleFonts.outfit(fontSize: 16)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(ordersProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  String _getFilterLabel(OrderFilter filter) {
    switch (filter) {
      case OrderFilter.all:
        return 'All Orders';
      case OrderFilter.processing:
        return 'Processing';
      case OrderFilter.shipped:
        return 'Shipped';
      case OrderFilter.delivered:
        return 'Delivered';
      case OrderFilter.cancelled:
        return 'Cancelled';
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.neutralDark,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: AppTheme.neutralMedium,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final OrderFilter filter;
  final VoidCallback onShopNow;

  const _EmptyState({
    required this.filter,
    required this.onShopNow,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                filter == OrderFilter.all ? Icons.shopping_bag_outlined : Icons.search_off,
                size: 60,
                color: AppTheme.primaryOrange,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              filter == OrderFilter.all ? 'No Orders Yet' : 'No ${_getFilterLabel(filter)} Orders',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.neutralDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              filter == OrderFilter.all
                  ? 'Explore our spiritual remedies and sacred products to start your journey.'
                  : 'You don\'t have any orders with this status.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.neutralMedium,
              ),
              textAlign: TextAlign.center,
            ),
            if (filter == OrderFilter.all) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onShopNow,
                icon: const Icon(Icons.spa),
                label: const Text('Shop Remedies'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getFilterLabel(OrderFilter filter) {
    switch (filter) {
      case OrderFilter.all:
        return 'All';
      case OrderFilter.processing:
        return 'Processing';
      case OrderFilter.shipped:
        return 'Shipped';
      case OrderFilter.delivered:
        return 'Delivered';
      case OrderFilter.cancelled:
        return 'Cancelled';
    }
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const _OrderCard({
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final firstItem = order.items.first;
    final itemCount = order.items.length;
    final totalQuantity = order.items.fold(0, (sum, item) => sum + item.quantity);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.orderId,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryOrange,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dateFormat.format(order.orderDate),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.neutralMedium,
                          ),
                        ),
                      ],
                    ),
                    _StatusBadge(status: order.deliveryStatus),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),

                // Product Row
                Row(
                  children: [
                    // Product Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 70,
                        height: 70,
                        color: AppTheme.neutralSoft,
                        child: firstItem.image.startsWith('http')
                            ? Image.network(
                                firstItem.image,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const _PlaceholderImage(),
                              )
                            : Image.asset(
                                firstItem.image,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const _PlaceholderImage(),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Product Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            firstItem.title,
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.neutralDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (itemCount > 1) ...[
                            const SizedBox(height: 4),
                            Text(
                              '+${itemCount - 1} more item${itemCount > 2 ? 's' : ''}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppTheme.neutralMedium,
                              ),
                            ),
                          ],
                          const SizedBox(height: 4),
                          Text(
                            'Qty: $totalQuantity',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppTheme.neutralMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Total Amount
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${order.totalAmount.toStringAsFixed(0)}',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.neutralDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              order.paymentStatus.icon,
                              size: 12,
                              color: order.paymentStatus.color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              order.paymentStatus.displayName,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: order.paymentStatus.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Expected Delivery Row
                if (order.deliveryStatus != DeliveryStatus.delivered &&
                    order.deliveryStatus != DeliveryStatus.cancelled &&
                    order.expectedDeliveryDate != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.infoBlue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.local_shipping_outlined, size: 16, color: AppTheme.infoBlue),
                        const SizedBox(width: 8),
                        Text(
                          'Expected by ${dateFormat.format(order.expectedDeliveryDate!)}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.infoBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.chevron_right, size: 18, color: AppTheme.infoBlue),
                      ],
                    ),
                  ),

                if (order.deliveryStatus == DeliveryStatus.delivered &&
                    order.actualDeliveryDate != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline, size: 16, color: AppTheme.successGreen),
                        const SizedBox(width: 8),
                        Text(
                          'Delivered on ${dateFormat.format(order.actualDeliveryDate!)}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.successGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.chevron_right, size: 18, color: AppTheme.successGreen),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final DeliveryStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 14, color: status.color),
          const SizedBox(width: 6),
          Text(
            status.displayName,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  const _PlaceholderImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.neutralSoft,
      child: Center(
        child: Icon(
          Icons.spa,
          color: AppTheme.neutralMedium.withOpacity(0.3),
          size: 30,
        ),
      ),
    );
  }
}
