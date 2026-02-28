import 'package:astroapp/services/astronomy/astronomy_service.dart';

void main() {
  final service = AstronomyService();
  
  // Test Date: 2000-01-01 12:00 PM UTC
  final testDate = DateTime.utc(2000, 1, 1, 12, 0);
  final lat = 28.6139; // New Delhi
  final lng = 77.2090;
  
  print('--- Verifying Charts for $testDate ---');
  
  final planets = service.calculatePlanetaryPositions(
    dateTime: testDate, 
    latitude: lat, 
    longitude: lng
  );
  
  final sunData = planets['Sun'];
  final ascendant = service.calculateAscendant(
    dateTime: testDate, 
    latitude: lat, 
    longitude: lng, 
    sunData: sunData
  );

  print('Lagna (D-1): ${ascendant['rashi']} (${ascendant['degree']}°)');
  print('Navamsa (D-9): ${ascendant['navamsa']}');
  print('Dasamsa (D-10): ${ascendant['dasamsa']}');
  
  print('\nPlanets:');
  planets.forEach((key, value) {
    print('$key:');
    print('  D-1: ${value['rashi']} ${value['degree']}°');
    print('  D-9: ${value['navamsa']}');
    print('  D-10: ${value['dasamsa']}');
  });
  
  // Simple check
  if (ascendant['rashi'] != null && ascendant['navamsa'] != null) {
    print('\n[SUCCESS] Chart calculations returned valid data structure.');
  } else {
    print('\n[FAILURE] Chart calculations returned null or invalid data.');
  }
}
