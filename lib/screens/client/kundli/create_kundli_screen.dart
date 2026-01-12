import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:country_state_city_pro/country_state_city_pro.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../widgets/abstract_background.dart';

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
              primary: AppTheme.primaryOrange,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.neutralDark,
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
              primary: AppTheme.primaryOrange,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.neutralDark,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              hourMinuteColor: AppTheme.forestBackground,
              hourMinuteTextColor: AppTheme.primaryOrange,
              dialHandColor: AppTheme.primaryOrange,
              dialBackgroundColor: AppTheme.forestBackground,
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
      backgroundColor: AppTheme.forestBackground,
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
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppTheme.forestBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              color: AppTheme.neutralDark,
              onPressed: () => context.pop(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "Create New Kundli",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
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
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.glowShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Discover Your Destiny",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Enter birth details to generate accurate charts.",
                  style: TextStyle(
                    color: Colors.white70,
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassMorphism,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Personal Information", style: Theme.of(context).textTheme.titleMedium),
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
              const Icon(Icons.location_on_outlined, color: AppTheme.primaryOrange, size: 20),
              const SizedBox(width: 8),
              Text("Birth Place", style: Theme.of(context).textTheme.titleMedium),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.forestBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: CountryStateCityPicker(
        country: _countryController,
        state: _stateController,
        city: _cityController,
        dialogColor: Colors.white,
        textFieldDecoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.neutralMedium.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.neutralMedium.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.primaryOrange, width: 2),
          ),
          suffixIcon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryOrange),
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
      style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.neutralDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppTheme.neutralMedium, fontWeight: FontWeight.normal),
        prefixIcon: Icon(icon, color: AppTheme.primaryOrange),
        filled: true,
        fillColor: AppTheme.forestBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.primaryOrange, width: 2),
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
          color: AppTheme.forestBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.transparent),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: AppTheme.primaryOrange),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: AppTheme.neutralMedium, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 14, 
                fontWeight: FontWeight.w600,
                color: isPlaceholder ? AppTheme.neutralMedium : AppTheme.neutralDark,
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
        color: AppTheme.forestBackground,
        borderRadius: BorderRadius.circular(16),
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
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
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
              color: isSelected ? AppTheme.primaryOrange : AppTheme.neutralMedium,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppTheme.neutralDark : AppTheme.neutralMedium,
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
          backgroundColor: AppTheme.primaryOrange,
           shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Generate Full Kundli",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 12),
            Icon(Icons.arrow_forward_rounded),
          ],
        ),
      ),
    );
  }
}
