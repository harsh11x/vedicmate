import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/cart_provider.dart';
import '../../providers/api_providers.dart';
import '../../config/api_config.dart';

class RemediesScreen extends ConsumerStatefulWidget {
  const RemediesScreen({super.key});

  @override
  ConsumerState<RemediesScreen> createState() => _RemediesScreenState();
}

class _RemediesScreenState extends ConsumerState<RemediesScreen> {
  final ScrollController _scrollController = ScrollController();
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Spiritual', 'Vastu', 'Healing', 'Cleansing', 'Jewelry', 'Accessories'];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider(_selectedCategory));

    return Scaffold(
      backgroundColor: AppTheme.neutralSoft,
      body: SafeArea(
        bottom: true,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: AppTheme.white,
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
                  'Spiritual Remedies',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.neutralDark,
                      ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryOrange.withValues(alpha: 0.1),
                        AppTheme.yellowPrimary.withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Category Filter
            SliverToBoxAdapter(
              child: Container(
                height: 60,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() => _selectedCategory = category);
                        },
                        selectedColor: AppTheme.primaryOrange,
                        labelStyle: TextStyle(
                          color: isSelected ? AppTheme.white : AppTheme.neutralDark,
                          fontWeight: FontWeight.w600,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? AppTheme.primaryOrange
                                : AppTheme.neutralLight,
                            width: 1.5,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Remedies List
            productsAsync.when(
              data: (remedies) {
                if (remedies.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          children: [
                            const Icon(Icons.inventory_2_outlined, size: 64, color: AppTheme.neutralMedium),
                            const SizedBox(height: 16),
                            const Text('No products found', style: TextStyle(color: AppTheme.neutralMedium)),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final remedy = remedies[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: GestureDetector(
                            onTap: () {
                              context.push('/remedy/product', extra: remedy);
                            },
                            child: _RemedyCard(remedy: remedy),
                          ),
                        );
                      },
                      childCount: remedies.length,
                    ),
                  ),
                );
              },
              loading: () => SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: const CircularProgressIndicator(color: AppTheme.primaryOrange),
                  ),
                ),
              ),
              error: (error, stack) => SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Text('Error: $error', style: const TextStyle(color: Colors.red)),
                  ),
                ),
              ),
            ),
          ],
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
    
    final double price = (remedy['price'] as num?)?.toDouble() ?? 0.0;
    final double originalPrice = (remedy['originalPrice'] as num?)?.toDouble() ?? (price * 1.3);
    int discountPercent = 0;
    if (originalPrice > price) {
      discountPercent = ((originalPrice - price) / originalPrice * 100).round();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryOrange.withValues(alpha: 0.2),
                  AppTheme.yellowPrimary.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: _buildImage(imageUrl),
                ),
                Positioned(
                  top: 12,
                  left: 12, // Badge on left
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.errorRed,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$discountPercent% OFF',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.yellowPrimary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      remedy['category'] ?? 'General',
                      style: const TextStyle(
                        color: AppTheme.textDark,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content Section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  remedy['name'] ?? remedy['title'] ?? 'Product',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: AppTheme.neutralDark,
                      ),
                ),
                const SizedBox(height: 8),

                // Pricing Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹$price',
                      style: const TextStyle(
                        color: AppTheme.textDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (discountPercent > 0)
                      Text(
                        '₹$originalPrice',
                        style: TextStyle(
                          color: AppTheme.neutralMedium,
                          fontSize: 14,
                          decoration: TextDecoration.lineThrough,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Description - Properly wrapped
                Text(
                  remedy['description'] ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.neutralMedium,
                        fontSize: 14,
                        height: 1.5,
                      ),
                  textAlign: TextAlign.left,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Add to cart functionality
                          ref.read(cartProvider.notifier).addToCart(
                            remedy['id'],
                            remedy['name'] ?? remedy['title'],
                            (remedy['price'] as num).toDouble(),
                            imageUrl,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${remedy['name'] ?? remedy['title']} added to cart'),
                              backgroundColor: AppTheme.successGreen,
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                        label: const Text('Add to Cart'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: AppTheme.primaryOrange, width: 1.5),
                          foregroundColor: AppTheme.primaryOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Buy now functionality
                          context.push('/checkout', extra: {
                            'item': remedy,
                            'isDirectBuy': true,
                          });
                        },
                        icon: const Icon(Icons.shopping_bag, size: 18),
                        label: const Text('Buy Now'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: AppTheme.primaryOrange,
                          foregroundColor: AppTheme.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String path) {
    if (path.isEmpty) return _buildPlaceholder();

    if (path.startsWith('http')) {
      return Image.network(
        path,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    } else if (path.startsWith('assets/')) {
        // Construct full URL using ApiConfig
        final fullUrl = '${ApiConfig.baseUrl.replaceAll('/api', '')}/$path';
        return Image.network(
          fullUrl, 
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) {
             return Image.asset(
                path,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholder(),
             );
          }
        );
    } 
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.spa,
        size: 80,
        color: AppTheme.primaryOrange.withValues(alpha: 0.3),
      ),
    );
  }
}
