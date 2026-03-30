import "package:flutter/services.dart";

import "../logging/app_logger.dart";
import "../voice/voice_feedback.dart";

/// Global configuration for button voice feedback
class ButtonVoiceFeedbackConfig {
  static final ButtonVoiceFeedbackConfig _instance =
      ButtonVoiceFeedbackConfig._internal();

  factory ButtonVoiceFeedbackConfig() {
    return _instance;
  }

  ButtonVoiceFeedbackConfig._internal();

  /// Enable/disable voice feedback for all buttons globally
  bool enableVoiceFeedback = true;

  /// Enable/disable haptic feedback for all buttons globally
  bool enableHapticFeedback = true;

  /// Delay before reading button label (milliseconds)
  /// Prevents overlap with other announcements
  int delayMs = 100;

  /// Set all configurations at once
  void configure({
    bool? enableVoiceFeedback,
    bool? enableHapticFeedback,
    int? delayMs,
  }) {
    if (enableVoiceFeedback != null) this.enableVoiceFeedback = enableVoiceFeedback;
    if (enableHapticFeedback != null) this.enableHapticFeedback = enableHapticFeedback;
    if (delayMs != null) this.delayMs = delayMs;
  }
}

/// Provides voice and haptic feedback for button presses
/// This helper class handles all button-related announcements
class ButtonFeedbackHelper {
  /// Announce button press with optional haptic feedback
  /// 
  /// Parameters:
  /// - [buttonLabel]: What button was pressed (e.g., "Profili kaydet")
  /// - [enableVoice]: Override global voice feedback setting
  /// - [enableHaptic]: Override global haptic feedback setting
  /// - [customMessage]: Use custom message instead of default
  /// 
  /// Example:
  /// ```dart
  /// await ButtonFeedbackHelper.announceButtonPress(
  ///   buttonLabel: "Profili Kaydet",
  /// );
  /// ```
  static Future<void> announceButtonPress({
    required String buttonLabel,
    bool? enableVoice,
    bool? enableHaptic,
    String? customMessage,
  }) async {
    final config = ButtonVoiceFeedbackConfig();

    // Check if voice feedback is enabled
    final voiceEnabled = enableVoice ?? config.enableVoiceFeedback;
    final hapticEnabled = enableHaptic ?? config.enableHapticFeedback;

    try {
      // Play haptic feedback first (doesn't require delay)
      if (hapticEnabled) {
        await playHapticFeedback();
      }

      // Announce button press with delay to avoid overlapping with other sounds
      if (voiceEnabled) {
        await Future<void>.delayed(Duration(milliseconds: config.delayMs));
        final message = customMessage ?? buttonLabel;
        await VoiceFeedback.instance.speakInfo(message);
      }
    } catch (e, st) {
      AppLogger.e("Button feedback announcement error", e, st);
    }
  }

  /// Play haptic feedback (vibration)
  /// Works on both Android and iOS
  static Future<void> playHapticFeedback() async {
    try {
      // Light haptic feedback for button press
      await HapticFeedback.lightImpact();
    } catch (e) {
      AppLogger.d("Haptic feedback error: $e");
    }
  }

  /// Helper: Get readable button text (clean up emojis and extra spaces)
  /// 
  /// Converts "📷 Tarama ekranını aç" to "Tarama ekranını aç"
  static String cleanButtonText(String text) {
    // Remove common emoji and special characters, keep text only
    String result = text;
    // Remove leading emoji and special characters
    result = result.replaceFirst(RegExp(r'^[^a-zA-ZÆØÅæøåçñáéíóúàèìòùäöüßÇÑ]+\s*'), '');
    // Remove multiple spaces
    result = result.replaceAll(RegExp(r'\s+'), ' ').trim();
    return result;
  }
}
