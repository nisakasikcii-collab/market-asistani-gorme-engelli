import "package:flutter/material.dart";

import "../logging/app_logger.dart";
import "../voice/voice_feedback.dart";

/// Ekran yüklendiğinde otomatik olarak başlık ve açıklamayı seslendiren widget.
/// Erişilebilirlik için: Ekran okuyucu kullanıcılar sayfaya geldiklerinde hemen
/// başlık ve açıklamayı duyarlar.
class AccessibleScreenAnnouncer extends StatefulWidget {
  final String screenTitle;
  final String screenDescription;
  final String? additionalHint;
  final Duration delay;
  final Widget child;

  const AccessibleScreenAnnouncer({
    super.key,
    required this.screenTitle,
    required this.screenDescription,
    this.additionalHint,
    this.delay = const Duration(milliseconds: 500),
    required this.child,
  });

  @override
  State<AccessibleScreenAnnouncer> createState() =>
      _AccessibleScreenAnnouncerState();
}

class _AccessibleScreenAnnouncerState extends State<AccessibleScreenAnnouncer> {
  final VoiceFeedback _voice = VoiceFeedback.instance;

  @override
  void initState() {
    super.initState();
    // Ekran yüklendiğinde başlık ve açıklamayı seslendir
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        await Future<void>.delayed(widget.delay);
        await _announceScreen();
      }
    });
  }

  Future<void> _announceScreen() async {
    try {
      String announcement = "${widget.screenTitle}. ${widget.screenDescription}";
      if (widget.additionalHint != null && widget.additionalHint!.isNotEmpty) {
        announcement += " ${widget.additionalHint}";
      }
      await _voice.speakInfo(announcement);
    } catch (e, st) {
      AppLogger.d("Ekran duyurusu hatası", e, st);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.screenTitle,
      child: widget.child,
    );
  }
}

/// Erişilebilir ekran yapı sınıfı — Başlık, açıklama ve TTS otomasyonu
class AccessibleScreen extends StatelessWidget {
  final String title;
  final String description;
  final String? screenLabel; // Ekran okuyucu etiket
  final String? additionalHint;
  final Widget body;
  final PreferredSizeWidget? appBar;
  final bool autoAnnounce;

  const AccessibleScreen({
    super.key,
    required this.title,
    required this.description,
    this.screenLabel,
    this.additionalHint,
    required this.body,
    this.appBar,
    this.autoAnnounce = true,
  });

  @override
  Widget build(BuildContext context) {
    final bodyWidget = Column(
      children: [
        if (appBar == null)
          Semantics(
            header: true,
            label: screenLabel ?? title,
            child: Material(
              color: Theme.of(context).colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 16,
                            height: 1.5,
                          ),
                    ),
                    if (additionalHint != null && additionalHint!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        additionalHint!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ),
        Expanded(child: body),
      ],
    );

    if (autoAnnounce) {
      return AccessibleScreenAnnouncer(
        screenTitle: title,
        screenDescription: description,
        additionalHint: additionalHint,
        child: Scaffold(
          appBar: appBar,
          body: SafeArea(child: bodyWidget),
        ),
      );
    } else {
      return Scaffold(
        appBar: appBar,
        body: SafeArea(child: bodyWidget),
      );
    }
  }
}
