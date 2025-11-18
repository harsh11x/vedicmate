import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/api_providers.dart';
import '../../services/settings_service.dart';

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
                // Call Type
                Text(
                  'Call Type',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _CallTypeCard(
                        icon: Icons.videocam,
                        label: 'Video Call',
                        isSelected: _selectedCallType == 'video',
                        onTap: () => setState(() => _selectedCallType = 'video'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CallTypeCard(
                        icon: Icons.phone,
                        label: 'Voice Call',
                        isSelected: _selectedCallType == 'audio',
                        onTap: () => setState(() => _selectedCallType = 'audio'),
                      ),
                    ),
                  ],
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
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isLoading = false);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Booking Confirmed!'),
          content: Text(
            'Your consultation is scheduled for ${DateFormat('MMM dd, yyyy').format(_selectedDate)} at $_selectedTimeSlot',
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
  }
}

final _settingsProvider = FutureProvider<AppSettings>((ref) async {
  final svc = ref.read(settingsServiceProvider);
  return svc.getSettings();
});

class _CallTypeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CallTypeCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.yellowPrimary : AppTheme.creamPrimary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.yellowPrimary : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppTheme.white : AppTheme.yellowPrimary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.white : AppTheme.textDark,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

