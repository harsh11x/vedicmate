import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../models/ai_pandit_model.dart';
import '../../widgets/daily_horoscope_card.dart';
import '../../widgets/quick_stats_widget.dart';
import '../../widgets/auspicious_timings_widget.dart';
import '../../widgets/special_offers_widget.dart';
import '../../widgets/numerology_widget.dart';
import '../../widgets/astronomy_widget.dart';
import '../../widgets/service_info_cards.dart';
import '../../widgets/ai_pandits_section.dart';
import '../../widgets/staggered_list_animation.dart';
import '../../widgets/abstract_background.dart';
import '../../providers/api_providers.dart';
import '../../providers/wallet_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/cart_provider.dart';
import 'reels_screen.dart';
import '../../providers/auth_provider.dart'; // Correctly placed import
import 'remedies_screen.dart';
import 'ai_pandit_chat_screen.dart';
import '../../widgets/live_pooja_banner.dart';
import '../../widgets/custom_request_banner.dart';
import '../shared/booking_scheduling_screen.dart';
import '../shared/chat_screen.dart';
import '../shared/video_call_screen.dart';
import '../shared/payment_wallet_screen.dart';
import '../shared/settings_screen.dart';
import '../shared/booking_history_screen.dart';
import '../../widgets/live_pooja_banner.dart';
import '../../widgets/action_box.dart';
import 'remedies_screen.dart';

class ClientDashboard extends ConsumerStatefulWidget {
  const ClientDashboard({super.key});

  @override
  ConsumerState<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends ConsumerState<ClientDashboard> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkBackground = _currentIndex == 2;
    final statusBarStyle = isDarkBackground
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: statusBarStyle.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkBackground ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        extendBody: true,
        body: Stack(
        children: [
          // Background Gradient only (No image to prevent overlap with Scaffold/Theme background)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFF8E1), // Light cream/gold top
                    Colors.white,
                  ],
                ),
              ),
            ),
          ),
          
          IndexedStack(
            index: _currentIndex,
            children: [
              _HomeTab(
                searchController: _searchController,
                onNavigateToTab: (index) => setState(() => _currentIndex = index),
              ),
              _ChatTab(),
              const ReelsScreen(),
              const RemediesScreen(),
              _ProfileTab(),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  decoration: AppTheme.navBarGlass,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(Icons.home_rounded, 'Home', 0),
                      _buildNavItem(Icons.chat_bubble_rounded, 'Chat', 1),
                      _buildNavItem(Icons.video_library_rounded, 'Reels', 2),
                      _buildNavItem(Icons.shopping_bag_rounded, 'Remedies', 3),
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
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 16 : 8, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryOrange.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryOrange : AppTheme.neutralMedium,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.primaryOrange,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
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
      pandits = pandits.where((p) => 
        p.name.toLowerCase().contains(query) || 
        p.specializations.any((s) => s.toLowerCase().contains(query))
      ).toList();
    }

    // Language
    if (_selectedLanguages.isNotEmpty) {
      pandits = pandits.where((p) => p.languages.any((l) => _selectedLanguages.contains(l))).toList();
    }

    // Category
    if (_selectedCategories.isNotEmpty) {
      pandits = pandits.where((p) => _selectedCategories.contains(p.category) || p.specializations.any((s) => _selectedCategories.contains(s))).toList();
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
                    Text('Filters', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
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
                          onSelected: (b) => setModalState(() => setState(() => _rateSort = b ? 'low_high' : '')),
                        ),
                        FilterChip(
                          label: const Text('High to Low'),
                          selected: _rateSort == 'high_low',
                          onSelected: (b) => setModalState(() => setState(() => _rateSort = b ? 'high_low' : '')),
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
                                selected: _selectedLanguages.length == AIPandits.allLanguages.length,
                                onSelected: (b) => setModalState(() => setState(() {
                                  if (b) {
                                    _selectedLanguages = List.from(AIPandits.allLanguages);
                                  } else {
                                    _selectedLanguages.clear();
                                  }
                                })),
                              ),
                            ),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: AIPandits.allLanguages.map((l) => FilterChip(
                                label: Text(l),
                                selected: _selectedLanguages.contains(l),
                                onSelected: (b) => setModalState(() => setState(() {
                                  if (b) {
                                    _selectedLanguages.add(l);
                                  } else {
                                    _selectedLanguages.remove(l);
                                  }
                                })),
                              )).toList(),
                            ),
                          ],
                        )
                      ]),
                      const SizedBox(height: 16),
                      _buildFilterSection('Categories', [
                        'Vedic Astrology', 'Numerology', 'Tarot', 'Palm Reading', 'Vastu Shastra'
                      ].map((c) => FilterChip(
                        label: Text(c),
                        selected: _selectedCategories.contains(c),
                        onSelected: (b) => setModalState(() => setState(() {
                          if (b) _selectedCategories.add(c);
                          else _selectedCategories.remove(c);
                        })),
                      )).toList()),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: children),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    // Watch auth state for reactive updates
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull;
    final userName = user?.displayName ?? 
                     (user?.email?.split('@').first ?? 'User');
    final greeting = _getGreeting();

    return Scaffold(
      backgroundColor: AppTheme.divineBackground,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Minimal Header (Logo + Greeting + Actions)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                greeting,
                                style: AppTheme.bodyStyle.copyWith(
                                  color: AppTheme.textGrey,
                                  fontSize: 14,
                                ),
                              ),
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      '${userName.split(' ').first}',
                                      style: GoogleFonts.inter(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.italic,
                                        color: AppTheme.textBlack,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('✨', style: TextStyle(fontSize: 20)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Actions Row (Wallet, Cart, Profile Pic if available)
                        Row(
                          children: [
                            // Wallet
                            Consumer(
                              builder: (context, ref, child) {
                                final walletBalanceAsync = ref.watch(walletBalanceProvider);
                                final balance = walletBalanceAsync.valueOrNull ?? 0.0;
                                return GestureDetector(
                                  onTap: () => context.push('/client/wallet'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: AppTheme.divineSurface,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.grey.withOpacity(0.1)),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.account_balance_wallet_outlined, size: 18, color: AppTheme.textBlack),
                                        const SizedBox(width: 8),
                                        Text(
                                          '₹${balance.toStringAsFixed(0)}',
                                          style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            // Cart
                            Consumer(
                              builder: (context, ref, child) {
                                final cartItems = ref.watch(cartProvider);
                                final itemCount = cartItems.fold(0, (sum, item) => sum + item.quantity);
                                return GestureDetector(
                                  onTap: () => context.push('/cart'),
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: AppTheme.divineSurface, // White
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.grey.withOpacity(0.1)),
                                        ),
                                        child: const Icon(Icons.shopping_bag_outlined, color: AppTheme.textBlack, size: 20),
                                      ),
                                      if (itemCount > 0)
                                        Positioned(
                                          right: -2,
                                          top: -2,
                                          child: CircleAvatar(
                                            radius: 8,
                                            backgroundColor: AppTheme.divineGold,
                                            child: Text(
                                              '$itemCount',
                                              style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Search Bar (Minimal)
                    Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppTheme.divineSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.withOpacity(0.05)),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: TextField(
                        controller: widget.searchController,
                        onChanged: (value) => setState(() => _searchQuery = value),
                        style: AppTheme.bodyStyle,
                        decoration: InputDecoration(
                          hintText: 'Search for guidance...',
                          hintStyle: TextStyle(color: AppTheme.textLight),
                          prefixIcon: const Icon(Icons.search, color: AppTheme.textGrey, size: 22),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.tune, color: AppTheme.textGrey, size: 20),
                            onPressed: _showFilterModal,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          fillColor: Colors.transparent, // Handled by Container
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),
              ),
            ),

            // 2. Featured / AI Pandits Section (Horizontal Scroll)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: AIPanditsSection(
                  title: 'Divine Consultation',
                  pandits: _filteredPandits,
                ),
              ).animate().fadeIn(delay: 200.ms).slideX(),
            ),

            // 3. Live Pooja Banner (Moved Up)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    // Match Action Box borders
                    border: Border.all(color: Colors.grey.withOpacity(0.05)),
                    // Minimal shadow like action boxes
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: LivePoojaBanner(
                     onTap: () => context.push('/live-pooja'),
                  ),
                ).animate().fadeIn(delay: 300.ms),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // 4. Main Actions (Grid) - Below Live Pooja
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: _ActionCardV2(
                        title: 'Kundli',
                        subtitle: 'Birth Chart',
                        imagePath: 'assets/images/services/kundli_box.png',
                        onTap: () => context.push('/kundli/create'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _ActionCardV2(
                        title: 'Match Making',
                        subtitle: 'Compatiblity',
                        imagePath: 'assets/images/services/matchmaking_box.png',
                        onTap: () => context.push('/relationship/form'),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms).scale(),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // 5. Custom Request Banner (Large rectangular like Daily Pooja)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.withOpacity(0.05)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CustomRequestBanner(
                    onTap: () => context.push('/booking/custom'),
                  ),
                ).animate().fadeIn(delay: 450.ms),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // 5. Explore Services (Grid)
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.auto_awesome_mosaic_rounded, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Explore Services',
                          style: GoogleFonts.outfit(
                            fontSize: 22, 
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textBlack,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ServiceInfoCards(), 
                ],
              ).animate().fadeIn(delay: 500.ms),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // 6. Quick Actions (Restored)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildQuickActionBtn(
                      context, 
                      icon: Icons.account_balance_wallet_rounded, 
                      label: 'Recharge', 
                      onTap: () => context.push('/client/wallet')
                    ),
                    _buildQuickActionBtn(
                      context, 
                      icon: Icons.history_rounded, 
                      label: 'History', 
                      onTap: () => context.push('/bookings/history')
                    ),
                    _buildQuickActionBtn(
                      context, 
                      icon: Icons.settings_rounded, 
                      label: 'Settings', 
                      onTap: () => context.push('/settings')
                    ),
                  ],
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
              ),
            ),

            // Bottom Spacing for Nav Bar
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionBtn(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryOrange, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTheme.bodyStyle.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textBlack,
              ),
            ),
          ],
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
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3), 
              BlendMode.darken
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.8),
              ],
              stops: const [0.4, 1.0],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
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
              color: (gradient.colors.firstOrNull ?? Colors.black).withOpacity(0.3),
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
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
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
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: AppTheme.glowShadow,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.auto_awesome, size: 12, color: Colors.white),
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
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star_rounded, color: AppTheme.accentGold, size: 14),
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

          if (chatRooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: AppTheme.forestBackground),
                  const SizedBox(height: 16),
                  Text(
                    'No chats yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start a conversation with an AI Pandit',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.neutralMedium,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.push('/ai-pandits/all'),
                    child: const Text('Browse AI Pandits'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final chatRoom = chatRooms[index];
              final participants = chatRoom['participantNames'] as Map<String, dynamic>? ?? {};
              final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
              final otherParticipantName = participants.entries
                  .firstWhere(
                    (e) => e.key != currentUserId,
                    orElse: () => MapEntry('', 'Pandit'),
                  )
                  .value as String? ?? 'Pandit';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryOrange.withOpacity(0.2),
                    child: Icon(Icons.person, color: AppTheme.primaryOrange),
                  ),
                  title: Text(
                    otherParticipantName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    chatRoom['lastMessage'] ?? 'No messages yet',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to chat screen
                    // We need booking ID - for now use chat room ID
                    context.push('/chat/${chatRoom['id']}');
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CallTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calls'),
        backgroundColor: AppTheme.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.phone_outlined, size: 64, color: AppTheme.forestBackground),
            const SizedBox(height: 16),
            Text(
              'No calls yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Start a voice call with an AI Pandit',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.neutralMedium,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.push('/ai-pandits/all'),
              child: const Text('Browse AI Pandits'),
            ),
          ],
        ),
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
                                border: Border.all(color: AppTheme.white, width: 4),
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
                                  border: Border.all(color: AppTheme.white, width: 2),
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
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppTheme.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '+91 98765 43210',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                      _buildStatItem(context, 'Wallet', '₹500', Icons.account_balance_wallet, AppTheme.successGreen),
                      Container(width: 1, height: 40, color: AppTheme.forestBackground),
                      _buildStatItem(context, 'Bookings', '12', Icons.calendar_today, AppTheme.primaryOrange),
                      Container(width: 1, height: 40, color: AppTheme.forestBackground),
                      _buildStatItem(context, 'Minutes', '450', Icons.timer, AppTheme.infoBlue),
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
                          icon: Icons.account_balance_wallet_outlined,
                          title: 'Wallet & Payments',
                          subtitle: 'Manage your wallet and transactions',
                          onTap: () => context.push('/payment/wallet'),
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

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon, Color color) {
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
            colors: [Color(0xFF1E293B), Color(0xFF0F172A)], // Cosmic Void gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppTheme.mediumShadow,
          border: Border.all(color: AppTheme.accentGold.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.accentGold.withOpacity(0.5)),
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
                    style: GoogleFonts.playfairDisplay(
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        const Icon(Icons.arrow_forward_rounded, color: AppTheme.white, size: 14),
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
            color: isTopRated ? AppTheme.yellowPrimary : AppTheme.yellowPrimary.withOpacity(0.3),
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
                              errorBuilder: (context, error, stackTrace) => Icon(
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
                              errorBuilder: (context, error, stackTrace) => Icon(
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                          const Icon(Icons.star, size: 16, color: AppTheme.textDark),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                        const Icon(Icons.auto_awesome, color: AppTheme.textDark, size: 12),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.yellowPrimary, AppTheme.goldAccent],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${pandit.experienceYears}+ Yrs',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
                          GestureDetector(
                            onTap: () => context.push('/ai-pandit/voice-call?panditId=${pandit.id}'),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.successGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.phone,
                                color: AppTheme.successGreen,
                                size: 18,
                              ),
                            ),
                          ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, color: Colors.amberAccent, size: 16),
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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

