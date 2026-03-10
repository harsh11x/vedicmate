/// Country codes for phone number input
class CountryCode {
  final String code;      // e.g. IN, US
  final String dialCode;  // e.g. +91, +1
  final String name;      // e.g. India, United States

  const CountryCode({required this.code, required this.dialCode, required this.name});

  @override
  String toString() => '$dialCode ($code)';
}

/// Common country codes - India first, then others alphabetically
const List<CountryCode> countryCodes = [
  CountryCode(code: 'IN', dialCode: '+91', name: 'India'),
  CountryCode(code: 'US', dialCode: '+1', name: 'United States'),
  CountryCode(code: 'GB', dialCode: '+44', name: 'United Kingdom'),
  CountryCode(code: 'AE', dialCode: '+971', name: 'United Arab Emirates'),
  CountryCode(code: 'AU', dialCode: '+61', name: 'Australia'),
  CountryCode(code: 'BD', dialCode: '+880', name: 'Bangladesh'),
  CountryCode(code: 'CA', dialCode: '+1', name: 'Canada'),
  CountryCode(code: 'DE', dialCode: '+49', name: 'Germany'),
  CountryCode(code: 'FR', dialCode: '+33', name: 'France'),
  CountryCode(code: 'MY', dialCode: '+60', name: 'Malaysia'),
  CountryCode(code: 'NP', dialCode: '+977', name: 'Nepal'),
  CountryCode(code: 'PK', dialCode: '+92', name: 'Pakistan'),
  CountryCode(code: 'SA', dialCode: '+966', name: 'Saudi Arabia'),
  CountryCode(code: 'SG', dialCode: '+65', name: 'Singapore'),
  CountryCode(code: 'LK', dialCode: '+94', name: 'Sri Lanka'),
  CountryCode(code: 'ZA', dialCode: '+27', name: 'South Africa'),
  CountryCode(code: 'OTHER', dialCode: '+', name: 'Other'),
];
