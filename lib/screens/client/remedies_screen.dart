import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';

class RemediesScreen extends StatefulWidget {
  const RemediesScreen({super.key});

  @override
  State<RemediesScreen> createState() => _RemediesScreenState();
}

class _RemediesScreenState extends State<RemediesScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = const [
    'All',
    'Pooja Path',
    'Vastu',
    'Relationship',
    'Money',
    'Career',
    'Health',
    'Protection',
  ];

  final List<_DesiRemedy> _remedies = const [
    _DesiRemedy(
      title: 'Daily Ghar Pooja Path',
      category: 'Pooja Path',
      icon: Icons.local_fire_department_rounded,
      timing: 'Morning after bath',
      shortText: 'Simple daily diya, incense, and mantra routine for shanti.',
      steps: [
        'Clean the mandir area and light one diya.',
        'Offer water, flowers, or tulsi if available.',
        'Chant Om Gan Ganapataye Namah 11 times.',
        'Sit quietly for 2 minutes and set one positive sankalp.',
      ],
    ),
    _DesiRemedy(
      title: 'Tuesday Hanuman Chalisa',
      category: 'Pooja Path',
      icon: Icons.temple_hindu_rounded,
      timing: 'Tuesday evening',
      shortText: 'For courage, nazar protection, and mental strength.',
      steps: [
        'Light a mustard oil diya near Hanuman ji.',
        'Offer jaggery or boondi if available.',
        'Read Hanuman Chalisa once with full focus.',
        'Avoid anger and harsh speech for the day.',
      ],
    ),
    _DesiRemedy(
      title: 'Vastu Salt Bowl Remedy',
      category: 'Vastu',
      icon: Icons.home_work_rounded,
      timing: 'Change every Saturday',
      shortText: 'A simple desi cleansing practice for heavy room energy.',
      steps: [
        'Place rock salt in a small bowl in a corner.',
        'Keep it away from children and pets.',
        'Replace the salt weekly and discard it outside.',
        'Keep the room ventilated and clutter-free.',
      ],
    ),
    _DesiRemedy(
      title: 'Main Door Positivity',
      category: 'Vastu',
      icon: Icons.door_front_door_rounded,
      timing: 'Every morning',
      shortText: 'Keep the entrance clean, lit, and welcoming.',
      steps: [
        'Clean the entrance and remove broken items.',
        'Place a small diya or warm light near the entry.',
        'Keep shoes arranged, not scattered.',
        'Use a simple toran or auspicious symbol if you like.',
      ],
    ),
    _DesiRemedy(
      title: 'Relationship Shanti Practice',
      category: 'Relationship',
      icon: Icons.favorite_rounded,
      timing: 'Friday evening',
      shortText: 'For better communication and calmness between partners.',
      steps: [
        'Light a ghee diya in the evening.',
        'Offer white flowers or rice to the divine.',
        'Write one thing you appreciate about your partner.',
        'Speak gently and avoid old arguments for the night.',
      ],
    ),
    _DesiRemedy(
      title: 'Family Harmony Remedy',
      category: 'Relationship',
      icon: Icons.family_restroom_rounded,
      timing: 'Sunday morning',
      shortText: 'A practical ritual for ghar ki shanti.',
      steps: [
        'Do one shared meal without phones.',
        'Light incense in the living area.',
        'Chant Om Shanti 21 times together or silently.',
        'Resolve one small pending household issue calmly.',
      ],
    ),
    _DesiRemedy(
      title: 'Lakshmi Friday Remedy',
      category: 'Money',
      icon: Icons.payments_rounded,
      timing: 'Friday sunset',
      shortText: 'For financial discipline and prosperity mindset.',
      steps: [
        'Clean your wallet and remove waste papers.',
        'Light a ghee diya for Maa Lakshmi.',
        'Offer kheer, mishri, or any simple sweet.',
        'Track expenses for 5 minutes before sleeping.',
      ],
    ),
    _DesiRemedy(
      title: 'Career Focus Sankalp',
      category: 'Career',
      icon: Icons.work_rounded,
      timing: 'Monday morning',
      shortText: 'For focus, discipline, and work clarity.',
      steps: [
        'Write your top 3 work priorities.',
        'Chant Om Namah Shivaya 21 times.',
        'Keep your desk clean before starting work.',
        'Complete the toughest task first for 25 minutes.',
      ],
    ),
    _DesiRemedy(
      title: 'Amla Wellness Routine',
      category: 'Health',
      icon: Icons.spa_rounded,
      timing: 'Morning',
      shortText: 'A simple Ayurvedic-style routine for daily wellness.',
      steps: [
        'Start the day with warm water.',
        'Use amla in food or routine only if it suits your body.',
        'Do 5 minutes of deep breathing.',
        'For medical concerns, consult a qualified doctor.',
      ],
    ),
    _DesiRemedy(
      title: 'Nazar Utarna Ritual',
      category: 'Protection',
      icon: Icons.shield_rounded,
      timing: 'Saturday evening',
      shortText: 'Traditional family practice for nazar and heavy energy.',
      steps: [
        'Take rock salt and mustard seeds in your hand.',
        'Rotate gently around the person 3 or 7 times.',
        'Discard outside the home safely.',
        'Keep the mood calm and avoid fear-based thinking.',
      ],
    ),
    _DesiRemedy(
      title: 'Study & Exam Clarity',
      category: 'Career',
      icon: Icons.menu_book_rounded,
      timing: 'Before study',
      shortText: 'For students who need focus and confidence.',
      steps: [
        'Clean the study table.',
        'Light incense or sit near natural light.',
        'Chant Saraswati mantra 11 times.',
        'Study in 25-minute blocks with short breaks.',
      ],
    ),
    _DesiRemedy(
      title: 'Evening Cleansing Path',
      category: 'Protection',
      icon: Icons.nightlight_round,
      timing: 'After sunset',
      shortText: 'A calming close-of-day routine for the home.',
      steps: [
        'Open windows for a few minutes if possible.',
        'Light camphor or incense safely.',
        'Walk through the main rooms with calm intention.',
        'End with Om Shanti Shanti Shanti.',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final visibleRemedies = _selectedCategory == 'All'
        ? _remedies
        : _remedies
            .where((remedy) => remedy.category == _selectedCategory)
            .toList();

    return Scaffold(
      backgroundColor: AppTheme.divineBackground,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildCategoryChips()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              sliver: SliverList.separated(
                itemCount: visibleRemedies.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  return _RemedyPracticeCard(remedy: visibleRemedies[index]);
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 90)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Desi Remedies',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 34,
              height: 1,
              letterSpacing: -1,
              fontWeight: FontWeight.w800,
              color: AppTheme.divineInk,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            height: 184,
            decoration: BoxDecoration(
              color: AppTheme.divineInk,
              borderRadius: BorderRadius.circular(34),
              boxShadow: AppTheme.cardShadow,
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  right: -40,
                  top: -34,
                  child: Container(
                    width: 210,
                    height: 210,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.divineGold.withOpacity(0.14),
                      border: Border.all(color: Colors.white10),
                    ),
                  ),
                ),
                Positioned(
                  right: 34,
                  top: 52,
                  child: Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.22),
                      border: Border.all(
                        color: AppTheme.divineGold.withOpacity(0.5),
                      ),
                    ),
                    child: const Icon(
                      Icons.local_fire_department_rounded,
                      color: AppTheme.divineGoldLight,
                      size: 34,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Pooja path aur ghar ke upay',
                        style: GoogleFonts.caveat(
                          color: AppTheme.divineGoldLight,
                          fontSize: 26,
                          height: 0.95,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 240,
                        child: Text(
                          'Simple remedies for vastu, relation, paisa, career, health, nazar and daily shanti.',
                          style: GoogleFonts.outfit(
                            color: Colors.white.withOpacity(0.84),
                            fontSize: 15,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'These are cultural and devotional practices. For medical, legal, financial, or emergency problems, consult a qualified professional.',
            style: GoogleFonts.outfit(
              color: AppTheme.textGrey,
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          return ChoiceChip(
            label: Text(category),
            selected: isSelected,
            onSelected: (_) => setState(() => _selectedCategory = category),
            selectedColor: AppTheme.divineGold,
            backgroundColor: AppTheme.elevatedSurface,
            showCheckmark: false,
            labelStyle: GoogleFonts.outfit(
              color: isSelected ? AppTheme.divineInk : AppTheme.textGrey,
              fontWeight: FontWeight.w700,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(99),
              side: BorderSide(
                color: isSelected
                    ? AppTheme.divineGold
                    : AppTheme.divineInk.withOpacity(0.10),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RemedyPracticeCard extends StatelessWidget {
  final _DesiRemedy remedy;

  const _RemedyPracticeCard({required this.remedy});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.elevatedSurface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppTheme.divineInk.withOpacity(0.08)),
        boxShadow: AppTheme.softShadow,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          iconColor: AppTheme.divineInk,
          collapsedIconColor: AppTheme.textGrey,
          leading: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.divineInk,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.divineGold.withOpacity(0.35)),
            ),
            child: Icon(
              remedy.icon,
              color: AppTheme.divineGoldLight,
              size: 26,
            ),
          ),
          title: Text(
            remedy.title,
            style: GoogleFonts.outfit(
              color: AppTheme.divineInk,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  remedy.shortText,
                  style: GoogleFonts.outfit(
                    color: AppTheme.textGrey,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _SmallPill(label: remedy.category),
                    _SmallPill(label: remedy.timing),
                  ],
                ),
              ],
            ),
          ),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How to do it',
                  style: GoogleFonts.outfit(
                    color: AppTheme.divineInk,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                ...remedy.steps.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: AppTheme.divineGold,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${entry.key + 1}',
                            style: GoogleFonts.outfit(
                              color: AppTheme.divineInk,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: GoogleFonts.outfit(
                              color: AppTheme.textGrey,
                              fontSize: 14,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallPill extends StatelessWidget {
  final String label;

  const _SmallPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.divineGold.withOpacity(0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          color: AppTheme.sacredCopper,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _DesiRemedy {
  final String title;
  final String category;
  final IconData icon;
  final String timing;
  final String shortText;
  final List<String> steps;

  const _DesiRemedy({
    required this.title,
    required this.category,
    required this.icon,
    required this.timing,
    required this.shortText,
    required this.steps,
  });
}
