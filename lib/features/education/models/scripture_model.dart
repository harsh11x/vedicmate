class ScriptureVerse {
  final String id;
  final int number;
  final String sanskrit;
  final String userLanguage; // Translation in user's language (e.g., English)
  final String transliteration;
  final String meaning; // detailed word-for-word or commentary

  ScriptureVerse({
    required this.id,
    required this.number,
    required this.sanskrit,
    required this.userLanguage,
    required this.transliteration,
    required this.meaning,
  });

  factory ScriptureVerse.fromJson(Map<String, dynamic> json) {
    return ScriptureVerse(
      id: json['id'] as String,
      number: json['number'] as int,
      sanskrit: json['sanskrit'] as String,
      userLanguage: json['translation'] as String,
      transliteration: json['transliteration'] as String? ?? '',
      meaning: json['meaning'] as String? ?? '',
    );
  }
}

class ScriptureChapter {
  final int number;
  final String title; // Sanskrit title
  final String translation; // English title
  final String summary;
  final List<ScriptureVerse> verses;

  ScriptureChapter({
    required this.number,
    required this.title,
    required this.translation,
    required this.summary,
    required this.verses,
  });

  factory ScriptureChapter.fromJson(Map<String, dynamic> json) {
    return ScriptureChapter(
      number: json['chapter_number'] as int,
      title: json['title'] as String,
      translation: json['translation'] as String,
      summary: json['summary'] as String,
      verses: (json['verses'] as List<dynamic>)
          .map((v) => ScriptureVerse.fromJson(v))
          .toList(),
    );
  }
}
