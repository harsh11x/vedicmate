import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/pandit_model.dart';
import '../../models/review_model.dart';

class PanditProfileDetailScreen extends StatelessWidget {
  final String panditId;

  const PanditProfileDetailScreen({super.key, required this.panditId});

  @override
  Widget build(BuildContext context) {
    // Mock data - in real app, fetch from API
    final pandit = PanditModel(
      id: panditId,
      name: 'Pandit Ravi Shankar',
      profileImage: null,
      specializations: ['Horoscope', 'Marriage', 'Career'],
      experienceYears: 15,
      rating: 4.8,
      totalReviews: 234,
      languages: ['Hindi', 'English', 'Sanskrit'],
      servicePricing: {
        'consultation': 500.0,
        'horoscope': 1000.0,
        'marriage': 1500.0,
      },
      bio: 'Experienced Vedic astrologer with 15+ years of practice. Specialized in horoscope reading, marriage compatibility, and career guidance.',
      certifications: ['Vedic Astrology Certification', 'Jyotish Expert'],
      isVerified: true,
      isAvailable: true,
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.saffronPrimary, AppTheme.saffronDark],
                  ),
                ),
                child: Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.white,
                    backgroundImage: pandit.profileImage != null
                        ? NetworkImage(pandit.profileImage!)
                        : null,
                    child: pandit.profileImage == null
                        ? const Icon(Icons.person, size: 50, color: AppTheme.saffronPrimary)
                        : null,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Verification
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          pandit.name,
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                      ),
                      if (pandit.isVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.goldAccent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified, size: 16, color: AppTheme.white),
                              SizedBox(width: 4),
                              Text(
                                'Verified',
                                style: TextStyle(
                                  color: AppTheme.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Rating
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppTheme.goldAccent),
                      const SizedBox(width: 4),
                      Text(
                        '${pandit.rating} (${pandit.totalReviews} reviews)',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Specializations
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: pandit.specializations.map((spec) {
                      return Chip(
                        label: Text(spec),
                        backgroundColor: AppTheme.creamPrimary,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  // About
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    pandit.bio ?? 'No bio available',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  // Experience
                  _InfoRow(
                    icon: Icons.work,
                    label: 'Experience',
                    value: '${pandit.experienceYears} years',
                  ),
                  const SizedBox(height: 12),
                  // Languages
                  _InfoRow(
                    icon: Icons.language,
                    label: 'Languages',
                    value: pandit.languages.join(', '),
                  ),
                  const SizedBox(height: 12),
                  // Certifications
                  if (pandit.certifications != null && pandit.certifications!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoRow(
                          icon: Icons.verified,
                          label: 'Certifications',
                          value: pandit.certifications!.join(', '),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  const SizedBox(height: 24),
                  // Service Pricing
                  Text(
                    'Service Pricing',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  ...pandit.servicePricing.entries.map((entry) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(entry.key.toUpperCase()),
                        trailing: Text(
                          '₹${entry.value.toInt()}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppTheme.saffronPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  // Reviews Section
                  Text(
                    'Reviews',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  _buildReviewsSection(context),
                  const SizedBox(height: 24),
                  // Book Now Button
                  ElevatedButton(
                    onPressed: () {
                      context.push(
                        '/booking/schedule?panditId=${pandit.id}&serviceType=consultation',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Book Consultation'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(BuildContext context) {
    // Mock reviews
    final reviews = [
      ReviewModel(
        id: '1',
        bookingId: 'b1',
        clientId: 'c1',
        panditId: panditId,
        rating: 5.0,
        knowledgeRating: 5.0,
        communicationRating: 4.5,
        punctualityRating: 5.0,
        comment: 'Excellent consultation! Very accurate predictions.',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      ReviewModel(
        id: '2',
        bookingId: 'b2',
        clientId: 'c2',
        panditId: panditId,
        rating: 4.5,
        knowledgeRating: 4.5,
        communicationRating: 4.0,
        punctualityRating: 5.0,
        comment: 'Great experience, highly recommended!',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];

    return Column(
      children: reviews.map((review) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      child: Icon(Icons.person),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Client Name',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                Icons.star,
                                size: 16,
                                color: index < review.rating.toInt()
                                    ? AppTheme.goldAccent
                                    : Colors.grey,
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                if (review.comment != null) ...[
                  const SizedBox(height: 8),
                  Text(review.comment!),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    _RatingChip(
                      label: 'Knowledge',
                      rating: review.knowledgeRating,
                    ),
                    const SizedBox(width: 4),
                    _RatingChip(
                      label: 'Communication',
                      rating: review.communicationRating,
                    ),
                    const SizedBox(width: 4),
                    _RatingChip(
                      label: 'Punctuality',
                      rating: review.punctualityRating,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.saffronPrimary),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _RatingChip extends StatelessWidget {
  final String label;
  final double rating;

  const _RatingChip({required this.label, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.creamPrimary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

