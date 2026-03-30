import "feedback_type.dart";

class CommunityFeedbackEntry {
  const CommunityFeedbackEntry({
    required this.id,
    required this.type,
    required this.note,
    required this.createdAt,
  });

  final String id;
  final FeedbackType type;
  final String note;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "type": type.key,
      "note": note,
      "createdAt": createdAt.toIso8601String(),
    };
  }

  static CommunityFeedbackEntry fromJson(Map<String, dynamic> json) {
    return CommunityFeedbackEntry(
      id: (json["id"] ?? "").toString(),
      type: FeedbackTypeUi.fromKey((json["type"] ?? "").toString()),
      note: (json["note"] ?? "").toString(),
      createdAt: DateTime.tryParse((json["createdAt"] ?? "").toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
