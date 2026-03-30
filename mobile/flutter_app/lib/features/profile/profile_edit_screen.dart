import "package:flutter/material.dart";

import "../../core/accessibility/es_accessibility.dart";
import "../../core/logging/app_logger.dart";
import "../../core/voice/voice_feedback.dart";
import "data/user_profile_repository.dart";
import "domain/dietary_restriction.dart";
import "domain/user_health_profile.dart";
import "widgets/restriction_selector_section.dart";

/// Profil güncelleme (kurulum sonrası).
class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final VoiceFeedback _voice = VoiceFeedback.instance;
  late Set<DietaryRestriction> _selected;
  late List<String> _customRestrictions;
  bool _saving = false;
  final String _helpText =
      "Kısıtlarınızı güncelleyin. Hiçbiri yoksa boş bırakabilirsiniz.";

  @override
  void initState() {
    super.initState();
    final existing = UserProfileRepository.instance.profile;
    _selected = Set<DietaryRestriction>.from(existing?.restrictions ?? {});
    _customRestrictions = List<String>.from(existing?.customRestrictions ?? []);
  }

  Future<void> _onSave() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final profile = UserHealthProfile(
        restrictions: _selected,
        customRestrictions: _customRestrictions,
      );
      final err = await UserProfileRepository.instance.updateProfile(profile);
      if (!context.mounted) return;
      if (err != null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
        await _voice.speakWarning(err);
        return;
      }
      await _voice.speakInfo("Profiliniz güncellendi.");
      if (!context.mounted) return;
      Navigator.of(context).pop();
    } catch (e, st) {
      AppLogger.e("Profil güncelleme hatası", e, st);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Güncelleme başarısız.")),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _replayScreen() async {
    await _voice.speakInfo(_helpText);
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = esAccessibleTitleStyle(context);

    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          header: true,
          label: "Sağlık profili düzenleme",
          child: const Text("Profilim"),
        ),
        actions: [
          Semantics(
            button: true,
            label: "Ekranı tekrar dinle",
            child: IconButton(
              icon: const Icon(Icons.volume_up, size: 28),
              onPressed: _replayScreen,
              tooltip: "Ekranı tekrar dinle",
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Kısıtlarınızı güncelleyin", style: titleStyle),
              const SizedBox(height: 8),
              Text(
                _helpText,
                style: esAccessibleBodyStyle(context),
              ),
              const SizedBox(height: 24),
              RestrictionSelectorSection(
                selected: _selected,
                onChanged: (s) => setState(() => _selected = s),
                customRestrictions: _customRestrictions,
                onCustomRestrictionsChanged: (customs) {
                  setState(() => _customRestrictions = customs);
                },
              ),
              const SizedBox(height: 28),
              esPrimaryButton(
                context: context,
                semanticLabel: _saving
                    ? "Kaydediliyor"
                    : "Değişiklikleri kaydet ve geri dön",
                onPressed: _saving ? null : _onSave,
                text: _saving ? "Kaydediliyor…" : "Kaydet",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
