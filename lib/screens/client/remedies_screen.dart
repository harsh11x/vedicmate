import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class RemediesScreen extends StatefulWidget {
  const RemediesScreen({super.key});

  @override
  State<RemediesScreen> createState() => _RemediesScreenState();
}

class _RemediesScreenState extends State<RemediesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        title: Text(
          'Remedies & Shop',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.yellowPrimary,
          unselectedLabelColor: AppTheme.neutralMedium,
          indicatorColor: AppTheme.yellowPrimary,
          tabs: const [
            Tab(text: 'Products'),
            Tab(text: 'Pooja/Havan'),
            Tab(text: 'Custom Request'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ProductsTab(),
          _PoojaHavanTab(),
          _CustomRequestTab(),
        ],
      ),
    );
  }
}

// Products Tab - Shop for pendants, bracelets, etc.
class _ProductsTab extends StatelessWidget {
  const _ProductsTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(
        (MediaQuery.of(context).size.width * 0.05).clamp(16.0, 24.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.neutralSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(Icons.search, color: AppTheme.neutralMedium),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Category Filter
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _CategoryChip(label: 'All', isSelected: true),
                const SizedBox(width: 8),
                _CategoryChip(label: 'Pendants'),
                const SizedBox(width: 8),
                _CategoryChip(label: 'Bracelets'),
                const SizedBox(width: 8),
                _CategoryChip(label: 'Mala'),
                const SizedBox(width: 8),
                _CategoryChip(label: 'Yantra'),
                const SizedBox(width: 8),
                _CategoryChip(label: 'Gemstones'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Products Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.7,
            children: [
              _ProductCard(
                name: 'Rudraksha Mala',
                price: 499,
                originalPrice: 699,
                image: Icons.eco,
                category: 'Mala',
                rating: 4.5,
              ),
              _ProductCard(
                name: 'Gemstone Bracelet',
                price: 1299,
                originalPrice: 1799,
                image: Icons.diamond,
                category: 'Bracelets',
                rating: 4.8,
              ),
              _ProductCard(
                name: 'Shri Yantra Plate',
                price: 799,
                originalPrice: 999,
                image: Icons.crop_square,
                category: 'Yantra',
                rating: 4.7,
              ),
              _ProductCard(
                name: 'Copper Bracelet',
                price: 299,
                originalPrice: 399,
                image: Icons.circle,
                category: 'Bracelets',
                rating: 4.3,
              ),
              _ProductCard(
                name: 'Crystal Pendant',
                price: 899,
                originalPrice: 1199,
                image: Icons.star,
                category: 'Pendants',
                rating: 4.6,
              ),
              _ProductCard(
                name: 'Saffron Mala',
                price: 399,
                originalPrice: 599,
                image: Icons.eco,
                category: 'Mala',
                rating: 4.4,
              ),
              _ProductCard(
                name: 'Emerald Pendant',
                price: 2499,
                originalPrice: 2999,
                image: Icons.diamond,
                category: 'Pendants',
                rating: 4.9,
              ),
              _ProductCard(
                name: 'Lakshmi Yantra',
                price: 599,
                originalPrice: 799,
                image: Icons.crop_square,
                category: 'Yantra',
                rating: 4.5,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _CategoryChip({
    required this.label,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.yellowPrimary : AppTheme.neutralSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppTheme.textDark : AppTheme.neutralMedium,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String name;
  final double price;
  final double? originalPrice;
  final IconData image;
  final String category;
  final double rating;

  const _ProductCard({
    required this.name,
    required this.price,
    this.originalPrice,
    required this.image,
    required this.category,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showProductDetails(context),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.yellowPrimary.withOpacity(0.2),
                        AppTheme.primaryOrange.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Icon(image, size: 60, color: AppTheme.yellowPrimary),
                ),
                if (originalPrice != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.errorRed,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${((1 - price / originalPrice!) * 100).toInt()}% OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
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
                    category,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.neutralMedium,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: AppTheme.yellowPrimary),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '₹${price.toInt()}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.yellowPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      if (originalPrice != null) ...[
                        const SizedBox(width: 8),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '₹${originalPrice!.toInt()}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: AppTheme.neutralMedium,
                              ),
                            ),
                          ),
                        ),
                      ],
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

  void _showProductDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ProductDetailsSheet(
        name: name,
        price: price,
        originalPrice: originalPrice,
        category: category,
        rating: rating,
      ),
    );
  }
}

class _ProductDetailsSheet extends StatelessWidget {
  final String name;
  final double price;
  final double? originalPrice;
  final String category;
  final double rating;

  const _ProductDetailsSheet({
    required this.name,
    required this.price,
    this.originalPrice,
    required this.category,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.neutralMedium,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating.floor()
                        ? Icons.star
                        : index < rating
                            ? Icons.star_half
                            : Icons.star_border,
                    size: 20,
                    color: AppTheme.yellowPrimary,
                  );
                }),
              ),
              const SizedBox(width: 8),
              Text(
                rating.toStringAsFixed(1),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '₹${price.toInt()}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.yellowPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (originalPrice != null) ...[
                const SizedBox(width: 12),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '₹${originalPrice!.toInt()}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        decoration: TextDecoration.lineThrough,
                        color: AppTheme.neutralMedium,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.yellowPrimary.withOpacity(0.2),
                  AppTheme.primaryOrange.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.image, size: 80, color: AppTheme.yellowPrimary),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Authentic spiritual product blessed by expert Pandits. Made with high-quality materials and traditional methods. This product is energized and ready to use.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Product added to cart!'),
                        backgroundColor: AppTheme.successGreen,
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Add to Cart'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Product added to cart!'),
                        backgroundColor: AppTheme.successGreen,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.yellowPrimary,
                    foregroundColor: AppTheme.textDark,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Buy Now'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Pooja/Havan Tab
class _PoojaHavanTab extends StatelessWidget {
  const _PoojaHavanTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(
        (MediaQuery.of(context).size.width * 0.05).clamp(16.0, 24.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom Puja/Havan Request Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.yellowPrimary, AppTheme.goldAccent],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.mediumShadow,
            ),
            child: Row(
              children: [
                const Icon(Icons.add_circle_outline, size: 40, color: AppTheme.textDark),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Custom Puja/Havan Request',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Book a personalized puja or havan for your specific needs',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textDark.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: AppTheme.textDark),
                  onPressed: () => _showCustomPujaDialog(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Popular Pooja & Havan',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
            children: [
              _PoojaCard(
                title: 'Lakshmi Pooja',
                subtitle: 'For Wealth & Prosperity',
                price: 1999,
                duration: '2 hours',
                icon: Icons.attach_money,
                color: Colors.green,
              ),
              _PoojaCard(
                title: 'Mangal Dosh Pooja',
                subtitle: 'For Marriage Harmony',
                price: 2999,
                duration: '3 hours',
                icon: Icons.favorite,
                color: Colors.pink,
              ),
              _PoojaCard(
                title: 'Rudra Abhishek',
                subtitle: 'For Health & Protection',
                price: 3999,
                duration: '4 hours',
                icon: Icons.health_and_safety,
                color: Colors.teal,
              ),
              _PoojaCard(
                title: 'Saraswati Pooja',
                subtitle: 'For Education & Knowledge',
                price: 2499,
                duration: '2 hours',
                icon: Icons.school,
                color: Colors.purple,
              ),
              _PoojaCard(
                title: 'Ganpati Havan',
                subtitle: 'For Success & Obstacles',
                price: 3499,
                duration: '3 hours',
                icon: Icons.star,
                color: Colors.orange,
              ),
              _PoojaCard(
                title: 'Shani Remedies',
                subtitle: 'For Career & Stability',
                price: 4499,
                duration: '5 hours',
                icon: Icons.work,
                color: Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCustomPujaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _CustomPujaDialog(),
    );
  }
}

class _PoojaCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double price;
  final String duration;
  final IconData icon;
  final Color color;

  const _PoojaCard({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.duration,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showPoojaDetails(context),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Icon(icon, size: 50, color: color),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.neutralMedium,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₹${price.toInt()}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.yellowPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            duration,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.yellowPrimary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: AppTheme.yellowPrimary,
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
    );
  }

  void _showPoojaDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _PoojaDetailsSheet(
        title: title,
        subtitle: subtitle,
        price: price,
        duration: duration,
      ),
    );
  }
}

class _PoojaDetailsSheet extends StatelessWidget {
  final String title;
  final String subtitle;
  final double price;
  final String duration;

  const _PoojaDetailsSheet({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'What\'s Included:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _DetailItem(text: 'Expert Pandit consultation'),
          _DetailItem(text: 'Live Pooja/Havan performance'),
          _DetailItem(text: 'HD photos and video recording'),
          _DetailItem(text: 'Prasad delivery to your address'),
          _DetailItem(text: 'Detailed remedy instructions'),
          _DetailItem(text: 'Follow-up consultation'),
          const SizedBox(height: 24),
          Row(
            children: [
              Icon(Icons.access_time, size: 20, color: AppTheme.neutralMedium),
              const SizedBox(width: 8),
              Text(
                'Duration: $duration',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Price',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '₹${price.toInt()}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.yellowPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/booking/schedule?serviceType=pooja&title=$title&price=$price');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.yellowPrimary,
                  foregroundColor: AppTheme.textDark,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Book Now'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String text;

  const _DetailItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 20, color: AppTheme.successGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomPujaDialog extends StatefulWidget {
  @override
  State<_CustomPujaDialog> createState() => _CustomPujaDialogState();
}

class _CustomPujaDialogState extends State<_CustomPujaDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  String _selectedType = 'Puja';
  String _selectedPurpose = 'General';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Custom Puja/Havan Request',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Puja', 'Havan', 'Abhishek', 'Other']
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedType = value!);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedPurpose,
                  decoration: const InputDecoration(
                    labelText: 'Purpose',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    'General',
                    'Love & Marriage',
                    'Wealth & Finance',
                    'Career & Business',
                    'Health & Protection',
                    'Education',
                    'Other'
                  ]
                      .map((purpose) => DropdownMenuItem(
                            value: purpose,
                            child: Text(purpose),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedPurpose = value!);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dateController,
                  decoration: const InputDecoration(
                    labelText: 'Preferred Date',
                    hintText: 'Select date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      _dateController.text =
                          '${date.day}/${date.month}/${date.year}';
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Special Requirements',
                    hintText: 'Describe your specific needs...',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please describe your requirements';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Custom puja request submitted! Our team will contact you soon.'),
                                backgroundColor: AppTheme.successGreen,
                              ),
                            );
                          }
                        },
                        child: const Text('Submit'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Request Tab - For remedies (love, finance, career, etc.)
class _CustomRequestTab extends StatelessWidget {
  const _CustomRequestTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(
        (MediaQuery.of(context).size.width * 0.05).clamp(16.0, 24.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom Remedy Request Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.yellowPrimary, AppTheme.goldAccent],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.mediumShadow,
            ),
            child: Row(
              children: [
                const Icon(Icons.add_circle_outline, size: 40, color: AppTheme.textDark),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Raise Custom Remedy Request',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Get personalized remedies for your specific needs',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textDark.withOpacity(0.8),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: AppTheme.textDark),
                  onPressed: () => _showCustomRemedyDialog(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Popular Remedy Categories',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.9,
            children: [
              _RemedyCategoryCard(
                title: 'Love & Relationship',
                icon: Icons.favorite,
                color: Colors.pink,
                onTap: () => _showCustomRemedyDialog(context, category: 'Love'),
              ),
              _RemedyCategoryCard(
                title: 'Wealth & Finance',
                icon: Icons.attach_money,
                color: Colors.green,
                onTap: () => _showCustomRemedyDialog(context, category: 'Wealth'),
              ),
              _RemedyCategoryCard(
                title: 'Career & Business',
                icon: Icons.work,
                color: Colors.blue,
                onTap: () => _showCustomRemedyDialog(context, category: 'Career'),
              ),
              _RemedyCategoryCard(
                title: 'Health & Protection',
                icon: Icons.health_and_safety,
                color: Colors.teal,
                onTap: () => _showCustomRemedyDialog(context, category: 'Health'),
              ),
              _RemedyCategoryCard(
                title: 'Marriage & Family',
                icon: Icons.family_restroom,
                color: Colors.red,
                onTap: () => _showCustomRemedyDialog(context, category: 'Marriage'),
              ),
              _RemedyCategoryCard(
                title: 'Education & Knowledge',
                icon: Icons.school,
                color: Colors.purple,
                onTap: () => _showCustomRemedyDialog(context, category: 'Education'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCustomRemedyDialog(BuildContext context, {String? category}) {
    showDialog(
      context: context,
      builder: (context) => _CustomRemedyDialog(initialCategory: category),
    );
  }
}

class _RemedyCategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RemedyCategoryCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.2),
                color.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: color),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomRemedyDialog extends StatefulWidget {
  final String? initialCategory;

  const _CustomRemedyDialog({this.initialCategory});

  @override
  State<_CustomRemedyDialog> createState() => _CustomRemedyDialogState();
}

class _CustomRemedyDialogState extends State<_CustomRemedyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'General';

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'General';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Custom Remedy Request',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    'General',
                    'Love',
                    'Wealth',
                    'Career',
                    'Health',
                    'Marriage',
                    'Education',
                    'Family',
                    'Other'
                  ]
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedCategory = value!);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Describe your requirement',
                    hintText: 'Tell us what remedy you need and why...',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please describe your requirement';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Custom remedy request submitted! Our expert will contact you soon.'),
                                backgroundColor: AppTheme.successGreen,
                              ),
                            );
                          }
                        },
                        child: const Text('Submit'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
