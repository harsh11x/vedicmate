import 'package:supabase_flutter/supabase_flutter.dart';

class HabitRepository {
  final SupabaseClient _supabase;

  HabitRepository(this._supabase);

  // --- Habits ---

  Future<List<Map<String, dynamic>>> getHabits(String userId) async {
    final response = await _supabase
        .from('habits')
        .select()
        .eq('user_id', userId)
        .eq('is_archived', false)
        .order('created_at');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> createHabit({
    required String userId,
    required String title,
    String? description,
    required String category,
    String frequency = 'daily',
  }) async {
    final response = await _supabase.from('habits').insert({
      'user_id': userId,
      'title': title,
      'description': description,
      'category': category,
      'frequency': frequency,
    }).select().single();
    return response;
  }

  Future<void> archiveHabit(String habitId) async {
    await _supabase
        .from('habits')
        .update({'is_archived': true})
        .eq('id', habitId);
  }

  // --- Logs ---

  Future<List<Map<String, dynamic>>> getHabitLogs({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Join not directly supported in simple select for this structure easily without views, 
    // but we can fetch logs for habits owned by user.
    // Better: Fetch logs where habit_id is in (fetch user habits) OR 
    // if RLS is set up, just fetch all logs and filter by date.
    // Assuming RLS allows users to see their own logs via habit relationship or direct user_id on log (schema didn't have user_id on log, only habit_id).
    // We strictly rely on relation: log -> habit -> user.
    
    // For performance, simpler to fetch logs for specific habits or just fetch 'habit_logs' 
    // and let RLS filter if we had RLS on joins. 
    // Since we didn't put user_id on habit_logs, we query:
    
    final habits = await getHabits(userId);
    if (habits.isEmpty) return [];
    
    final habitIds = habits.map((h) => h['id']).toList();

    final response = await _supabase
        .from('habit_logs')
        .select()
        .in_('habit_id', habitIds)
        .gte('completed_at', startDate.toIso8601String().split('T')[0])
        .lte('completed_at', endDate.toIso8601String().split('T')[0]);
        
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> logHabitCompletion({
    required String habitId,
    required DateTime date,
    String? notes,
    int? rating,
  }) async {
    final dateStr = date.toIso8601String().split('T')[0];
    
    await _supabase.from('habit_logs').upsert({
      'habit_id': habitId,
      'completed_at': dateStr,
      'notes': notes,
      'rating': rating,
    }, onConflict: 'habit_id, completed_at'); 
  }

  Future<void> deleteHabitLog(String logId) async {
    await _supabase.from('habit_logs').delete().eq('id', logId);
  }
  
  Future<void> removeLogForDate({required String habitId, required DateTime date}) async {
      final dateStr = date.toIso8601String().split('T')[0];
      await _supabase.from('habit_logs')
        .delete()
        .eq('habit_id', habitId)
        .eq('completed_at', dateStr);
  }
}
