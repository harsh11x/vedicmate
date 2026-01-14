import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';

class LanguageSelector extends StatefulWidget {
  final Function(String, String) onLanguageSelected;
  final String initialLanguageCode;
  final bool isDark;

  const LanguageSelector({
    super.key,
    required this.onLanguageSelected,
    this.initialLanguageCode = 'en',
    this.isDark = false,
  });

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  late String _selectedLanguageCode;
  
  // Map of language codes to native names and English names
  final Map<String, Map<String, String>> _languages = {
    'en': {'name': 'English', 'native': 'English'},
    'hi': {'name': 'Hindi', 'native': 'हिन्दी'},
    'as': {'name': 'Assamese', 'native': 'অসমীয়া'},
    'bn': {'name': 'Bengali', 'native': 'বাংলা'},
    'brx': {'name': 'Bodo', 'native': 'बड़ो'},
    'doi': {'name': 'Dogri', 'native': 'डोगरी'},
    'gu': {'name': 'Gujarati', 'native': 'ગુજરાતી'},
    'kn': {'name': 'Kannada', 'native': 'ಕನ್ನಡ'},
    'ks': {'name': 'Kashmiri', 'native': 'कॉशुर'},
    'kok': {'name': 'Konkani', 'native': 'कोंकणी'},
    'mai': {'name': 'Maithili', 'native': 'मैथिली'},
    'ml': {'name': 'Malayalam', 'native': 'മലയാളം'},
    'mni': {'name': 'Manipuri', 'native': 'ꯃꯤꯇꯩ ꯂꯣꯟ'},
    'mr': {'name': 'Marathi', 'native': 'मराठी'},
    'ne': {'name': 'Nepali', 'native': 'नेपाली'},
    'or': {'name': 'Odia', 'native': 'ଓଡ଼ିଆ'},
    'pa': {'name': 'Punjabi', 'native': 'ਪੰਜਾਬੀ'},
    'sa': {'name': 'Sanskrit', 'native': 'संस्कृतम्'},
    'sat': {'name': 'Santali', 'native': 'ᱥᱟᱱᱛᱟᱲᱤ'},
    'sd': {'name': 'Sindhi', 'native': 'सिन्धी'},
    'ta': {'name': 'Tamil', 'native': 'தமிழ்'},
    'te': {'name': 'Telugu', 'native': 'తెలుగు'},
    'ur': {'name': 'Urdu', 'native': 'اردو'},
  };

  @override
  void initState() {
    super.initState();
    _selectedLanguageCode = widget.initialLanguageCode;
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString('selected_ai_language');
    if (savedLang != null && _languages.containsKey(savedLang)) {
      setState(() {
        _selectedLanguageCode = savedLang;
      });
      // Notify parent about the loaded language
      widget.onLanguageSelected(savedLang, _languages[savedLang]!['name']!);
    }
  }

  Future<void> _saveLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_ai_language', code);
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      initialValue: _selectedLanguageCode,
      onSelected: (String newValue) {
        setState(() {
          _selectedLanguageCode = newValue;
        });
        _saveLanguage(newValue);
        widget.onLanguageSelected(newValue, _languages[newValue]!['name']!);
        
        // Show confirmation snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Language changed to ${_languages[newValue]!['name']} (${_languages[newValue]!['native']})',
              style: GoogleFonts.outfit(),
            ),
            backgroundColor: AppTheme.primaryOrange,
            duration: const Duration(seconds: 1),
          ),
        );
      },
      itemBuilder: (BuildContext context) {
        return _languages.entries.map((entry) {
          return PopupMenuItem<String>(
            value: entry.key,
            child: Row(
              children: [
                Text(
                  entry.value['native']!,
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.neutralDark,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${entry.value['name']})',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: AppTheme.neutralMedium,
                  ),
                ),
                if (_selectedLanguageCode == entry.key) ...[
                  const Spacer(),
                  const Icon(Icons.check, color: AppTheme.primaryOrange, size: 16),
                ],
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: widget.isDark ? Colors.white.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.isDark ? Colors.white.withOpacity(0.2) : AppTheme.primaryOrange.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.language,
              size: 16,
              color: widget.isDark ? Colors.white : AppTheme.primaryOrange,
            ),
            const SizedBox(width: 6),
            Text(
              _selectedLanguageCode.toUpperCase(),
              style: GoogleFonts.outfit(
                color: widget.isDark ? Colors.white : AppTheme.neutralDark,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: widget.isDark ? Colors.white.withOpacity(0.7) : AppTheme.neutralMedium,
            ),
          ],
        ),
      ),
    );
  }
}
