import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../models/ai_pandit_model.dart';
import '../../providers/api_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'reels_screen.dart';
import '../../providers/auth_provider.dart'; // Correctly placed import
import 'remedies_screen.dart';
import 'ai_pandit_chat_list_screen.dart';
import '../shared/settings_screen.dart';

class ClientDashboard extends ConsumerStatefulWidget {
  const ClientDashboard({super.key});

  @override
  ConsumerState<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends ConsumerState<ClientDashboard> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToTab(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDarkBackground = _currentIndex == 2 || isDark;
    final statusBarStyle = isDarkBackground
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: statusBarStyle.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            isDarkBackground ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        extendBody: true,
        body: Stack(
          children: [
            // Parchment editorial background inspired by the reference.
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [
                            const Color(0xFF0D0C0A),
                            const Color(0xFF17130F),
                            const Color(0xFF211B16),
                          ]
                        : [
                            const Color(0xFFF7F1E8),
                            const Color(0xFFF0E6D8),
                          ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _ScribblePainter(isDark: isDark)),
              ),
            ),

            PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) => setState(() => _currentIndex = index),
              children: [
                _HomeTab(
                  searchController: _searchController,
                  onNavigateToTab: _navigateToTab,
                ),
                _ChatTab(),
                ReelsScreen(
                  onBack: () => _navigateToTab(0),
                  isReelsTabActive: _currentIndex == 2,
                ),
                const RemediesScreen(),
                _ProfileTab(),
              ],
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(36),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.darkSurfaceRaised.withOpacity(0.84)
                          : AppTheme.elevatedSurface.withOpacity(0.76),
                      borderRadius: BorderRadius.circular(34),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.10)
                            : AppTheme.divineInk.withOpacity(0.10),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.36 : 0.12),
                          blurRadius: 34,
                          offset: const Offset(0, 18),
                          spreadRadius: -10,
                        ),
                        if (!isDark)
                          BoxShadow(
                            color: Colors.white.withOpacity(0.8),
                            blurRadius: 1,
                            offset: const Offset(0, 1),
                          ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNavItem(Icons.home_rounded, 'Home', 0),
                        _buildNavItem(Icons.chat_bubble_rounded, 'Chat', 1),
                        _buildNavItem(Icons.video_library_rounded, 'Reels', 2),
                        _buildNavItem(
                            Icons.shopping_bag_rounded, 'Remedies', 3),
                        _buildNavItem(Icons.person_rounded, 'Profile', 4),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => _navigateToTab(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 14 : 10, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppTheme.divineGoldLight : AppTheme.divineInk)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark
                    ? Colors.white.withOpacity(0.08)
                    : AppTheme.divineInk.withOpacity(0.06)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? (isDark ? AppTheme.divineInk : AppTheme.divineSurface)
                  : (isDark
                      ? AppTheme.darkTextSecondary
                      : AppTheme.neutralMedium),
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isDark ? AppTheme.divineInk : AppTheme.divineSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends ConsumerStatefulWidget {
  final TextEditingController searchController;
  final Function(int) onNavigateToTab;

  const _HomeTab({
    required this.searchController,
    required this.onNavigateToTab,
  });

  @override
  ConsumerState<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<_HomeTab> {
  String _searchQuery = '';
  List<String> _selectedLanguages = [];
  List<String> _selectedCategories = [];
  String _rateSort = ''; // 'low_high', 'high_low'

  List<AIPanditModel> get _filteredPandits {
    var pandits = AIPandits.allPandits;

    // Search
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      pandits = pandits
          .where((p) =>
              p.name.toLowerCase().contains(query) ||
              p.specializations.any((s) => s.toLowerCase().contains(query)))
          .toList();
    }

    // Language
    if (_selectedLanguages.isNotEmpty) {
      pandits = pandits
          .where((p) => p.languages.any((l) => _selectedLanguages.contains(l)))
          .toList();
    }

    // Category
    if (_selectedCategories.isNotEmpty) {
      pandits = pandits
          .where((p) =>
              _selectedCategories.contains(p.publicCategory) ||
              p.publicSpecializations
                  .any((s) => _selectedCategories.contains(s)))
          .toList();
    }

    // Rate Sort
    if (_rateSort == 'low_high') {
      pandits.sort((a, b) => a.ratePerMinute.compareTo(b.ratePerMinute));
    } else if (_rateSort == 'high_low') {
      pandits.sort((a, b) => b.ratePerMinute.compareTo(a.ratePerMinute));
    }

    return pandits;
  }

  // Filtered lists for sections

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Filters',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: ListView(
                    children: [
                      _buildFilterSection('Sort by Rate', [
                        FilterChip(
                          label: const Text('Low to High'),
                          selected: _rateSort == 'low_high',
                          onSelected: (b) => setModalState(() =>
                              setState(() => _rateSort = b ? 'low_high' : '')),
                        ),
                        FilterChip(
                          label: const Text('High to Low'),
                          selected: _rateSort == 'high_low',
                          onSelected: (b) => setModalState(() =>
                              setState(() => _rateSort = b ? 'high_low' : '')),
                        ),
                      ]),
                      const SizedBox(height: 16),
                      _buildFilterSection('Languages', [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: FilterChip(
                                label: const Text('Check All'),
                                selected: _selectedLanguages.length ==
                                    AIPandits.allLanguages.length,
                                onSelected: (b) =>
                                    setModalState(() => setState(() {
                                          if (b) {
                                            _selectedLanguages = List.from(
                                                AIPandits.allLanguages);
                                          } else {
                                            _selectedLanguages.clear();
                                          }
                                        })),
                              ),
                            ),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: AIPandits.allLanguages
                                  .map((l) => FilterChip(
                                        label: Text(l),
                                        selected:
                                            _selectedLanguages.contains(l),
                                        onSelected: (b) =>
                                            setModalState(() => setState(() {
                                                  if (b) {
                                                    _selectedLanguages.add(l);
                                                  } else {
                                                    _selectedLanguages
                                                        .remove(l);
                                                  }
                                                })),
                                      ))
                                  .toList(),
                            ),
                          ],
                        )
                      ]),
                      const SizedBox(height: 16),
                      _buildFilterSection(
                          'Categories',
                          [
                            'Vedic Wellness',
                            'Life Planning',
                            'Home Harmony',
                            'Relationship Guidance',
                            'Remedy Guidance'
                          ]
                              .map((c) => FilterChip(
                                    label: Text(c),
                                    selected: _selectedCategories.contains(c),
                                    onSelected: (b) =>
                                        setModalState(() => setState(() {
                                              if (b)
                                                _selectedCategories.add(c);
                                              else
                                                _selectedCategories.remove(c);
                                            })),
                                  ))
                              .toList()),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: children),
      ],
    );
  }

  void _showComingSoon(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.divineInk,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch auth state for reactive updates
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull;
    final userName =
        user?.displayName ?? (user?.email?.split('@').first ?? 'User');

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _EditorialHomeHeader(
                userName: userName.split(' ').first,
                onWalletTap: () => context.push('/payment/wallet'),
                onProfileTap: () => context.push('/settings'),
              )
                  .animate()
                  .fadeIn(duration: 520.ms, curve: Curves.easeOutCubic)
                  .slideY(begin: -0.035, end: 0),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _ReferenceHeroCard(
                  onTap: () => context.push('/live-pooja'),
                )
                    .animate()
                    .fadeIn(
                        delay: 120.ms,
                        duration: 520.ms,
                        curve: Curves.easeOutCubic)
                    .slideY(begin: 0.025, end: 0),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.82,
                ),
                delegate: SliverChildListDelegate.fixed([
                  _ReferenceServiceTile(
                    title: 'Daily\nPractice',
                    imagePath: 'assets/images/home_cards/temple_bg.png',
                    onTap: () => context.push('/lifestyle/habits'),
                  ),
                  _ReferenceServiceTile(
                    title: 'Scripture\nLibrary',
                    imagePath: 'assets/images/home_cards/vedic_books.png',
                    onTap: () => context.push('/education/library'),
                  ),
                  _ReferenceServiceTile(
                    title: 'Yoga\nWellness',
                    imagePath: 'assets/images/home_cards/vastu.png',
                    onTap: () => context.push('/education/yoga-poses'),
                  ),
                  _ReferenceServiceTile(
                    title: 'Reflection\nJournal',
                    imagePath: 'assets/images/home_cards/kundli.png',
                    onTap: () => context.push('/lifestyle/journal'),
                  ),
                  _ReferenceServiceTile(
                    title: 'Relationship\nGuide',
                    imagePath: 'assets/images/home_cards/zodiac_match.png',
                    onTap: () => context.push('/relationship/form'),
                  ),
                  _ReferenceServiceTile(
                    title: 'Remedy\nShop',
                    imagePath: 'assets/images/home_cards/lal_kitab.png',
                    onTap: () => context.push('/remedies'),
                  ),
                  _ReferenceServiceTile(
                    title: 'Culture\nTimeline',
                    imagePath: 'assets/images/home_cards/numerology.png',
                    onTap: () => context.push('/history/timeline'),
                  ),
                  _ReferenceServiceTile(
                    title: 'Live\nGuides',
                    imagePath: 'assets/images/home_cards/vedic_astrology.png',
                    onTap: () => context.push('/ai-pandits/all'),
                  ),
                  _ReferenceServiceTile(
                    title: 'More\nTools',
                    imagePath: 'assets/images/home_cards/more_services.png',
                    onTap: () => context.push('/ai-pandits/all'),
                  ),
                ]),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _ReferenceConsultStrip(
                  onTap: () => context.push('/ai-pandits/all'),
                )
                    .animate()
                    .fadeIn(
                        delay: 300.ms,
                        duration: 520.ms,
                        curve: Curves.easeOutCubic)
                    .slideY(begin: 0.025, end: 0),
              ),
            ),

            // Bottom Spacing for Nav Bar
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionBtn(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 100,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.45),
              borderRadius: BorderRadius.circular(24),
              border:
                  Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: AppTheme.divineGold, size: 26),
                const SizedBox(height: 10),
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textBlack,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}

class _HomeSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _HomeSectionHeader({
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 4,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppTheme.divineGold, AppTheme.sacredCopper],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.divineInk,
                  letterSpacing: -0.35,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: AppTheme.textGrey,
                    height: 1.25,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _EditorialHomeHeader extends StatelessWidget {
  final String userName;
  final VoidCallback onWalletTap;
  final VoidCallback onProfileTap;

  const _EditorialHomeHeader({
    required this.userName,
    required this.onWalletTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: SizedBox(
        height: 316,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
                child: CustomPaint(painter: _EditorialLinePainter())),
            Positioned(
              right: -18,
              top: 44,
              child: Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFC99A4A).withOpacity(0.42),
                ),
              ),
            ),
            Positioned(
              right: -50,
              bottom: -10,
              top: -10,
              width: 320,
              child: Opacity(
                opacity: 0.95,
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return RadialGradient(
                      center: const Alignment(0.3, 0.0),
                      radius: 0.65,
                      colors: [Colors.white, Colors.white.withOpacity(0.0)],
                      stops: const [0.4, 1.0],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.dstIn,
                  child: Image.asset(
                    'assets/images/home_cards/temple_bg.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 10,
              child: Row(
                children: [
                  _HeaderIconButton(
                      icon: Icons.account_balance_wallet_outlined,
                      onTap: onWalletTap),
                  const SizedBox(width: 12),
                  _HeaderIconButton(
                      icon: Icons.person_outline_rounded, onTap: onProfileTap),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.58,
                  height: 52,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Welcome, $userName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        fontStyle: FontStyle.italic,
                        letterSpacing: -0.3,
                        color: const Color(0xFF1B1712),
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: 'Ancient ', style: _headlineStyle()),
                      TextSpan(
                          text: 'wisdom.\n',
                          style: _headlineStyle(italic: true)),
                      TextSpan(text: 'Modern ', style: _headlineStyle()),
                      TextSpan(
                          text: 'connections.',
                          style: _headlineStyle(italic: true)),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: 60,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC79A52),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Discover yourself.\nFind your perfect match.\nLive in harmony.',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: const Color(0xFF5F574D),
                    height: 1.62,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _headlineStyle({bool italic = false}) {
    return GoogleFonts.cormorantGaramond(
      fontSize: 36,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      fontWeight: italic ? FontWeight.w500 : FontWeight.w600,
      color: italic ? const Color(0xFFC79A52) : const Color(0xFF1B1712),
      height: 1.04,
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.32)),
        ),
        child: Icon(icon, size: 22, color: const Color(0xFF1E1914)),
      ),
    );
  }
}

class _ReferenceHeroCard extends StatelessWidget {
  final VoidCallback onTap;

  const _ReferenceHeroCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 224,
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(34),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(child: CustomPaint(painter: _ZodiacLinePainter())),
            Positioned(
              right: -40,
              top: -20,
              bottom: -20,
              width: 280,
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Colors.transparent, Colors.white],
                    stops: [0.0, 0.3],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: Image.asset(
                  'assets/images/home_cards/live_pooja.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              right: 28,
              top: 36,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white10),
                ),
                child: Center(
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1B1915),
                      border: Border.all(
                          color: const Color(0xFFC79A4D).withOpacity(0.42)),
                    ),
                    child: const Icon(Icons.temple_hindu_rounded,
                        color: Color(0xFFC79A4D), size: 20),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Live',
                      style: GoogleFonts.caveat(
                          fontSize: 28,
                          color: const Color(0xFFC79A52),
                          height: 0.94)),
                  const SizedBox(height: 10),
                  Text(
                    'POOJA',
                    style: GoogleFonts.outfit(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: 190,
                    child: Text(
                      'Join sacred rituals live\nwith Vedic blessings.',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        color: Colors.white70,
                        height: 1.55,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                          color: const Color(0xFFC79A52).withOpacity(0.86)),
                      color: Colors.white.withOpacity(0.04),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Join Live Pooja',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFC79A52),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.arrow_forward_rounded,
                            color: Color(0xFFC79A52), size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReferenceServiceTile extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;

  const _ReferenceServiceTile({
    required this.title,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8F0E4).withOpacity(0.70),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
              color: const Color(0xFFB8A88E).withOpacity(0.34), width: 0.8),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Opacity(
                opacity: 0.95,
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return RadialGradient(
                      center: Alignment.center,
                      radius: 0.55,
                      colors: [Colors.white, Colors.white.withOpacity(0.0)],
                      stops: const [0.5, 1.0],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.dstIn,
                  child: Image.asset(
                    imagePath,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Positioned.fill(child: CustomPaint(painter: _TileSketchPainter())),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.28,
                      color: const Color(0xFF1F1B16),
                      height: 1.08,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_rounded,
                      size: 14, color: Color(0xFF8A6A38)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReferenceConsultStrip extends StatelessWidget {
  final VoidCallback onTap;

  const _ReferenceConsultStrip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F0E4).withOpacity(0.66),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: const Color(0xFFB8A88E).withOpacity(0.42)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                  color: Color(0xFF181511), shape: BoxShape.circle),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Color(0xFFC79A4D), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'YOUR JOURNEY WRITTEN IN THE STARS.\n',
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        letterSpacing: 1.3,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF534A40),
                      ),
                    ),
                    TextSpan(
                      text: "Let's walk it together.",
                      style: GoogleFonts.caveat(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFB5833A)),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                  color: const Color(0xFFC79A4D),
                  borderRadius: BorderRadius.circular(99)),
              child: Row(
                children: [
                  Text(
                    'CONSULT NOW',
                    style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded,
                      color: Colors.white, size: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScribblePainter extends CustomPainter {
  final bool isDark;

  const _ScribblePainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withOpacity(0.10)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width * 0.1, 100)
      ..quadraticBezierTo(size.width * 0.4, 20, size.width * 0.9, 160)
      ..moveTo(size.width * 0.2, 500)
      ..quadraticBezierTo(size.width * 0.6, 400, size.width * 0.95, 650)
      ..moveTo(0, 900)
      ..quadraticBezierTo(size.width * 0.5, 760, size.width, 1000);

    canvas.drawPath(path, paint);

    final finePaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withOpacity(0.06)
      ..strokeWidth = 0.65
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < 7; i++) {
      final y = 190.0 + (i * 112);
      canvas.drawLine(
        Offset(size.width * 0.62, y),
        Offset(size.width * 0.98, y + 76),
        finePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ScribblePainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}

class _EditorialLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1F1B16).withOpacity(0.10)
      ..strokeWidth = 0.7
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < 9; i++) {
      final startX = size.width * (0.34 + i * 0.045);
      canvas.drawLine(
        Offset(startX, 0),
        Offset(size.width * (0.56 + i * 0.06), size.height * 0.74),
        paint,
      );
    }
    canvas.drawCircle(Offset(size.width * 0.62, size.height * 0.24), 62, paint);
    canvas.drawLine(Offset(size.width * 0.48, size.height * 0.06),
        Offset(size.width * 0.88, size.height * 0.04), paint);
    canvas.drawLine(Offset(size.width * 0.54, size.height * 0.36),
        Offset(size.width * 0.94, size.height * 0.28), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ZodiacLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.72, size.height * 0.52);
    final paint = Paint()
      ..color = const Color(0xFFC79A4D).withOpacity(0.22)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    for (final radius in [40.0, 62.0, 84.0]) {
      canvas.drawCircle(center, radius, paint);
    }
    for (var i = 0; i < 12; i++) {
      final angle = i * math.pi / 6;
      final p1 = center + Offset(math.cos(angle) * 40, math.sin(angle) * 40);
      final p2 = center + Offset(math.cos(angle) * 88, math.sin(angle) * 88);
      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TileSketchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1F1B16).withOpacity(0.055)
      ..strokeWidth = 0.55
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(size.width * 0.78, size.height * 0.25), 34, paint);
    canvas.drawLine(Offset(size.width * 0.45, 0),
        Offset(size.width, size.height * 0.58), paint);
    canvas.drawLine(Offset(size.width * 0.08, size.height),
        Offset(size.width * 0.88, size.height * 0.10), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ActionCardV2 extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final VoidCallback onTap;

  const _ActionCardV2({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 168,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.92),
              AppTheme.sandalwood.withOpacity(0.42),
            ],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.86), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: AppTheme.divineInk.withOpacity(0.12),
              blurRadius: 22,
              offset: const Offset(0, 14),
              spreadRadius: -12,
            ),
            BoxShadow(
              color: AppTheme.divineGold.withOpacity(0.14),
              blurRadius: 24,
              offset: const Offset(0, 8),
              spreadRadius: -14,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.sandalwood.withOpacity(0.8),
                          AppTheme.divineGold.withOpacity(0.22),
                        ],
                      ),
                    ),
                    child: const Icon(Icons.auto_awesome,
                        size: 40, color: AppTheme.divineGold),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.divineInk.withOpacity(0.08),
                        AppTheme.sacredCopper.withOpacity(0.12),
                        Colors.black.withOpacity(0.62),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.74),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: Colors.white.withOpacity(0.7)),
                    ),
                    child: Icon(Icons.auto_awesome_rounded,
                        size: 14, color: AppTheme.sacredCopper),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.35,
                          height: 1.05,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.32),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(99),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.24)),
                        ),
                        child: Text(
                          subtitle,
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withOpacity(0.94),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// AI Service Card - Prominent card for AI services
class _AIServiceCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Gradient gradient;
  final VoidCallback onTap;

  const _AIServiceCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: (gradient.colors.firstOrNull ?? Colors.black)
                  .withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
              spreadRadius: -2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: AppTheme.titleStyle.copyWith(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTheme.bodyStyle.copyWith(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Celestial Glassmorphic AI Pandit Card
class _AIPanditCard extends StatelessWidget {
  final AIPanditModel pandit;
  final VoidCallback onTap;

  const _AIPanditCard({
    required this.pandit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: AppTheme.glassMorphism.copyWith(
          boxShadow: AppTheme.softShadow,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.9),
              Colors.white.withOpacity(0.7),
            ],
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Background Image
              ShaderMask(
                shaderCallback: (rect) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black, Colors.black.withOpacity(0.0)],
                    stops: const [0.7, 1.0],
                  ).createShader(rect);
                },
                blendMode: BlendMode.dstIn,
                child: pandit.profileImage.startsWith('http')
                    ? Image.network(
                        pandit.profileImage,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      )
                    : Image.asset(
                        pandit.profileImage,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      ),
              ),

              // 2. Gradient Overlay for Text Readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.4),
                      Colors.black.withOpacity(0.9),
                    ],
                    stops: const [0.5, 0.8, 1.0],
                  ),
                ),
              ),

              // 3. Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: AI Badge & Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: AppTheme.glowShadow,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.auto_awesome,
                                  size: 12, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                'AI',
                                style: GoogleFonts.outfit(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star_rounded,
                                  color: AppTheme.accentGold, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '${pandit.rating}',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),

                    // Name
                    Text(
                      pandit.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Specialization
                    Text(
                      pandit.specializations.firstOrNull ?? 'Astrologer',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Active Status / Years Exp
                    Row(
                      children: [
                        if (pandit.isAvailable) ...[
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.successGreen,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.successGreen,
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Online',
                            style: GoogleFonts.outfit(
                              color: AppTheme.successGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Text(
                          '${pandit.experienceYears}+ Yrs',
                          style: GoogleFonts.outfit(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppTheme.neutralSoft,
      child: Center(
        child: Icon(
          Icons.person,
          size: 50,
          color: AppTheme.neutralMedium.withOpacity(0.5),
        ),
      ),
    );
  }
}

class _ChatTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatService = ref.watch(chatServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        backgroundColor: AppTheme.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: chatService.getUserChatRooms(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final chatRooms = snapshot.data ?? [];

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start a conversation',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textBlack,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Chat with our AI-powered expert pandits',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: AppTheme.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final pandit = AIPandits.allPandits[index];
                      return PanditListTile(
                        pandit: pandit,
                        onProfileTap: () =>
                            context.push('/ai-pandit/profile/${pandit.id}'),
                        onChatTap: () => context
                            .push('/ai-pandit/chat?panditId=${pandit.id}'),
                        onCallTap: () => context.push(
                            '/ai-pandit/voice-call?panditId=${pandit.id}'),
                      );
                    },
                    childCount: AIPandits.allPandits.length,
                  ),
                ),
              ),
              if (chatRooms.isNotEmpty) ...[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Your Chats',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textBlack,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final chatRoom = chatRooms[index];
                        final participants = chatRoom['participantNames']
                                as Map<String, dynamic>? ??
                            {};
                        final currentUserId =
                            FirebaseAuth.instance.currentUser?.uid ?? '';
                        final otherParticipantName = participants.entries
                                .firstWhere(
                                  (e) => e.key != currentUserId,
                                  orElse: () => MapEntry('', 'Pandit'),
                                )
                                .value as String? ??
                            'Pandit';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  AppTheme.primaryOrange.withOpacity(0.2),
                              child: Icon(Icons.person,
                                  color: AppTheme.primaryOrange),
                            ),
                            title: Text(
                              otherParticipantName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              chatRoom['lastMessage'] ?? 'No messages yet',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Icon(Icons.chevron_right),
                            onTap: () =>
                                context.push('/chat/${chatRoom['id']}'),
                          ),
                        );
                      },
                      childCount: chatRooms.length,
                    ),
                  ),
                ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SettingsScreen();
  }
}

class _OldProfileTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.neutralSoft,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320, // Increased height to prevent overlap
            pinned: true,
            backgroundColor: AppTheme.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Gradient Background
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryOrange,
                          AppTheme.forestDark,
                        ],
                      ),
                    ),
                  ),
                  // Decorative Circles
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -30,
                    left: -30,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Profile Content
                  SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: AppTheme.white,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: AppTheme.white, width: 4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 50,
                                color: AppTheme.primaryOrange,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppTheme.yellowPrimary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: AppTheme.white, width: 2),
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  size: 14,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Builder(
                          builder: (context) {
                            final user = FirebaseAuth.instance.currentUser;
                            final userName = user?.displayName ??
                                (user?.email?.split('@').first ?? 'User');
                            return Text(
                              userName,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: AppTheme.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '+91 98765 43210',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppTheme.white.withOpacity(0.9),
                                ),
                          ),
                        ),
                        const SizedBox(height: 40), // Added spacing at bottom
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Dashboard Stats Card
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -30),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(context, 'Bookings', '12',
                          Icons.calendar_today, AppTheme.primaryOrange),
                      Container(
                          width: 1,
                          height: 40,
                          color: AppTheme.forestBackground),
                      _buildStatItem(context, 'Minutes', '450', Icons.timer,
                          AppTheme.infoBlue),
                      Container(
                          width: 1,
                          height: 40,
                          color: AppTheme.forestBackground),
                      _buildStatItem(
                          context,
                          'Streak',
                          '7 days',
                          Icons.local_fire_department_outlined,
                          AppTheme.successGreen),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Menu Items
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.neutralDark,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: Column(
                      children: [
                        _ProfileMenuItem(
                          icon: Icons.person_outline,
                          title: 'Edit Profile',
                          subtitle: 'Update your personal information',
                          onTap: () => context.push('/profile/edit'),
                          isFirst: true,
                        ),
                        _ProfileMenuItem(
                          icon: Icons.history,
                          title: 'Booking History',
                          subtitle: 'View your past consultations',
                          onTap: () => context.push('/bookings/history'),
                          isLast: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Preferences',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.neutralDark,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: Column(
                      children: [
                        _ProfileMenuItem(
                          icon: Icons.language,
                          title: 'Language',
                          subtitle: 'English (US)',
                          onTap: () {},
                          isFirst: true,
                        ),
                        _ProfileMenuItem(
                          icon: Icons.notifications_outlined,
                          title: 'Notifications',
                          subtitle: 'Manage your alerts',
                          onTap: () {},
                        ),
                        _ProfileMenuItem(
                          icon: Icons.settings_outlined,
                          title: 'Settings',
                          subtitle: 'App preferences and privacy',
                          onTap: () => context.push('/settings'),
                          isLast: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Support',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.neutralDark,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: Column(
                      children: [
                        _ProfileMenuItem(
                          icon: Icons.help_outline,
                          title: 'Help & Support',
                          subtitle: 'Get assistance with your issues',
                          onTap: () {},
                          isFirst: true,
                        ),
                        _ProfileMenuItem(
                          icon: Icons.info_outline,
                          title: 'About Us',
                          subtitle: 'Learn more about Vedic Mate',
                          onTap: () {},
                          isLast: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Logout Button
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 100),
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle logout
                        context.go('/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorRed.withOpacity(0.1),
                        foregroundColor: AppTheme.errorRed,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Log Out',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value,
      IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.neutralMedium,
              ),
        ),
      ],
    );
  }
}

class _CustomBookingBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _CustomBookingBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF1E293B),
              Color(0xFF0F172A)
            ], // Cosmic Void gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppTheme.mediumShadow,
          border:
              Border.all(color: AppTheme.accentGold.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppTheme.accentGold.withOpacity(0.5)),
                    ),
                    child: Text(
                      'CUSTOM REQUEST',
                      style: GoogleFonts.outfit(
                        color: AppTheme.accentGold,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Personalize Your Spiritual Journey',
                    style: GoogleFonts.outfit(
                      color: AppTheme.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Book custom poojas, havans, or personal consultations.',
                    style: GoogleFonts.outfit(
                      color: AppTheme.neutralMedium,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppTheme.glowShadow,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Book Now',
                          style: GoogleFonts.outfit(
                            color: AppTheme.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_rounded,
                            color: AppTheme.white, size: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Decorative Icon/Image
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.white.withOpacity(0.05),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.white.withOpacity(0.1)),
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: AppTheme.accentGold,
                size: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(20) : Radius.zero,
          bottom: isLast ? const Radius.circular(20) : Radius.zero,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.neutralSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppTheme.primaryOrange, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.neutralMedium,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppTheme.forestBackground),
            ],
          ),
        ),
      ),
    );
  }
}

// Featured AI Pandit Card with Badge
class _FeaturedAIPanditCard extends StatelessWidget {
  final AIPanditModel pandit;
  final bool isTopRated;
  final VoidCallback onTap;

  const _FeaturedAIPanditCard({
    required this.pandit,
    required this.isTopRated,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isTopRated
                ? AppTheme.yellowPrimary
                : AppTheme.yellowPrimary.withOpacity(0.3),
            width: isTopRated ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.yellowPrimary.withOpacity(isTopRated ? 0.3 : 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.yellowPrimary.withOpacity(0.3),
                        AppTheme.goldAccent.withOpacity(0.2),
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
                      child: pandit.profileImage.startsWith('assets')
                          ? Image.asset(
                              pandit.profileImage,
                              width: double.infinity,
                              height: 150,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                Icons.person,
                                size: 60,
                                color: AppTheme.yellowPrimary,
                              ),
                            )
                          : Image.network(
                              pandit.profileImage,
                              width: double.infinity,
                              height: 150,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                Icons.person,
                                size: 60,
                                color: AppTheme.yellowPrimary,
                              ),
                            ),
                    ),
                  ),
                ),
                if (isTopRated)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.yellowPrimary, AppTheme.goldAccent],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: AppTheme.goldGlowShadow,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star,
                              size: 16, color: AppTheme.textDark),
                          const SizedBox(width: 4),
                          const Text(
                            'Top Rated',
                            style: TextStyle(
                              color: AppTheme.textDark,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.yellowPrimary, AppTheme.goldAccent],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: AppTheme.goldGlowShadow,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome,
                            color: AppTheme.textDark, size: 12),
                        const SizedBox(width: 4),
                        const Text(
                          'AI',
                          style: TextStyle(
                            color: AppTheme.textDark,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          pandit.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.successGreen,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Online',
                        style: TextStyle(
                          color: AppTheme.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pandit.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pandit.specializations.take(2).join(', '),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.neutralMedium,
                          fontSize: 11,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppTheme.yellowPrimary,
                              AppTheme.goldAccent
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${pandit.experienceYears}+ Yrs',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: AppTheme.textDark,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: onTap,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.infoBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.chat_bubble_outline,
                                color: AppTheme.infoBlue,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Quick Action Card
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Create Kundli Box Widget
class _CreateKundliBox extends StatelessWidget {
  const _CreateKundliBox();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/kundli/create'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6B4DFF), // Violet
              Color(0xFF8F73FF), // Lighter Violet
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF6B4DFF).withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Pattern
            Positioned(
              right: -20,
              top: -20,
              child: Opacity(
                opacity: 0.1,
                child: Icon(
                  Icons.auto_awesome,
                  size: 150,
                  color: Colors.white,
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded,
                          color: Colors.amberAccent, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Most Popular',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Make Your Kundli',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Get detailed insights about your life path, relationships, and career with our advanced Vedic charts.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Create Now',
                        style: TextStyle(
                          color: Color(0xFF6B4DFF),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Color(0xFF6B4DFF),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
