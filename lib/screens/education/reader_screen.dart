import 'package:flutter/material.dart';
import 'dart:io';
import '../../core/theme/app_theme.dart';
import '../../features/education/models/scripture_model.dart';
import '../../features/education/services/scripture_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class ReaderScreen extends StatefulWidget {
  final String title;
  final int chapterNumber;
  final String scriptureId; // Added to distinguish scriptures
  
  const ReaderScreen({
    super.key,
    required this.title,
    required this.chapterNumber,
    required this.scriptureId,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final ScriptureRepository _repository = ScriptureRepository();
  late Future<ScriptureChapter> _chapterFuture;
  bool _isCompleted = false;
  
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;
  String _selectedSpeechLanguage = 'hi-IN'; // Default to Hindi
  String _selectedTextLanguage = 'en'; // Default to English
  List<String> _availableLanguages = [];

  @override
  void initState() {
    super.initState();
    _chapterFuture = _repository.getChapter(widget.scriptureId, widget.chapterNumber);
    _checkCompletionStatus();
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      // Get available languages
      final languages = await _flutterTts.getLanguages;
      if (languages != null) {
        setState(() {
          _availableLanguages = List<String>.from(languages);
        });
      }
      
      await _flutterTts.setLanguage(_selectedSpeechLanguage);
      await _flutterTts.setSpeechRate(0.4);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setStartHandler(() {
        setState(() {
          _isPlaying = true;
        });
      });

      _flutterTts.setCompletionHandler(() {
        setState(() {
          _isPlaying = false;
        });
      });

      _flutterTts.setErrorHandler((msg) {
        setState(() {
          _isPlaying = false;
        });
        debugPrint("TTS Error: $msg");
      });

    } catch (e) {
      debugPrint("TTS init error: $e");
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _checkCompletionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final String key = 'completed_chapters_${widget.scriptureId}';
    final completed = prefs.getStringList(key) ?? [];
    if (completed.contains(widget.chapterNumber.toString())) {
      setState(() {
        _isCompleted = true;
      });
    }
  }

  Future<void> _markAsComplete() async {
    final prefs = await SharedPreferences.getInstance();
    final String key = 'completed_chapters_${widget.scriptureId}';
    final completed = prefs.getStringList(key) ?? [];
    if (!completed.contains(widget.chapterNumber.toString())) {
      completed.add(widget.chapterNumber.toString());
      await prefs.setStringList(key, completed);
      setState(() {
        _isCompleted = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chapter marked as complete!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isYogaSutras = widget.scriptureId == 'yoga_sutras';
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title} - Ch ${widget.chapterNumber}'),
        backgroundColor: AppTheme.primaryOrange,
        actions: isYogaSutras
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TextButton.icon(
                    onPressed: () => context.push('/education/yoga-poses'),
                    icon: const Icon(Icons.self_improvement, size: 20, color: Colors.white),
                    label: const Text('Yoga Poses', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ]
            : null,
      ),
      body: FutureBuilder<ScriptureChapter>(
        future: _chapterFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading chapter: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Chapter not found.'));
          }

          final chapter = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: chapter.verses.length + 2, // +1 for header, +1 for completion button
                  separatorBuilder: (_, index) {
                    if (index == 0) return const SizedBox.shrink(); // No separator after header
                    return const Divider(height: 32, indent: 16, endIndent: 16);
                  },
                  itemBuilder: (context, index) {
                    // First item is the header
                    if (index == 0) {
                      return Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppTheme.yellowPrimary.withValues(alpha: 0.1),
                        ),
                        child: Column(
                          children: [
                            _buildChapterImage(),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Text(
                                    chapter.translation,
                                    style: GoogleFonts.architectsDaughter(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: AppTheme.textBlack,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    chapter.summary,
                                    style: GoogleFonts.patrickHand(
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                      color: AppTheme.neutralDark,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    // Last item is the completion button
                    if (index == chapter.verses.length + 1) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton.icon(
                          onPressed: _isCompleted ? null : _markAsComplete,
                          icon: Icon(_isCompleted ? Icons.check_circle : Icons.check_circle_outline),
                          label: Text(_isCompleted ? 'Chapter Completed' : 'Mark as Complete'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isCompleted ? Colors.green : AppTheme.primaryOrange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      );
                    }
                    
                    // Verses
                    final verse = chapter.verses[index - 1];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildVerseCard(verse),
                    );
                  },
                ),
              ),
              
              // Audio Player Controls
              _buildAudioControls(chapter),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChapterImage() {
    // Determine image path based on scripture and chapter
    String? localImagePath;
    
    // Check known generated images
    if (widget.scriptureId == 'gita') {
      if (widget.chapterNumber == 3) localImagePath = '/Users/harshdev/.gemini/antigravity/brain/c79219d8-76b6-4913-bfa5-194e94777507/gita_ch3_illustration.png';
      if (widget.chapterNumber == 4) localImagePath = '/Users/harshdev/.gemini/antigravity/brain/c79219d8-76b6-4913-bfa5-194e94777507/gita_ch4_illustration.png';
      // Mappings for placeholders for other chapters
    } else if (widget.scriptureId == 'yoga_sutras') {
       if (widget.chapterNumber == 2) localImagePath = '/Users/harshdev/.gemini/antigravity/brain/c79219d8-76b6-4913-bfa5-194e94777507/yoga_ch2_illustration.png';
    }

    if (localImagePath != null && File(localImagePath).existsSync()) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppTheme.textBlack.withOpacity(0.1))),
        ),
        child: Image.file(
          File(localImagePath),
          fit: BoxFit.cover,
        ),
      );
    }

    // Default placeholder or icon if no image
    return Container(
      height: 120,
      width: double.infinity,
      color: AppTheme.primaryOrange.withOpacity(0.05),
      child: Center(
        child: Icon(
          Icons.auto_stories,
          size: 48,
          color: AppTheme.primaryOrange.withOpacity(0.2),
        ),
      ),
    );
  }

  Widget _buildVerseCard(ScriptureVerse verse) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Verse ${verse.number}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            Row(
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.bookmark_border, size: 20)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.share, size: 20)),
              ],
            )
          ],
        ),
        const SizedBox(height: 12),
        Text(
          verse.sanskrit,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryOrange,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
         const SizedBox(height: 8),
         Text(
          verse.transliteration,
          style: const TextStyle(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          verse.userLanguage,
          style: const TextStyle(
            fontSize: 16,
            color: AppTheme.textDark,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        ExpansionTile(
          title: const Text('Word Meanings', style: TextStyle(fontSize: 14, color: Colors.grey)),
          children: [
             Padding(
               padding: const EdgeInsets.all(8.0),
               child: Text(verse.meaning, style: const TextStyle(fontSize: 14)),
             ),
          ],
        ),
      ],
    );
  }

  Future<void> _speakChapter(ScriptureChapter chapter) async {
    if (_isPlaying) {
      await _flutterTts.stop();
      setState(() {
        _isPlaying = false;
      });
    } else {
      // Concatenate all verses for continuous play
      String textToSpeak = "${chapter.title}. ${chapter.translation}. ";
      for (var verse in chapter.verses) {
        textToSpeak += "Verse ${verse.number}. ${verse.sanskrit}. ${verse.userLanguage}. ";
      }
      
      await _flutterTts.speak(textToSpeak);
    }
  }

  Widget _buildAudioControls(ScriptureChapter chapter) {
    // Check if it's a multi-chapter scripture (Bhagavad Gita or Yoga Sutras)
    final bool isGita = widget.scriptureId == 'gita';
    final bool isYoga = widget.scriptureId == 'yoga_sutras';
    final bool isMultiChapter = isGita || isYoga;
    
    // Limits (Gita has 18 chapters, Yoga has 4)
    final int maxChapters = isGita ? 18 : (isYoga ? 4 : 1);
    final bool hasNext = isMultiChapter && widget.chapterNumber < maxChapters;
    final bool hasPrev = isMultiChapter && widget.chapterNumber > 1;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Previous Button
              Opacity(
                opacity: hasPrev ? 1.0 : 0.3,
                child: Column(
                  children: [
                    IconButton(
                      onPressed: hasPrev ? () => _navigateToChapter(widget.chapterNumber - 1) : null,
                      icon: const Icon(Icons.arrow_back_ios, size: 20),
                      visualDensity: VisualDensity.compact,
                    ),
                    Text('Prev', style: GoogleFonts.patrickHand(fontSize: 12)),
                  ],
                ),
              ),
              
              // Center Controls
              Row(
                children: [
                  // Speech Language Selector
                  IconButton(
                    onPressed: () => _showSpeechLanguageSelector(), 
                    icon: const Icon(Icons.record_voice_over, color: Colors.grey, size: 24),
                    tooltip: 'Speech Language',
                  ),
                  const SizedBox(width: 8),
                  // Play/Pause Button
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.primaryOrange,
                    child: IconButton(
                      iconSize: 32,
                      onPressed: () => _speakChapter(chapter), 
                      icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Text Language Selector
                  IconButton(
                    onPressed: () => _showTextLanguageSelector(), 
                    icon: const Icon(Icons.translate, color: Colors.grey, size: 24),
                    tooltip: 'Text Language',
                  ),
                ],
              ),

              // Next Button
              Opacity(
                opacity: hasNext ? 1.0 : 0.3,
                child: Column(
                  children: [
                    IconButton(
                      onPressed: hasNext ? () => _navigateToChapter(widget.chapterNumber + 1) : null,
                      icon: const Icon(Icons.arrow_forward_ios, size: 20),
                      visualDensity: VisualDensity.compact,
                    ),
                    Text('Next', style: GoogleFonts.patrickHand(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSpeechLanguageSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Speech Language',
                style: GoogleFonts.architectsDaughter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: _getSpeechLanguageOptions(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _getSpeechLanguageOptions() {
    final commonLanguages = {
      'hi-IN': 'Hindi (India)',
      'sa-IN': 'Sanskrit (India)',
      'en-US': 'English (US)',
      'en-GB': 'English (UK)',
      'en-IN': 'English (India)',
      'ta-IN': 'Tamil (India)',
      'te-IN': 'Telugu (India)',
      'mr-IN': 'Marathi (India)',
      'bn-IN': 'Bengali (India)',
      'gu-IN': 'Gujarati (India)',
      'kn-IN': 'Kannada (India)',
      'ml-IN': 'Malayalam (India)',
      'pa-IN': 'Punjabi (India)',
      'es-ES': 'Spanish (Spain)',
      'fr-FR': 'French (France)',
      'de-DE': 'German (Germany)',
      'it-IT': 'Italian (Italy)',
      'pt-BR': 'Portuguese (Brazil)',
      'ru-RU': 'Russian (Russia)',
      'ja-JP': 'Japanese (Japan)',
      'zh-CN': 'Chinese (Simplified)',
      'ar-SA': 'Arabic (Saudi Arabia)',
    };

    return commonLanguages.entries.map((entry) {
      final isSelected = _selectedSpeechLanguage == entry.key;
      final isAvailable = _availableLanguages.contains(entry.key);
      
      return ListTile(
        leading: Icon(
          Icons.record_voice_over,
          color: isSelected ? AppTheme.primaryOrange : Colors.grey,
        ),
        title: Text(
          entry.value,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isAvailable ? Colors.black : Colors.grey,
          ),
        ),
        trailing: isSelected ? const Icon(Icons.check, color: AppTheme.primaryOrange) : null,
        enabled: isAvailable,
        onTap: isAvailable ? () async {
          setState(() {
            _selectedSpeechLanguage = entry.key;
          });
          await _flutterTts.setLanguage(entry.key);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Speech language: ${entry.value}'),
              duration: const Duration(seconds: 2),
            ),
          );
        } : null,
      );
    }).toList();
  }

  void _showTextLanguageSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Text Language',
                style: GoogleFonts.architectsDaughter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Note: Text translations are currently in English. More languages coming soon!',
                style: GoogleFonts.patrickHand(
                  fontSize: 14,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.translate, color: AppTheme.primaryOrange),
                title: const Text('English', style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.check, color: AppTheme.primaryOrange),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.translate, color: Colors.grey),
                title: const Text('Hindi', style: TextStyle(color: Colors.grey)),
                subtitle: const Text('Coming soon', style: TextStyle(fontSize: 12)),
                enabled: false,
              ),
              ListTile(
                leading: const Icon(Icons.translate, color: Colors.grey),
                title: const Text('Tamil', style: TextStyle(color: Colors.grey)),
                subtitle: const Text('Coming soon', style: TextStyle(fontSize: 12)),
                enabled: false,
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToChapter(int newChapter) {
    context.pushReplacement(
      Uri(
        path: '/education/reader/${widget.scriptureId}',
        queryParameters: {
          'title': widget.title,
          'chapter': newChapter.toString(),
        },
      ).toString(),
    );
  }
}
