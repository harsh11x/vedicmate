import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/ai_pandit_model.dart';
import '../../services/user_preferences_service.dart';

class PanditSelectionScreen extends StatefulWidget {
  final String selectedCategory;

  const PanditSelectionScreen({
    super.key,
    required this.selectedCategory,
  });

  @override
  State<PanditSelectionScreen> createState() => _PanditSelectionScreenState();
}

class _PanditSelectionScreenState extends State<PanditSelectionScreen> with TickerProviderStateMixin {
  final _prefsService = UserPreferencesService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  List<AIPanditModel> _pandits = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPandits();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    _animationController.forward();
  }

  void _loadPandits() {
    setState(() {
      _pandits = AIPandits.getCuratedByCategory(widget.selectedCategory, limit: 10);
    });
  }

  List<AIPanditModel> _getFilteredPandits() {
    if (_searchQuery.isEmpty) {
      return _pandits;
    }
    return _pandits.where((pandit) {
      return pandit.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          pandit.specializations.any((s) => s.toLowerCase().contains(_searchQuery.toLowerCase()));
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handlePanditSelection(AIPanditModel pandit, String action) async {
    await _prefsService.savePreferredPandit(pandit.id);
    await _prefsService.setOnboardingComplete(true);

    if (mounted) {
      if (action == 'chat') {
        context.go('/ai-pandit/chat?panditId=${pandit.id}');
      } else {
        context.go('/ai-pandit/voice-call?panditId=${pandit.id}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredPandits = _getFilteredPandits();

    return Scaffold(
      backgroundColor: AppTheme.neutralSoft,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose Your AI Pandit',
              style: TextStyle(
                color: AppTheme.textDark,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              widget.selectedCategory,
              style: const TextStyle(
                color: AppTheme.neutralMedium,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              // Progress Indicator
              Container(
                color: AppTheme.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildProgressDot(true),
                        _buildProgressLine(true),
                        _buildProgressDot(true),
                        _buildProgressLine(true),
                        _buildProgressDot(true),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Step 3 of 3 - Final Step!',
                      style: TextStyle(
                        color: AppTheme.neutralMedium,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Search Bar
              Container(
                color: AppTheme.white,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name or specialization...',
                    prefixIcon: const Icon(Icons.search, color: AppTheme.neutralMedium),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppTheme.neutralMedium),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppTheme.neutralSoft,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              // Results Count
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.yellowPrimary, AppTheme.goldAccent],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: AppTheme.textDark,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${filteredPandits.length} AI Pandits Available',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.neutralDark,
                          ),
                    ),
                  ],
                ),
              ),
              // Pandits List
              Expanded(
                child: filteredPandits.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.search_off,
                              size: 64,
                              color: AppTheme.neutralMedium,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No AI Pandits found',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AppTheme.neutralMedium,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your search',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.neutralMedium,
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredPandits.length,
                        itemBuilder: (context, index) {
                          final pandit = filteredPandits[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _PanditProfileCard(
                              pandit: pandit,
                              onChat: () => _handlePanditSelection(pandit, 'chat'),
                              onCall: () => _handlePanditSelection(pandit, 'call'),
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

  Widget _buildProgressDot(bool isActive) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        gradient: isActive
            ? const LinearGradient(
                colors: [AppTheme.yellowPrimary, AppTheme.goldAccent],
              )
            : null,
        color: isActive ? null : AppTheme.forestBackground,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildProgressLine(bool isActive) {
    return Container(
      width: 40,
      height: 2,
      color: isActive ? AppTheme.yellowPrimary : AppTheme.forestBackground,
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

class _PanditProfileCard extends StatelessWidget {
  final AIPanditModel pandit;
  final VoidCallback onChat;
  final VoidCallback onCall;

  const _PanditProfileCard({
    required this.pandit,
    required this.onChat,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.pink,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];
    final bgColor = colors[pandit.id.hashCode % colors.length];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.yellowPrimary.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.yellowPrimary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Image
          Stack(
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.yellowPrimary.withOpacity(0.2),
                      bgColor.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Center(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Image.network(
                      pandit.profileImage,
                      width: double.infinity,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.person,
                        size: 50,
                        color: bgColor.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.yellowPrimary, AppTheme.goldAccent],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppTheme.goldGlowShadow,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome, size: 14, color: AppTheme.textDark),
                      SizedBox(width: 4),
                      Text(
                        'AI Pandit',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: AppTheme.accentGold, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${pandit.rating}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (pandit.isAvailable)
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, size: 8, color: AppTheme.white),
                        SizedBox(width: 4),
                        Text(
                          'Online',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          // Info Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pandit.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.yellowPrimary, AppTheme.goldAccent],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        pandit.specializations.first,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.neutralSoft,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${pandit.experienceYears}+ Yrs',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.neutralDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  pandit.bio ?? '',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.neutralMedium,
                        height: 1.5,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.language, size: 16, color: AppTheme.neutralMedium),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        pandit.languages.take(3).join(', '),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.neutralMedium,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.yellowPrimary, AppTheme.goldAccent],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.yellowPrimary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: onChat,
                          icon: const Icon(Icons.chat_bubble, size: 18, color: AppTheme.textDark),
                          label: const Text(
                            'Chat',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.successGreen, Color(0xFF4CAF50)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.successGreen.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: onCall,
                          icon: const Icon(Icons.phone, size: 18, color: AppTheme.white),
                          label: const Text(
                            'Call',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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
