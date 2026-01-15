import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../services/user_preferences_service.dart';
import '../../utils/profile_completeness.dart'; // Added for Profile Completeness

class BirthDetailsScreen extends StatefulWidget {
  final String selectedCategory;

  const BirthDetailsScreen({
    super.key,
    required this.selectedCategory,
  });

  @override
  State<BirthDetailsScreen> createState() => _BirthDetailsScreenState();
}

class _BirthDetailsScreenState extends State<BirthDetailsScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _placeOfBirthController = TextEditingController();
  final _dayController = TextEditingController(); // Added for Numerology
  final _nameController = TextEditingController(); // Added for Name
  final _prefsService = UserPreferencesService();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    _animationController.forward();
    
    _loadSavedName();
  }

  Future<void> _loadSavedName() async {
    final name = await _prefsService.getUserName();
    if (name != null) {
      setState(() {
        _nameController.text = name;
      });
    }
  }

  @override
  void dispose() {
    _placeOfBirthController.dispose();
    _dayController.dispose();
    _nameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.yellowPrimary,
              onPrimary: AppTheme.textDark,
              surface: AppTheme.white,
              onSurface: AppTheme.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.yellowPrimary,
              onPrimary: AppTheme.textDark,
              surface: AppTheme.white,
              onSurface: AppTheme.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _handleContinue() async {
    bool isNumerology = widget.selectedCategory == 'Numerology';
    bool hasFullDate = _selectedDate != null;
    bool hasDay = _dayController.text.isNotEmpty;
    bool hasName = _nameController.text.isNotEmpty;
    
    // Validation
    if (!hasName) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name')),
      );
      return;
    }

    if (isNumerology) {
      if (!hasFullDate && !hasDay) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter either Date of Birth OR just the Day')),
        );
        return;
      }
    } else {
      // Normal validation
      if (!hasFullDate) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Date of Birth is required')),
        );
        return;
      }
    }

    if (_formKey.currentState!.validate()) {
      // Save Name using both Prefs and ProfileCompleteness (Supabase)
      await _prefsService.saveUserName(_nameController.text.trim());
      await ProfileCompleteness.saveUserName(_nameController.text.trim());

      // Save birth details
      if (hasFullDate) {
        await _prefsService.saveBirthDetails(
          dateOfBirth: _selectedDate!,
          placeOfBirth: _placeOfBirthController.text.isNotEmpty ? _placeOfBirthController.text : null,
          timeOfBirth: _selectedTime != null
              ? '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
              : null,
        );
        
        // Also save to Supabase via ProfileCompleteness
        await ProfileCompleteness.saveBirthDetails(
          dateOfBirth: _selectedDate!,
          timeOfBirth: _selectedTime != null
              ? '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
              : '',
          placeOfBirth: _placeOfBirthController.text.isNotEmpty 
              ? {'city': _placeOfBirthController.text} // Simple map for now
              : {},
        );
      }
      
      if (isNumerology && hasDay) {
         int? day = int.tryParse(_dayController.text);
         if (day != null) {
            await _prefsService.saveNumerologyDay(day);
            // Numerology handling in ProfileCompleteness is separate (e.g. input dialog)
            // But we can manually save it if we want. For now LOCAL is enough for AI to pick it up (due to my previous change).
         }
      }

      if (mounted) {
        // Direct Navigation Logic (AI 2.0)
        String targetPanditId = 'ai_pandit_1'; // Default: Vedic (Rajesh Shastri)
        
        switch (widget.selectedCategory) {
          case 'Numerology':
            targetPanditId = 'ai_pandit_2'; // Suresh Joshi
            break;
          case 'Lal Kitab':
            targetPanditId = 'ai_pandit_15'; // Acharya Dinesh Bhatt
            break;
          case 'Vedic Astrology':
          default:
            targetPanditId = 'ai_pandit_1';
            break;
        }

        context.push('/ai-pandit/chat?panditId=$targetPanditId');
      }
    }
  }

  void _handleSkipOptional() {
    _handleContinue(); // Reuse logic
  }

  @override
  Widget build(BuildContext context) {
    bool isNumerology = widget.selectedCategory == 'Numerology';

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Birth Details',
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryLight.withOpacity(0.3),
              AppTheme.white,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ... Progress Indicator ...
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildProgressDot(true),
                          _buildProgressLine(true),
                          _buildProgressDot(true),
                          _buildProgressLine(false),
                          _buildProgressDot(false),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Step 2 of 3',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.neutralMedium,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      
                      // ... Header ...
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.yellowPrimary.withOpacity(0.1),
                              AppTheme.goldAccent.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.yellowPrimary.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppTheme.yellowPrimary, AppTheme.goldAccent],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person, // Changed to person icon since we ask for name now
                                color: AppTheme.textDark,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isNumerology ? 'Numerology Details' : 'Birth Details',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Please details accurately for best results',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppTheme.textLight,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // === Name Input (New) ===
                      Text(
                        'Full Name *',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          hintText: 'Enter your full name',
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.yellowPrimary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.person_outline, color: AppTheme.yellowPrimary, size: 20),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: AppTheme.creamPrimary.withOpacity(0.3),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppTheme.yellowPrimary,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // === Numerology: Day of Birth Input ===
                      if (isNumerology) ...[
                        Text(
                          'Day of Birth (e.g., 23) *',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _dayController,
                          keyboardType: TextInputType.number,
                          maxLength: 2,
                          decoration: InputDecoration(
                            hintText: 'Enter day (1-31)',
                            counterText: '',
                            prefixIcon: Container(
                              margin: const EdgeInsets.all(8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.yellowPrimary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.calendar_view_day, color: AppTheme.yellowPrimary, size: 20),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: AppTheme.creamPrimary.withOpacity(0.3),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppTheme.yellowPrimary,
                                width: 2,
                              ),
                            ),
                          ),
                          onChanged: (val) {
                             setState(() {}); // refresh UI state for button enablement
                          },
                          validator: (value) {
                             // Only validate if user typed something
                             if (value != null && value.isNotEmpty) {
                                int? day = int.tryParse(value);
                                if (day == null || day < 1 || day > 31) {
                                   return 'Invalid day';
                                }
                             }
                             return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        Row(children: [
                           const Expanded(child: Divider()),
                           Padding(
                             padding: const EdgeInsets.symmetric(horizontal: 16),
                             child: Text("OR", style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.neutralMedium)),
                           ),
                           const Expanded(child: Divider()),
                        ]),
                        const SizedBox(height: 16),
                      ],

                      // Date of Birth (Existing)
                      Text(
                        'Full Date of Birth',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _selectDate,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.creamPrimary.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedDate != null ? AppTheme.yellowPrimary : AppTheme.forestBackground,
                              width: _selectedDate != null ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.yellowPrimary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.calendar_today, color: AppTheme.yellowPrimary, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _selectedDate != null
                                    ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                    : 'Select your birth date',
                                style: TextStyle(
                                  color: _selectedDate != null ? AppTheme.textDark : AppTheme.neutralMedium,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Place of Birth (Optional) - Hide for Numerology
                      if (!isNumerology) ...[
                        Row(
                          children: [
                            Text(
                              'Place of Birth',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textDark,
                                  ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.forestBackground,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Optional',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.neutralMedium,
                                      fontSize: 10,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _placeOfBirthController,
                          // ... existing input logic ...
                          decoration: InputDecoration(
                            hintText: 'Enter city, state',
                            prefixIcon: Container(
                              margin: const EdgeInsets.all(8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.yellowPrimary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.location_on, color: AppTheme.yellowPrimary, size: 20),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: AppTheme.creamPrimary.withOpacity(0.3),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppTheme.yellowPrimary,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Time of Birth (Optional)
                        Row(
                          children: [
                            Text(
                              'Time of Birth',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textDark,
                                  ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.forestBackground,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Optional',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.neutralMedium,
                                      fontSize: 10,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _selectTime,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.creamPrimary.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedTime != null ? AppTheme.yellowPrimary : AppTheme.forestBackground,
                                width: _selectedTime != null ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8), // Icon padding
                                  decoration: BoxDecoration(
                                    color: AppTheme.yellowPrimary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.access_time, color: AppTheme.yellowPrimary, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _selectedTime != null
                                      ? '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                                      : 'Select your birth time',
                                  style: TextStyle(
                                    color: _selectedTime != null ? AppTheme.textDark : AppTheme.neutralMedium,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Info Box
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.infoBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.infoBlue.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, color: AppTheme.infoBlue, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Optional fields help provide more accurate predictions',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppTheme.infoBlue,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      // Continue Button
                      Container(
                        decoration: BoxDecoration(
                          gradient: (_selectedDate != null || (isNumerology && _dayController.text.isNotEmpty))
                              ? const LinearGradient(
                                  colors: [AppTheme.yellowPrimary, AppTheme.goldAccent],
                                )
                              : null,
                          color: (_selectedDate == null && !(isNumerology && _dayController.text.isNotEmpty)) ? AppTheme.forestBackground : null,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: (_selectedDate != null || (isNumerology && _dayController.text.isNotEmpty))
                              ? [
                                  BoxShadow(
                                    color: AppTheme.yellowPrimary.withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ]
                              : null,
                        ),
                        child: ElevatedButton(
                          onPressed: (_selectedDate != null || (isNumerology && _dayController.text.isNotEmpty)) ? _handleContinue : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'CONTINUE',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: (_selectedDate != null || (isNumerology && _dayController.text.isNotEmpty)) ? AppTheme.textDark : AppTheme.neutralMedium,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward,
                                color: (_selectedDate != null || (isNumerology && _dayController.text.isNotEmpty)) ? AppTheme.textDark : AppTheme.neutralMedium,
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
          ),
        ),
      ),
    );
  }

  Widget _buildProgressDot(bool isActive) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        gradient: isActive
            ? const LinearGradient(
                colors: [AppTheme.yellowPrimary, AppTheme.goldAccent],
              )
            : null,
        color: isActive ? null : AppTheme.forestBackground,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildProgressLine(bool isActive) {
    return Container(
      width: 40,
      height: 2,
      color: isActive ? AppTheme.yellowPrimary : AppTheme.forestBackground,
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
