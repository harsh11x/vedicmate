
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:country_state_city_pro/country_state_city_pro.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../services/user_preferences_service.dart';

class KundliDetailsSheet extends ConsumerStatefulWidget {
  const KundliDetailsSheet({super.key});

  @override
  ConsumerState<KundliDetailsSheet> createState() => _KundliDetailsSheetState();
}

class _KundliDetailsSheetState extends ConsumerState<KundliDetailsSheet> {
  final _formKey = GlobalKey<FormState>();
  final _prefsSelector = UserPreferencesService();
  
  // Controllers
  final _nameController = TextEditingController();
  final _countryController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  
  // State
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    setState(() => _isLoading = true);
    try {
      // Load user name
      final user = FirebaseAuth.instance.currentUser;
      _nameController.text = user?.displayName ?? '';

      // Load saved preferences
      final dob = await _prefsSelector.getDateOfBirth();
      final timeStr = await _prefsSelector.getTimeOfBirth();
      final place = await _prefsSelector.getPlaceOfBirth();

      if (dob != null) {
        _selectedDate = dob;
      }
      
      if (timeStr != null) {
        // Parse time string (e.g., "10:30 AM")
        try {
          // Ideally parse properly based on your storage format
           // Simple parsing assuming standard format, or default to null if complex
           // For now, let's leave it null to force re-selection if parsing is hard without a parser
           // But mostly the format is what TimeOfDay.format gives (e.g. "10:30 AM" or "10:30")
           // Let's try basic split
           final parts = timeStr.split(":");
           if (parts.length >= 2) {
             final hour = int.parse(parts[0]);
             final minutePart = parts[1].split(" ")[0]; // remove AM/PM if exists
             final minute = int.parse(minutePart);
             _selectedTime = TimeOfDay(hour: hour, minute: minute);
           }
        } catch (e) {
          print('Error parsing time: $e');
        }
      }

      if (place != null && place.isNotEmpty) {
        // Try to pre-fill city/state/country from the comma separated string
        // Format: "City, State, Country"
        final parts = place.split(',').map((e) => e.trim()).toList();
        if (parts.isNotEmpty) _cityController.text = parts[0];
        if (parts.length > 1) _stateController.text = parts[1];
        if (parts.length > 2) _countryController.text = parts[2];
      }
    } catch (e) {
      print('Error loading preferences: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: AppTheme.lightTheme.copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryOrange,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: AppTheme.lightTheme.copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryOrange,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _saveAndShare() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Logic to save
    setState(() => _isLoading = true);
    
    try {
      final dob = _selectedDate ?? DateTime.now(); // Fallback if optional but logic below handles nulls?
      // Actually strictly require DOB for Kundli
      if (_selectedDate == null) {
         if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Date of Birth is required")));
            setState(() => _isLoading = false);
         }
         return;
      }

      final timeString = _selectedTime?.format(context) ?? '';
      
      final place = [_cityController.text, _stateController.text, _countryController.text]
          .where((e) => e.isNotEmpty)
          .join(', ');

      // Save to prefs
      await _prefsSelector.saveBirthDetails(
        dateOfBirth: _selectedDate!,
        timeOfBirth: timeString.isNotEmpty ? timeString : null,
        placeOfBirth: place.isNotEmpty ? place : null,
      );

      // Create message string
      final sb = StringBuffer();
      sb.writeln("My Kundli details:");
      sb.writeln("Name: ${_nameController.text}");
      sb.writeln("DOB: ${DateFormat('dd MMM yyyy').format(_selectedDate!)}");
      if (_selectedTime != null) {
        sb.writeln("Time: $timeString");
      }
      if (place.isNotEmpty) {
        sb.writeln("Place: $place");
      }

      if (mounted) {
        Navigator.pop(context, sb.toString());
      }

    } catch (e) {
      print('Error saving: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange)),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea( // SafeArea wrapper
        top: false,      // Bottom sheet, so top safe area is usually not needed/handled by modal
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kundli Details',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.neutralDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Share your birth details for precise Vedic readings.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.neutralMedium,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppTheme.neutralMedium),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
        
                // Name
                Text('FULL NAME', style: _labelStyle),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration(hint: 'e.g. Aryan Sharma'),
                  validator: (v) => v?.isEmpty == true ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
        
                // DOB & Time
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('DATE OF BIRTH', style: _labelStyle),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _selectDate(context),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.forestBackground.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.neutralMedium.withOpacity(0.2)),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _selectedDate == null 
                                        ? 'mm/dd/yyyy'
                                        : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                                      style: GoogleFonts.inter(
                                        color: _selectedDate == null ? AppTheme.neutralMedium : AppTheme.neutralDark,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.calendar_today_outlined, size: 18, color: AppTheme.neutralDark),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Row(
                             children: [
                               Text('TIME', style: _labelStyle),
                               Text(' (Optional)', style: _labelStyle.copyWith(color: AppTheme.neutralMedium.withOpacity(0.6))),
                             ],
                           ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _selectTime(context),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.forestBackground.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.neutralMedium.withOpacity(0.2)),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _selectedTime == null 
                                        ? '--:-- --'
                                        : _selectedTime!.format(context),
                                      style: GoogleFonts.inter(
                                        color: _selectedTime == null ? AppTheme.neutralMedium : AppTheme.neutralDark,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.access_time, size: 18, color: AppTheme.neutralDark),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
        
                // Place
                Row(
                   children: [
                     Text('PLACE OF BIRTH', style: _labelStyle),
                      Text(' (Optional)', style: _labelStyle.copyWith(color: AppTheme.neutralMedium.withOpacity(0.6))),
                   ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.forestBackground.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.neutralMedium.withOpacity(0.2)),
                  ),
                  child: CountryStateCityPicker(
                      country: _countryController,
                      state: _stateController,
                      city: _cityController,
                      dialogColor: Colors.white,
                      textFieldDecoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'City, Country',
                        suffixIcon: Icon(Icons.location_on_outlined, size: 18, color: AppTheme.neutralMedium),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                ),
        
                const SizedBox(height: 24),
        
                // Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveAndShare,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryOrange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.stars, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Update Kundli',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextStyle get _labelStyle => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AppTheme.neutralMedium,
    letterSpacing: 1.0,
  );

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: AppTheme.neutralMedium),
      filled: true,
      fillColor: AppTheme.forestBackground.withOpacity(0.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.neutralMedium.withOpacity(0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.neutralMedium.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primaryOrange),
      ),
    );
  }
}
