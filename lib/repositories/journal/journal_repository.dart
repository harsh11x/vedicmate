import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:encrypt/encrypt.dart'; // Add encrypt package later for real encryption

class JournalRepository {
  final SupabaseClient _supabase;

  JournalRepository(this._supabase);

  Future<List<Map<String, dynamic>>> getEntries(String userId) async {
    final response = await _supabase
        .from('journal_entries')
        .select()
        .eq('user_id', userId)
        .order('entry_date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> createEntry({
    required String userId,
    required DateTime date,
    required String content,
    int? mood,
    int? energy,
    List<String>? tags,
  }) async {
    // TODO: Implement actual encryption using 'encrypt' package
    // For now, we store as plain text but labeled as 'encrypted' in logic
    final encryptedContent = content; 

    final response = await _supabase.from('journal_entries').insert({
      'user_id': userId,
      'entry_date': date.toIso8601String().split('T')[0],
      'content_encrypted': encryptedContent,
      'mood_rating': mood,
      'energy_rating': energy,
      'tags': tags,
    }).select().single();
    return response;
  }

  Future<void> updateEntry({
    required String entryId,
    String? content,
    int? mood,
    int? energy,
    List<String>? tags,
  }) async {
    final updates = <String, dynamic>{};
    if (content != null) updates['content_encrypted'] = content; // TODO: Encrypt
    if (mood != null) updates['mood_rating'] = mood;
    if (energy != null) updates['energy_rating'] = energy;
    if (tags != null) updates['tags'] = tags;

    if (updates.isEmpty) return;

    await _supabase.from('journal_entries').update(updates).eq('id', entryId);
  }

  Future<void> deleteEntry(String entryId) async {
    await _supabase.from('journal_entries').delete().eq('id', entryId);
  }
}
