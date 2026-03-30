import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_core/firebase_core.dart";

import "../../../core/logging/app_logger.dart";
import "../domain/user_health_profile.dart";

/// Firebase yapılandırılmışsa anonim kullanıcı ile `users/{uid}` belgesine yazar.
class ProfileFirestoreSync {
  ProfileFirestoreSync._();

  static Future<void> upsertProfile(UserHealthProfile profile) async {
    if (Firebase.apps.isEmpty) return;
    try {
      User? user = FirebaseAuth.instance.currentUser;
      user ??= (await FirebaseAuth.instance.signInAnonymously()).user;
      if (user == null) return;

      await FirebaseFirestore.instance.collection("users").doc(user.uid).set(
        {
          "healthProfile": profile.toJson(),
          "healthProfileUpdatedAt": FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e, st) {
      AppLogger.e("Firestore profil senkronu başarısız", e, st);
    }
  }
}
