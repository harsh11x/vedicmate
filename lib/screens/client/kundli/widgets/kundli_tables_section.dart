import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class KundliTablesSection extends StatelessWidget {
  const KundliTablesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTableCard("Planetary Details", [
            ["Planet", "Rashi", "Degree", "Nakshatra"],
            ["Sun", "Leo", "15°22'", "P.Phalguni"],
            ["Moon", "Cancer", "22°10'", "Ashlesha"],
            ["Mars", "Aries", "08°45'", "Ashwini"],
            ["Mercury", "Virgo", "12°30'", "Hasta"],
            ["Jupiter", "Sagittarius", "18°15'", "P.Ashadha"],
            ["Venus", "Libra", "25°40'", "Vishakha"],
            ["Saturn", "Capricorn", "10°05'", "Shravana"],
             ["Rahu", "Pisces", "05°12'", "U.Bhadra"],
            ["Ketu", "Virgo", "05°12'", "U.Phalguni"],
          ]),
          const SizedBox(height: 20),
          _buildTableCard("Ashtakvarga Points", [
             ["Sign", "Sun", "Moon", "Mars", "Merc", "Jup", "Ven", "Sat", "Total"],
             ["Aries", "4", "5", "3", "5", "4", "5", "3", "29"],
             ["Taurus", "5", "4", "3", "4", "5", "4", "3", "28"],
             // Mock data truncated
             ["Gemini", "3", "6", "4", "5", "4", "5", "2", "29"], 
          ]),
           const SizedBox(height: 20),
           _buildTableCard("Vimshottari Dasha", [
               ["Planet", "Start Date", "End Date"],
               ["Mercury", "10-05-2020", "10-05-2037"],
               ["Ketu", "10-05-2037", "10-05-2044"],
               ["Venus", "10-05-2044", "10-05-2064"],
           ]),
        ],
      ),
    );
  }

  Widget _buildTableCard(String title, List<List<String>> data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(AppTheme.primaryOrange.withOpacity(0.1)),
              columns: data[0].map((e) => DataColumn(label: Text(e, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
              rows: data.sublist(1).map((row) {
                return DataRow(cells: row.map((cell) => DataCell(Text(cell))).toList());
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
