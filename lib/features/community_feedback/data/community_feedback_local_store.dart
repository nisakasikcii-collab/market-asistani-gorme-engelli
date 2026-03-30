import "dart:convert";

import "package:shared_preferences/shared_preferences.dart";

import "../domain/community_feedback_entry.dart";

class CommunityFeedbackLocalStore {
  static const _kEntries = "es_community_feedback_entries";
  static const _kSentAt = "es_community_feedback_sent_at";

  Future<List<CommunityFeedbackEntry>> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kEntries);
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(CommunityFeedbackEntry.fromJson)
        .toList();
  }

  Future<void> saveEntries(List<CommunityFeedbackEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_kEntries, raw);
  }

  Future<List<DateTime>> loadSentAt() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kSentAt) ?? const [];
    return raw
        .map(DateTime.tryParse)
        .whereType<DateTime>()
        .toList(growable: false);
  }

  Future<void> saveSentAt(List<DateTime> sentAt) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = sentAt.map((e) => e.toIso8601String()).toList();
    await prefs.setStringList(_kSentAt, raw);
  }
}
