import "package:flutter/material.dart";

import "button_voice_feedback.dart";

/// Kontrast dostu başlık stili; sistem metin ölçeğiyle uyumlu.
/// Enlarged (22px), SemiBold (w600) for better accessibility.
TextStyle? esAccessibleTitleStyle(BuildContext context) {
  final theme = Theme.of(context);
  return theme.textTheme.headlineSmall?.copyWith(
    fontWeight: FontWeight.w600,
    fontSize: 24, // Increased from 22
    color: theme.colorScheme.onSurface,
    letterSpacing: 0.5, // Added for clarity
  );
}

/// Gövde metni — satır yüksekliği ekran okuyucu kullananlar için rahat okuma.
/// Enlarged (18px), SemiBold (w600) for better accessibility.
TextStyle? esAccessibleBodyStyle(BuildContext context) {
  final theme = Theme.of(context);
  return theme.textTheme.bodyLarge?.copyWith(
    height: 1.5, // Increased from 1.4
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: theme.colorScheme.onSurface,
  );
}

/// Başlık metni — erişilebilir boyut ve font ağırlığı.
TextStyle? esAccessibleHeadingStyle(BuildContext context) {
  final theme = Theme.of(context);
  return theme.textTheme.displaySmall?.copyWith(
    fontWeight: FontWeight.bold,
    fontSize: 28,
    color: theme.colorScheme.onSurface,
    letterSpacing: 0.3,
  );
}

/// Büyük buton metni — Görme engelli kullanıcılar için görünür ve işitilir.
TextStyle? esAccessibleButtonStyle(BuildContext context) {
  final theme = Theme.of(context);
  return theme.textTheme.labelLarge?.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );
}

/// Erişilebilir [ElevatedButton]: etiket hem görünür hem Semantics.
/// Tam genişlik, yuvarlatılmış köşeler, kalın metin.
/// 
/// When tapped, provides automatic voice feedback reading the button label.
/// Set [enableVoiceFeedback] to false to disable voice announcements.
Widget esPrimaryButton({
  required BuildContext context,
  required String semanticLabel,
  String? semanticHint,
  required VoidCallback? onPressed,
  required String text,
  double height = 60, // Increased from 56
  bool enableVoiceFeedback = true,
  bool enableHapticFeedback = true,
  String? voiceFeedbackText,
}) {
  // Wrap onPressed to add voice feedback
  final wrappedOnPressed = onPressed == null
      ? null
      : () async {
          if (enableVoiceFeedback) {
            await ButtonFeedbackHelper.announceButtonPress(
              buttonLabel: semanticLabel,
              enableVoice: enableVoiceFeedback,
              enableHaptic: enableHapticFeedback,
              customMessage: voiceFeedbackText,
            );
          } else if (enableHapticFeedback) {
            await ButtonFeedbackHelper.playHapticFeedback();
          }
          onPressed();  // onPressed is never null here
        };

  return Semantics(
    button: true,
    label: semanticLabel,
    hint: semanticHint ?? "Dokunun. Sesli geri bildirim: $semanticLabel",
    enabled: onPressed != null,
    child: SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: wrappedOnPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: esAccessibleButtonStyle(context),
        ),
      ),
    ),
  );
}

/// Ikonu olan erişilebilir buton — Açık etiketler ve büyük dokunma alanı.
/// 
/// When tapped, provides automatic voice feedback reading the button label.
/// Set [enableVoiceFeedback] to false to disable voice announcements.
Widget esIconButton({
  required BuildContext context,
  required String semanticLabel,
  String? semanticHint,
  required IconData icon,
  required VoidCallback? onPressed,
  Color? iconColor,
  double iconSize = 36, // Increased from default
  bool enableVoiceFeedback = true,
  bool enableHapticFeedback = true,
  String? voiceFeedbackText,
}) {
  final theme = Theme.of(context);

  // Wrap onPressed to add voice feedback
  final wrappedOnPressed = onPressed == null
      ? null
      : () async {
          if (enableVoiceFeedback) {
            await ButtonFeedbackHelper.announceButtonPress(
              buttonLabel: semanticLabel,
              enableVoice: enableVoiceFeedback,
              enableHaptic: enableHapticFeedback,
              customMessage: voiceFeedbackText,
            );
          } else if (enableHapticFeedback) {
            await ButtonFeedbackHelper.playHapticFeedback();
          }
          onPressed();  // onPressed is never null here
        };

  return Semantics(
    button: true,
    label: semanticLabel,
    hint: semanticHint ?? "Dokunun. Sesli geri bildirim: $semanticLabel",
    enabled: onPressed != null,
    child: Container(
      constraints: const BoxConstraints(
        minWidth: 60, // Minimum touch target
        minHeight: 60,
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: iconSize,
          color: iconColor ?? theme.colorScheme.primary,
        ),
        onPressed: wrappedOnPressed,
        tooltip: semanticLabel,
        padding: const EdgeInsets.all(12),
        splashRadius: 30,
      ),
    ),
  );
}

/// İçerik alanı başlığı — Ekran okuyucu tarafından önce okunacak.
Widget esAccessibleScreenHeader({
  required BuildContext context,
  required String title,
  String? subtitle,
  required String screenLabel, // For accessibility
}) {
  final titleStyle = esAccessibleHeadingStyle(context);
  final bodyStyle = esAccessibleBodyStyle(context);

  return Semantics(
    header: true,
    label: screenLabel,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: titleStyle),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(subtitle, style: bodyStyle?.copyWith(fontSize: 16)),
        ]
      ],
    ),
  );
}

/// Yüksek kontrast kartı — Görme engelli kullanıcılar için optimize edilmiş.
Widget esAccessibleCard({
  required BuildContext context,
  required Widget child,
  EdgeInsets padding = const EdgeInsets.all(16),
  String? semanticLabel,
}) {
  final theme = Theme.of(context);
  return Semantics(
    container: true,
    label: semanticLabel,
    child: Card(
      color: theme.colorScheme.surfaceContainer,
      elevation: 6, // Increased for better visibility
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline,
          width: 2, // Added border for contrast
        ),
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    ),
  );
}

/// Ayırıcı çizgi — Ekran okuyucular tarafından ayırıcı olarak tanındı.
Widget esAccessibleDivider({
  String label = "Bölüm ayırıcı",
}) {
  return Semantics(
    label: label,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Container(
        height: 3, // Thicker divider
        color: Colors.grey.shade700,
      ),
    ),
  );
}
