import "package:flutter/foundation.dart";

import "../domain/user_health_profile.dart";
import "profile_firestore_sync.dart";
import "profile_local_store.dart";

/// Yerel kaynak doğruluk kabul edilir; Firestore en iyi çaba ile senkronlanır.
class UserProfileRepository extends ChangeNotifier {
  UserProfileRepository._();

  static final UserProfileRepository instance = UserProfileRepository._();

  final ProfileLocalStore _local = ProfileLocalStore();

  bool _loaded = false;
  bool _onboardingComplete = false;
  UserHealthProfile? _profile;

  bool get isLoaded => _loaded;
  bool get onboardingComplete => _onboardingComplete;
  UserHealthProfile? get profile => _profile;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    _onboardingComplete = await _local.getOnboardingComplete();
    _profile = await _local.loadProfile();
    _loaded = true;
    notifyListeners();
  }

  /// İlk kurulum: kısıtları kaydeder ve ana ekrana geçişi işaretler.
  Future<String?> completeOnboarding(UserHealthProfile profile) async {
    final err = validateProfile(profile);
    if (err != null) return err;
    final stamped = profile.copyWith(updatedAt: DateTime.now());
    _profile = stamped;
    await _local.saveProfile(stamped);
    await _local.setOnboardingComplete(true);
    _onboardingComplete = true;
    await ProfileFirestoreSync.upsertProfile(stamped);
    notifyListeners();
    return null;
  }

  /// Profil güncelleme (onboarding sonrası).
  Future<String?> updateProfile(UserHealthProfile profile) async {
    final err = validateProfile(profile);
    if (err != null) return err;
    if (!_onboardingComplete) {
      return "Önce kurulumu tamamlayın.";
    }
    final stamped = profile.copyWith(updatedAt: DateTime.now());
    _profile = stamped;
    await _local.saveProfile(stamped);
    await ProfileFirestoreSync.upsertProfile(stamped);
    notifyListeners();
    return null;
  }

  /// Basit doğrulama: ileride not alanı vb. eklenebilir.
  static String? validateProfile(UserHealthProfile profile) {
    if (profile.restrictions.length > 32) {
      return "Geçersiz profil verisi.";
    }
    return null;
  }
}
