import "dietary_restriction.dart";

/// Yerel ve Firestore ile senkronize edilen sağlık profili.
class UserHealthProfile {
  const UserHealthProfile({
    required this.restrictions,
    this.customRestrictions = const [],
    this.updatedAt,
  });

  final Set<DietaryRestriction> restrictions;
  final List<String> customRestrictions; // "Diğer" için kullanıcı tanımlı kısıtlar
  final DateTime? updatedAt;

  UserHealthProfile copyWith({
    Set<DietaryRestriction>? restrictions,
    List<String>? customRestrictions,
    DateTime? updatedAt,
  }) {
    return UserHealthProfile(
      restrictions: restrictions ?? this.restrictions,
      customRestrictions: customRestrictions ?? this.customRestrictions,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "restrictions": restrictions.map((e) => e.name).toList(),
      "customRestrictions": customRestrictions,
      "updatedAt": updatedAt?.toUtc().toIso8601String(),
    };
  }

  static UserHealthProfile fromJson(Map<String, dynamic> json) {
    final raw = json["restrictions"];
    final set = <DietaryRestriction>{};
    if (raw is List) {
      for (final item in raw) {
        if (item is! String) continue;
        try {
          set.add(DietaryRestriction.values.byName(item));
        } catch (_) {
          // Eski veya bilinmeyen anahtarları yok say
        }
      }
    }

    List<String> customRestrictions = [];
    final custom = json["customRestrictions"];
    if (custom is List) {
      customRestrictions = custom.whereType<String>().toList();
    }

    DateTime? updated;
    final u = json["updatedAt"];
    if (u is String && u.isNotEmpty) {
      updated = DateTime.tryParse(u);
    }
    return UserHealthProfile(
      restrictions: set,
      customRestrictions: customRestrictions,
      updatedAt: updated,
    );
  }
}
