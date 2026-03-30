import "package:flutter/material.dart";

import "../../core/accessibility/es_accessibility.dart";
import "../../core/logging/app_logger.dart";
import "../../core/voice/voice_feedback.dart";
import "../profile/data/user_profile_repository.dart";
import "../profile/domain/dietary_restriction.dart";
import "../profile/domain/user_health_profile.dart";
import "../profile/widgets/restriction_selector_section.dart";

/// İlk açılış: hoş geldin + kısıt seçimi + kaydet.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final VoiceFeedback _voice = VoiceFeedback.instance;
  Set<DietaryRestriction> _selected = {};
  List<String> _customRestrictions = [];
  bool _saving = false;
  bool _onboardingComplete = false;

  final String _welcomeText =
      "Market içinde ürünleri sesli olarak analiz edebilmeniz için "
      "sağlık profilinizi bir kez kaydedin. Veriler cihazınızda saklanır; "
      "Firebase açıksa anonim hesapla buluta da yedeklenir.";

  @override
  void initState() {
    super.initState();
    // İlk açılışta yardım metnini oku
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _voice.speakInfo(_welcomeText);
    });
  }

  /// Seçimler değiştiğinde otomatik olarak kaydet
  Future<void> _onRestrictionChanged(Set<DietaryRestriction> selected) async {
    setState(() => _selected = selected);
    // Seçim yapıldı, hemen kaydet
    await _autoSave();
  }

  /// Özel kısıtlar değiştiğinde otomatik olarak kaydet
  Future<void> _onCustomRestrictionsChanged(List<String> customs) async {
    setState(() => _customRestrictions = customs);
    // Özel kısıt eklendi, hemen kaydet
    await _autoSave();
  }

  /// Profili otomatik olarak kaydet
  Future<void> _autoSave() async {
    if (_saving || _onboardingComplete) return;
    setState(() => _saving = true);
    try {
      final profile = UserHealthProfile(
        restrictions: _selected,
        customRestrictions: _customRestrictions,
      );
      final err = await UserProfileRepository.instance.completeOnboarding(profile);
      if (err != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
        }
        await _voice.speakWarning(err);
        setState(() => _saving = false);
        return;
      }

      setState(() {
        _onboardingComplete = true;
        _saving = false;
      });

      await _voice.speakInfo(
        _selected.isEmpty
            ? "Profiliniz kaydedildi. İsterseniz daha sonra ayarlardan kısıt ekleyebilirsiniz."
            : "Profiliniz kaydedildi. Seçtiğiniz kısıtlara göre ürün uyarıları vereceğim.",
      );
    } catch (e, st) {
      AppLogger.e("Onboarding kayıt hatası", e, st);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Kayıt başarısız. Tekrar deneyin.")),
        );
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _replayWelcome() async {
    await _voice.speakInfo(_welcomeText);
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = esAccessibleTitleStyle(context);
    final bodyStyle = esAccessibleBodyStyle(context);

    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          header: true,
          label: "Hoş geldiniz kurulum ekranı",
          child: const Text("Eyeshopper AI"),
        ),
        actions: [
          Semantics(
            button: true,
            label: "Karşılama metnini tekrar dinle",
            child: IconButton(
              icon: const Icon(Icons.volume_up, size: 28),
              onPressed: _replayWelcome,
              tooltip: "Karşılama metnini tekrar dinle",
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
              Text("Hoş geldiniz", style: titleStyle),
              const SizedBox(height: 8),
              Text(_welcomeText, style: bodyStyle),
              const SizedBox(height: 24),
              RestrictionSelectorSection(
                selected: _selected,
                onChanged: _onRestrictionChanged,
                customRestrictions: _customRestrictions,
                onCustomRestrictionsChanged: _onCustomRestrictionsChanged,
              ),
              const SizedBox(height: 20),
              // Otomatik kayıt durumu göster
              if (_saving)
                Semantics(
                  label: "Profil kaydediliyor",
                  child: Card(
                    color: Colors.orange,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Seçimleri kaydediliyor...",
                            style: bodyStyle?.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (_onboardingComplete)
                Semantics(
                  label: "Profil başarıyla kaydedildi",
                  child: Card(
                    color: Colors.green,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 12),
                          Text(
                            "Profiliniz kaydedildi!",
                            style: bodyStyle?.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Semantics(
                  button: true,
                  label: "Devam et butonu",
                  child: ElevatedButton(
                    onPressed: _onContinuePressed,
                    child: const Text("Devam Et"),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onContinuePressed() async {
    await _voice.speakInfo("Devam et butonuna bastınız. Profil kaydediliyor.");
    await _autoSave();
    if (_onboardingComplete && mounted) {
      // Ana ekrana geç
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }
}
