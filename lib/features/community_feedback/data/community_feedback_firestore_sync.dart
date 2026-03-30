import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_core/firebase_core.dart";

import "../../../core/logging/app_logger.dart";
import "../domain/community_feedback_entry.dart";
import "../domain/feedback_type.dart";

class CommunityFeedbackFirestoreSync {
  CommunityFeedbackFirestoreSync._();

  static Future<void> addFeedback(CommunityFeedbackEntry entry) async {
    if (Firebase.apps.isEmpty) return;
    try {
      User? user = FirebaseAuth.instance.currentUser;
      user ??= (await FirebaseAuth.instance.signInAnonymously()).user;
      if (user == null) return;

      await FirebaseFirestore.instance.collection("community_feedback").add({
        "uid": user.uid,
        "type": entry.type.key,
        "note": entry.note,
        "createdAt": FieldValue.serverTimestamp(),
      });
    } catch (e, st) {
      AppLogger.e("Topluluk geri bildirim yazimi basarisiz", e, st);
    }
  }

  static Future<List<CommunityFeedbackEntry>> fetchRecent({
    int limit = 30,
  }) async {
    if (Firebase.apps.isEmpty) return const [];
    try {
      final snap = await FirebaseFirestore.instance
          .collection("community_feedback")
          .orderBy("createdAt", descending: true)
          .limit(limit)
          .get();

      return snap.docs.map((doc) {
        final data = doc.data();
        return CommunityFeedbackEntry.fromJson({
          "id": doc.id,
          "type": data["type"],
          "note": data["note"],
          "createdAt": (data["createdAt"] as Timestamp?)?.toDate().toIso8601String(),
        });
      }).toList(growable: false);
    } catch (e, st) {
      AppLogger.e("Topluluk geri bildirim okuma basarisiz", e, st);
      return const [];
    }
  }
}
