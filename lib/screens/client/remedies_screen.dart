import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class RemediesScreen extends StatefulWidget {
  const RemediesScreen({super.key});

  @override
  State<RemediesScreen> createState() => _RemediesScreenState();
}

class _RemediesScreenState extends State<RemediesScreen> {
  final ScrollController _scrollController = ScrollController();
  String _selectedCategory = 'All';

  final List<Map<String, dynamic>> _remedies = [
    {
      'id': '1',
      'title': 'Rudraksha Mala',
      'category': 'Spiritual',
      'price': 2999,
      'image': 'assets/images/remedy1.png',
      'description': 'Authentic Rudraksha mala for spiritual protection and positive energy. Made from genuine Rudraksha beads sourced from Nepal. Wearing this mala helps in meditation, reduces stress, and brings peace of mind.',
      'benefits': [
        'Enhances spiritual growth',
        'Reduces stress and anxiety',
        'Improves concentration',
        'Brings positive energy',
      ],
    },
    {
      'id': '2',
      'title': 'Ganesh Yantra',
      'category': 'Vastu',
      'price': 1499,
      'image': 'assets/images/remedy2.png',
      'description': 'Sacred Ganesh Yantra made of pure copper. This powerful yantra removes obstacles, brings prosperity, and ensures success in all endeavors. Place it in your home or office for maximum benefits.',
      'benefits': [
        'Removes obstacles',
        'Brings prosperity',
        'Ensures success',
        'Protects from negative energy',
      ],
    },
    {
      'id': '3',
      'title': 'Crystal Healing Set',
      'category': 'Healing',
      'price': 3999,
      'image': 'assets/images/remedy3.png',
      'description': 'Premium crystal healing set with 7 different crystals including Amethyst, Rose Quartz, Clear Quartz, Citrine, Black Tourmaline, Selenite, and Tiger Eye. Each crystal has unique healing properties.',
      'benefits': [
        'Emotional healing',
        'Energy cleansing',
        'Chakra balancing',
        'Stress relief',
      ],
    },
    {
      'id': '4',
      'title': 'Sage Smudging Kit',
      'category': 'Cleansing',
      'price': 899,
      'image': 'assets/images/remedy4.png',
      'description': 'Complete sage smudging kit with white sage bundle, abalone shell, and feather. Used for space cleansing, removing negative energy, and purifying your environment.',
      'benefits': [
        'Cleanses negative energy',
        'Purifies environment',
        'Promotes positive vibes',
        'Spiritual protection',
      ],
    },
    {
      'id': '5',
      'title': 'Vastu Mirror',
      'category': 'Vastu',
      'price': 2499,
      'image': 'assets/images/remedy5.png',
      'description': 'Authentic Vastu mirror with sacred geometry patterns. This mirror deflects negative energy and enhances positive vibrations in your home or office space.',
      'benefits': [
        'Deflects negative energy',
        'Enhances positive vibes',
        'Vastu compliance',
        'Protection from evil eye',
      ],
    },
    {
      'id': '6',
      'title': 'Lakshmi Puja Kit',
      'category': 'Spiritual',
      'price': 1999,
      'image': 'assets/images/remedy6.png',
      'description': 'Complete Lakshmi puja kit with all necessary items for performing Lakshmi puja. Includes idols, incense, diya, flowers, and other puja essentials. Brings wealth and prosperity.',
      'benefits': [
        'Attracts wealth',
        'Brings prosperity',
        'Removes financial obstacles',
        'Blessings of Goddess Lakshmi',
      ],
    },
    {
      'id': '7',
      'title': 'Rudraksha Mala Chain',
      'category': 'Jewelry',
      'price': 2499,
      'image': 'assets/images/mala_chain.png',
      'description': 'Premium Rudraksha mala chain with 108 beads. Handcrafted with genuine Rudraksha seeds from Nepal. Perfect for daily meditation and spiritual practices. Available in various sizes.',
      'benefits': [
        'Spiritual protection',
        'Enhances meditation',
        'Reduces stress',
        'Positive energy flow',
      ],
    },
    {
      'id': '8',
      'title': 'Gemstone Bracelet Set',
      'category': 'Jewelry',
      'price': 3499,
      'image': 'assets/images/bracelet.png',
      'description': 'Beautiful gemstone bracelet set with natural stones including Ruby, Emerald, Blue Sapphire, Yellow Sapphire, and Pearl. Each stone has specific astrological benefits.',
      'benefits': [
        'Astrological benefits',
        'Enhances planetary energies',
        'Stylish accessory',
        'Natural gemstones',
      ],
    },
    {
      'id': '9',
      'title': 'Navratna Ring',
      'category': 'Jewelry',
      'price': 4999,
      'image': 'assets/images/navratna_ring.png',
      'description': 'Authentic Navratna ring with 9 precious gemstones arranged in traditional pattern. Includes Ruby, Pearl, Coral, Emerald, Yellow Sapphire, Diamond, Blue Sapphire, Hessonite, and Cat\'s Eye.',
      'benefits': [
        'Complete planetary protection',
        'Traditional design',
        'Precious gemstones',
        'Astrological significance',
      ],
    },
    {
      'id': '10',
      'title': 'Tulsi Mala',
      'category': 'Spiritual',
      'price': 899,
      'image': 'assets/images/tulsi_mala.png',
      'description': 'Sacred Tulsi (Holy Basil) mala with 108 beads. Made from pure Tulsi wood, known for its spiritual and medicinal properties. Ideal for daily prayers and meditation.',
      'benefits': [
        'Spiritual purification',
        'Health benefits',
        'Divine connection',
        'Traditional practice',
      ],
    },
    {
      'id': '11',
      'title': 'Silver Om Pendant',
      'category': 'Jewelry',
      'price': 1799,
      'image': 'assets/images/om_pendant.png',
      'description': 'Elegant silver Om symbol pendant with chain. Handcrafted with intricate designs. The Om symbol represents the ultimate reality and consciousness.',
      'benefits': [
        'Spiritual symbol',
        'Elegant design',
        'Silver purity',
        'Universal consciousness',
      ],
    },
    {
      'id': '12',
      'title': 'Copper Bracelet',
      'category': 'Accessories',
      'price': 1299,
      'image': 'assets/images/copper_bracelet.png',
      'description': 'Pure copper bracelet with Vedic symbols. Copper is known for its health benefits and positive energy. Features traditional engravings.',
      'benefits': [
        'Health benefits',
        'Positive energy',
        'Traditional design',
        'Pure copper',
      ],
    },
    {
      'id': '13',
      'title': 'Gold Plated Mangalsutra',
      'category': 'Jewelry',
      'price': 5999,
      'image': 'assets/images/mangalsutra.png',
      'description': 'Traditional gold plated mangalsutra with black beads and gold pendant. Symbol of marital bliss and prosperity. Available in various designs.',
      'benefits': [
        'Marital harmony',
        'Traditional significance',
        'Elegant design',
        'Prosperity symbol',
      ],
    },
    {
      'id': '14',
      'title': 'Panchdhatu Ring',
      'category': 'Jewelry',
      'price': 3999,
      'image': 'assets/images/panchdhatu_ring.png',
      'description': 'Sacred Panchdhatu ring made from five metals: Gold, Silver, Copper, Zinc, and Iron. Believed to balance all five elements and bring harmony.',
      'benefits': [
        'Elemental balance',
        'Five metal alloy',
        'Traditional significance',
        'Harmony and balance',
      ],
    },
  ];

  final List<String> _categories = ['All', 'Spiritual', 'Vastu', 'Healing', 'Cleansing', 'Jewelry', 'Accessories'];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredRemedies = _selectedCategory == 'All'
        ? _remedies
        : _remedies.where((r) => r['category'] == _selectedCategory).toList();

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
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final remedy = filteredRemedies[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _RemedyCard(remedy: remedy),
                  );
                },
                childCount: filteredRemedies.length,
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }
}

class _RemedyCard extends StatelessWidget {
  final Map<String, dynamic> remedy;

  const _RemedyCard({required this.remedy});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                  AppTheme.primaryOrange.withOpacity(0.2),
                  AppTheme.yellowPrimary.withOpacity(0.1),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.spa,
                    size: 80,
                    color: AppTheme.primaryOrange.withOpacity(0.3),
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
                    ),
                    child: Text(
                      remedy['category'],
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
                // Title and Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        remedy['title'],
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: AppTheme.neutralDark,
                            ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.yellowPrimary, AppTheme.goldAccent],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '₹${remedy['price']}',
                        style: const TextStyle(
                          color: AppTheme.textDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Description - Properly wrapped
                Text(
                  remedy['description'],
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.neutralMedium,
                        fontSize: 14,
                        height: 1.5,
                      ),
                  textAlign: TextAlign.left,
                ),

                const SizedBox(height: 16),

                // Benefits
                Text(
                  'Benefits:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.neutralDark,
                      ),
                ),
                const SizedBox(height: 8),
                ...(remedy['benefits'] as List<String>).map((benefit) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 6, right: 8),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryOrange,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              benefit,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.neutralMedium,
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    )),

                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Add to cart functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${remedy['title']} added to cart'),
                              backgroundColor: AppTheme.successGreen,
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Proceeding to buy ${remedy['title']}'),
                              backgroundColor: AppTheme.primaryOrange,
                            ),
                          );
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
}

