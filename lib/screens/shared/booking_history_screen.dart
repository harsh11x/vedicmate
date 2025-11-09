import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/booking_model.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking History'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
            Tab(text: 'All'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingsList(BookingStatus.confirmed),
          _buildBookingsList(BookingStatus.completed),
          _buildBookingsList(BookingStatus.cancelled),
          _buildBookingsList(null),
        ],
      ),
    );
  }

  Widget _buildBookingsList(BookingStatus? status) {
    // Mock data
    final allBookings = [
      BookingModel(
        id: '1',
        clientId: 'c1',
        panditId: 'p1',
        serviceType: 'Horoscope Reading',
        scheduledAt: DateTime.now().add(const Duration(days: 2)),
        duration: 30,
        amount: 500.0,
        platformFee: 75.0,
        gst: 103.5,
        totalAmount: 678.5,
        status: BookingStatus.confirmed,
        callType: 'video',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      BookingModel(
        id: '2',
        clientId: 'c1',
        panditId: 'p2',
        serviceType: 'Marriage Consultation',
        scheduledAt: DateTime.now().subtract(const Duration(days: 5)),
        duration: 45,
        amount: 1000.0,
        platformFee: 150.0,
        gst: 207.0,
        totalAmount: 1357.0,
        status: BookingStatus.completed,
        callType: 'audio',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        completedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      BookingModel(
        id: '3',
        clientId: 'c1',
        panditId: 'p3',
        serviceType: 'Career Guidance',
        scheduledAt: DateTime.now().subtract(const Duration(days: 3)),
        duration: 30,
        amount: 600.0,
        platformFee: 90.0,
        gst: 124.2,
        totalAmount: 814.2,
        status: BookingStatus.cancelled,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];

    final filteredBookings = status == null
        ? allBookings
        : allBookings.where((b) => b.status == status).toList();

    if (filteredBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No bookings found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredBookings.length,
      itemBuilder: (context, index) {
        return _BookingCard(booking: filteredBookings[index]);
      },
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;

  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    Color statusColor;
    IconData statusIcon;
    switch (booking.status) {
      case BookingStatus.confirmed:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case BookingStatus.completed:
        statusColor = Colors.blue;
        statusIcon = Icons.done_all;
        break;
      case BookingStatus.cancelled:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Navigate to booking details
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.serviceType,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pandit Name',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          booking.status.toString().split('.').last.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  _InfoItem(
                    icon: Icons.calendar_today,
                    label: dateFormat.format(booking.scheduledAt),
                  ),
                  const SizedBox(width: 16),
                  _InfoItem(
                    icon: Icons.access_time,
                    label: timeFormat.format(booking.scheduledAt),
                  ),
                  const SizedBox(width: 16),
                  _InfoItem(
                    icon: booking.callType == 'video'
                        ? Icons.videocam
                        : Icons.phone,
                    label: booking.callType == 'video' ? 'Video' : 'Audio',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '₹${booking.totalAmount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.saffronPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (booking.status == BookingStatus.confirmed)
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            context.push('/chat/${booking.id}');
                          },
                          child: const Text('Chat'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            context.push('/call/video/${booking.id}');
                          },
                          child: const Text('Join Call'),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppTheme.textLight),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

