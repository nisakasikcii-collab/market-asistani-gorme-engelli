# Button Voice Feedback Implementation Guide

## Overview

This guide explains how to implement automatic voice feedback for all buttons in your Flutter application for visually impaired users. Users will hear button labels aloud when they tap buttons, along with optional vibration feedback.

---

## Features

✅ **Automatic Voice Feedback**: Button labels are read aloud when tapped
✅ **Haptic Feedback**: Optional vibration on button press
✅ **Screen Reader Compatible**: Works with TalkBack (Android) and VoiceOver (iOS)
✅ **Globally Configurable**: Enable/disable feedback for entire app
✅ **Per-Button Control**: Override global settings for specific buttons
✅ **Web Compatible**: Works on Android and web platforms
✅ **Customizable Messages**: Use custom text instead of button label
✅ **Zero Breaking Changes**: Backward compatible with existing code

---

## Quick Start

### 1. Enable Global Button Voice Feedback

In your `app_entry.dart` or app initialization code:

```dart
import 'package:flutter/material.dart';
import 'lib/core/accessibility/button_voice_feedback.dart';

void main() {
  // Configure button voice feedback once at app startup
  ButtonVoiceFeedbackConfig().configure(
    enableVoiceFeedback: true,    // Enable voice announcements
    enableHapticFeedback: true,   // Enable vibration
    delayMs: 100,                 // Delay before announcement (prevents overlap)
  );
  
  runApp(const MyApp());
}
```

### 2. Use Enhanced Buttons (Automatic Voice Feedback)

The existing `esPrimaryButton()` and `esIconButton()` now automatically provide voice feedback:

```dart
// Voice feedback enabled by default
esPrimaryButton(
  context: context,
  semanticLabel: "Profili Kaydet",        // This will be read aloud
  semanticHint: "Sağlık bilgilerini kaydet",
  onPressed: _saveProfile,
  text: "💾 Profili Kaydet",
)

// Disable voice feedback for specific button
esPrimaryButton(
  context: context,
  semanticLabel: "Kapat",
  onPressed: _close,
  text: "Kapat",
  enableVoiceFeedback: false,  // Override for this button
)

// Use custom voice message
esPrimaryButton(
  context: context,
  semanticLabel: "Profili Kaydet",
  onPressed: _save,
  text: "💾 Kaydet",
  voiceFeedbackText: "Profil bilgilerini kaydediliyor",  // Custom message
)
```

### 3. Use New Accessible Button Widgets

For standard Flutter buttons, use the new accessible wrappers:

```dart
import 'package:flutter/material.dart';
import 'lib/core/accessibility/accessible_buttons.dart';

// AccessibleElevatedButton
AccessibleElevatedButton(
  semanticLabel: "Ürün Tarama",
  onPressed: _startScan,
  child: const Text("Taramayı Başlat"),
)

// AccessibleTextButton
AccessibleTextButton(
  semanticLabel: "Detayları Göster",
  onPressed: _showDetails,
  child: const Text("Detaylar"),
)

// AccessibleIconButton (with 48dp minimum touch target)
AccessibleIconButton(
  semanticLabel: "Ayarları Aç",
  icon: Icons.settings,
  onPressed: _openSettings,
)

// AccessibleFloatingActionButton
AccessibleFloatingActionButton(
  semanticLabel: "Yeni Ürün Ekle",
  icon: Icons.add,
  onPressed: _addProduct,
)
```

---

## Configuration Options

### Global Configuration

```dart
final config = ButtonVoiceFeedbackConfig();

config.configure(
  enableVoiceFeedback: true,    // Read button labels aloud
  enableHapticFeedback: true,   // Vibration feedback
  delayMs: 100,                 // Milliseconds to wait before reading
);
```

### Per-Button Configuration

Override global settings for specific buttons:

```dart
// Disable voice for this button
esPrimaryButton(
  context: context,
  semanticLabel: "Skip",
  onPressed: _skip,
  text: "Skip",
  enableVoiceFeedback: false,   // Override global setting
)

// Disable haptic vibration for this button
AccessibleElevatedButton(
  semanticLabel: "Confirm",
  onPressed: _confirm,
  enableHapticFeedback: false,  // No vibration
  child: const Text("Confirm"),
)

// Use custom voice message
AccessibleIconButton(
  semanticLabel: "Delete Product",
  icon: Icons.delete,
  onPressed: _delete,
  voiceFeedbackText: "Product will be deleted permanently",
  child: const Text("Delete"),
)
```

---

## Usage Examples by Scenario

### Scenario 1: Enable Voice Feedback for All Buttons

**Goal**: Read every button label when tapped

**Solution**:
```dart
void main() {
  ButtonVoiceFeedbackConfig().configure(
    enableVoiceFeedback: true,
    enableHapticFeedback: true,
  );
  runApp(const MyApp());
}

// All buttons will now announce themselves
esPrimaryButton(
  context: context,
  semanticLabel: "Kaydet",  // "Kaydet" will be read aloud
  onPressed: _save,
  text: "Kaydet",
)
```

### Scenario 2: Custom Message Based on Button Action

**Goal**: Button "Sil" should announce "Ürün silinecek" instead of "Sil"

**Solution**:
```dart
AccessibleElevatedButton(
  semanticLabel: "Sil",
  onPressed: _deleteProduct,
  voiceFeedbackText: "Ürün silinecek. Devam etmek için dokunun.",
  child: const Text("Sil"),
)
```

### Scenario 3: Disable Voice for Specific Button (e.g., Too Many Clicks)

**Goal**: User clicks button multiple times rapidly; disable voice to avoid spam

**Solution**:
```dart
AccessibleElevatedButton(
  semanticLabel: "İleri",
  onPressed: _next,
  enableVoiceFeedback: false,  // Only haptic feedback
  child: const Text("İleri"),
)
```

### Scenario 4: Only Haptic Feedback (No Voice)

**Goal**: Users prefer vibration only, not voice

**Solution**:
```dart
void main() {
  ButtonVoiceFeedbackConfig().configure(
    enableVoiceFeedback: false,  // Disable voice
    enableHapticFeedback: true,   // Keep vibration
  );
  runApp(const MyApp());
}
```

### Scenario 5: Get Accessibility on Web Platform

**Goal**: Buttons should work on web with similar accessibility

**Solution**:
```dart
// Same code works on web - voice feedback uses platform TTS
AccessibleElevatedButton(
  semanticLabel: "Web'de buton",
  onPressed: _action,
  child: const Text("Eylem"),
)

// On web, browser's TTS will read the label
// On Android/iOS, app's TTS handles it
```

---

## For Developers: Migration Guide

### Before (Manual Announcements)

```dart
ElevatedButton(
  onPressed: () async {
    await SmartAssistant.instance.announceAction("Profil kaydediliyor");
    _saveProfile();
  },
  child: const Text("Kaydet"),
)
```

### After (Automatic Voice Feedback)

```dart
esPrimaryButton(
  context: context,
  semanticLabel: "Profili Kaydet",
  onPressed: _saveProfile,  // No manual TTS needed!
  text: "Kaydet",
)
```

---

## Technical Details

### How It Works

1. **User taps button** → Button press handler triggered
2. **Haptic feedback sent** (optional vibration) → Immediate physical feedback
3. **Delay applied** (100ms default) → Prevents speech overlap
4. **Voice announcement** → `VoiceFeedback.speakInfo()` reads label
5. **Button action executes** → Normal `onPressed` callback

### Files Involved

| File | Purpose |
|------|---------|
| `button_voice_feedback.dart` | Core configuration and helpers |
| `accessible_buttons.dart` | Pre-built button widgets (ElevatedButton, TextButton, etc.) |
| `es_accessibility.dart` | **UPDATED**: esPrimaryButton and esIconButton now include voice feedback |

### Voice Feedback Priority

- Uses `VoiceFeedback.speakInfo()` so voice feedback is interruptible
- Can be paused/interrupted by more urgent announcements (warnings, errors)
- Respects app's global TTS (Turkish locale already configured)

### Haptic Feedback Support

- ✅ Android: Full support via `HapticFeedback.lightImpact()`
- ✅ iOS: Full support via `HapticFeedback.lightImpact()`
- ✅ Web: Gracefully degraded (no haptic available)

---

## Best Practices

### ✅ DO

- ✅ Use `semanticLabel` that clearly describes button action
- ✅ Use semantic labels in present tense: "Kaydet", "Tara", "Sil"
- ✅ Provide `semanticHint` for additional context
- ✅ Test voice feedback with screen readers enabled
- ✅ Use custom messages for complex actions:
  ```dart
  voiceFeedbackText: "Ürün silinecek, işlem geri alınamaz"
  ```
- ✅ Keep delay at 100ms default for smooth UX

### ❌ DON'T

- ❌ Use emojis in semantic labels (they won't be read correctly)
- ❌ Use voice feedback message longer than 2 sentences
- ❌ Set delay too high (> 500ms) - makes UI feel sluggish
- ❌ Disable voice feedback globally unless intentional
- ❌ Use complex jargon in voice feedback messages

---

## Troubleshooting

### Problem: Voice feedback not working

**Solution**:
1. Check if `enableVoiceFeedback` is `true` in config
2. Verify `VoiceFeedback.instance` is initialized
3. Check device volume is not muted
4. Ensure TTS is working with test: `VoiceFeedback.instance.speakInfo("Test")`

### Problem: Voice feedback too slow

**Solution**:
```dart
ButtonVoiceFeedbackConfig().configure(
  delayMs: 50,  // Reduce from 100ms
);
```

### Problem: Multiple announcements playing at once

**Solution**:
```dart
esPrimaryButton(
  context: context,
  semanticLabel: "Kaydet",
  onPressed: () async {
    // Don't call announceAction() here if already announcing button label
    await _saveProfile();
  },
  text: "Kaydet",
)
```

### Problem: Sound not working on web

**Solution**:
Web uses browser's native TTS API. Check:
1. Browser TTS is enabled (most browsers support it)
2. Volume is not muted in browser
3. Test with: `window.speechSynthesis.speak(utterance)`

---

## Testing

### Manual Testing on Android (TalkBack)

```
1. Enable TalkBack: Settings > Accessibility > TalkBack > ON
2. Open app
3. Tap any button
4. Verify: You hear vibration (haptic) + voice reading button label
5. Repeat with multiple buttons to ensure consistency
```

### Manual Testing on iOS (VoiceOver)

```
1. Enable VoiceOver: Settings > Accessibility > VoiceOver > ON
2. Open app
3. Double-tap button
4. Verify: You hear button label read aloud
5. Double-tap again to activate button action
```

### Manual Testing on Web

```
1. Open app in web browser
2. Tab to button
3. Space or Enter to press
4. Verify: You hear button label (via browser TTS)
5. Button action executes normally
```

### Automated Testing

```dart
testWidgets('Button announces itself', (tester) async {
  await tester.pumpWidget(MyApp());
  
  // Find button
  expect(
    find.bySemanticsLabel("Profili Kaydet"),
    findsOneWidget,
  );
  
  // Verify voice would be called (mock VoiceFeedback if needed)
  await tester.tap(find.byType(ElevatedButton).first);
});
```

---

## FAQ

**Q: Will this slow down my app?**
A: No. Announcements are non-blocking (async) and delaying only 100ms.

**Q: Can I disable voice feedback for web?**
A: Yes: `Button VoiceFeedbackConfig().configure(enableVoiceFeedback: false)` when `kIsWeb`

**Q: What about buttons inside dialogs?**
A: Same approach works. DialogsAre just widgets, so accessible buttons work too.

**Q: Can I test voice feedback without TTS device?**
A: Yes, set up mock: `VoiceFeedback.instance.speakInfo()` can be mocked in tests

**Q: Does this work with GestureDetector?**
A: For custom gestures, wrap with `Semantics` + use `ButtonFeedbackHelper`:
```dart
GestureDetector(
  onTap: () async {
    await ButtonFeedbackHelper.announceButtonPress(
      buttonLabel: "Custom Action",
    );
    _doAction();
  },
  child: ...
)
```

---

## Related Documentation

- [Accessibility Guide](ACCESSIBILITY_GUIDE.md) - Full accessibility overview
- [Button Implementation Examples](ACCESSIBILITY_MIGRATION_EXAMPLE.md) - Before/after comparisons
- [Accessibility Checklist](ACCESSIBILITY_CHECKLIST.md) - 60+ point verification list

---

**Last Updated**: March 28, 2026
**Version**: 1.0
**Status**: Ready for production
