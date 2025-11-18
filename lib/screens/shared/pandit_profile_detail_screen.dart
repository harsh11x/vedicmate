import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/pandit_model.dart';
import '../../models/review_model.dart';
import '../../services/pandit_service.dart';
import '../../providers/api_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'booking_scheduling_screen.dart';
import 'chat_screen.dart';
import 'video_call_screen.dart';

class PanditProfileDetailScreen extends ConsumerStatefulWidget {
  final String panditId;

  const PanditProfileDetailScreen({super.key, required this.panditId});

  @override
  ConsumerState<PanditProfileDetailScreen> createState() => _PanditProfileDetailScreenState();
}

class _PanditProfileDetailScreenState extends ConsumerState<PanditProfileDetailScreen> {
  bool _isFollowing = false;
  bool _isExpanded = false;
  final List<String> _galleryImages = [
    'https://via.placeholder.com/300x400/FFC107/FFFFFF?text=Sidhi+1',
    'https://via.placeholder.com/300x400/FFC107/FFFFFF?text=Sidhi+2',
    'https://via.placeholder.com/300x400/FFC107/FFFFFF?text=Sidhi+3',
    'https://via.placeholder.com/300x400/FFC107/FFFFFF?text=Sidhi+4',
  ];

  @override
  Widget build(BuildContext context) {
    // Fetch pandit data - in real app, use API
    final pandit = _getPanditData();
    final reviews = _getMockReviews();

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            _buildTopBar(),
            
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Section
                    _buildProfileSection(pandit),
                    
                    const SizedBox(height: 20),
                    
                    // Key Information Cards
                    _buildKeyInfoCards(pandit),
                    
                    const SizedBox(height: 20),
                    
                    // About Section
                    _buildAboutSection(pandit),
                    
                    const SizedBox(height: 20),
                    
                    // Gallery Section
                    _buildGallerySection(),
                    
                    const SizedBox(height: 20),
                    
                    // User Reviews Section
                    _buildReviewsSection(reviews, pandit),
                    
                    const SizedBox(height: 100), // Space for bottom buttons
                  ],
                ),
              ),
            ),
            
            // Bottom Action Bar
            _buildBottomActionBar(pandit),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.neutralDark),
            onPressed: () => context.pop(),
          ),
          Expanded(
            child: Text(
              'Profile',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.share, color: AppTheme.neutralDark),
            onPressed: () {
              // Share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing profile...')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppTheme.neutralDark),
            onPressed: () {
              _showMoreOptions();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(PanditModel pandit) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Profile Picture with Online Indicator
          Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppTheme.yellowPrimary.withOpacity(0.2),
                backgroundImage: pandit.profileImage != null
                    ? NetworkImage(pandit.profileImage!)
                    : null,
                child: pandit.profileImage == null
                    ? Icon(Icons.person, size: 40, color: AppTheme.yellowPrimary)
                    : null,
              ),
              // Online Indicator
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(width: 16),
          
          // Name, Rating, Specializations
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name with Verified Badge
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        pandit.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (pandit.isVerified)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.successGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 16,
                          color: AppTheme.white,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                
                // Rating and Orders
                Row(
                  children: [
                    Icon(Icons.star, color: AppTheme.yellowPrimary, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${pandit.rating}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${pandit.totalReviews} Orders',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.neutralMedium,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Specializations
                Row(
                  children: [
                    Icon(Icons.category, size: 14, color: AppTheme.neutralMedium),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        pandit.specializations.join(', '),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.neutralMedium,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Follow Button
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isFollowing = !_isFollowing;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isFollowing ? 'Following ${pandit.name}' : 'Unfollowed ${pandit.name}'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _isFollowing ? AppTheme.neutralSoft : AppTheme.yellowPrimary,
              foregroundColor: AppTheme.neutralDark,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            child: Text(
              _isFollowing ? 'Following' : 'Follow',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyInfoCards(PanditModel pandit) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.softShadow,
        ),
        child: Row(
          children: [
            // Languages
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Languages',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.neutralMedium,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pandit.languages.join(', '),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Divider
            Container(
              width: 1,
              height: 40,
              color: AppTheme.neutralLight.withOpacity(0.3),
            ),
            
            // Experience
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Experience',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.neutralMedium,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${pandit.experienceYears} Years',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            // Divider
            Container(
              width: 1,
              height: 40,
              color: AppTheme.neutralLight.withOpacity(0.3),
            ),
            
            // Price
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Price',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.neutralMedium,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹ ${pandit.servicePricing.values.first.toInt()}/min',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppTheme.primaryOrange,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(PanditModel pandit) {
    final fullBio = pandit.bio ?? 'No description available.';
    final shortBio = fullBio.length > 150 ? fullBio.substring(0, 150) + '...' : fullBio;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _isExpanded ? fullBio : shortBio,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.neutralDark,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          if (fullBio.length > 150)
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _isExpanded ? 'Read less' : 'Read more',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.successGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGallerySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Gallery',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _galleryImages.length + 1,
            itemBuilder: (context, index) {
              if (index == _galleryImages.length) {
                // View All overlay
                return GestureDetector(
                  onTap: () {
                    _showFullGallery();
                  },
                  child: Container(
                    width: 120,
                    margin: const EdgeInsets.only(left: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.neutralDark.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                      image: _galleryImages.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(_galleryImages.last),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.5),
                                BlendMode.darken,
                              ),
                            )
                          : null,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.grid_view, color: AppTheme.white, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            'View All',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              
              return Container(
                width: 120,
                margin: EdgeInsets.only(right: index < _galleryImages.length - 1 ? 12 : 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppTheme.yellowPrimary.withOpacity(0.2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _galleryImages[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppTheme.yellowPrimary.withOpacity(0.2),
                        child: Icon(Icons.image, color: AppTheme.yellowPrimary, size: 40),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsSection(List<ReviewModel> reviews, PanditModel pandit) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Reviews',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          
          // Review Card
          if (reviews.isNotEmpty)
            _buildReviewCard(reviews.first),
          
          const SizedBox(height: 16),
          
          // View All Reviews Button
          GestureDetector(
            onTap: () {
              _showAllReviews(reviews, pandit);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.neutralSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'View ${pandit.totalReviews}+ Reviews',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    final timeAgo = _getTimeAgo(review.createdAt);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.neutralSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Review Quote
          Text(
            '"${review.comment ?? 'No comment'}"',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.neutralDark,
              fontSize: 14,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          
          // Reviewer Info
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryOrange.withOpacity(0.2),
                child: Icon(Icons.person, color: AppTheme.primaryOrange),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ishita', // Mock reviewer name
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timeAgo,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.neutralMedium,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Rating Stars
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating.round() ? Icons.star : Icons.star_border,
                    size: 16,
                    color: AppTheme.yellowPrimary,
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(PanditModel pandit) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Chat Now Button
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  _handleChatNow(pandit);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.yellowPrimary,
                  foregroundColor: AppTheme.neutralDark,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.chat_bubble_outline, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Chat Now',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Call Now Button
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  _handleCallNow(pandit);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successGreen,
                  foregroundColor: AppTheme.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.phone, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Call Now',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleChatNow(PanditModel pandit) {
    // Navigate to booking/scheduling screen for chat
    context.push(
      '/booking/schedule?panditId=${pandit.id}&serviceType=chat',
    );
  }

  void _handleCallNow(PanditModel pandit) {
    // Navigate to booking/scheduling screen for call
    context.push(
      '/booking/schedule?panditId=${pandit.id}&serviceType=video',
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Report'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report submitted')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Block'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User blocked')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFullGallery() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Gallery',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 400,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _galleryImages.length,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        _galleryImages[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppTheme.yellowPrimary.withOpacity(0.2),
                            child: Icon(Icons.image, color: AppTheme.yellowPrimary),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAllReviews(List<ReviewModel> reviews, PanditModel pandit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'All Reviews (${pandit.totalReviews})',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildReviewCard(reviews[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  PanditModel _getPanditData() {
    // Mock data - in real app, fetch from API using widget.panditId
    return PanditModel(
      id: widget.panditId,
      name: 'Sidhi',
      profileImage: null,
      specializations: ['Vedic', 'Vastu', 'Prashana'],
      experienceYears: 10,
      rating: 4.96,
      totalReviews: 212197,
      languages: ['English', 'Hindi'],
      servicePricing: {
        'consultation': 27.0,
      },
      bio: 'Sidhi is a Vedic astrologer in India. She loves to help her clients when they are in need. Her predictions are known for their accuracy and she provides spiritual guidance based on ancient Vedic principles. With years of experience, she has helped thousands of people find clarity and direction in their lives.',
      isVerified: true,
      isAvailable: true,
    );
  }

  List<ReviewModel> _getMockReviews() {
    return [
      ReviewModel(
        id: '1',
        bookingId: 'b1',
        clientId: 'c1',
        panditId: widget.panditId,
        rating: 5.0,
        knowledgeRating: 5.0,
        communicationRating: 5.0,
        punctualityRating: 5.0,
        comment: 'Very good astrologer I believe his prediction is very accurate ... please consult him once. he will solve all your problems with small remedies. Thank you :)',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ReviewModel(
        id: '2',
        bookingId: 'b2',
        clientId: 'c2',
        panditId: widget.panditId,
        rating: 4.5,
        knowledgeRating: 4.5,
        communicationRating: 4.5,
        punctualityRating: 4.5,
        comment: 'Great consultation! Very helpful and accurate predictions.',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }
}
