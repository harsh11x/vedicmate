import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/pandit_model.dart';
import '../../providers/api_providers.dart';
import '../../widgets/pandit_card.dart';

class PanditSearchScreen extends ConsumerStatefulWidget {
  const PanditSearchScreen({super.key});

  @override
  ConsumerState<PanditSearchScreen> createState() => _PanditSearchScreenState();
}

class _PanditSearchScreenState extends ConsumerState<PanditSearchScreen> {
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
    final panditFuture = ref.watch(_panditListProvider(_searchController.text));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Pandits'),
      ),
      body: Column(
        children: [
          // Enhanced Search Bar
          Padding(
            padding: EdgeInsets.all(
              (MediaQuery.of(context).size.width * 0.04).clamp(12.0, 20.0),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: AppTheme.mediumShadow,
                border: Border.all(
                  color: AppTheme.primaryOrange.withOpacity(0.15),
                  width: 1.5,
                ),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search by name, specialization...',
                  hintStyle: TextStyle(
                    color: AppTheme.neutralMedium,
                    fontSize: 15,
                  ),
                  prefixIcon: Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.search,
                      color: AppTheme.white,
                      size: 20,
                    ),
                  ),
                  suffixIcon: Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.filter_list, color: AppTheme.primaryOrange, size: 20),
                      onPressed: _showFilterDialog,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
            child: panditFuture.when(
              data: (list) {
                // client-side filter/sort
                List<PanditModel> filtered = List.from(list);
                if (_selectedSpecialization != 'All') {
                  filtered = filtered
                      .where((p) => p.specializations
                          .any((s) => s.toLowerCase() == _selectedNameCase(_selectedSpecialization)))
                      .toList();
                }
                if (_selectedLanguage != 'All') {
                  filtered = filtered
                      .where((p) => p.languages
                          .any((l) => l.toLowerCase() == _selectedNameCase(_selectedLanguage)))
                      .toList();
                }
                if (_searchController.text.isNotEmpty) {
                  final q = _searchController.text.toLowerCase();
                  filtered = filtered.where((p) =>
                    p.name.toLowerCase().contains(q) ||
                    p.specializations.any((s) => s.toLowerCase().contains(q))
                  ).toList();
                }
                switch (_sortBy) {
                  case 'Price: Low to High':
                    filtered.sort((a,b)=> a.servicePricing.values.first.compareTo(b.servicePricing.values.first));
                    break;
                  case 'Price: High to Low':
                    filtered.sort((a,b)=> b.servicePricing.values.first.compareTo(a.servicePricing.values.first));
                    break;
                  case 'Rating':
                    filtered.sort((a,b)=> b.rating.compareTo(a.rating));
                    break;
                  case 'Experience':
                    filtered.sort((a,b)=> b.experienceYears.compareTo(a.experienceYears));
                    break;
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'No pandits found',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final p = filtered[index];
                    return PanditCard(
                      pandit: p,
                      onTap: () => context.push('/pandit/profile/${p.id}'),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('Failed to load pandits: $e'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _selectedNameCase(String v) => v.toLowerCase();

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
          setState(() => _selectedNameCase(value));
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

final _panditListProvider = FutureProvider.family<List<PanditModel>, String>((ref, query) async {
  final service = ref.read(panditServiceProvider);
  return service.fetchPandits(query: query);
});

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
          border: Border.all(color: AppTheme.yellowPrimary),
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
              const SizedBox(height: 12),
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

