import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/pandit_model.dart';
import '../../widgets/pandit_card.dart';
import '../../widgets/daily_horoscope_card.dart';
import '../../widgets/quick_stats_widget.dart';
import '../../widgets/auspicious_timings_widget.dart';
import '../../widgets/special_offers_widget.dart';
import '../../services/pandit_service.dart';
import '../../providers/api_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'live_screen.dart';
import 'remedies_screen.dart';
import 'ai_pandit_chat_screen.dart';
import '../shared/pandit_search_screen.dart';
import '../shared/pandit_profile_detail_screen.dart';
import '../shared/booking_scheduling_screen.dart';
import '../shared/chat_screen.dart';
import '../shared/video_call_screen.dart';
import '../shared/payment_wallet_screen.dart';
import '../shared/settings_screen.dart';
import '../shared/booking_history_screen.dart';

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
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _HomeTab(
            searchController: _searchController,
            onNavigateToTab: (index) => setState(() => _currentIndex = index),
          ),
          _ChatTab(),
          const LiveScreen(),
          _CallTab(),
          _ProfileTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          boxShadow: [
            BoxShadow(
              color: AppTheme.neutralDark.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.08,
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.02,
              vertical: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home, 'Home', 0),
                _buildNavItem(Icons.chat_bubble_outline, 'Chat', 1),
                _buildNavItem(Icons.live_tv, 'Live', 2),
                _buildNavItem(Icons.phone, 'Call', 3),
                _buildNavItem(Icons.person_outline, 'Profile', 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? icon : icon,
            color: isSelected ? AppTheme.yellowPrimary : AppTheme.neutralLight,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppTheme.yellowPrimary : AppTheme.neutralLight,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
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
  @override
  Widget build(BuildContext context) {
    final panditService = ref.watch(panditServiceProvider);
    final panditsAsync = ref.watch(panditsProvider);

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top Bar with Greeting and Wallet
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(
                  (MediaQuery.of(context).size.width * 0.05).clamp(16.0, 24.0),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi, Nickals 👋',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Welcome back!',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.neutralMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Wallet Balance Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.yellowPrimary, AppTheme.goldAccent],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.account_balance_wallet, size: 18, color: AppTheme.textDark),
                          const SizedBox(width: 6),
                          Text(
                            '₹1,250',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          color: AppTheme.neutralDark,
                          onPressed: () {},
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.errorRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Quick Stats Widget
            SliverToBoxAdapter(
              child: QuickStatsWidget(
                walletBalance: 1250.0,
                upcomingBookings: 2,
                activeChats: 3,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.neutralSoft,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: widget.searchController,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search, color: AppTheme.neutralMedium),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.mic, color: AppTheme.neutralMedium),
                        onPressed: () {},
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        context.push('/pandit/search?q=$value');
                      }
                    },
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Daily Horoscope Card
            SliverToBoxAdapter(
              child: DailyHoroscopeCard(
                zodiacSign: 'Aries',
                horoscopeText: 'Today brings new opportunities for growth and prosperity. Trust your instincts and embrace positive changes coming your way.',
                signColor: Colors.red,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Service Categories
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.12,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.05,
                  ),
                  children: [
                    _ServiceCategoryCard(
                      icon: Icons.auto_awesome,
                      label: 'AI Astrologer',
                      color: AppTheme.yellowPrimary,
                      onTap: () => context.push('/ai-pandit/chat'),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.04),
                    _ServiceCategoryCard(
                      icon: Icons.phone,
                      label: 'AI Voice Call',
                      color: AppTheme.successGreen,
                      onTap: () => context.push('/ai-pandit/voice-call'),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.04),
                    _ServiceCategoryCard(
                      icon: Icons.star,
                      label: 'Kundli',
                      color: Colors.pink,
                      onTap: () => context.push('/kundli/generation'),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.04),
                    _ServiceCategoryCard(
                      icon: Icons.favorite,
                      label: 'Love',
                      color: Colors.red,
                      onTap: () => widget.onNavigateToTab(1),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.04),
                    _ServiceCategoryCard(
                      icon: Icons.chat_bubble,
                      label: 'Chat',
                      color: Colors.blue,
                      onTap: () => widget.onNavigateToTab(1),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.04),
                    _ServiceCategoryCard(
                      icon: Icons.calendar_today,
                      label: 'Bookings',
                      color: Colors.purple,
                      onTap: () => context.push('/bookings/history'),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.04),
                    _ServiceCategoryCard(
                      icon: Icons.shopping_bag,
                      label: 'Remedies',
                      color: Colors.teal,
                      onTap: () => context.push('/remedies'),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Special Offers Section
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: (MediaQuery.of(context).size.width * 0.05).clamp(16.0, 24.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Special Offers',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const SpecialOffersWidget(),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Auspicious Timings
            SliverToBoxAdapter(
              child: const AuspiciousTimingsWidget(),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Promotional Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: (MediaQuery.of(context).size.width * 0.05).clamp(16.0, 24.0),
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.yellowPrimary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Talk to astrologer for free',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: AppTheme.neutralDark,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Let's open up to the thing that matters among the people",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.neutralMedium,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => context.push('/ai-pandit/chat'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.neutralDark,
                                      foregroundColor: AppTheme.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text('Chat'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => context.push('/ai-pandit/voice-call'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.successGreen,
                                      foregroundColor: AppTheme.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.phone, size: 18),
                                          const SizedBox(width: 4),
                                          const Text('Voice Call'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Decorative graphic
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.yellowPrimary.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.people,
                          size: 40,
                          color: AppTheme.yellowPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Trending Pandits Section
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: (MediaQuery.of(context).size.width * 0.05).clamp(16.0, 24.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppTheme.errorRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.local_fire_department,
                            color: AppTheme.errorRed,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Trending Astrologers',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => context.push('/pandit/search'),
                      child: const Text('See all'),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Featured Pandits (Top Rated)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 260,
                child: panditsAsync.when(
                  data: (pandits) {
                    if (pandits.isEmpty) {
                      return Center(
                        child: Text(
                          'No astrologers available',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.neutralMedium,
                          ),
                        ),
                      );
                    }
                    // Sort by rating and take top 3
                    final sortedPandits = List<PanditModel>.from(pandits)
                      ..sort((a, b) => b.rating.compareTo(a.rating));
                    final featuredPandits = sortedPandits.take(3).toList();
                    
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: featuredPandits.length,
                      itemBuilder: (context, index) {
                        final pandit = featuredPandits[index];
                        return Container(
                          width: 200,
                          margin: const EdgeInsets.only(right: 16),
                          child: _FeaturedPanditCard(
                            pandit: pandit,
                            isTopRated: index == 0,
                            onTap: () => context.push('/pandit/profile/${pandit.id}'),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Text(
                      'Error loading astrologers',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.errorRed,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // All Astrologers Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: (MediaQuery.of(context).size.width * 0.05).clamp(16.0, 24.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All Astrologers',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/pandit/search'),
                      child: const Text('See all'),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Astrologers List (Horizontal Scrollable)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 240,
                child: panditsAsync.when(
                  data: (pandits) {
                    if (pandits.isEmpty) {
                      return Center(
                        child: Text(
                          'No astrologers available',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.neutralMedium,
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: pandits.length,
                      itemBuilder: (context, index) {
                        final pandit = pandits[index];
                        return Container(
                          width: 180,
                          margin: const EdgeInsets.only(right: 16),
                          child: _AstrologerCard(
                            pandit: pandit,
                            onTap: () => context.push('/pandit/profile/${pandit.id}'),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Text(
                      'Error loading astrologers',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.errorRed,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Quick Actions Section
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: (MediaQuery.of(context).size.width * 0.05).clamp(16.0, 24.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.history,
                            label: 'Booking History',
                            color: AppTheme.infoBlue,
                            onTap: () => context.push('/bookings/history'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.account_balance_wallet,
                            label: 'Recharge Wallet',
                            color: AppTheme.successGreen,
                            onTap: () => context.push('/wallet/recharge'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.settings,
                            label: 'Settings',
                            color: AppTheme.neutralMedium,
                            onTap: () => context.push('/settings'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

class _ServiceCategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ServiceCategoryCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.2;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth.clamp(70.0, 100.0),
        padding: EdgeInsets.all((screenWidth * 0.04).clamp(12.0, 16.0)),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.softShadow,
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
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: (screenWidth * 0.03).clamp(10.0, 12.0),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AstrologerCard extends StatelessWidget {
  final PanditModel pandit;
  final VoidCallback onTap;

  const _AstrologerCard({
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
    ];
    final bgColor = colors[pandit.id.hashCode % colors.length];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.mediumShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with favorite icon
            Stack(
              children: [
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: bgColor.withOpacity(0.2),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: pandit.profileImage != null
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: Image.network(
                              pandit.profileImage!,
                              width: double.infinity,
                              height: 140,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildDefaultAvatar(bgColor),
                            ),
                          )
                        : _buildDefaultAvatar(bgColor),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.favorite_border, size: 20),
                    color: Colors.purple,
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pandit.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, color: AppTheme.yellowPrimary, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${pandit.rating}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${pandit.servicePricing.values.first.toInt()}/per min',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryOrange,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
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

  Widget _buildDefaultAvatar(Color bgColor) {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.3),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      child: Icon(
        Icons.person,
        size: 60,
        color: bgColor,
      ),
    );
  }
}

class _ChatTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        backgroundColor: AppTheme.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: AppTheme.neutralLight),
            const SizedBox(height: 16),
            Text(
              'No chats yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Start a conversation with an astrologer',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.neutralMedium,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.push('/pandit/search'),
              child: const Text('Browse Astrologers'),
            ),
          ],
        ),
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
            Icon(Icons.phone_outlined, size: 64, color: AppTheme.neutralLight),
            const SizedBox(height: 16),
            Text(
              'No calls yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Book a call with an astrologer',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.neutralMedium,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.push('/pandit/search'),
              child: const Text('Browse Astrologers'),
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
    return Scaffold(
      backgroundColor: AppTheme.neutralSoft,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppTheme.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.white, width: 4),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 40,
                          color: AppTheme.primaryOrange,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nickals',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppTheme.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Complete your profile',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _ProfileMenuItem(
                    icon: Icons.edit,
                    title: 'Edit Profile',
                    subtitle: 'Update your personal information',
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),
                  _ProfileMenuItem(
                    icon: Icons.account_balance_wallet,
                    title: 'Wallet & Payments',
                    subtitle: 'Manage your wallet and transactions',
                    onTap: () => context.push('/payment/wallet'),
                  ),
                  const SizedBox(height: 16),
                  _ProfileMenuItem(
                    icon: Icons.history,
                    title: 'Booking History',
                    subtitle: 'View your past consultations',
                    onTap: () => context.push('/bookings/history'),
                  ),
                  const SizedBox(height: 16),
                  _ProfileMenuItem(
                    icon: Icons.settings,
                    title: 'Settings',
                    subtitle: 'App preferences and privacy',
                    onTap: () => context.push('/settings'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primaryOrange),
        ),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

// Featured Pandit Card with Badge
class _FeaturedPanditCard extends StatelessWidget {
  final PanditModel pandit;
  final bool isTopRated;
  final VoidCallback onTap;

  const _FeaturedPanditCard({
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
          border: isTopRated
              ? Border.all(color: AppTheme.yellowPrimary, width: 2)
              : null,
          boxShadow: isTopRated ? AppTheme.glowShadow : AppTheme.mediumShadow,
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
                        AppTheme.primaryOrange.withOpacity(0.2),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Center(
                    child: pandit.profileImage != null
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                            child: Image.network(
                              pandit.profileImage!,
                              width: double.infinity,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            Icons.person,
                            size: 60,
                            color: AppTheme.yellowPrimary,
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
                          Text(
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
                      color: Colors.black.withOpacity(0.6),
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
                    left: 8,
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
                      Text(
                        '₹${pandit.servicePricing.values.first.toInt()}/min',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppTheme.primaryOrange,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => context.push('/booking/schedule?panditId=${pandit.id}&serviceType=chat'),
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
                            onTap: () => context.push('/booking/schedule?panditId=${pandit.id}&serviceType=video'),
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
            color: color.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: AppTheme.softShadow,
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

// Provider for fetching pandits
final panditsProvider = FutureProvider<List<PanditModel>>((ref) async {
  final panditService = ref.watch(panditServiceProvider);
  return await panditService.fetchPandits();
});
