import "package:eyeshopper_ai/features/community_feedback/logic/feedback_rate_limiter.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  test("ardisik gonderim cok hizliysa engeller", () {
    final now = DateTime(2026, 1, 1, 12, 0, 0);
    final decision = FeedbackRateLimiter.check(
      sentAt: [now.subtract(const Duration(seconds: 5))],
      now: now,
    );
    expect(decision.allowed, isFalse);
  });

  test("son bir saatte limit asilirsa engeller", () {
    final now = DateTime(2026, 1, 1, 12, 0, 0);
    final sentAt = List.generate(
      6,
      (i) => now.subtract(Duration(minutes: i * 5)),
    );
    final decision = FeedbackRateLimiter.check(sentAt: sentAt, now: now);
    expect(decision.allowed, isFalse);
  });

  test("normal kosullarda izin verir", () {
    final now = DateTime(2026, 1, 1, 12, 0, 0);
    final decision = FeedbackRateLimiter.check(
      sentAt: [now.subtract(const Duration(minutes: 20))],
      now: now,
    );
    expect(decision.allowed, isTrue);
  });
}
