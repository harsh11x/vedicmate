import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/cart_provider.dart';
import '../../config/api_config.dart';

class RemedyProductScreen extends ConsumerWidget {
  final Map<String, dynamic> remedy;

  const RemedyProductScreen({super.key, required this.remedy});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Data extraction with safety
    final String name = remedy['name'] ?? remedy['title'] ?? 'Product';
    final String description = remedy['description'] ?? 'No description available.';
    final double price = (remedy['price'] as num?)?.toDouble() ?? 0.0;
    // Handle original price for discount calculation
    final double originalPrice = (remedy['originalPrice'] as num?)?.toDouble() ?? (price * 1.3); // Default 30% diff if missing 
    final String category = remedy['category'] ?? 'General';
    final List<dynamic> benefitsInfo = remedy['benefits'] is List ? remedy['benefits'] : [];
    
    // Image Handling
    String imageUrl = '';
    if (remedy['images'] is List && (remedy['images'] as List).isNotEmpty) {
      imageUrl = (remedy['images'] as List).first;
    } else if (remedy['images'] is String) {
      imageUrl = remedy['images'];
    }

    // Calculate Discount
    int discountPercent = 0;
    if (originalPrice > price) {
      discountPercent = ((originalPrice - price) / originalPrice * 100).round();
    }

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: CustomScrollView(
        slivers: [
          // Image Header
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: AppTheme.white,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: AppTheme.neutralDark),
              ),
              onPressed: () => context.pop(),
            ),
            actions: [
              Consumer(builder: (context, ref, _) {
                final cartItems = ref.watch(cartProvider);
                final itemCount = cartItems.fold(0, (sum, item) => sum + item.quantity);
                return Stack(
                  children: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.shopping_cart_outlined, color: AppTheme.neutralDark),
                      ),
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
                color: AppTheme.white,
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
                        color: AppTheme.neutralLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Category & Rating
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          category.toUpperCase(),
                          style: const TextStyle(
                            color: AppTheme.primaryOrange,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.star_rounded, color: AppTheme.accentGold),
                      const SizedBox(width: 4),
                      const Text(
                        '4.8 (120 reviews)',
                        style: TextStyle(
                          color: AppTheme.neutralMedium,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    name,
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.neutralDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Price Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹$price',
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryOrange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (discountPercent > 0) ...[
                        Text(
                          '₹$originalPrice',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.neutralMedium,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Text(
                            '$discountPercent% OFF',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
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
                    description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.neutralMedium,
                      height: 1.6,
                    ),
                  ),
                  
                  if (benefitsInfo.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    // Benefits
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
                      children: benefitsInfo.map((benefit) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppTheme.neutralSoft,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.neutralLight),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle_outline, size: 16, color: AppTheme.successGreen),
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
          color: Colors.white,
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
                      name,
                      price,
                      imageUrl,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Added to cart'),
                        backgroundColor: AppTheme.successGreen,
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppTheme.primaryOrange, width: 2),
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
                    shadowColor: AppTheme.primaryOrange.withValues(alpha: 0.4),
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
        // Construct standard URL using ApiConfig
        final fullUrl = '${ApiConfig.baseUrl.replaceAll('/api', '')}/$path';
        return Image.network(
          fullUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) {
             // Try asset loading as fallback
             return Image.asset(
                path,
                fit: BoxFit.cover, // Use cover to fill space
                errorBuilder: (_, __, ___) => _buildPlaceholder(),
             );
          }
        );
    } 
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppTheme.neutralSoft,
      child: Center(
        child: Icon(
          Icons.spa,
          size: 80,
          color: AppTheme.primaryOrange.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
