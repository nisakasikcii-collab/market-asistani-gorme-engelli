import "dart:convert";

import "package:shared_preferences/shared_preferences.dart";

import "../domain/user_health_profile.dart";

class ProfileLocalStore {
  static const _kOnboarding = "es_onboarding_completed";
  static const _kProfile = "es_health_profile_json";

  Future<bool> getOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kOnboarding) ?? false;
  }

  Future<void> setOnboardingComplete(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboarding, value);
  }

  Future<UserHealthProfile?> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kProfile);
    if (raw == null || raw.isEmpty) return null;
    final map = jsonDecode(raw);
    if (map is! Map<String, dynamic>) return null;
    return UserHealthProfile.fromJson(map);
  }

  Future<void> saveProfile(UserHealthProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kProfile, jsonEncode(profile.toJson()));
  }
}
