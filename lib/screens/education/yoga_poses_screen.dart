import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../models/yoga_pose_model.dart';
import '../../features/education/services/yoga_repository.dart';

class YogaPosesScreen extends StatefulWidget {
  const YogaPosesScreen({super.key});

  @override
  State<YogaPosesScreen> createState() => _YogaPosesScreenState();
}

class _YogaPosesScreenState extends State<YogaPosesScreen> {
  final YogaRepository _repository = YogaRepository();
  late Future<List<YogaPose>> _posesFuture;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _posesFuture = _repository.getAllPoses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterPoses() {
    setState(() {
      if (_searchQuery.isNotEmpty) {
        _posesFuture = _repository.searchPoses(_searchQuery);
      } else if (_selectedCategory != 'All') {
        _posesFuture = _repository.getPosesByCategory(_selectedCategory);
      } else {
        _posesFuture = _repository.getAllPoses();
      }
    });
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'standing':
        return Icons.accessibility_new;
      case 'sitting':
        return Icons.event_seat;
      case 'lying':
        return Icons.hotel;
      case 'balancing':
        return Icons.balance;
      case 'twisting':
        return Icons.rotate_90_degrees_ccw;
      case 'inversion':
        return Icons.flip;
      default:
        return Icons.self_improvement;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Yoga Asanas',
          style: GoogleFonts.architectsDaughter(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: AppTheme.primaryOrange,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.primaryOrange.withValues(alpha: 0.1),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search poses...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                          _filterPoses();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _filterPoses();
              },
            ),
          ),

          // Category Filters
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _repository.getCategories().length,
              itemBuilder: (context, index) {
                final category = _repository.getCategories()[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                        _searchQuery = '';
                        _searchController.clear();
                      });
                      _filterPoses();
                    },
                    backgroundColor: Colors.white,
                    selectedColor: AppTheme.primaryOrange.withValues(alpha: 0.3),
                    checkmarkColor: AppTheme.primaryOrange,
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primaryOrange : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),

          // Poses Grid
          Expanded(
            child: FutureBuilder<List<YogaPose>>(
              future: _posesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.self_improvement,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No poses found',
                          style: GoogleFonts.patrickHand(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final poses = snapshot.data!;
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: poses.length,
                  itemBuilder: (context, index) {
                    final pose = poses[index];
                    return _buildPoseCard(pose);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPoseCard(YogaPose pose) {
    return GestureDetector(
      onTap: () {
        context.push('/education/yoga-pose/${pose.id}');
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Placeholder
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        _getCategoryIcon(pose.category),
                        size: 64,
                        color: AppTheme.primaryOrange.withValues(alpha: 0.3),
                      ),
                    ),
                    // Difficulty Badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(pose.difficulty),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          pose.difficulty,
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
            ),

            // Pose Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pose.nameEnglish,
                          style: GoogleFonts.architectsDaughter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textBlack,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pose.nameSanskrit,
                          style: GoogleFonts.patrickHand(
                            fontSize: 12,
                            color: AppTheme.primaryOrange,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          _getCategoryIcon(pose.category),
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            pose.category,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
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
            ),
          ],
        ),
      ),
    );
  }
}
