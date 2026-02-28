import 'package:supabase_flutter/supabase_flutter.dart';

class ScriptureRepository {
  final SupabaseClient _supabase;

  ScriptureRepository(this._supabase);

  Future<List<Map<String, dynamic>>> getAllScriptures() async {
    final response = await _supabase
        .from('scriptures')
        .select()
        .order('title_en');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> getScriptureDetails(String scriptureId) async {
    final response = await _supabase
        .from('scriptures')
        .select('*, scripture_chapters(*)')
        .eq('id', scriptureId)
        .single();
    return response;
  }

  Future<List<Map<String, dynamic>>> getChapterVerses(String chapterId) async {
    final response = await _supabase
        .from('scripture_verses')
        .select()
        .eq('chapter_id', chapterId)
        .order('verse_number');
    return List<Map<String, dynamic>>.from(response);
  }
}
