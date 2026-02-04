import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/cart_provider.dart';
import '../../providers/api_providers.dart';
import '../../core/config/env.dart';

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
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(productsProvider(_selectedCategory));
          await ref.read(productsProvider(_selectedCategory).future);
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
                        AppTheme.primaryOrange.withOpacity(0.1),
                        AppTheme.yellowPrimary.withOpacity(0.05),
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
                                : AppTheme.forestBackground,
                            width: 1.5,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Remedies Grid
            productsAsync.when(
              data: (remedies) {
                if (remedies.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          children: [
                            const Icon(Icons.inventory_2_outlined, size: 64, color: AppTheme.textGrey),
                            const SizedBox(height: 16),
                            const Text('No products found', style: TextStyle(color: AppTheme.textGrey)),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 2 boxes side by side
                      childAspectRatio: 0.65, // Adjust for height
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final remedy = remedies[index];
                        return GestureDetector(
                          onTap: () {
                            context.push('/remedy/product', extra: remedy);
                          },
                          child: _RemedyCard(remedy: remedy),
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
                    child: const CircularProgressIndicator(color: AppTheme.divineGold),
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
    ),
  );
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
                  child: _buildImage(imageUrl),
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
                             context.push('/checkout', extra: {
                              'item': remedy,
                              'isDirectBuy': true,
                            });
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

  Widget _buildImage(String path) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    } else if (path.startsWith('assets/')) {
        return Image.network(
          // HARDCODING BASE URL FOR NOW TO ENSURE IT WORKS
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
                errorBuilder: (_, __, ___) => _buildPlaceholder(),
             );
          }
        );
    } 
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
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
}
