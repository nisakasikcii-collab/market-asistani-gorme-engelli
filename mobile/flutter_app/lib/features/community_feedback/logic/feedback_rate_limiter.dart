class FeedbackRateDecision {
  const FeedbackRateDecision({
    required this.allowed,
    this.message,
  });

  final bool allowed;
  final String? message;
}

class FeedbackRateLimiter {
  const FeedbackRateLimiter._();

  static FeedbackRateDecision check({
    required List<DateTime> sentAt,
    required DateTime now,
    Duration minGap = const Duration(seconds: 20),
    int maxPerHour = 6,
  }) {
    if (sentAt.isNotEmpty) {
      final latest = sentAt.reduce((a, b) => a.isAfter(b) ? a : b);
      if (now.difference(latest) < minGap) {
        return const FeedbackRateDecision(
          allowed: false,
          message: "Cok hizli gonderim tespit edildi. Lutfen biraz bekleyin.",
        );
      }
    }

    final oneHourAgo = now.subtract(const Duration(hours: 1));
    final countLastHour = sentAt.where((t) => t.isAfter(oneHourAgo)).length;
    if (countLastHour >= maxPerHour) {
      return const FeedbackRateDecision(
        allowed: false,
        message: "Son bir saatte fazla bildirim gonderildi. Lutfen daha sonra tekrar deneyin.",
      );
    }

    return const FeedbackRateDecision(allowed: true);
  }
}
