enum FeedbackType {
  wrongPrice,
  shelfChanged,
  other,
}

extension FeedbackTypeUi on FeedbackType {
  String get labelTr {
    switch (this) {
      case FeedbackType.wrongPrice:
        return "Yanlis fiyat etiketi";
      case FeedbackType.shelfChanged:
        return "Reyon yeri degismis";
      case FeedbackType.other:
        return "Diger";
    }
  }

  String get key {
    switch (this) {
      case FeedbackType.wrongPrice:
        return "wrong_price";
      case FeedbackType.shelfChanged:
        return "shelf_changed";
      case FeedbackType.other:
        return "other";
    }
  }

  static FeedbackType fromKey(String key) {
    for (final t in FeedbackType.values) {
      if (t.key == key) return t;
    }
    return FeedbackType.other;
  }
}
