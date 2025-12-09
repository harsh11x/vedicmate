import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/ai_pandit_model.dart';

class AllAIPanditsScreen extends StatefulWidget {
  const AllAIPanditsScreen({super.key});

  @override
  State<AllAIPanditsScreen> createState() => _AllAIPanditsScreenState();
}

class _AllAIPanditsScreenState extends State<AllAIPanditsScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AIPanditModel> _getFilteredPandits() {
    List<AIPanditModel> pandits = AIPandits.getAllPandits();

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      pandits = AIPandits.search(_searchQuery);
    }

    // Apply gender/specialization filter
    switch (_selectedFilter) {
      case 'Male':
        pandits = pandits.where((p) => p.gender == 'male').toList();
        break;
      case 'Female':
        pandits = pandits.where((p) => p.gender == 'female').toList();
        break;
      case 'Top Rated':
        pandits = List<AIPanditModel>.from(pandits)
          ..sort((a, b) => b.rating.compareTo(a.rating));
        pandits = pandits.take(5).toList();
        break;
      case 'Most Experienced':
        pandits = List<AIPanditModel>.from(pandits)
          ..sort((a, b) => b.experienceYears.compareTo(a.experienceYears));
        break;
      default:
        // All - no additional filter
        break;
    }

    return pandits;
  }

  @override
  Widget build(BuildContext context) {
    final filteredPandits = _getFilteredPandits();

    return Scaffold(
      backgroundColor: AppTheme.neutralSoft,
      appBar: AppBar(
        title: const Text('AI Pandits'),
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: AppTheme.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or specialization...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.neutralMedium),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppTheme.neutralMedium),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.neutralSoft,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Filter Chips
          Container(
            color: AppTheme.white,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    isSelected: _selectedFilter == 'All',
                    onTap: () => setState(() => _selectedFilter = 'All'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Top Rated',
                    isSelected: _selectedFilter == 'Top Rated',
                    onTap: () => setState(() => _selectedFilter = 'Top Rated'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Male',
                    isSelected: _selectedFilter == 'Male',
                    onTap: () => setState(() => _selectedFilter = 'Male'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Female',
                    isSelected: _selectedFilter == 'Female',
                    onTap: () => setState(() => _selectedFilter = 'Female'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Most Experienced',
                    isSelected: _selectedFilter == 'Most Experienced',
                    onTap: () => setState(() => _selectedFilter = 'Most Experienced'),
                  ),
                ],
              ),
            ),
          ),

          // Results Count
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  '${filteredPandits.length} AI Pandits Available',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.neutralDark,
                      ),
                ),
              ],
            ),
          ),

          // Pandits Grid
          Expanded(
            child: filteredPandits.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppTheme.neutralMedium,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No AI Pandits found',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppTheme.neutralMedium,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.neutralMedium,
                              ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filteredPandits.length,
                    itemBuilder: (context, index) {
                      final pandit = filteredPandits[index];
                      return _AIPanditGridCard(
                        pandit: pandit,
                        onTap: () => context.push('/ai-pandit/chat?panditId=${pandit.id}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [AppTheme.yellowPrimary, AppTheme.goldAccent],
                )
              : null,
          color: isSelected ? null : AppTheme.neutralSoft,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: AppTheme.yellowPrimary, width: 1.5)
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.textDark : AppTheme.neutralDark,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _AIPanditGridCard extends StatelessWidget {
  final AIPanditModel pandit;
  final VoidCallback onTap;

  const _AIPanditGridCard({
    required this.pandit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.pink,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];
    final bgColor = colors[pandit.id.hashCode % colors.length];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.yellowPrimary.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.yellowPrimary.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with badges
            Stack(
              children: [
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.yellowPrimary.withOpacity(0.2),
                        bgColor.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Center(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: Image.network(
                        pandit.profileImage,
                        width: double.infinity,
                        height: 140,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.person,
                          size: 50,
                          color: bgColor.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.yellowPrimary, AppTheme.goldAccent],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: AppTheme.goldGlowShadow,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome, size: 10, color: AppTheme.textDark),
                        const SizedBox(width: 4),
                        const Text(
                          'AI',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: AppTheme.accentGold, size: 10),
                        const SizedBox(width: 2),
                        Text(
                          '${pandit.rating}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (pandit.isAvailable)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.successGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Online',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pandit.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pandit.specializations.first,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.neutralMedium,
                                fontSize: 10,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.yellowPrimary, AppTheme.goldAccent],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${pandit.experienceYears}+ Yrs',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ),
                        Icon(
                          pandit.gender == 'male' ? Icons.male : Icons.female,
                          size: 16,
                          color: pandit.gender == 'male' ? Colors.blue : Colors.pink,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

