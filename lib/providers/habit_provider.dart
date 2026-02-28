import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../repositories/habit/habit_repository.dart';
import 'auth_provider.dart';

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return HabitRepository(Supabase.instance.client);
});

final habitsProvider = StateNotifierProvider<HabitNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  final authState = ref.watch(authStateProvider);
  return HabitNotifier(repository, authState);
});

class HabitNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final HabitRepository _repository;
  final AsyncValue _authState;

  HabitNotifier(this._repository, this._authState) : super(const AsyncValue.loading()) {
    loadHabits();
  }

  Future<void> loadHabits() async {
    final user = _authState.value;
    if (user == null) {
      state = const AsyncValue.data([]);
      return;
    }

    try {
      state = const AsyncValue.loading();
      final habits = await _repository.getHabits(user.uid);
      state = AsyncValue.data(habits);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addHabit({
    required String title,
    String? description,
    required String category,
    String frequency = 'daily',
  }) async {
    final user = _authState.value;
    if (user == null) return;

    try {
      await _repository.createHabit(
        userId: user.uid,
        title: title,
        description: description,
        category: category,
        frequency: frequency,
      );
      await loadHabits();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> archiveHabit(String habitId) async {
    try {
      await _repository.archiveHabit(habitId);
      await loadHabits();
    } catch (e) {
      rethrow;
    }
  }
}

// Provider for fetching logs for a specific date range
final habitLogsProvider = FutureProvider.family<List<Map<String, dynamic>>, Map<String, dynamic>>((ref, params) async {
  final repository = ref.watch(habitRepositoryProvider);
  final authState = ref.watch(authProvider);
  final user = authState.value;
  
  if (user == null) return [];

  final startDate = params['startDate'] as DateTime;
  final endDate = params['endDate'] as DateTime;

  return repository.getHabitLogs(
    userId: user.uid,
    startDate: startDate,
    endDate: endDate,
  );
});
