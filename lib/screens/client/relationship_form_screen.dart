import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/custom_text_field.dart';

class RelationshipFormScreen extends StatefulWidget {
  const RelationshipFormScreen({super.key});

  @override
  State<RelationshipFormScreen> createState() => _RelationshipFormScreenState();
}

class _RelationshipFormScreenState extends State<RelationshipFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // User Details
  final _userNameController = TextEditingController();
  final _userPlaceController = TextEditingController();
  DateTime? _userDob;
  TimeOfDay? _userTime;
  String _userGender = 'Male';

  // Partner Details
  final _partnerNameController = TextEditingController();
  final _partnerPlaceController = TextEditingController();
  DateTime? _partnerDob;
  TimeOfDay? _partnerTime;
  String _partnerGender = 'Female';

  @override
  void dispose() {
    _userNameController.dispose();
    _userPlaceController.dispose();
    _partnerNameController.dispose();
    _partnerPlaceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isUser) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1995),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppTheme.divineGold),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isUser) _userDob = picked;
        else _partnerDob = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isUser) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppTheme.divineGold),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isUser) _userTime = picked;
        else _partnerTime = picked;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_userDob == null || _userTime == null || _partnerDob == null || _partnerTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select Date and Time for both')),
        );
        return;
      }

      // Prepare data
      final data = {
        'user': {
          'name': _userNameController.text,
          'dob': _userDob!.toIso8601String(),
          'time': _userTime!.format(context),
          'place': _userPlaceController.text,
          'gender': _userGender,
        },
        'partner': {
          'name': _partnerNameController.text,
          'dob': _partnerDob!.toIso8601String(),
          'time': _partnerTime!.format(context),
          'place': _partnerPlaceController.text,
          'gender': _partnerGender,
        },
      };

      // Navigate to result
      context.push('/relationship/result', extra: data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.divineBackground,
      appBar: AppBar(
        title: Text(
          'Relationship Check',
          style: GoogleFonts.cormorantGaramond(
              fontWeight: FontWeight.w600, 
              color: AppTheme.divineInk,
              fontSize: 26,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.divineInk),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildPersonSection(
                title: 'Your Details',
                color: AppTheme.divineGold.withOpacity(0.2),
                nameController: _userNameController,
                placeController: _userPlaceController,
                dob: _userDob,
                time: _userTime,
                gender: _userGender,
                onDateTap: () => _selectDate(context, true),
                onTimeTap: () => _selectTime(context, true),
                onGenderChanged: (v) => setState(() => _userGender = v!),
              ),
              const SizedBox(height: 24),
              const Icon(Icons.favorite, color: AppTheme.divineGold, size: 32),
              const SizedBox(height: 24),
              _buildPersonSection(
                title: 'Partner Details',
                color: AppTheme.divineGold.withOpacity(0.2),
                nameController: _partnerNameController,
                placeController: _partnerPlaceController,
                dob: _partnerDob,
                time: _partnerTime,
                gender: _partnerGender,
                onDateTap: () => _selectDate(context, false),
                onTimeTap: () => _selectTime(context, false),
                onGenderChanged: (v) => setState(() => _partnerGender = v!),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppTheme.divineInk,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    'Analyze Compatibility',
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.divineSurface),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonSection({
    required String title,
    required Color color,
    required TextEditingController nameController,
    required TextEditingController placeController,
    required DateTime? dob,
    required TimeOfDay? time,
    required String gender,
    required VoidCallback onDateTap,
    required VoidCallback onTimeTap,
    required Function(String?) onGenderChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.divineSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.divineInk)),
          const SizedBox(height: 16),
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              labelStyle: TextStyle(color: AppTheme.textGrey),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.divineGold.withOpacity(0.2))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.divineGold.withOpacity(0.2))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.divineGold, width: 1.5)),
              filled: true,
              fillColor: AppTheme.divineSurface,
            ),
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onDateTap,
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: dob == null ? 'DOB' : DateFormat('dd MMM yyyy').format(dob),
                        labelStyle: TextStyle(color: AppTheme.textGrey),
                        prefixIcon: const Icon(Icons.calendar_today, size: 18, color: AppTheme.divineGold),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.divineGold.withOpacity(0.2))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.divineGold.withOpacity(0.2))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.divineGold, width: 1.5)),
                        filled: true,
                        fillColor: AppTheme.divineSurface,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: onTimeTap,
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: time == null ? 'Time' : time.format(context),
                        labelStyle: TextStyle(color: AppTheme.textGrey),
                        prefixIcon: const Icon(Icons.access_time, size: 18, color: AppTheme.divineGold),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.divineGold.withOpacity(0.2))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.divineGold.withOpacity(0.2))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.divineGold, width: 1.5)),
                        filled: true,
                        fillColor: AppTheme.divineSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: placeController,
            decoration: InputDecoration(
              labelText: 'Place of Birth',
              labelStyle: TextStyle(color: AppTheme.textGrey),
              prefixIcon: const Icon(Icons.location_on_outlined, size: 18, color: AppTheme.divineGold),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.divineGold.withOpacity(0.2))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.divineGold.withOpacity(0.2))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.divineGold, width: 1.5)),
              filled: true,
              fillColor: AppTheme.divineSurface,
            ),
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          // Gender
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Male'),
                  value: 'Male',
                  groupValue: gender,
                  onChanged: onGenderChanged,
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppTheme.divineGold,
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Female'),
                  value: 'Female',
                  groupValue: gender,
                  onChanged: onGenderChanged,
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppTheme.divineGold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
