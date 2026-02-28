import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import 'elegant_dropdown.dart';

/// Dialog to collect numerology preferences from user
class NumerologyInputDialog extends StatefulWidget {
  const NumerologyInputDialog({super.key});

  @override
  State<NumerologyInputDialog> createState() => _NumerologyInputDialogState();
}

class _NumerologyInputDialogState extends State<NumerologyInputDialog> {
  String _selectedOption = 'day_only'; // 'day_only' or 'full_date'
  int? _dayOfBirth;
  DateTime? _fullDateOfBirth;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.calculate, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Numerology Setup',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textBlack,
                        ),
                      ),
                      Text(
                        'Choose your preference',
                        style: AppTheme.bodyStyle.copyWith(
                          color: AppTheme.textGrey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Option 1: Day Only
            _buildOptionCard(
              title: 'Day of Birth Only',
              subtitle: 'Quick numerology based on your birth day (1-31)',
              icon: Icons.today,
              value: 'day_only',
              child: _selectedOption == 'day_only'
                  ? Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: ElegantDropdown<int>(
                        hint: 'Select Day',
                        value: _dayOfBirth,
                        prefixIcon: Icons.calendar_today_rounded,
                        items: List.generate(31, (index) => index + 1)
                            .map((day) => DropdownMenuItem(
                                  value: day,
                                  child: Text('$day'),
                                ))
                            .toList(),
                        onChanged: (value) => setState(() => _dayOfBirth = value),
                      ),
                    )
                  : null,
            ),

            const SizedBox(height: 16),

            // Option 2: Full Date
            _buildOptionCard(
              title: 'Full Date of Birth',
              subtitle: 'Complete numerology with full birth date',
              icon: Icons.calendar_today,
              value: 'full_date',
              child: _selectedOption == 'full_date'
                  ? Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() => _fullDateOfBirth = date);
                          }
                        },
                        icon: const Icon(Icons.calendar_month),
                        label: Text(
                          _fullDateOfBirth != null
                              ? '${_fullDateOfBirth!.day}/${_fullDateOfBirth!.month}/${_fullDateOfBirth!.year}'
                              : 'Select Date',
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    )
                  : null,
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Skip for Now'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _canSubmit() ? _submit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    Widget? child,
  }) {
    final isSelected = _selectedOption == value;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedOption = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryOrange.withOpacity(0.05) : AppTheme.divineSurface,
          border: Border.all(
            color: isSelected ? AppTheme.primaryOrange : Colors.grey.withOpacity(0.2),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Radio<String>(
                  value: value,
                  groupValue: _selectedOption,
                  onChanged: (val) => setState(() => _selectedOption = val!),
                  activeColor: AppTheme.primaryOrange,
                ),
                Icon(icon, color: isSelected ? AppTheme.primaryOrange : AppTheme.textGrey),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textBlack,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: AppTheme.bodyStyle.copyWith(
                          color: AppTheme.textGrey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (child != null) child,
          ],
        ),
      ),
    );
  }

  bool _canSubmit() {
    if (_selectedOption == 'day_only') {
      return _dayOfBirth != null;
    } else {
      return _fullDateOfBirth != null;
    }
  }

  void _submit() {
    final result = {
      'inputType': _selectedOption,
      if (_selectedOption == 'day_only') 'dayOfBirth': _dayOfBirth,
      if (_selectedOption == 'full_date') 'fullDateOfBirth': _fullDateOfBirth,
    };
    Navigator.pop(context, result);
  }
}
