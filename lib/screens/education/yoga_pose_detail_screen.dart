import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../models/yoga_pose_model.dart';
import '../../features/education/services/yoga_repository.dart';

class YogaPoseDetailScreen extends StatefulWidget {
  final String poseId;

  const YogaPoseDetailScreen({
    super.key,
    required this.poseId,
  });

  @override
  State<YogaPoseDetailScreen> createState() => _YogaPoseDetailScreenState();
}

class _YogaPoseDetailScreenState extends State<YogaPoseDetailScreen> {
  final YogaRepository _repository = YogaRepository();
  late Future<YogaPose?> _poseFuture;
  bool _isPracticed = false;
  int _practiceCount = 0;

  @override
  void initState() {
    super.initState();
    _poseFuture = _repository.getPoseById(widget.poseId);
    _loadPracticeStatus();
  }

  Future<void> _loadPracticeStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isPracticed = prefs.getBool('practiced_${widget.poseId}') ?? false;
      _practiceCount = prefs.getInt('practice_count_${widget.poseId}') ?? 0;
    });
  }

  Future<void> _togglePracticed() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isPracticed = !_isPracticed;
      if (_isPracticed) {
        _practiceCount++;
      }
    });
    await prefs.setBool('practiced_${widget.poseId}', _isPracticed);
    await prefs.setInt('practice_count_${widget.poseId}', _practiceCount);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isPracticed
                ? 'Marked as practiced! Total: $_practiceCount times'
                : 'Removed from practiced',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
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
      body: FutureBuilder<YogaPose?>(
        future: _poseFuture,
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
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Pose not found'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          final pose = snapshot.data!;
          return CustomScrollView(
            slivers: [
              // App Bar with Image
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: AppTheme.primaryOrange,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppTheme.primaryOrange.withValues(alpha: 0.3),
                          AppTheme.primaryOrange.withValues(alpha: 0.1),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _getCategoryIcon(pose.category),
                        size: 120,
                        color: AppTheme.primaryOrange.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title Section
                    Container(
                      padding: const EdgeInsets.all(24),
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pose.nameEnglish,
                            style: GoogleFonts.architectsDaughter(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textBlack,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            pose.nameSanskrit,
                            style: GoogleFonts.patrickHand(
                              fontSize: 20,
                              color: AppTheme.primaryOrange,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildInfoChip(
                                icon: _getCategoryIcon(pose.category),
                                label: pose.category,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 8),
                              _buildInfoChip(
                                icon: Icons.signal_cellular_alt,
                                label: pose.difficulty,
                                color: _getDifficultyColor(pose.difficulty),
                              ),
                              const SizedBox(width: 8),
                              _buildInfoChip(
                                icon: Icons.timer,
                                label: pose.duration,
                                color: Colors.purple,
                              ),
                            ],
                          ),
                          if (_practiceCount > 0) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.emoji_events,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Practiced $_practiceCount ${_practiceCount == 1 ? 'time' : 'times'}',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const Divider(height: 1),

                    // Benefits Section
                    _buildSection(
                      title: 'Benefits',
                      icon: Icons.favorite,
                      iconColor: Colors.red,
                      child: Column(
                        children: pose.benefits.map((benefit) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    benefit,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const Divider(height: 1),

                    // Instructions Section
                    _buildSection(
                      title: 'Step-by-Step Instructions',
                      icon: Icons.format_list_numbered,
                      iconColor: Colors.blue,
                      child: Column(
                        children: pose.instructions.asMap().entries.map((entry) {
                          final index = entry.key;
                          final instruction = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryOrange,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      instruction,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const Divider(height: 1),

                    // Precautions Section
                    _buildSection(
                      title: 'Precautions & Contraindications',
                      icon: Icons.warning,
                      iconColor: Colors.orange,
                      child: Column(
                        children: pose.precautions.map((precaution) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: Colors.orange,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    precaution,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _togglePracticed,
        backgroundColor: _isPracticed ? Colors.green : AppTheme.primaryOrange,
        icon: Icon(_isPracticed ? Icons.check_circle : Icons.check_circle_outline),
        label: Text(_isPracticed ? 'Practiced' : 'Mark as Practiced'),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.architectsDaughter(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}
