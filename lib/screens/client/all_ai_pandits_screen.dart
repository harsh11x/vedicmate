import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<AIPanditModel> _getFilteredPandits() {
    List<AIPanditModel> pandits = AIPandits.getAllPandits();

    if (_searchQuery.isNotEmpty) {
      pandits = AIPandits.search(_searchQuery);
    }

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
        break;
    }

    return pandits;
  }

  @override
  Widget build(BuildContext context) {
    final filteredPandits = _getFilteredPandits();

    return Scaffold(
      backgroundColor: AppTheme.forestBackground,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Elegant Sliver App Bar
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 120,
            backgroundColor: AppTheme.forestBackground,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: GestureDetector(
                onTap: () => context.pop(),
                child: CircleAvatar(
                  backgroundColor: AppTheme.white,
                  child: const Icon(Icons.arrow_back, color: AppTheme.neutralDark, size: 20),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                'Sacred Guides',
                style: AppTheme.lightTheme.textTheme.displaySmall?.copyWith( // Using display small for sliver title
                   fontSize: 24,
                   fontWeight: FontWeight.w700,
                   color: AppTheme.neutralDark,
                ),
              ),
              background: Container(color: AppTheme.forestBackground),
            ),
          ),

          // Search Bar & Filters
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   // Floating Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: AppTheme.lightTheme.textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'Search for guidance...',
                        prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.neutralMedium),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 20, color: AppTheme.neutralMedium),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                      onChanged: (value) => setState(() => _searchQuery = value),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Horizontal Filters
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    child: Row(
                      children: [
                        _FilterChip(label: 'All', isSelected: _selectedFilter == 'All', onTap: () => setState(() => _selectedFilter = 'All')),
                        const SizedBox(width: 12),
                        _FilterChip(label: 'Top Rated', isSelected: _selectedFilter == 'Top Rated', onTap: () => setState(() => _selectedFilter = 'Top Rated')),
                        const SizedBox(width: 12),
                        _FilterChip(label: 'Most Experienced', isSelected: _selectedFilter == 'Most Experienced', onTap: () => setState(() => _selectedFilter = 'Most Experienced')),
                        const SizedBox(width: 12),
                        _FilterChip(label: 'Male', isSelected: _selectedFilter == 'Male', onTap: () => setState(() => _selectedFilter = 'Male')),
                        const SizedBox(width: 12),
                        _FilterChip(label: 'Female', isSelected: _selectedFilter == 'Female', onTap: () => setState(() => _selectedFilter = 'Female')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Results Grid
          filteredPandits.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_search_rounded, size: 64, color: AppTheme.neutralMedium.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text('No guides found', style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(color: AppTheme.neutralMedium)),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final pandit = filteredPandits[index];
                        return _AIPanditGridCard(
                          pandit: pandit,
                          onTap: () => context.push('/ai-pandit/profile/${pandit.id}'),
                        );
                      },
                      childCount: filteredPandits.length,
                    ),
                  ),
                ),
          
          // Bottom Spacer
          const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.neutralDark : AppTheme.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? AppTheme.neutralDark : Colors.transparent,
            width: 1.5
          ),
          boxShadow: isSelected ? [] : AppTheme.softShadow,
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: isSelected ? AppTheme.white : AppTheme.neutralGrey,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _AIPanditGridCard extends StatelessWidget {
  final AIPanditModel pandit;
  final VoidCallback onTap;

  const _AIPanditGridCard({required this.pandit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppTheme.softShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Expanded(
              flex: 4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  pandit.profileImage.startsWith('assets')
                      ? Image.asset(
                          pandit.profileImage,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(color: AppTheme.forestBackground, child: const Icon(Icons.person, color: AppTheme.neutralMedium)),
                        )
                      : Image.network(
                          pandit.profileImage,
                          fit: BoxFit.cover,
                           errorBuilder: (c, e, s) => Container(color: AppTheme.forestBackground, child: const Icon(Icons.person, color: AppTheme.neutralMedium)),
                        ),
                  
                  // Gradient Overlay
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.4),
                          ],
                          stops: const [0.7, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Top Badges
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, color: AppTheme.accentGold, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            pandit.rating.toString(),
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.neutralDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Info Section
            Expanded(
              flex: 3,
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.neutralDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pandit.specializations.first,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: AppTheme.forestDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${pandit.experienceYears}+ Yrs',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.neutralMedium,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppTheme.forestBackground,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: AppTheme.neutralDark,
                          ),
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

