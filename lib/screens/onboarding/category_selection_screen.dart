import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../services/user_preferences_service.dart';

class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({super.key});

  @override
  State<CategorySelectionScreen> createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> with TickerProviderStateMixin {
  String? _selectedCategory;
  final _prefsService = UserPreferencesService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<CategoryData> _categories = [
    CategoryData(
      name: 'Lal Kitab',
      description: 'Traditional Lal Kitab astrology with simple and effective remedies',
      icon: Icons.auto_stories,
      gradient: const LinearGradient(
        colors: [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
      ),
    ),
    CategoryData(
      name: 'Palm Reading',
      description: 'Palmistry and hand analysis to reveal your destiny',
      icon: Icons.back_hand,
      gradient: const LinearGradient(
        colors: [Color(0xFFFD79A8), Color(0xFFFF7979)],
      ),
    ),
    CategoryData(
      name: 'Vedic Astrology',
      description: 'Classical Vedic astrology for life predictions and guidance',
      icon: Icons.stars,
      gradient: const LinearGradient(
        colors: [AppTheme.yellowPrimary, AppTheme.goldAccent],
      ),
    ),
    CategoryData(
      name: 'Vastu Shastra',
      description: 'Architectural harmony and spatial energy balance',
      icon: Icons.home_work,
      gradient: const LinearGradient(
        colors: [Color(0xFF00B894), Color(0xFF55EFC4)],
      ),
    ),
    CategoryData(
      name: 'Numerology',
      description: 'Number-based predictions and life path analysis',
      icon: Icons.calculate,
      gradient: const LinearGradient(
        colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
      ),
    ),
  ];

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleContinue() async {
    if (_selectedCategory != null) {
      await _prefsService.saveSelectedCategory(_selectedCategory!);
      if (mounted) {
        context.push('/birth-details?category=$_selectedCategory');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: const Text(
          'Choose Your Path',
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
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.yellowPrimary, AppTheme.goldAccent],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: AppTheme.goldGlowShadow,
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            size: 40,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Select Your AI Astrology Category',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Choose the spiritual path that resonates with you',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.neutralMedium,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Category Cards
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = _selectedCategory == category.name;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _CategoryCard(
                            category: category,
                            isSelected: isSelected,
                            onTap: () {
                              setState(() {
                                _selectedCategory = category.name;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  // Continue Button
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: _selectedCategory != null
                            ? const LinearGradient(
                                colors: [AppTheme.yellowPrimary, AppTheme.goldAccent],
                              )
                            : null,
                        color: _selectedCategory == null ? AppTheme.forestBackground : null,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: _selectedCategory != null
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
                        onPressed: _selectedCategory != null ? _handleContinue : null,
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
                                color: _selectedCategory != null ? AppTheme.textDark : AppTheme.neutralMedium,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward,
                              color: _selectedCategory != null ? AppTheme.textDark : AppTheme.neutralMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CategoryData {
  final String name;
  final String description;
  final IconData icon;
  final Gradient gradient;

  CategoryData({
    required this.name,
    required this.description,
    required this.icon,
    required this.gradient,
  });
}

class _CategoryCard extends StatelessWidget {
  final CategoryData category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isSelected ? category.gradient : null,
          color: isSelected ? null : AppTheme.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppTheme.forestBackground,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? category.gradient.colors.first.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 20 : 10,
              offset: Offset(0, isSelected ? 8 : 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.2) : category.gradient.colors.first.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                category.icon,
                size: 32,
                color: isSelected ? AppTheme.white : category.gradient.colors.first,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppTheme.white : AppTheme.textDark,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isSelected ? AppTheme.white.withOpacity(0.9) : AppTheme.neutralMedium,
                          height: 1.4,
                        ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: AppTheme.white,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
