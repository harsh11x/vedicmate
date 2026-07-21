import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/cart_provider.dart';
import '../../core/config/env.dart';

class RemedyProductScreen extends ConsumerWidget {
  final Map<String, dynamic> remedy;

  const RemedyProductScreen({super.key, required this.remedy});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Extract image safely
    String imageUrl = '';
    if (remedy['images'] is List && (remedy['images'] as List).isNotEmpty) {
      imageUrl = (remedy['images'] as List).first;
    } else if (remedy['images'] is String) {
      imageUrl = remedy['images'];
    } else if (remedy['image'] is String) {
      imageUrl = remedy['image'];
    }

    // Extract name safely
    final productName = remedy['name'] ?? remedy['title'] ?? 'Product';

    return Scaffold(
      backgroundColor: AppTheme.divineBackground,
      body: CustomScrollView(
        slivers: [
          // Image Header
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: AppTheme.divineBackground,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.arrow_back, color: AppTheme.neutralDark),
              ),
              onPressed: () => context.pop(),
            ),
            actions: [
              Consumer(builder: (context, ref, _) {
                final cartItems = ref.watch(cartProvider);
                final itemCount =
                    cartItems.fold(0, (sum, item) => sum + item.quantity);
                return Stack(
                  children: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.shopping_cart_outlined,
                            color: AppTheme.neutralDark),
                      ),
                      onPressed: () {
                        context.push('/cart');
                      },
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
              }),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _buildImage(imageUrl),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black12,
                          Colors.black45,
                        ],
                        stops: [0.6, 0.8, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppTheme.divineBackground,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              transform: Matrix4.translationValues(0, -20, 0),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.forestBackground,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Category & Rating
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.divineGold.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _displayCategory(remedy['category']),
                          style: const TextStyle(
                            color: AppTheme.sacredCopper,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.star_rounded,
                          color: AppTheme.accentGold),
                      const SizedBox(width: 4),
                      Text(
                        '4.8 (120 reviews)',
                        style: TextStyle(
                          color: AppTheme.neutralMedium,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title & Price
                  Text(
                    productName,
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.neutralDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '₹${remedy['price']}',
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryOrange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (remedy['originalPrice'] != null &&
                          remedy['originalPrice'] > remedy['price']) ...[
                        Text(
                          '₹${remedy['originalPrice']}',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            decoration: TextDecoration.lineThrough,
                            color: AppTheme.neutralMedium,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${(((remedy['originalPrice'] - remedy['price']) / remedy['originalPrice']) * 100).round()}% OFF',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'Description',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.neutralDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    remedy['description'] ?? 'No description available.',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.neutralMedium,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Benefits
                  if (remedy['benefits'] != null &&
                      remedy['benefits'] is List) ...[
                    Text(
                      'Key Benefits',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.neutralDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: (remedy['benefits'] as List).map((benefit) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppTheme.neutralSoft,
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: AppTheme.forestBackground),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle_outline,
                                  size: 16, color: AppTheme.successGreen),
                              const SizedBox(width: 8),
                              Text(
                                benefit.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.neutralDark,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.elevatedSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(cartProvider.notifier).addToCart(
                          remedy['id'],
                          productName,
                          (remedy['price'] as num).toDouble(),
                          imageUrl,
                        );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$productName added to cart'),
                        backgroundColor: AppTheme.successGreen,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: AppTheme.primaryOrange, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Add to Cart',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.primaryOrange,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/checkout', extra: {
                      'item': remedy,
                      'isDirectBuy': true,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppTheme.primaryOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: AppTheme.primaryOrange.withOpacity(0.4),
                  ),
                  child: Text(
                    'Buy Now',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String path) {
    if (path.isEmpty) return _buildPlaceholder();

    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    } else if (path.startsWith('assets/')) {
      return Image.network(
          // HARDCODING BASE URL FOR NOW TO ENSURE IT WORKS
          '${EnvConfig.apiBaseUrl}/$path',
          fit: BoxFit.cover, errorBuilder: (context, error, stack) {
        return Image.asset(
          path,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
        );
      });
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.sandalwood.withOpacity(0.9),
            AppTheme.divineSurface,
            AppTheme.divineGold.withOpacity(0.18),
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppTheme.divineInk,
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.divineGold.withOpacity(0.35)),
          ),
          child: const Icon(
            Icons.spa_rounded,
            size: 58,
            color: AppTheme.divineGoldLight,
          ),
        ),
      ),
    );
  }

  String _displayCategory(dynamic category) {
    final raw = (category ?? 'General').toString();
    return raw
        .replaceAll('-', ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}
