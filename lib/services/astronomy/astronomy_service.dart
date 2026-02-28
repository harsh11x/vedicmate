import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:sweph/sweph.dart';

class AstronomyService {
  static final AstronomyService _instance = AstronomyService._internal();
  factory AstronomyService() => _instance;
  AstronomyService._internal();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    
    // Initialize Swiss Ephemeris
    // We need to copy ephe files to a local directory if we want high precision,
    // or use Moshier (no files) which is less precise (~0.1 arcsec) but good for Phase 1.
    // For now, let's try with no path (Moshier fallback) or bundled assets.
    
    // Assuming simple initialization for now.
    // If we have distinct assets, we copy them.
    // await _copyEphemerisFiles();

    // Set ephemeris path to empty string to force Moshier or internal if files not found
    // Or set to the app document directory if we copied files.
    // Sweph.swe_set_ephe_path('path/to/ephe'); 
    
    _isInitialized = true;
  }

  Map<String, dynamic> calculatePlanetaryPositions({
    required DateTime dateTime,
    required double latitude,
    required double longitude,
    String ayanamsa = 'Lahiri', // Default to Lahiri (Chitra Paksha)
  }) {
    if (!_isInitialized) {
      // In a real app, ensure init() is called at startup.
      // For this synchronous method, we might have issues if not init.
      // But Sweph calls are synchronous FFI.
    }

    // Convert DateTime to UTC
    final utc = dateTime.toUtc();
    final double year = utc.year.toDouble();
    final double month = utc.month.toDouble();
    final double day = utc.day.toDouble();
    final double hour = utc.hour + (utc.minute / 60.0) + (utc.second / 3600.0);

    // Calculate Julian Day (UT)
    final double jdUt = Sweph.swe_julday(year.toInt(), month.toInt(), day.toInt(), hour, CalendarType.SE_GREG_CAL);

    // Set Sidereal Mode (Lahiri)
    // Dynamic cast to bypass conflicting type errors for now.
    // Sweph.swe_set_sid_mode(SiderealMode.SE_SIDM_LAHIRI as dynamic, 0, 0);

    // Calculate Planets (0=Sun, 1=Moon, ...)
    // Mock data for UI development
    final planets = {
      'Sun': _toRashiData(0.0, false),
      'Moon': _toRashiData(30.0, false),
      'Mars': _toRashiData(60.0, false),
      'Mercury': _toRashiData(90.0, false),
      'Jupiter': _toRashiData(120.0, false),
      'Venus': _toRashiData(150.0, false),
      'Saturn': _toRashiData(180.0, false),
      'Rahu': _toRashiData(210.0, true), 
      'Ketu': _toRashiData(30.0, true), 
    };

    return planets;
  }

  Map<String, dynamic> _calcPlanet(double jd, HeavenlyBody body) {
    // Flags: SEFLG_SWIEPH (use SE), SEFLG_SIDEREAL (sidereal), SEFLG_SPEED (calc speed)
    final flags = SwephFlag.SEFLG_SWIEPH | SwephFlag.SEFLG_SIDEREAL | SwephFlag.SEFLG_SPEED;
    
    final result = Sweph.swe_calc_ut(jd, body, flags);
    final longitude = result.longitude;
    final speed = result.speedInLongitude; 

    return _toRashiData(longitude, speed < 0);
  }
  
  Map<String, dynamic> _calcKetu(double jd) {
    // Ketu is always 180 degrees from Rahu
    final rahu = _calcPlanet(jd, HeavenlyBody.SE_TRUE_NODE);
    final rahuLong = rahu['longitude'] as double;
    final ketuLong = (rahuLong + 180.0) % 360.0;
    return _toRashiData(ketuLong, true); // Ketu is always retrograde (Mean/True usually)
  }

  Map<String, dynamic> calculateAscendant({
    required DateTime dateTime,
    required double latitude,
    required double longitude,
    required Map<String, dynamic> sunData, // Unused in accurate calc, kept for signature comp
  }) {
     // Convert DateTime to UTC
    final utc = dateTime.toUtc();
    final double year = utc.year.toDouble();
    final double month = utc.month.toDouble();
    final double day = utc.day.toDouble();
    final double hour = utc.hour + (utc.minute / 60.0) + (utc.second / 3600.0);
    
    final double jdUt = Sweph.swe_julday(year.toInt(), month.toInt(), day.toInt(), hour, CalendarType.SE_GREG_CAL);

    // Set Sidereal Mode (Lahiri)
    // SiderealMode is int constant class, SiderealModeFlag is the    // Set Ayanamsa
    // Sweph.swe_set_sid_mode(SiderealMode.SE_SIDM_LAHIRI as dynamic, 0, 0);
    
    // Flags for Houses: Sidereal
    // Using Placidus houses as per Vedic astrology often uses Placidus or Whole Sign.
    
    // Let's get Ayanamsa value
    // final double ayanamsa = Sweph.swe_get_ayanamsa_ut(jdUt);
    
    // Compute Tropical Ascendant using swe_houses
    // final housesResult = Sweph.swe_houses(jdUt, latitude, longitude, Hsys.P); // P = Placidus
    // final double tropicalAscendant = housesResult.ascmc[0];
    
    final double siderealAscendant = 0.0; // Mock (Aries Ascendant)
    
    double finalSiderealAscendant = siderealAscendant;
    if (finalSiderealAscendant < 0) finalSiderealAscendant += 360.0;
    
    return _toRashiData(finalSiderealAscendant, false);
  }

 // ... (Keep _toRashiData and calculateShadbala as they are useful logic on top of raw degrees)
 // But I need to preserve `calculateShadbala`, `_toRashiData` (mostly), `_isExalted` etc.
 // I will paste them back below.
 
   // Helper: Normalize degree
  double _normalizeDegree(double degree) {
    degree = degree % 360;
    if (degree < 0) degree += 360;
    return degree;
  }

  Map<String, dynamic> _toRashiData(double long, bool isRetrograde) {
    long = _normalizeDegree(long);
    final int rashiIndex = (long / 30).floor();
    final double degree = long % 30;
    
    final List<String> rashis = [
      'Mesha (Aries)', 'Vrishabha (Taurus)', 'Mithuna (Gemini)', 'Karka (Cancer)', 
      'Simha (Leo)', 'Kanya (Virgo)', 'Tula (Libra)', 'Vrischika (Scorpio)', 
      'Dhanu (Sagittarius)', 'Makara (Capricorn)', 'Kumbha (Aquarius)', 'Meena (Pisces)'
    ];

    // Nakshatra Calc
    final double nakshatraSpan = 13.333333; // 13 deg 20 min
    final int nakshatraIndex = (long / nakshatraSpan).floor();
    final List<String> nakshatras = [
      'Ashwini', 'Bharani', 'Krittika', 'Rohini', 'Mrigashira', 'Ardra', 
      'Punarvasu', 'Pushya', 'Ashlesha', 'Magha', 'Purva Phalguni', 'Uttara Phalguni',
      'Hasta', 'Chitra', 'Swati', 'Vishakha', 'Anuradha', 'Jyeshtha', 
      'Mula', 'Purva Ashadha', 'Uttara Ashadha', 'Shravana', 'Dhanishta', 
      'Shatabhisha', 'Purva Bhadrapada', 'Uttara Bhadrapada', 'Revati'
    ];
    
    // Navamsa (D-9) Calc
    final double navamsaSpan = 3.333333333;
    final int navamsaIndexRaw = (long / navamsaSpan).floor();
    final int navamsaIndex = navamsaIndexRaw % 12;

    // Dasamsa (D-10) Calc
    final double dasamsaSpan = 3.0; // 30 / 10
    final int dasamsaPart = (degree / dasamsaSpan).floor(); // 0-9
    int dasamsaIndex;
    
    if ((rashiIndex + 1) % 2 != 0) { // Odd
      dasamsaIndex = (rashiIndex + dasamsaPart) % 12;
    } else { // Even
      dasamsaIndex = (rashiIndex + 8 + dasamsaPart) % 12;
    }

    return {
      'rashi': rashis[rashiIndex],
      'rashi_index': rashiIndex + 1, // 1-based
      'degree': double.parse(degree.toStringAsFixed(2)),
      'nakshatra': nakshatras[nakshatraIndex % 27],
      'longitude': long,
      'is_retro': isRetrograde,
      'navamsa': rashis[navamsaIndex],
      'navamsa_index': navamsaIndex + 1, // 1-based
      'dasamsa': rashis[dasamsaIndex],
      'dasamsa_index': dasamsaIndex + 1,
    };
  }
  
  // Kept calculateShadbala and helpers unchanged...
  Map<String, double> calculateShadbala(Map<String, dynamic> planets) {
     Map<String, double> strengths = {};
    planets.forEach((planet, data) {
      double score = 50.0; // Base score
      final rashiIndex = data['rashi_index'];
      
      if (_isExalted(planet, rashiIndex)) {
        score += 30.0;
      } else if (_isDebilitated(planet, rashiIndex)) {
        score -= 20.0;
      } else if (_isOwnSign(planet, rashiIndex)) {
        score += 15.0;
      }
      strengths[planet] = score;
    });
    return strengths;
  }
  
  bool _isExalted(String planet, int rashiIndex) {
    switch (planet) {
      case 'Sun': return rashiIndex == 1; // Aries
      case 'Moon': return rashiIndex == 2; // Taurus
      case 'Mars': return rashiIndex == 10; // Capricorn
      case 'Mercury': return rashiIndex == 6; // Virgo
      case 'Jupiter': return rashiIndex == 4; // Cancer
      case 'Venus': return rashiIndex == 12; // Pisces
      case 'Saturn': return rashiIndex == 7; // Libra
      default: return false;
    }
  }

  bool _isDebilitated(String planet, int rashiIndex) {
    switch (planet) {
      case 'Sun': return rashiIndex == 7; // Libra
      case 'Moon': return rashiIndex == 8; // Scorpio
      case 'Mars': return rashiIndex == 4; // Cancer
      case 'Mercury': return rashiIndex == 12; // Pisces
      case 'Jupiter': return rashiIndex == 10; // Capricorn
      case 'Venus': return rashiIndex == 6; // Virgo
      case 'Saturn': return rashiIndex == 1; // Aries
      default: return false;
    }
  }

  bool _isOwnSign(String planet, int rashiIndex) {
    switch (planet) {
      case 'Sun': return rashiIndex == 5;
      case 'Moon': return rashiIndex == 4;
      case 'Mars': return rashiIndex == 1 || rashiIndex == 8;
      case 'Mercury': return rashiIndex == 3 || rashiIndex == 6;
      case 'Jupiter': return rashiIndex == 9 || rashiIndex == 12;
      case 'Venus': return rashiIndex == 2 || rashiIndex == 7;
      case 'Saturn': return rashiIndex == 10 || rashiIndex == 11;
      default: return false;
    }
  }
}
