import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../../services/supabase_service.dart';

class BirthDetailsScreen extends StatefulWidget {
  final String astrologyType;
  const BirthDetailsScreen({super.key, required this.astrologyType});

  @override
  State<BirthDetailsScreen> createState() => _BirthDetailsScreenState();
}

class _BirthDetailsScreenState extends State<BirthDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dobController = TextEditingController();
  final _timeController = TextEditingController();
  final _placeController = TextEditingController();
  
  bool _isLoading = false;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppTheme.primaryOrange),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppTheme.primaryOrange),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B19), // Force Dark
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('${widget.astrologyType} Details', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Colors.white)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
           // 1. Cosmic Background
           Positioned.fill(
             child: Container(
               decoration: const BoxDecoration(
                 gradient: LinearGradient(
                   begin: Alignment.topCenter,
                   end: Alignment.bottomCenter,
                   colors: [
                     Color(0xFF0B0B19), 
                     Color(0xFF2D1B4E), 
                   ],
                 ),
               ),
             ),
           ),
           
           // 2. Animated Zodiac Wheel (Top Background)
           Positioned(
             top: -100,
             right: -100,
             child: Opacity(
               opacity: 0.1,
               child: _SpinningZodiacWheel(),
             ),
           ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryOrange.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.fingerprint, color: AppTheme.primaryOrange, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your Cosmic Blueprint',
                                  style: GoogleFonts.outfit(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Accurate details ensure precise predictions.',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Temporal Section (Date & Time)
                    _buildSectionHeader('Temporal Coordinates', Icons.access_time_filled_rounded),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E2E).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        children: [
                           // DOB Field
                            _buildRichField(
                              controller: _dobController,
                              label: 'Date of Birth',
                              subLabel: 'We calculate planetary positions based on this.',
                              hint: 'DD/MM/YYYY',
                              icon: Icons.calendar_today_rounded,
                              readOnly: true,
                              onTap: () => _selectDate(context),
                              validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Divider(color: Colors.white10),
                            ),
                            // Time Field
                            _buildRichField(
                              controller: _timeController,
                              label: 'Time of Birth',
                              subLabel: 'Determines your Ascendant (Lagna).',
                              hint: 'HH:MM AM/PM',
                              icon: Icons.schedule_rounded,
                              readOnly: true,
                              onTap: () => _selectTime(context),
                            ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                     // Spatial Section (Place)
                    _buildSectionHeader('Spatial Coordinates', Icons.public_rounded),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E2E).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: _buildRichField(
                        controller: _placeController,
                        label: 'Place of Birth',
                        subLabel: 'Adjusts for latitude & longitude.',
                        hint: 'City, Country',
                        icon: Icons.pin_drop_rounded,
                      ),
                    ),
                    
                    const SizedBox(height: 48),

                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryOrange.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        gradient: AppTheme.primaryGradient,
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading 
                            ? null 
                            : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _isLoading = true);
                            try {
                              // Save Logic (Keep existing)
                              final userId = FirebaseAuth.instance.currentUser?.uid;
                              if (userId != null) {
                                await SupabaseService().saveBirthDetails(
                                  userId: userId,
                                  astrologyType: widget.astrologyType,
                                  dateOfBirth: _selectedDate!,
                                  placeOfBirth: _placeController.text,
                                  timeOfBirth: _timeController.text,
                                );
                              }
                            } catch (e) {
                              debugPrint('Error saving: $e');
                            } finally {
                              if (mounted) {
                                setState(() => _isLoading = false);
                                context.push(
                                  '/onboarding/select-pandit',
                                  extra: {
                                    'astrologyType': widget.astrologyType,
                                    'dob': _selectedDate?.toIso8601String(),
                                    'tob': _timeController.text,
                                    'pob': _placeController.text,
                                  },
                                );
                              }
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          shadowColor: Colors.transparent,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Analyze Horoscope',
                                    style: GoogleFonts.outfit(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_rounded, size: 20),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.accentGold, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.accentGold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildRichField({
    required TextEditingController controller,
    required String label,
    required String subLabel,
    required String hint,
    required IconData icon,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(subLabel, style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: TextFormField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            style: GoogleFonts.outfit(color: Colors.white),
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.outfit(color: Colors.white30),
              prefixIcon: Icon(icon, color: Colors.white70),
              filled: false,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}

class _SpinningZodiacWheel extends StatefulWidget {
  @override
  State<_SpinningZodiacWheel> createState() => _SpinningZodiacWheelState();
}

class _SpinningZodiacWheelState extends State<_SpinningZodiacWheel> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Container(
        width: 400,
        height: 400,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: CustomPaint(
          painter: _ZodiacPainter(),
        ),
      ),
    );
  }
}

class _ZodiacPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
      
    final radius = size.width / 2;
    final center = Offset(radius, radius);
    
    // Draw 12 divisions
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * 3.14159 / 180;
      final start = center + Offset(radius * 0.4 * cos(angle), radius * 0.4 * sin(angle));
      final end = center + Offset(radius * cos(angle), radius * sin(angle));
      canvas.drawLine(start, end, paint);
    }
    
    canvas.drawCircle(center, radius * 0.4, paint);
    canvas.drawCircle(center, radius * 0.7, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

}
