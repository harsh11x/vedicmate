import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
// NOTE: Razorpay has been deprecated in favor of RevenueCat
// This screen needs to be updated to use RevenueCat for payments
import '../../core/theme/app_theme.dart';
import '../shared/payment_wallet_screen.dart';
import '../../services/custom_request_service.dart';

class CustomBookingScreen extends StatefulWidget {
  const CustomBookingScreen({super.key});

  @override
  State<CustomBookingScreen> createState() => _CustomBookingScreenState();
}

class _CustomBookingScreenState extends State<CustomBookingScreen> {
  String _selectedType = 'Custom Request';
  
  final Map<String, dynamic> _servicePrices = {
    'Custom Request': 'TBD', // Price to be discussed
    'Custom Pooja': 4999,
    'Private Havan': 2999,
    'Personal Consultation': 1999,
    'Dosha Nivaran': 3999,
    'Gemstone Consultation': 999,
  };

  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeSlot;
  final TextEditingController _requirementsController = TextEditingController();
  
  // Method is fixed to Video Call as per requirements
  final String _method = 'Video Call';
  
  // Payment
  bool _isProcessing = false;
  String? _currentOrderId;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _requirementsController.dispose();
    super.dispose();
  }

  // DEPRECATED: Payment processing removed - needs RevenueCat integration
  Future<void> _processPayment() async {
    // Validate
    if (_selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time slot')),
      );
      return;
    }

    final priceValue = _servicePrices[_selectedType];
    
    // Handle TBD pricing - submit request without payment
    if (priceValue == 'TBD') {
      await _submitTbdRequest();
      return;
    }

    // TODO: Implement RevenueCat payment flow
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment functionality needs to be updated to use RevenueCat'),
      ),
    );
  }

  // DEPRECATED: Payment handlers removed - needs RevenueCat integration

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 48),
            ),
            const SizedBox(height: 16),
            Text(
              'Booking Confirmed!',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Your custom request has been submitted successfully. Our team will review and confirm the details shortly.',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop(); // Close dialog
              context.pop(); // Go back to dashboard
            },
            child: Text('OK', style: GoogleFonts.outfit(color: AppTheme.primaryOrange)),
          ),
        ],
      ),
    );
  }

  void _showRetryDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Text('Payment Failed', style: GoogleFonts.outfit(fontSize: 18)),
          ],
        ),
        content: Text(error, style: GoogleFonts.outfit(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text('Cancel', style: GoogleFonts.outfit()),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop();
              _processPayment();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryOrange,
            ),
            child: Text('Try Again', style: GoogleFonts.outfit(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _submitTbdRequest() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in to continue')));
      return;
    }
    setState(() => _isProcessing = true);
    try {
      final res = await CustomRequestService.createTbdRequest(
        userId: user.uid,
        userName: user.displayName ?? 'User',
        userEmail: user.email ?? '',
        userPhone: user.phoneNumber ?? '',
        serviceType: _selectedType,
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
        timeSlot: _selectedTimeSlot!,
        requirements: _requirementsController.text.trim(),
      );
      if (res['success'] == true && mounted) {
        _showTbdSuccessDialog();
      } else {
        throw Exception(res['error'] ?? 'Failed to submit');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString().replaceFirst('Exception: ', '')}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showTbdSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 48),
            ),
            const SizedBox(height: 16),
            Text(
              'Request Sent!',
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Custom request has been sent. Once confirmed, it will be reflected in your orders in the Settings page.',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop();
              context.pop();
            },
            child: Text('OK', style: GoogleFonts.outfit(color: AppTheme.primaryOrange)),
          ),
          FilledButton(
            onPressed: () {
              context.pop();
              context.pop();
              context.push('/custom-requests/orders');
            },
            style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryOrange),
            child: Text('View Orders', style: GoogleFonts.outfit(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.forestBackground, // Light background
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.neutralDark, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Session Details',
          style: GoogleFonts.outfit(
            color: AppTheme.neutralDark,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Description
            Text(
              'Personalize Your Consultation',
              style: GoogleFonts.playfairDisplay(
                color: AppTheme.neutralDark,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Choose the consultation type. Prices vary by service. Scheduling will be finalized via Calendly after payment.',
              style: GoogleFonts.outfit(
                color: AppTheme.neutralMedium,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 32),

            // 1. Select Consultation Type
            _buildSectionLabel('Select Consultation Type'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.forestBackground),
                boxShadow: AppTheme.softShadow,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedType,
                  isExpanded: true,
                  dropdownColor: AppTheme.white,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.primaryOrange),
                  style: GoogleFonts.outfit(
                    color: AppTheme.neutralDark,
                    fontSize: 16,
                  ),
                  items: _servicePrices.keys.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(type),
                          Text(
                            _servicePrices[type] == 'TBD' 
                                ? 'Price TBD' 
                                : '₹${_servicePrices[type]}',
                            style: GoogleFonts.outfit(
                              color: AppTheme.neutralMedium,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedType = newValue!;
                    });
                  },
                ),
              ),
            ),

             const SizedBox(height: 24),

            // 1.b Requirements Input (New)
            _buildSectionLabel('Your Requirements (Optional)'),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                 color: AppTheme.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.softShadow,
              ),
              child: TextField(
                maxLines: 3,
                style: GoogleFonts.outfit(color: AppTheme.neutralDark),
                decoration: InputDecoration(
                  hintText: 'Tell us a bit about what you are looking for...',
                  hintStyle: GoogleFonts.outfit(color: AppTheme.neutralMedium),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppTheme.white,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // 2. Consultation Method (Fixed - Video Call Only)
            _buildSectionLabel('Consultation Method'),
            const SizedBox(height: 16),
            // Removed Chat option, Video Call is now full width
            _buildMethodOption('Video Call', Icons.videocam_outlined, true),
            
            const SizedBox(height: 12),
             Row(
              children: [
                 Icon(Icons.info_outline_rounded, size: 14, color: AppTheme.primaryOrange),
                 const SizedBox(width: 8),
                 Expanded(
                   child: Text(
                    'Sessions are conducted via Google Meet.',
                    style: GoogleFonts.outfit(color: AppTheme.primaryOrange, fontSize: 12),
                   ),
                 ),
              ],
            ),

            const SizedBox(height: 32),

            // 3. Select Date (Preferred)
            _buildSectionLabel('Select Preferred Date & Time'),
            const SizedBox(height: 16),
            _buildMonthHeader(),
            const SizedBox(height: 16),
            _buildDateSelector(),
            
            const SizedBox(height: 24),
            _buildSectionLabel('Choose your Time (10:00 AM - 07:00 PM)'),
            const SizedBox(height: 16),
            _buildTimeSelector(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.outfit(
        color: AppTheme.neutralDark,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildMethodOption(String label, IconData icon, bool isSelected) {
    return Container(
      width: double.infinity, // Full width
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryOrange : AppTheme.white,
        borderRadius: BorderRadius.circular(30),
        border: isSelected ? null : Border.all(color: AppTheme.forestBackground),
        boxShadow: isSelected ? AppTheme.glowShadow : AppTheme.softShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? AppTheme.white : AppTheme.neutralMedium,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: isSelected ? AppTheme.white : AppTheme.neutralMedium,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          DateFormat('MMMM yyyy').format(_selectedDate),
          style: GoogleFonts.outfit(
            color: AppTheme.neutralDark,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, size: 16, color: AppTheme.neutralDark),
              onPressed: () {
                final newDate = _selectedDate.subtract(const Duration(days: 30));
                // Prevent going back before current month if current month is selected
                if (newDate.month >= DateTime.now().month || newDate.year > DateTime.now().year) {
                   setState(() => _selectedDate = newDate);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.neutralDark),
              onPressed: () => setState(() => _selectedDate = _selectedDate.add(const Duration(days: 30))),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildDateSelector() {
    final now = DateTime.now();
    // Start from today, don't show past dates
    final startDate = now; 
    
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 14, // Show next 2 weeks
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final date = startDate.add(Duration(days: index));
          final isSelected = date.day == _selectedDate.day && date.month == _selectedDate.month;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
                _selectedTimeSlot = null; // Reset time slot when date changes
              });
            },
            child: Container(
              width: 60,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryOrange : AppTheme.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.transparent : AppTheme.forestBackground,
                ),
                boxShadow: isSelected ? AppTheme.glowShadow : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date),
                    style: GoogleFonts.outfit(
                      color: isSelected ? AppTheme.white.withOpacity(0.8) : AppTheme.neutralMedium,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('d').format(date),
                    style: GoogleFonts.outfit(
                      color: isSelected ? AppTheme.white : AppTheme.neutralDark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeSelector() {
    // Generate times from 10:00 AM to 07:00 PM
    final List<DateTime> timeSlots = [];
    final now = DateTime.now();
    final isToday = _selectedDate.year == now.year && 
                    _selectedDate.month == now.month && 
                    _selectedDate.day == now.day;

    DateTime startTime = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 10, 0);
    // End time is 7:00 PM (19:00)
    DateTime endTime = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 19, 0);

    while (startTime.isBefore(endTime) || startTime.isAtSameMomentAs(endTime)) {
      // Logic to filter past hours if date is today
      if (!isToday || startTime.isAfter(now)) {
        timeSlots.add(startTime);
      }
      startTime = startTime.add(const Duration(hours: 1));
    }

    if (timeSlots.isEmpty) {
       return Center(
         child: Padding(
           padding: const EdgeInsets.all(16.0),
           child: Text(
             'No slots available for today.',
             style: GoogleFonts.outfit(color: AppTheme.neutralMedium),
           ),
         ),
       );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: timeSlots.map((dateTime) {
        final timeString = DateFormat('hh:00 a').format(dateTime);
        final isSelected = _selectedTimeSlot == timeString;
        
        return GestureDetector(
          onTap: () => setState(() => _selectedTimeSlot = timeString),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryOrange : AppTheme.white,
              borderRadius: BorderRadius.circular(24),
              border: isSelected ? null : Border.all(color: AppTheme.forestBackground),
              boxShadow: isSelected ? AppTheme.glowShadow : [],
            ),
            child: Text(
              timeString,
              style: GoogleFonts.outfit(
                color: isSelected ? AppTheme.white : AppTheme.neutralDark,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomBar() {
    final priceValue = _servicePrices[_selectedType];
    final priceText = priceValue == 'TBD' ? 'Price TBD' : '₹$priceValue';
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: AppTheme.softShadow,
      ),
      child: SafeArea( // Ensure button is above home indicator
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('d MMM').format(_selectedDate) + (_selectedTimeSlot != null ? ' • $_selectedTimeSlot' : ''),
                  style: GoogleFonts.outfit(
                    color: AppTheme.neutralMedium,
                    fontSize: 12,
                  ),
                ),
                Text(
                  priceText, // Dynamic Price or TBD
                  style: GoogleFonts.outfit(
                    color: AppTheme.neutralDark,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                  foregroundColor: AppTheme.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 4,
                  shadowColor: AppTheme.primaryOrange.withOpacity(0.4),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: AppTheme.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        priceValue == 'TBD' ? 'Contact Us' : 'Proceed to Payment',
                        style: GoogleFonts.outfit(
                          color: AppTheme.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
