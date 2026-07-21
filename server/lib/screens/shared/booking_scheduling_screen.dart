import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/api_providers.dart';
import '../../providers/wallet_provider.dart';
import '../../services/settings_service.dart';
import '../../services/booking_service.dart';
import '../../models/booking_model.dart';

class BookingSchedulingScreen extends ConsumerStatefulWidget {
  final String panditId;
  final String serviceType;

  const BookingSchedulingScreen({
    super.key,
    required this.panditId,
    required this.serviceType,
  });

  @override
  ConsumerState<BookingSchedulingScreen> createState() => _BookingSchedulingScreenState();
}

class _BookingSchedulingScreenState extends ConsumerState<BookingSchedulingScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeSlot;
  String _selectedCallType = 'video';
  final List<String> _timeSlots = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
    '06:00 PM',
  ];
  final double _servicePrice = 500.0;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(_settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Consultation'),
      ),
      body: settingsAsync.when(
        data: (settings) {
          final platformFee = _servicePrice * (settings.platformFeePercent / 100);
          final gst = (_servicePrice + platformFee) * (AppConstants.gstRate / 100);
          final totalAmount = _servicePrice + platformFee + gst;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service Info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.stars, color: AppTheme.yellowPrimary, size: 40),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.serviceType.toUpperCase(),
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₹$_servicePrice',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: AppTheme.yellowPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Date Selection
                Text(
                  'Select Date',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Card(
                  child: TableCalendar(
                    firstDay: DateTime.now(),
                    lastDay: DateTime.now().add(const Duration(days: 90)),
                    focusedDay: _selectedDate,
                    selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDate = selectedDay;
                        _selectedTimeSlot = null;
                      });
                    },
                    calendarFormat: CalendarFormat.month,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    calendarStyle: CalendarStyle(
                      selectedDecoration: BoxDecoration(
                        color: AppTheme.yellowPrimary,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: AppTheme.yellowLight,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Time Slots
                Text(
                  'Select Time',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _timeSlots.map((slot) {
                    final isSelected = _selectedTimeSlot == slot;
                    return ChoiceChip(
                      label: Text(slot),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedTimeSlot = selected ? slot : null);
                      },
                      selectedColor: AppTheme.yellowPrimary,
                      labelStyle: TextStyle(
                        color: isSelected ? AppTheme.white : AppTheme.textDark,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                // Price Breakdown
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Price Breakdown',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                        _PriceRow(label: 'Service Fee', amount: _servicePrice),
                        _PriceRow(
                          label: 'Platform Fee (${settings.platformFeePercent}%)',
                          amount: platformFee,
                        ),
                        _PriceRow(
                          label: 'GST (${AppConstants.gstRate}%)',
                          amount: gst,
                        ),
                        const Divider(),
                        _PriceRow(
                          label: 'Total Amount',
                          amount: totalAmount,
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Book Button
                ElevatedButton(
                  onPressed: (_selectedTimeSlot == null || _isLoading)
                      ? null
                      : _handleBooking,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.08,
                      vertical: 16,
                    ),
                    minimumSize: Size(
                      MediaQuery.of(context).size.width * 0.3,
                      48,
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : FittedBox(
                          fit: BoxFit.scaleDown,
                          child: const Text('Confirm Booking'),
                        ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load settings: $e')),
      ),
    );
  }

  void _handleBooking() async {
    if (_selectedTimeSlot == null) return;

    setState(() => _isLoading = true);

    try {
      final bookingService = ref.read(bookingServiceProvider);
      final userId = FirebaseAuth.instance.currentUser?.uid;
      
      if (userId == null) {
        throw Exception('Please login to book a consultation');
      }

      // Parse time slot
      final timeParts = _selectedTimeSlot!.split(' ');
      final time = timeParts[0];
      final period = timeParts[1];
      final hourMinute = time.split(':');
      int hour = int.parse(hourMinute[0]);
      final minute = int.parse(hourMinute[1]);
      
      if (period == 'PM' && hour != 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;

      final scheduledDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        hour,
        minute,
      );

      // Get service price from pandit (simplified - should fetch from pandit model)
      final servicePrice = _servicePrice;

      // Create booking
      final booking = await bookingService.createBooking(
        clientId: userId,
        panditId: widget.panditId,
        serviceType: widget.serviceType,
        scheduledAt: scheduledDateTime,
        duration: 30, // Default duration
        callType: _selectedCallType,
        servicePrice: servicePrice,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        
        // Refresh wallet balance
        ref.read(walletNotifierProvider.notifier).refresh();
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Booking Confirmed!'),
            content: Text(
              'Your consultation is scheduled for ${DateFormat('MMM dd, yyyy').format(scheduledDateTime)} at $_selectedTimeSlot\n\nBooking ID: ${booking.id}',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/client/dashboard');
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Booking Failed'),
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }
}

final _settingsProvider = FutureProvider<AppSettings>((ref) async {
  final svc = ref.read(settingsServiceProvider);
  return svc.getSettings();
});

class _PriceRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isTotal;

  const _PriceRow({
    required this.label,
    required this.amount,
    this.isTotal = false,
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
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                  color: isTotal ? AppTheme.yellowPrimary : null,
                ),
          ),
        ],
      ),
    );
  }
}

