import "package:flutter/foundation.dart";

import "../domain/community_feedback_entry.dart";
import "../domain/feedback_type.dart";
import "../logic/feedback_rate_limiter.dart";
import "community_feedback_firestore_sync.dart";
import "community_feedback_local_store.dart";

class CommunityFeedbackRepository extends ChangeNotifier {
  CommunityFeedbackRepository._();

  static final CommunityFeedbackRepository instance = CommunityFeedbackRepository._();

  final CommunityFeedbackLocalStore _local = CommunityFeedbackLocalStore();

  bool _loaded = false;
  final List<CommunityFeedbackEntry> _entries = [];
  List<DateTime> _sentAt = [];

  bool get isLoaded => _loaded;
  List<CommunityFeedbackEntry> get entries => List.unmodifiable(_entries);

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final localEntries = await _local.loadEntries();
    final remoteEntries = await CommunityFeedbackFirestoreSync.fetchRecent();
    _entries
      ..clear()
      ..addAll(remoteEntries.isNotEmpty ? remoteEntries : localEntries);
    _sentAt = await _local.loadSentAt();
    _loaded = true;
    notifyListeners();
  }

  Future<String?> addFeedback({
    required FeedbackType type,
    required String note,
  }) async {
    final clean = note.trim();
    if (clean.length < 5) {
      return "Not cok kisa. Lutfen daha acik bir aciklama soyleyin.";
    }
    if (clean.length > 280) {
      return "Not cok uzun. Lutfen 280 karakter altinda tutun.";
    }

    final now = DateTime.now();
    final rate = FeedbackRateLimiter.check(sentAt: _sentAt, now: now);
    if (!rate.allowed) return rate.message ?? "Gonderim siniri asildi.";

    final entry = CommunityFeedbackEntry(
      id: now.microsecondsSinceEpoch.toString(),
      type: type,
      note: clean,
      createdAt: now,
    );
    _entries.insert(0, entry);
    _sentAt = [..._sentAt, now];
    await _local.saveEntries(_entries);
    await _local.saveSentAt(_sentAt);
    notifyListeners();
    await CommunityFeedbackFirestoreSync.addFeedback(entry);
    return null;
  }
}
