import "package:flutter/material.dart";

import "button_voice_feedback.dart";

/// Enhanced ElevatedButton with automatic voice feedback
/// 
/// Example:
/// ```dart
/// AccessibleElevatedButton(
///   semanticLabel: "Profili Kaydet",
///   onPressed: _saveProfile,
///   child: const Text("Kaydet"),
/// )
/// ```
class AccessibleElevatedButton extends StatelessWidget {
  final String semanticLabel;
  final String? semanticHint;
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final bool enableVoiceFeedback;
  final bool enableHapticFeedback;
  final String? voiceFeedbackText;

  const AccessibleElevatedButton({
    Key? key,
    required this.semanticLabel,
    this.semanticHint,
    required this.onPressed,
    required this.child,
    this.style,
    this.enableVoiceFeedback = true,
    this.enableHapticFeedback = true,
    this.voiceFeedbackText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            onPressed?.call();
          };

    return Semantics(
      button: true,
      label: semanticLabel,
      hint: semanticHint ?? "Dokunun. Sesli geri bildirim: $semanticLabel",
      enabled: onPressed != null,
      child: ElevatedButton(
        onPressed: wrappedOnPressed,
        style: style,
        child: child,
      ),
    );
  }
}

/// Enhanced TextButton with automatic voice feedback
/// 
/// Example:
/// ```dart
/// AccessibleTextButton(
///   semanticLabel: "Detayları Gör",
///   onPressed: _showDetails,
///   child: const Text("Detaylar"),
/// )
/// ```
class AccessibleTextButton extends StatelessWidget {
  final String semanticLabel;
  final String? semanticHint;
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final bool enableVoiceFeedback;
  final bool enableHapticFeedback;
  final String? voiceFeedbackText;

  const AccessibleTextButton({
    Key? key,
    required this.semanticLabel,
    this.semanticHint,
    required this.onPressed,
    required this.child,
    this.style,
    this.enableVoiceFeedback = true,
    this.enableHapticFeedback = true,
    this.voiceFeedbackText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            onPressed?.call();
          };

    return Semantics(
      button: true,
      label: semanticLabel,
      hint: semanticHint ?? "Dokunun. Sesli geri bildirim: $semanticLabel",
      enabled: onPressed != null,
      child: TextButton(
        onPressed: wrappedOnPressed,
        style: style,
        child: child,
      ),
    );
  }
}

/// Enhanced OutlinedButton with automatic voice feedback
/// 
/// Example:
/// ```dart
/// AccessibleOutlinedButton(
///   semanticLabel: "İptal Et",
///   onPressed: _cancel,
///   child: const Text("İptal"),
/// )
/// ```
class AccessibleOutlinedButton extends StatelessWidget {
  final String semanticLabel;
  final String? semanticHint;
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final bool enableVoiceFeedback;
  final bool enableHapticFeedback;
  final String? voiceFeedbackText;

  const AccessibleOutlinedButton({
    Key? key,
    required this.semanticLabel,
    this.semanticHint,
    required this.onPressed,
    required this.child,
    this.style,
    this.enableVoiceFeedback = true,
    this.enableHapticFeedback = true,
    this.voiceFeedbackText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            onPressed?.call();
          };

    return Semantics(
      button: true,
      label: semanticLabel,
      hint: semanticHint ?? "Dokunun. Sesli geri bildirim: $semanticLabel",
      enabled: onPressed != null,
      child: OutlinedButton(
        onPressed: wrappedOnPressed,
        style: style,
        child: child,
      ),
    );
  }
}

/// Enhanced IconButton with automatic voice feedback
/// 
/// Example:
/// ```dart
/// AccessibleIconButton(
///   semanticLabel: "Sil",
///   icon: Icons.delete,
///   onPressed: _delete,
/// )
/// ```
class AccessibleIconButton extends StatelessWidget {
  final String semanticLabel;
  final String? semanticHint;
  final VoidCallback? onPressed;
  final IconData icon;
  final Color? color;
  final double size;
  final bool enableVoiceFeedback;
  final bool enableHapticFeedback;
  final String? voiceFeedbackText;
  final double minTouchSize;

  const AccessibleIconButton({
    Key? key,
    required this.semanticLabel,
    this.semanticHint,
    required this.onPressed,
    required this.icon,
    this.color,
    this.size = 24,
    this.enableVoiceFeedback = true,
    this.enableHapticFeedback = true,
    this.voiceFeedbackText,
    this.minTouchSize = 48, // Minimum accessible touch target
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            onPressed?.call();
          };

    return Semantics(
      button: true,
      label: semanticLabel,
      hint: semanticHint ?? "Dokunun. Sesli geri bildirim: $semanticLabel",
      enabled: onPressed != null,
      child: Container(
        constraints: BoxConstraints(
          minWidth: minTouchSize,
          minHeight: minTouchSize,
        ),
        child: IconButton(
          icon: Icon(icon, size: size, color: color),
          onPressed: wrappedOnPressed,
          tooltip: semanticLabel,
        ),
      ),
    );
  }
}

/// Enhanced FloatingActionButton with automatic voice feedback
/// 
/// Example:
/// ```dart
/// AccessibleFloatingActionButton(
///   semanticLabel: "Yeni ürün ekle",
///   icon: Icons.add,
///   onPressed: _addProduct,
/// )
/// ```
class AccessibleFloatingActionButton extends StatelessWidget {
  final String semanticLabel;
  final String? semanticHint;
  final VoidCallback? onPressed;
  final Widget? child;
  final IconData? icon;
  final bool enableVoiceFeedback;
  final bool enableHapticFeedback;
  final String? voiceFeedbackText;

  const AccessibleFloatingActionButton({
    Key? key,
    required this.semanticLabel,
    this.semanticHint,
    required this.onPressed,
    this.child,
    this.icon,
    this.enableVoiceFeedback = true,
    this.enableHapticFeedback = true,
    this.voiceFeedbackText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            onPressed?.call();
          };

    return Semantics(
      button: true,
      label: semanticLabel,
      hint: semanticHint ?? "Dokunun. Sesli geri bildirim: $semanticLabel",
      enabled: onPressed != null,
      child: FloatingActionButton(
        onPressed: wrappedOnPressed,
        tooltip: semanticLabel,
        child: child ?? (icon != null ? Icon(icon) : null),
      ),
    );
  }
}
