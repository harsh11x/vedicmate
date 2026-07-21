import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';
import '../../models/ai_pandit_model.dart';
import '../../widgets/service_info_cards.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/api_providers.dart';
import 'reels_screen.dart';
import 'remedies_screen.dart';
import '../shared/settings_screen.dart';

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
      backgroundColor: AppTheme.celestialVoid, // Cosmic Background
      extendBody: true,
      body: Stack(
        children: [
          // Ambient Background Stars/Glow
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0B0B19), // Deep Void
                    Color(0xFF1A1A2E), // Slight Nebula
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
              // Placeholder screens needs cosmic theme too, but focusing on home first
               _PlaceholderScreen(title: 'Chat', icon: Icons.chat_bubble_outline),
               const ReelsScreen(), // Assuming this has its own UI
               const RemediesScreen(), // Assuming this has its own UI
               const SettingsScreen(), // Assuming this has its own UI
            ],
          ),
          
          // Cosmic Bottom Navigation Bar
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.celestialBlue.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryOrange.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(Icons.home_rounded, 'Home', 0),
                      _buildNavItem(Icons.chat_bubble_rounded, 'Chat', 1),
                      _buildNavItem(Icons.video_library_rounded, 'Reels', 2),
                      _buildNavItem(Icons.shopping_bag_rounded, 'Shop', 3),
                      _buildNavItem(Icons.person_rounded, 'Profile', 4),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 16 : 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryOrange.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: AppTheme.primaryOrange.withOpacity(0.5)) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.accentGold : Colors.white.withOpacity(0.6),
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.outfit(
                  color: Colors.white,
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

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon; // ignore: unused_element
  const _PlaceholderScreen({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Keep transparent to show cosmic bg
      appBar: AppBar(
        title: Text(title, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent, 
        elevation: 0,
      ),
      body: Center(child: Text('Coming Soon', style: TextStyle(color: Colors.white))),
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
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 
                     (user?.email?.split('@').first ?? 'Seeker');
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Cosmic Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: GoogleFonts.outfit(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          userName,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    _buildSolarBalance(ref),
                  ],
                ),
              ),
            ),

            // 2. Search Bar (Glassmorphic)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: TextField(
                    controller: widget.searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search the cosmos...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                      prefixIcon: Icon(Icons.search, color: AppTheme.accentGold),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    onSubmitted: (val) {
                       if (val.isNotEmpty) context.push('/ai-pandits/all?q=$val');
                    },
                  ),
                ),
              ),
            ),

            // 3. AI Feature
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: _CosmicActionCard(
                  title: 'Vedic AI Chat',
                  subtitle: 'Ask about your destiny',
                  icon: Icons.auto_awesome,
                  color: AppTheme.primaryOrange,
                  onTap: () => context.push('/ai-pandit/chat'),
                ),
              ),
            ),

            // 4. Section: Featured Pandits
            _buildSectionHeader('Cosmic Guides', onSeeAll: () => context.push('/ai-pandits/all')),
            
            SliverToBoxAdapter(
              child: SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    final pandits = AIPandits.getTopRated();
                    if (index >= pandits.length) return const SizedBox.shrink();
                     return Padding(
                       padding: const EdgeInsets.only(right: 12),
                       child: _CosmicPanditCard(
                         pandit: pandits[index], 
                         onTap: () => context.push('/ai-pandit/profile/${pandits[index].id}')
                       ),
                     );
                  },
                ),
              ),
            ),

            // 5. Existing Astrology Services (Grid)
            SliverToBoxAdapter(
               child: Padding(
                 padding: const EdgeInsets.only(top: 24),
                 child: ServiceInfoCards(), // Assuming this widget exists and handles its own theme or we update it separately
               ),
            ),

            // 6. Section: All Pandits
            _buildSectionHeader('All AI Pandits', onSeeAll: () => context.push('/ai-pandits/all')),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                   final pandits = AIPandits.getAllPandits();
                   if (index >= pandits.length) return null;
                   return Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                     child: _CosmicPanditListTile(
                       pandit: pandits[index],
                       onTap: () => context.push('/ai-pandit/profile/${pandits[index].id}'),
                     ),
                   );
                },
                childCount: AIPandits.getAllPandits().length,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildSolarBalance(WidgetRef ref) {
    final walletBalanceAsync = ref.watch(walletBalanceProvider);
    final balance = walletBalanceAsync.valueOrNull ?? 0.0;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.accentGold.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accentGold.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentGold.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.account_balance_wallet, color: AppTheme.accentGold, size: 16),
          const SizedBox(width: 8),
          Text(
            '₹${balance.toStringAsFixed(0)}',
            style: GoogleFonts.outfit(
              color: AppTheme.accentGold,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (onSeeAll != null)
              GestureDetector(
                onTap: onSeeAll,
                child: Text(
                  'See All',
                  style: GoogleFonts.outfit(
                    color: AppTheme.accentGold,
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Custom Widgets for Client Dashboard

class _CosmicActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CosmicActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.2),
              color.withOpacity(0.05),
            ],
          ),
        ),
        child: Stack(
          children: [
             Positioned(
               right: -10,
               bottom: -10,
               child: Icon(icon, size: 80, color: color.withOpacity(0.1)),
             ),
             Padding(
               padding: const EdgeInsets.all(16),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Icon(icon, color: color),
                   const Spacer(),
                   Text(
                     title,
                     style: GoogleFonts.outfit(
                       color: Colors.white,
                       fontWeight: FontWeight.bold,
                       fontSize: 16,
                     ),
                   ),
                   Text(
                     subtitle,
                     style: GoogleFonts.outfit(
                       color: Colors.white.withOpacity(0.6),
                       fontSize: 12,
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

class _CosmicPanditCard extends StatelessWidget {
  final AIPanditModel pandit;
  final VoidCallback onTap;

  const _CosmicPanditCard({required this.pandit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: AppTheme.celestialBlue,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                     child: pandit.profileImage.startsWith('http')
                        ? Image.network(pandit.profileImage, fit: BoxFit.cover)
                        : Image.asset(pandit.profileImage, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star, color: AppTheme.accentGold, size: 10),
                          const SizedBox(width: 4),
                          Text(
                            pandit.rating.toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pandit.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    pandit.specializations.firstOrNull ?? 'Astrologer',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 10,
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

class _CosmicPanditListTile extends StatelessWidget {
  final AIPanditModel pandit;
   final VoidCallback onTap;

  const _CosmicPanditListTile({required this.pandit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.celestialBlue.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                 child: SizedBox(
                    width: 60,
                    height: 60,
                    child: pandit.profileImage.startsWith('http')
                        ? Image.network(pandit.profileImage, fit: BoxFit.cover)
                         : Image.asset(pandit.profileImage, fit: BoxFit.cover),
                 ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pandit.name,
                      style: const TextStyle(
                         color: Colors.white,
                         fontWeight: FontWeight.bold,
                         fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pandit.specializations.join(', '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.language, size: 12, color: AppTheme.primaryOrange),
                        const SizedBox(width: 4),
                        Text(
                          pandit.languages.join(', '),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                             fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Icon(Icons.chevron_right, color: AppTheme.primaryOrange),
                ],
              ),
            ],
        ),
      ),
    );
  }
}
