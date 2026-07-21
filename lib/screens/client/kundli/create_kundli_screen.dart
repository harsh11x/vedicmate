import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:country_state_city_pro/country_state_city_pro.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../widgets/abstract_background.dart';
import '../../../../widgets/sketchy_painter.dart';

class CreateKundliScreen extends ConsumerStatefulWidget {
  const CreateKundliScreen({super.key});

  @override
  ConsumerState<CreateKundliScreen> createState() => _CreateKundliScreenState();
}

class _CreateKundliScreenState extends ConsumerState<CreateKundliScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _countryController;
  late TextEditingController _stateController;
  late TextEditingController _cityController;
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedGender = 'Male';
  String? _selectedCountry;
  String? _selectedState;
  String? _selectedCity;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _countryController = TextEditingController();
    _stateController = TextEditingController();
    _cityController = TextEditingController();
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
            colorScheme: ColorScheme.light(
              primary: AppTheme.divineGold,
              onPrimary: AppTheme.divineInk,
              surface: AppTheme.divineSurface,
              onSurface: AppTheme.divineInk,
            ),
          
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: AppTheme.lightTheme.copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.divineGold,
              onPrimary: AppTheme.divineInk,
              surface: AppTheme.divineSurface,
              onSurface: AppTheme.divineInk,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppTheme.divineSurface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              hourMinuteColor: AppTheme.divineBackground,
              hourMinuteTextColor: AppTheme.divineInk,
              dialHandColor: AppTheme.divineGold,
              dialBackgroundColor: AppTheme.divineBackground,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _generateKundli() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select Date of Birth'),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      if (_selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select Time of Birth'),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      if (_cityController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select Country, State and City'),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final dobString = _selectedDate!.toIso8601String();
      final timeString = _selectedTime!.format(context);
      
      // Combine city, state, country for place
      final place = [_cityController.text, _stateController.text, _countryController.text]
          .where((e) => e.isNotEmpty)
          .join(', ');

      context.push(
        Uri(
          path: '/kundli/generation',
          queryParameters: {
            'name': _nameController.text,
            'dob': dobString,
            'time': timeString,
            'place': place,
            'gender': _selectedGender,
          },
        ).toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.divineBackground,
      body: AbstractBackground(
        child: Column(
          children: [
            _buildModernHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildGreetingCard(),
                      const SizedBox(height: 24),
                      _buildFormCard(),
                      const SizedBox(height: 32),
                      _buildGenerateButton(),
                      const SizedBox(height: 48), // Bottom padding
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 20,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: AppTheme.divineSurface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        border: Border(bottom: BorderSide(color: AppTheme.divineGold.withOpacity(0.3))),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppTheme.divineBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.divineGold.withOpacity(0.3)),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              color: AppTheme.divineInk,
              onPressed: () => context.pop(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "Create New Kundli",
              style: GoogleFonts.cormorantGaramond(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: AppTheme.divineInk,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.divineInk,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.divineGold.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.divineGold.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome, color: AppTheme.divineGold, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Discover Your Destiny",
                  style: GoogleFonts.cormorantGaramond(
                    color: AppTheme.divineSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Enter birth details to generate accurate charts.",
                  style: TextStyle(
                    color: AppTheme.divineSurface.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return SketchyContainer(
      backgroundColor: AppTheme.divineSurface,
      borderColor: AppTheme.divineGold,
      borderRadius: 24,
      padding: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Personal Information", style: GoogleFonts.cormorantGaramond(fontSize: 24, fontWeight: FontWeight.w600, color: AppTheme.divineInk)),
          const SizedBox(height: 20),
          _buildModernTextField(
            controller: _nameController,
            label: "Full Name",
            icon: Icons.person_outline_rounded,
            validator: (v) => v?.trim().isEmpty == true ? 'Name is required' : null,
          ),
          const SizedBox(height: 20),
          _buildGenderSelector(),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildModernPicker(
                  label: "Date of Birth",
                  value: _selectedDate == null ? "Select Date" : DateFormat('dd MMM yyyy').format(_selectedDate!),
                  icon: Icons.calendar_month_rounded,
                  onTap: () => _selectDate(context),
                  isPlaceholder: _selectedDate == null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildModernPicker(
                  label: "Time of Birth",
                  value: _selectedTime?.format(context) ?? "Select Time",
                  icon: Icons.access_time_filled_rounded,
                  onTap: () => _selectTime(context),
                  isPlaceholder: _selectedTime == null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Birth Place Section
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: AppTheme.divineGold, size: 20),
              const SizedBox(width: 8),
              Text("Birth Place", style: GoogleFonts.cormorantGaramond(fontSize: 22, fontWeight: FontWeight.w600, color: AppTheme.divineInk)),
            ],
          ),
          const SizedBox(height: 16),
          _buildLocationPicker(),
        ],
      ),
    );
  }

  Widget _buildLocationPicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.divineBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divineGold.withOpacity(0.2)),
      ),
      child: CountryStateCityPicker(
        country: _countryController,
        state: _stateController,
        city: _cityController,
        dialogColor: AppTheme.divineSurface,
        textFieldDecoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Select Location",
          hintStyle: TextStyle(color: AppTheme.textGrey),
          prefixIcon: Icon(Icons.location_on_outlined, color: AppTheme.divineGold, size: 20),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.divineInk),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppTheme.textGrey, fontWeight: FontWeight.normal),
        prefixIcon: Icon(icon, color: AppTheme.divineGold),
        filled: true,
        fillColor: AppTheme.divineBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppTheme.divineGold.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppTheme.divineGold.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.divineGold, width: 2),
        ),
      ),
    );
  }

  Widget _buildModernPicker({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
    required bool isPlaceholder,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.divineBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divineGold.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: AppTheme.divineGold),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: AppTheme.textGrey, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 14, 
                fontWeight: FontWeight.w600,
                color: isPlaceholder ? AppTheme.textGrey : AppTheme.divineInk,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.divineBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divineGold.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(child: _buildGenderOption('Male', Icons.male)),
          Expanded(child: _buildGenderOption('Female', Icons.female)),
        ],
      ),
    );
  }

  Widget _buildGenderOption(String label, IconData icon) {
    final isSelected = _selectedGender == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.divineSurface : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: AppTheme.divineGold.withOpacity(0.5)) : Border.all(color: Colors.transparent),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ] : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppTheme.divineGold : AppTheme.textGrey,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppTheme.divineInk : AppTheme.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.glowShadow,
      ),
      child: ElevatedButton(
        onPressed: _generateKundli,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
          backgroundColor: AppTheme.divineInk,
           shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Generate Full Kundli",
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.divineSurface),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.arrow_forward_rounded, color: AppTheme.divineSurface),
          ],
        ),
      ),
    );
  }
}
