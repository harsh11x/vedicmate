import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../widgets/lagna_chart.dart';
import '../../../../widgets/navamsha_chart.dart';
import '../../../../widgets/moon_chart.dart';
import '../../../../widgets/chalit_chart.dart';

class KundliChartWidget extends StatelessWidget {
  final String title;
  final String chartType;
  final String? lagnaSign;
  final Map<int, String>? houses;
  final Map<String, String>? planets;

  const KundliChartWidget({
    super.key,
    required this.title,
    required this.chartType,
    this.lagnaSign,
    this.houses,
    this.planets,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getBorderColor().withOpacity(0.3)),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_getChartIcon(), size: 18, color: _getBorderColor()),
              const SizedBox(width: 8),
              Text(
                title, 
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 16,
                  color: _getBorderColor(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 1,
            child: _buildChart(),
          ),
          const SizedBox(height: 8),
          Text(
            _getChartDescription(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: AppTheme.neutralGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    switch (chartType) {
      case 'Lagna':
        return LagnaChart(
          lagnaSign: lagnaSign ?? 'Aries',
          houses: houses ?? _getLagnaHouses(),
          planets: planets ?? _getLagnaPlanets(),
        );
      case 'Navamsha':
        return NavamshaChart(
          lagnaSign: lagnaSign ?? 'Libra', // Default fallback
          houses: houses ?? _getNavamshaHouses(),
          planets: planets ?? _getNavamshaPlanets(),
        );
      case 'Moon':
        return MoonChart(
          moonSign: lagnaSign ?? 'Cancer', // Reusing lagnaSign param as main sign
          houses: houses ?? _getMoonHouses(),
          planets: planets ?? _getMoonPlanets(),
        );
      case 'Chalit':
        return const ChalitChart(
          lagnaSign: 'Aries',
          lagnaDegree: 15.5,
        );
      default:
        return LagnaChart();
    }
  }

  Color _getBorderColor() {
    switch (chartType) {
      case 'Lagna':
        return AppTheme.divineGold;
      case 'Navamsha':
        return AppTheme.mysticalPurple;
      case 'Moon':
        return const Color(0xFF1565C0); // Moon Blue
      case 'Chalit':
        return const Color(0xFF2E7D32); // Chalit Green
      default:
        return AppTheme.divineGold;
    }
  }

  IconData _getChartIcon() {
    switch (chartType) {
      case 'Lagna':
        return Icons.star;
      case 'Navamsha':
        return Icons.grid_4x4;
      case 'Moon':
        return Icons.nightlight_round;
      case 'Chalit':
        return Icons.radio_button_unchecked;
      default:
        return Icons.auto_awesome;
    }
  }

  String _getChartDescription() {
    switch (chartType) {
      case 'Lagna':
        return 'D-1: Birth Chart showing ascendant and planetary positions';
      case 'Navamsha':
        return 'D-9: Reveals marriage, inner potential & destiny';
      case 'Moon':
        return 'Chandra Lagna: Emotional nature & mental state';
      case 'Chalit':
        return 'Bhava Chalit: True house positions based on cusps';
      default:
        return '';
    }
  }

  // Mock data methods - in real app, these would come from calculation service
  Map<int, String> _getLagnaHouses() {
    return {
      1: 'Ari', 2: 'Tau', 3: 'Gem', 4: 'Can',
      5: 'Leo', 6: 'Vir', 7: 'Lib', 8: 'Sco',
      9: 'Sag', 10: 'Cap', 11: 'Aqu', 12: 'Pis',
    };
  }

  Map<String, String> _getLagnaPlanets() {
    return {
      'Sun': 'Leo 15°', 'Moon': 'Cancer 22°', 'Mars': 'Aries 8°',
      'Mercury': 'Virgo 12°', 'Jupiter': 'Sagittarius 18°', 'Venus': 'Libra 25°',
      'Saturn': 'Capricorn 10°', 'Rahu': 'Pisces 5°', 'Ketu': 'Virgo 5°',
    };
  }

  Map<int, String> _getNavamshaHouses() {
    return {
      1: 'Lib', 2: 'Sco', 3: 'Sag', 4: 'Cap',
      5: 'Aqu', 6: 'Pis', 7: 'Ari', 8: 'Tau',
      9: 'Gem', 10: 'Can', 11: 'Leo', 12: 'Vir',
    };
  }

  Map<String, String> _getNavamshaPlanets() {
    return {
      'Sun': 'Libra 5°', 'Moon': 'Taurus 12°', 'Mars': 'Capricorn 28°',
      'Mercury': 'Virgo 2°', 'Jupiter': 'Cancer 15°', 'Venus': 'Pisces 20°',
      'Saturn': 'Libra 10°', 'Rahu': 'Gemini 8°', 'Ketu': 'Sagittarius 8°',
    };
  }

  Map<int, String> _getMoonHouses() {
    return {
      1: 'Can', 2: 'Leo', 3: 'Vir', 4: 'Lib',
      5: 'Sco', 6: 'Sag', 7: 'Cap', 8: 'Aqu',
      9: 'Pis', 10: 'Ari', 11: 'Tau', 12: 'Gem',
    };
  }

  Map<String, String> _getMoonPlanets() {
    return {
      'Sun': 'Leo 15°', 'Moon': 'Cancer 22°', 'Mars': 'Scorpio 8°',
      'Mercury': 'Virgo 12°', 'Jupiter': 'Pisces 18°', 'Venus': 'Taurus 25°',
      'Saturn': 'Aquarius 10°', 'Rahu': 'Gemini 5°', 'Ketu': 'Sagittarius 5°',
    };
  }
}
