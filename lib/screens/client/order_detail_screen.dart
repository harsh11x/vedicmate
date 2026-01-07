import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      backgroundColor: AppTheme.neutralSoft,
      body: orderAsync.when(
        data: (order) {
          if (order == null) {
            return _buildNotFound(context);
          }
          return _buildOrderDetail(context, order);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryOrange),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading order', style: GoogleFonts.outfit(fontSize: 16)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(orderDetailProvider(orderId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotFound(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: AppTheme.neutralMedium),
          const SizedBox(height: 16),
          Text(
            'Order not found',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetail(BuildContext context, Order order) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');
    final dateTimeFormat = DateFormat('MMM dd, yyyy • hh:mm a');

    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          expandedHeight: 120,
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
          actions: [
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.neutralSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.help_outline, color: AppTheme.neutralDark, size: 20),
              ),
              onPressed: () => _showHelpDialog(context),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(left: 16, bottom: 16, right: 16),
            title: Text(
              'Order Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neutralDark,
                    fontSize: 20,
                  ),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    order.deliveryStatus.color.withOpacity(0.8),
                    order.deliveryStatus.color,
                  ],
                ),
              ),
            ),
          ),
        ),

        // Order Status Card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _StatusCard(order: order),
          ),
        ),

        // Order Timeline
        if (order.timeline != null && order.timeline!.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _TimelineSection(
                timeline: order.timeline!,
                currentStatus: order.deliveryStatus,
              ),
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // Ordered Items
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SectionCard(
              title: 'Ordered Items',
              icon: Icons.shopping_bag_outlined,
              child: Column(
                children: order.items.map((item) => _OrderItemTile(item: item)).toList(),
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // Invoice / Price Breakdown
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SectionCard(
              title: 'Invoice',
              icon: Icons.receipt_long_outlined,
              trailing: InkWell(
                onTap: () => _copyOrderId(context, order.orderId),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      order.orderId,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppTheme.primaryOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.copy, size: 14, color: AppTheme.primaryOrange),
                  ],
                ),
              ),
              child: Column(
                children: [
                  _InvoiceRow(label: 'Order Date', value: dateTimeFormat.format(order.orderDate)),
                  const Divider(height: 16),
                  _InvoiceRow(label: 'Subtotal', value: '₹${order.subtotal.toStringAsFixed(2)}'),
                  if (order.tax > 0)
                    _InvoiceRow(label: 'Tax (18% GST)', value: '₹${order.tax.toStringAsFixed(2)}'),
                  _InvoiceRow(
                    label: 'Delivery Charges',
                    value: order.deliveryCharge > 0 ? '₹${order.deliveryCharge.toStringAsFixed(2)}' : 'FREE',
                    valueColor: order.deliveryCharge > 0 ? null : AppTheme.successGreen,
                  ),
                  const Divider(height: 16),
                  _InvoiceRow(
                    label: 'Total Amount',
                    value: '₹${order.totalAmount.toStringAsFixed(2)}',
                    isBold: true,
                  ),
                ],
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // Payment Details
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SectionCard(
              title: 'Payment Details',
              icon: Icons.payment_outlined,
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: order.paymentStatus.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          order.paymentStatus.icon,
                          color: order.paymentStatus.color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.paymentStatus.displayName,
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: order.paymentStatus.color,
                              ),
                            ),
                            if (order.paymentId != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Transaction ID: ${order.paymentId}',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppTheme.neutralMedium,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // Shipping Address
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SectionCard(
              title: 'Shipping Address',
              icon: Icons.location_on_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.shippingAddress.name,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.neutralDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.shippingAddress.phone,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.neutralMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    order.shippingAddress.fullAddress,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.neutralDark,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // Delivery Info
        if (order.trackingNumber != null ||
            order.expectedDeliveryDate != null ||
            order.actualDeliveryDate != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SectionCard(
                title: 'Delivery Information',
                icon: Icons.local_shipping_outlined,
                child: Column(
                  children: [
                    if (order.trackingNumber != null)
                      _DeliveryInfoRow(
                        icon: Icons.qr_code,
                        label: 'Tracking Number',
                        value: order.trackingNumber!,
                        onCopy: () => _copyText(context, order.trackingNumber!, 'Tracking number copied'),
                      ),
                    if (order.expectedDeliveryDate != null &&
                        order.deliveryStatus != DeliveryStatus.delivered)
                      _DeliveryInfoRow(
                        icon: Icons.event,
                        label: 'Expected Delivery',
                        value: dateFormat.format(order.expectedDeliveryDate!),
                      ),
                    if (order.actualDeliveryDate != null)
                      _DeliveryInfoRow(
                        icon: Icons.check_circle,
                        label: 'Delivered On',
                        value: dateFormat.format(order.actualDeliveryDate!),
                        valueColor: AppTheme.successGreen,
                      ),
                  ],
                ),
              ),
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // Cancel Order Button (if cancellable)
        if (order.canCancel)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _CancelOrderButton(order: order),
            ),
          ),

        if (order.canCancel)
          const SliverToBoxAdapter(child: SizedBox(height: 12)),

        // Cancellation Reason (if cancelled)
        if (order.deliveryStatus == DeliveryStatus.cancelled && order.cancellationReason != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.errorRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.errorRed.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.errorRed, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cancellation Reason',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.errorRed,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order.cancellationReason!,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppTheme.neutralDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        if (order.deliveryStatus == DeliveryStatus.cancelled)
          const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // Action Buttons
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showHelpDialog(context),
                    icon: const Icon(Icons.support_agent),
                    label: const Text('Need Help?'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryOrange,
                      side: const BorderSide(color: AppTheme.primaryOrange),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: order.trackingNumber != null
                        ? () => _trackOrder(context, order.trackingNumber!)
                        : null,
                    icon: const Icon(Icons.location_searching),
                    label: const Text('Track Order'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  void _copyOrderId(BuildContext context, String orderId) {
    Clipboard.setData(ClipboardData(text: orderId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order ID copied: $orderId'),
        backgroundColor: AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _copyText(BuildContext context, String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Need Help?',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _HelpOption(
              icon: Icons.phone,
              title: 'Call Us',
              subtitle: '+91 1800-123-4567',
              onTap: () {},
            ),
            _HelpOption(
              icon: Icons.email,
              title: 'Email Us',
              subtitle: 'support@vedicmate.com',
              onTap: () {},
            ),
            _HelpOption(
              icon: Icons.chat_bubble,
              title: 'Live Chat',
              subtitle: 'Available 24/7',
              onTap: () {},
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _trackOrder(BuildContext context, String trackingNumber) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tracking: $trackingNumber'),
        backgroundColor: AppTheme.infoBlue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final Order order;

  const _StatusCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final status = order.deliveryStatus;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            status.color.withOpacity(0.9),
            status.color,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: status.color.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(status.icon, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.displayName,
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStatusMessage(status),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusMessage(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.processing:
        return 'Your order is being prepared';
      case DeliveryStatus.confirmed:
        return 'Order confirmed, will be shipped soon';
      case DeliveryStatus.shipped:
        return 'Your package is on the way';
      case DeliveryStatus.outForDelivery:
        return 'Your package will arrive today';
      case DeliveryStatus.delivered:
        return 'Your package has been delivered';
      case DeliveryStatus.cancelled:
        return 'This order has been cancelled';
    }
  }
}

class _TimelineSection extends StatelessWidget {
  final List<OrderTimeline> timeline;
  final DeliveryStatus currentStatus;

  const _TimelineSection({
    required this.timeline,
    required this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    final allStatuses = [
      DeliveryStatus.processing,
      DeliveryStatus.confirmed,
      DeliveryStatus.shipped,
      DeliveryStatus.outForDelivery,
      DeliveryStatus.delivered,
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline, color: AppTheme.primaryOrange),
              const SizedBox(width: 8),
              Text(
                'Order Timeline',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.neutralDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...allStatuses.asMap().entries.map((entry) {
            final index = entry.key;
            final status = entry.value;
            final isCompleted = currentStatus.stepIndex >= status.stepIndex;
            final isCurrent = currentStatus == status;
            final timelineEntry = timeline.where((t) => t.status == status).firstOrNull;
            final isLast = index == allStatuses.length - 1;

            return _TimelineItem(
              status: status,
              isCompleted: isCompleted,
              isCurrent: isCurrent,
              isLast: isLast,
              timestamp: timelineEntry?.timestamp,
              description: timelineEntry?.description,
              location: timelineEntry?.location,
            );
          }),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final DeliveryStatus status;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLast;
  final DateTime? timestamp;
  final String? description;
  final String? location;

  const _TimelineItem({
    required this.status,
    required this.isCompleted,
    required this.isCurrent,
    required this.isLast,
    this.timestamp,
    this.description,
    this.location,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, hh:mm a');
    final color = isCompleted ? status.color : AppTheme.neutralLight;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCompleted ? color : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: color,
                  width: isCurrent ? 3 : 2,
                ),
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                isCompleted ? Icons.check : status.icon,
                size: 16,
                color: isCompleted ? Colors.white : color,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? color : AppTheme.neutralLight,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.displayName,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                    color: isCompleted ? AppTheme.neutralDark : AppTheme.neutralMedium,
                  ),
                ),
                if (timestamp != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    dateFormat.format(timestamp!),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.neutralMedium,
                    ),
                  ),
                ],
                if (location != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 12, color: AppTheme.neutralMedium),
                      const SizedBox(width: 4),
                      Text(
                        location!,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppTheme.neutralMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryOrange, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neutralDark,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _OrderItemTile extends StatelessWidget {
  final OrderItem item;

  const _OrderItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 60,
              height: 60,
              color: AppTheme.neutralSoft,
              child: item.image.startsWith('http')
                  ? Image.network(
                      item.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.spa,
                        color: AppTheme.neutralMedium.withOpacity(0.3),
                      ),
                    )
                  : Image.asset(
                      item.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.spa,
                        color: AppTheme.neutralMedium.withOpacity(0.3),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.neutralDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: ${item.quantity}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.neutralMedium,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹${item.total.toStringAsFixed(0)}',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.neutralDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _InvoiceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _InvoiceRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: isBold ? 15 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? AppTheme.neutralDark : AppTheme.neutralMedium,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: isBold ? 18 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? (isBold ? AppTheme.primaryOrange : AppTheme.neutralDark),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final VoidCallback? onCopy;

  const _DeliveryInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.neutralMedium),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.neutralMedium,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? AppTheme.neutralDark,
                  ),
                ),
              ],
            ),
          ),
          if (onCopy != null)
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              onPressed: onCopy,
              color: AppTheme.neutralMedium,
            ),
        ],
      ),
    );
  }
}

class _HelpOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HelpOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.primaryOrange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppTheme.primaryOrange),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _CancelOrderButton extends ConsumerStatefulWidget {
  final Order order;

  const _CancelOrderButton({required this.order});

  @override
  ConsumerState<_CancelOrderButton> createState() => _CancelOrderButtonState();
}

class _CancelOrderButtonState extends ConsumerState<_CancelOrderButton> {
  bool _isLoading = false;

  Future<void> _showCancelDialog() async {
    final reasonController = TextEditingController();
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.warning_amber_rounded, color: AppTheme.errorRed),
            ),
            const SizedBox(width: 12),
            Text(
              'Cancel Order',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to cancel this order?',
              style: GoogleFonts.inter(fontSize: 14, color: AppTheme.neutralDark),
            ),
            const SizedBox(height: 16),
            Text(
              'Order: ${widget.order.orderId}',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.neutralMedium,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'Reason for cancellation (optional)',
                hintText: 'e.g., Changed my mind, Found better price...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.primaryOrange),
                ),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Keep Order',
              style: TextStyle(color: AppTheme.neutralMedium),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Cancel Order'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _cancelOrder(reasonController.text.trim());
    }
  }

  Future<void> _cancelOrder(String reason) async {
    setState(() => _isLoading = true);

    try {
      final backendService = ref.read(backendOrderServiceProvider);
      final result = await backendService.cancelOrder(
        widget.order.id,
        reason: reason.isEmpty ? 'Cancelled by user' : reason,
      );

      if (result != null && mounted) {
        // Refresh orders
        ref.invalidate(ordersProvider);
        ref.invalidate(orderDetailProvider(widget.order.id));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Order cancelled successfully'),
            backgroundColor: AppTheme.successGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Pop back to order history
        if (mounted) {
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel order: $e'),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _isLoading ? null : _showCancelDialog,
      icon: _isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.cancel_outlined),
      label: Text(_isLoading ? 'Cancelling...' : 'Cancel Order'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.errorRed,
        side: const BorderSide(color: AppTheme.errorRed),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

