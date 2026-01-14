import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../services/custom_request_service.dart';
import '../../utils/invoice_generator.dart';

class CustomRequestOrdersScreen extends StatefulWidget {
  const CustomRequestOrdersScreen({super.key});

  @override
  State<CustomRequestOrdersScreen> createState() => _CustomRequestOrdersScreenState();
}

class _CustomRequestOrdersScreenState extends State<CustomRequestOrdersScreen> {
  List<dynamic> _orders = [];
  bool _isLoading = true;
  String _filter = 'all'; // all, pending, accepted, rejected

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final orders = await CustomRequestService.getUserOrders(user.uid);
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading orders: $e');
      setState(() => _isLoading = false);
    }
  }

  List<dynamic> get _filteredOrders {
    if (_filter == 'all') return _orders;
    return _orders.where((order) => order['status'] == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.forestBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.neutralDark, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'My Custom Requests',
          style: GoogleFonts.outfit(
            color: AppTheme.neutralDark,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredOrders.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadOrders,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredOrders.length,
                          itemBuilder: (context, index) {
                            return _buildOrderCard(_filteredOrders[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All', 'all'),
            const SizedBox(width: 8),
            _buildFilterChip('Pending', 'pending'),
            const SizedBox(width: 8),
            _buildFilterChip('Accepted', 'accepted'),
            const SizedBox(width: 8),
            _buildFilterChip('Rejected', 'rejected'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filter = value);
      },
      backgroundColor: Colors.white,
      selectedColor: AppTheme.primaryOrange.withOpacity(0.2),
      labelStyle: GoogleFonts.outfit(
        color: isSelected ? AppTheme.primaryOrange : AppTheme.neutralMedium,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: AppTheme.neutralMedium.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'No orders found',
            style: GoogleFonts.outfit(
              fontSize: 18,
              color: AppTheme.neutralMedium,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your custom requests will appear here',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: AppTheme.neutralMedium.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status'] as String;
    final paymentStatus = order['paymentStatus'] as String;
    final amount = order['amount'];
    final serviceType = order['serviceType'] as String;
    final date = order['date'] as String;
    final timeSlot = order['timeSlot'] as String;
    final joiningLink = order['joiningLink'] as String?;
    final finalDate = order['finalDate'] as String?;
    final finalTime = order['finalTime'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor(status).withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        serviceType,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.neutralDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Order ID: ${order['orderId']}',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: AppTheme.neutralMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(status),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(Icons.calendar_today, 'Requested Date', '$date • $timeSlot'),
                if (finalDate != null && finalTime != null) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow(Icons.event_available, 'Confirmed Date', '$finalDate • $finalTime', isHighlighted: true),
                ],
                const SizedBox(height: 8),
                _buildDetailRow(Icons.payment, 'Amount', amount == 'TBD' ? 'Price TBD' : '₹$amount'),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.credit_card, 'Payment', paymentStatus == 'paid' ? 'Paid' : 'Failed', 
                  isHighlighted: paymentStatus == 'paid'),
                
                // Joining Link
                if (joiningLink != null) ...[
                  const Divider(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _launchUrl(joiningLink),
                    icon: const Icon(Icons.video_call, size: 20),
                    label: Text('Join Session', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],

                // Actions
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showInvoiceDialog(order),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryOrange,
                          side: const BorderSide(color: AppTheme.primaryOrange),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('View Invoice', style: GoogleFonts.outfit()),
                      ),
                    ),
                    if (paymentStatus == 'failed') ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _retryPayment(order),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryOrange,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text('Retry Payment', style: GoogleFonts.outfit(color: Colors.white)),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {bool isHighlighted = false}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: isHighlighted ? Colors.green : AppTheme.neutralMedium),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.outfit(
            fontSize: 14,
            color: AppTheme.neutralMedium,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
            color: isHighlighted ? Colors.green : AppTheme.neutralDark,
          ),
        ),
      ],
    );
  }

  void _showInvoiceDialog(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.receipt_long, color: AppTheme.primaryOrange),
            const SizedBox(width: 8),
            Text('Invoice', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInvoiceRow('Order ID', order['orderId']),
              _buildInvoiceRow('Service', order['serviceType']),
              _buildInvoiceRow('Date', order['date']),
              _buildInvoiceRow('Time', order['timeSlot']),
              if (order['finalDate'] != null)
                _buildInvoiceRow('Confirmed Date', order['finalDate']),
              if (order['finalTime'] != null)
                _buildInvoiceRow('Confirmed Time', order['finalTime']),
              _buildInvoiceRow('Amount', order['amount'] == 'TBD' ? 'TBD' : '₹${order['amount']}'),
              _buildInvoiceRow('Payment Status', order['paymentStatus']),
              if (order['razorpayPaymentId'] != null)
                _buildInvoiceRow('Transaction ID', order['razorpayPaymentId']),
              _buildInvoiceRow('Status', order['status'].toUpperCase()),
              _buildInvoiceRow('Created', DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(order['createdAt']))),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text('Close', style: GoogleFonts.outfit(color: AppTheme.neutralMedium)),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              try {
                await InvoiceGenerator.generateAndDownloadInvoice(order);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invoice downloaded successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to download invoice')),
                  );
                }
              }
            },
            icon: const Icon(Icons.download, size: 18),
            label: Text('Download PDF', style: GoogleFonts.outfit(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryOrange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: AppTheme.neutralMedium,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.neutralDark,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }

  void _retryPayment(Map<String, dynamic> order) {
    // Navigate back to booking screen with pre-filled data
    context.push('/booking/custom');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please complete the booking again')),
    );
  }
}
