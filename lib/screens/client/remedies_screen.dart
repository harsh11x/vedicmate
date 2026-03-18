import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/cart_provider.dart';
import '../../core/config/env.dart';
import 'package:google_fonts/google_fonts.dart';

Widget _remedyCardImage(String path) {
  if (path.startsWith('http')) {
    return Image.network(
      path,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _remedyCardPlaceholder(),
    );
  } else if (path.startsWith('assets/')) {
    return Image.network(
      '${EnvConfig.apiBaseUrl}/$path',
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) {
        return Image.asset(
          path,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _remedyCardPlaceholder(),
        );
      },
    );
  }
  return _remedyCardPlaceholder();
}

Widget _remedyCardPlaceholder() {
  return Container(
    color: AppTheme.divineGold.withOpacity(0.1),
    child: Center(
      child: Icon(
        Icons.spa,
        size: 40,
        color: AppTheme.divineGold.withOpacity(0.5),
      ),
    ),
  );
}

class RemediesScreen extends ConsumerStatefulWidget {
  const RemediesScreen({super.key});

  @override
  ConsumerState<RemediesScreen> createState() => _RemediesScreenState();
}

class _RemediesScreenState extends ConsumerState<RemediesScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.divineBackground,
      body: RefreshIndicator(
        onRefresh: () async {
          // No-op for now (Yoga-only screen)
        },
        child: SafeArea(
        bottom: true,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: AppTheme.divineBackground,
              elevation: 0,
              actions: [
                Consumer(
                  builder: (context, ref, child) {
                    final cartItems = ref.watch(cartProvider);
                    final itemCount = cartItems.fold(0, (sum, item) => sum + item.quantity);
                    return Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.shopping_cart_outlined, color: AppTheme.neutralDark),
                          onPressed: () => context.push('/cart'),
                        ),
                        if (itemCount > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryOrange,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$itemCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                title: Text(
                  'Yoga',
                  style: AppTheme.titleStyle.copyWith(
                        fontSize: 24,
                        color: AppTheme.neutralDark,
                      ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.divineBackground,
                  ),
                ),
              ),
            ),

            // Yoga Sutras entry
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _YogaCard(
                      onTap: () => context.push(Uri(
                        path: '/education/reader/yoga_sutras',
                        queryParameters: {'title': 'Yoga Sutras', 'chapter': '1'},
                      ).toString()),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    ),
  );
  }
}

class _RemedyCard extends ConsumerWidget {
  final Map<String, dynamic> remedy;

  const _RemedyCard({required this.remedy});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check if images is a list and get the first one, or string
    String imageUrl = '';
    if (remedy['images'] is List && (remedy['images'] as List).isNotEmpty) {
      imageUrl = (remedy['images'] as List).first;
    } else if (remedy['images'] is String) {
      imageUrl = remedy['images'];
    }
    
    final price = (remedy['price'] as num?)?.toDouble() ?? 0.0;
    // Mock original price logic if not available, simply +20% for demo visualization if missing
    // In real app, 'originalPrice' should come from backend
    final originalPrice = (remedy['originalPrice'] as num?)?.toDouble() ?? (price * 1.2); 
    final discount = ((originalPrice - price) / originalPrice * 100).round();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: _remedyCardImage(imageUrl),
                ),
                // Discount Badge
                if (discount > 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.errorRed,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$discount% OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Content Section
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        remedy['category'] ?? 'General',
                        style: AppTheme.bodyStyle.copyWith(
                          color: AppTheme.divineGold,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        remedy['name'] ?? remedy['title'] ?? 'Product',
                        style: AppTheme.bodyStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppTheme.textBlack,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Price Row
                      Row(
                        children: [
                          Text(
                            '₹${price.toStringAsFixed(0)}',
                            style: AppTheme.bodyStyle.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppTheme.textBlack,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '₹${originalPrice.toStringAsFixed(0)}',
                            style: AppTheme.bodyStyle.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: AppTheme.textGrey,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  // Buttons Row
                  Row(
                    children: [
                      /*Small Cart Icon Button*/
                      Expanded(
                        child: InkWell(
                          onTap: () {
                             ref.read(cartProvider.notifier).addToCart(
                              remedy['id'],
                              remedy['name'] ?? remedy['title'],
                              (remedy['price'] as num).toDouble(),
                              imageUrl,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Added to Cart'),
                                duration: Duration(milliseconds: 600),
                                backgroundColor: AppTheme.successGreen,
                              ),
                            );
                          },
                          child: Container(
                            height: 32,
                            decoration: BoxDecoration(
                              border: Border.all(color: AppTheme.divineGold),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Icon(Icons.add_shopping_cart, size: 16, color: AppTheme.divineGold),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      /*Buy Now Button*/
                      Expanded(
                        flex: 2,
                        child: InkWell(
                          onTap: () {
                             ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Purchase is not available for this item.'),
                                backgroundColor: AppTheme.primaryOrange,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: Container(
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppTheme.divineGold,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                'Buy',
                                style: AppTheme.bodyStyle.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class _YogaCard extends StatelessWidget {
  final VoidCallback onTap;

  const _YogaCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/services/vedic_astrology.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: AppTheme.divineGold.withOpacity(0.12)),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.35),
                      Colors.black.withOpacity(0.75),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Yoga Sutras',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Patanjali\'s Path',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                      ),
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
}
