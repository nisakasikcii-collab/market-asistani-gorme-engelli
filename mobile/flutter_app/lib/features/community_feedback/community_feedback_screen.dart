import "package:flutter/material.dart";

import "../../core/accessibility/es_accessibility.dart";
import "../../core/voice/voice_feedback.dart";
import "data/community_feedback_repository.dart";
import "domain/feedback_type.dart";

class CommunityFeedbackScreen extends StatefulWidget {
  const CommunityFeedbackScreen({super.key});

  @override
  State<CommunityFeedbackScreen> createState() => _CommunityFeedbackScreenState();
}

class _CommunityFeedbackScreenState extends State<CommunityFeedbackScreen> {
  final VoiceFeedback _voice = VoiceFeedback.instance;
  final TextEditingController _noteController = TextEditingController();

  FeedbackType _selectedType = FeedbackType.wrongPrice;
  bool _listening = false;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    CommunityFeedbackRepository.instance.addListener(_onRepo);
  }

  @override
  void dispose() {
    CommunityFeedbackRepository.instance.removeListener(_onRepo);
    _noteController.dispose();
    super.dispose();
  }

  void _onRepo() {
    if (mounted) setState(() {});
  }

  Future<void> _onVoiceNote() async {
    if (_listening) return;
    setState(() => _listening = true);
    try {
      await _voice.speakInfo("Sesli not icin dinliyorum.");
      final text = await _voice.listenOnce(listenFor: const Duration(seconds: 15));
      if (text == null || text.trim().isEmpty) {
        await _voice.speakWarning("Sesli not algilanamadi.");
        return;
      }
      _noteController.text = text.trim();
      await _voice.speakInfo("Notunuz alindi. Gondermek icin gonder dugmesine basabilirsiniz.");
    } finally {
      if (mounted) setState(() => _listening = false);
    }
  }

  Future<void> _onSend() async {
    if (_sending) return;
    setState(() => _sending = true);
    try {
      final err = await CommunityFeedbackRepository.instance.addFeedback(
        type: _selectedType,
        note: _noteController.text,
      );
      if (err != null) {
        await _voice.speakWarning(err);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
        return;
      }
      _noteController.clear();
      await _voice.speakInfo("Geri bildiriminiz kaydedildi.");
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = esAccessibleTitleStyle(context);
    final bodyStyle = esAccessibleBodyStyle(context);
    final entries = CommunityFeedbackRepository.instance.entries;

    return Scaffold(
      appBar: AppBar(title: const Text("Topluluk Geri Bildirim")),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text("Sesli geri bildirim birak", style: titleStyle),
            const SizedBox(height: 8),
            Text(
              "Etiket secin, notunuzu sesli veya yazarak girin, sonra gonderin.",
              style: bodyStyle,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<FeedbackType>(
              value: _selectedType,
              items: FeedbackType.values
                  .map(
                    (e) => DropdownMenuItem<FeedbackType>(
                      value: e,
                      child: Text(e.labelTr),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedType = value);
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Bildirim tipi",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              minLines: 2,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Not",
                hintText: "Örnek: Bu rafta fiyat etiketi ürünle uyuşmuyor.",
              ),
            ),
            const SizedBox(height: 12),
            esPrimaryButton(
              context: context,
              semanticLabel: "Sesli notu kaydet",
              onPressed: _listening ? null : _onVoiceNote,
              text: _listening ? "Dinleniyor…" : "Sesli not al",
            ),
            const SizedBox(height: 10),
            esPrimaryButton(
              context: context,
              semanticLabel: "Geri bildirimi gonder",
              onPressed: _sending ? null : _onSend,
              text: _sending ? "Gonderiliyor…" : "Gonder",
            ),
            const SizedBox(height: 24),
            Text("Gecmis bildirimler", style: titleStyle),
            const SizedBox(height: 8),
            if (entries.isEmpty)
              Text("Henuz bildirim yok.", style: bodyStyle)
            else
              ...entries.take(20).map((entry) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(entry.type.labelTr),
                  subtitle: Text(entry.note),
                );
              }),
          ],
        ),
      ),
    );
  }
}
