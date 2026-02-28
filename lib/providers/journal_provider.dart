import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../repositories/journal/journal_repository.dart';
import 'auth_provider.dart';

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return JournalRepository(Supabase.instance.client);
});

final journalEntriesProvider = StateNotifierProvider<JournalNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  final repository = ref.watch(journalRepositoryProvider);
  final authState = ref.watch(authStateProvider);
  return JournalNotifier(repository, authState);
});

class JournalNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final JournalRepository _repository;
  final AsyncValue _authState;

  JournalNotifier(this._repository, this._authState) : super(const AsyncValue.loading()) {
    loadEntries();
  }

  Future<void> loadEntries() async {
    final user = _authState.value;
    if (user == null) {
      state = const AsyncValue.data([]);
      return;
    }

    try {
      state = const AsyncValue.loading();
      final entries = await _repository.getEntries(user.uid);
      state = AsyncValue.data(entries);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addEntry({
    required DateTime date,
    required String content,
    int? mood,
    int? energy,
    List<String>? tags,
  }) async {
    final user = _authState.value;
    if (user == null) return;

    try {
      await _repository.createEntry(
        userId: user.uid,
        date: date,
        content: content,
        mood: mood,
        energy: energy,
        tags: tags,
      );
      await loadEntries();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteEntry(String id) async {
    try {
      await _repository.deleteEntry(id);
      await loadEntries();
    } catch (e) {
      rethrow;
    }
  }
}
