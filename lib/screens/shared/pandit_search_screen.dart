import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/pandit_model.dart';
import '../../widgets/pandit_card.dart';

class PanditSearchScreen extends StatefulWidget {
  const PanditSearchScreen({super.key});

  @override
  State<PanditSearchScreen> createState() => _PanditSearchScreenState();
}

class _PanditSearchScreenState extends State<PanditSearchScreen> {
  final _searchController = TextEditingController();
  String _selectedSpecialization = 'All';
  String _selectedLanguage = 'All';
  String _sortBy = 'Rating';

  final List<String> _specializations = [
    'All',
    'Horoscope',
    'Marriage',
    'Career',
    'Health',
    'Vastu',
    'Palmistry',
  ];

  final List<String> _languages = [
    'All',
    'Hindi',
    'English',
    'Sanskrit',
    'Tamil',
    'Telugu',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Pandits'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, specialization...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _showFilterDialog,
                ),
              ),
            ),
          ),
          // Filters
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppTheme.creamPrimary,
            child: Row(
              children: [
                Expanded(
                  child: _FilterChip(
                    label: _selectedSpecialization,
                    onTap: () => _showSpecializationDialog(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _FilterChip(
                    label: _selectedLanguage,
                    onTap: () => _showLanguageDialog(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _FilterChip(
                    label: 'Sort: $_sortBy',
                    onTap: () => _showSortDialog(),
                  ),
                ),
              ],
            ),
          ),
          // Results
          Expanded(
            child: _buildResultsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    // Mock data
    final pandits = [
      PanditModel(
        id: '1',
        name: 'Pandit Ravi Shankar',
        specializations: ['Horoscope', 'Marriage'],
        experienceYears: 15,
        rating: 4.8,
        totalReviews: 234,
        languages: ['Hindi', 'English'],
        servicePricing: {'consultation': 500.0},
        isVerified: true,
      ),
      PanditModel(
        id: '2',
        name: 'Pandit Priya Sharma',
        specializations: ['Career', 'Health'],
        experienceYears: 10,
        rating: 4.9,
        totalReviews: 189,
        languages: ['Hindi', 'English', 'Sanskrit'],
        servicePricing: {'consultation': 600.0},
        isVerified: true,
      ),
      PanditModel(
        id: '3',
        name: 'Pandit Krishna Das',
        specializations: ['Vastu', 'Palmistry'],
        experienceYears: 20,
        rating: 4.7,
        totalReviews: 312,
        languages: ['Hindi', 'Sanskrit'],
        servicePricing: {'consultation': 700.0},
        isVerified: true,
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pandits.length,
      itemBuilder: (context, index) {
        return PanditCard(
          pandit: pandits[index],
          onTap: () => context.push('/pandit/profile/${pandits[index].id}'),
        );
      },
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _FilterBottomSheet(
        onApply: (specialization, language, sortBy) {
          setState(() {
            _selectedSpecialization = specialization;
            _selectedLanguage = language;
            _sortBy = sortBy;
          });
        },
      ),
    );
  }

  void _showSpecializationDialog() {
    showDialog(
      context: context,
      builder: (context) => _SelectionDialog(
        title: 'Select Specialization',
        options: _specializations,
        selected: _selectedSpecialization,
        onSelect: (value) {
          setState(() => _selectedSpecialization = value);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => _SelectionDialog(
        title: 'Select Language',
        options: _languages,
        selected: _selectedLanguage,
        onSelect: (value) {
          setState(() => _selectedLanguage = value);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => _SelectionDialog(
        title: 'Sort By',
        options: ['Rating', 'Price: Low to High', 'Price: High to Low', 'Experience'],
        selected: _sortBy,
        onSelect: (value) {
          setState(() => _sortBy = value);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.saffronPrimary),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 16),
          ],
        ),
      ),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final Function(String, String, String) onApply;

  const _FilterBottomSheet({required this.onApply});

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  String _specialization = 'All';
  String _language = 'All';
  String _sortBy = 'Rating';
  RangeValues _priceRange = const RangeValues(0, 2000);
  RangeValues _ratingRange = const RangeValues(0, 5);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filters',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          Text('Price Range: ₹${_priceRange.start.toInt()} - ₹${_priceRange.end.toInt()}'),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 2000,
            divisions: 20,
            onChanged: (values) => setState(() => _priceRange = values),
          ),
          Text('Rating: ${_ratingRange.start.toStringAsFixed(1)} - ${_ratingRange.end.toStringAsFixed(1)}'),
          RangeSlider(
            values: _ratingRange,
            min: 0,
            max: 5,
            divisions: 10,
            onChanged: (values) => setState(() => _ratingRange = values),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(_specialization, _language, _sortBy);
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SelectionDialog extends StatelessWidget {
  final String title;
  final List<String> options;
  final String selected;
  final Function(String) onSelect;

  const _SelectionDialog({
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: options.map((option) {
          return RadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: selected,
            onChanged: (value) {
              if (value != null) {
                onSelect(value);
              }
            },
          );
        }).toList(),
      ),
    );
  }
}

