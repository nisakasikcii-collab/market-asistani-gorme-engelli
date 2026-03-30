import "package:flutter/material.dart";

import "../../core/accessibility/es_accessibility.dart";
import "../../core/accessibility/smart_assistant.dart";
import "../../core/logging/app_logger.dart";
import "../../core/voice/voice_feedback.dart";
import "../profile/data/user_profile_repository.dart";
import "../profile/domain/user_health_profile.dart";

/// Diğer/Özel Durumlar Ekranı: Kullanıcı özel kısıtlamalarını yazabilir.
class OtherConditionsScreen extends StatefulWidget {
  const OtherConditionsScreen({super.key});

  @override
  State<OtherConditionsScreen> createState() => _OtherConditionsScreenState();
}

class _OtherConditionsScreenState extends State<OtherConditionsScreen> {
  final VoiceFeedback _voice = VoiceFeedback.instance;
  final TextEditingController _conditionController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Ekran açıldığında otomatik sesli duyurusu
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        await SmartAssistant.instance.announceScreen(
          "Özel Durumlar",
          "Burada rahatsızlığınızı veya özel durumunuzu yazabilirsiniz. "
          "Örneğin: Migreni, Astım, Diyabet, vb.",
        );
      }
    });
  }

  @override
  void dispose() {
    _conditionController.dispose();
    super.dispose();
  }

  /// Metin alanındaki yazıyı kaydet ve geri dön
  Future<void> _onSaveAndContinue() async {
    final customCondition = _conditionController.text.trim();

    if (customCondition.isEmpty) {
      await _voice.speakWarning("Lütfen özel durumunuzu yazın.");
      return;
    }

    setState(() => _saving = true);

    try {
      // Mevcut profili al
      final repo = UserProfileRepository.instance;
      final currentProfile = repo.profile ?? const UserHealthProfile(restrictions: {});

      // Yeni özel kısıtlamayı ekle
      final updatedCustomRestrictions = [
        ...currentProfile.customRestrictions,
        customCondition,
      ];

      // Profili güncelle
      final updatedProfile = currentProfile.copyWith(
        customRestrictions: updatedCustomRestrictions,
      );

      // Profili kaydet
      final err = await repo.updateProfile(updatedProfile);
      if (err != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Kayıt hatası: $err")),
          );
        }
        await _voice.speakWarning("Kayıt başarısız: $err");
        setState(() => _saving = false);
        return;
      }

      // Başarı bildirimi
      await SmartAssistant.instance.announceSuccess(
        "\"$customCondition\" kaydedildi. Ana ekrana geri dönülüyor.",
      );

      if (mounted) {
        setState(() => _saving = false);
        // Onboarding ekranına geri dön
        Navigator.of(context).pop();
      }
    } catch (e, st) {
      AppLogger.e("Özel durum kayıt hatası", e, st);
      await _voice.speakWarning("Bir hata oluştu: $e");
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  /// Geri dön
  Future<void> _onCancel() async {
    await _voice.speakInfo("İptal. Önceki ekrana dönülüyor.");
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = esAccessibleTitleStyle(context);
    final bodyStyle = esAccessibleBodyStyle(context);
    final headingStyle = esAccessibleHeadingStyle(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          header: true,
          label: "Özel durumlar ekranı",
          child: const Text("Özel Durumlar"),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================== BAŞLIK ====================
              Text(
                "Özel Durumunuzu Yazın",
                style: headingStyle,
              ),
              const SizedBox(height: 12),

              // ==================== AÇIKLAMA ====================
              Text(
                "Rahatsızlığınız veya özel durumunuz var mı? "
                "Örneğin: Migreni, Astım, Diyabet, Alerjik reaksiyon, vb. "
                "Yazın ki ürün uyarıları özelleştirelim.",
                style: bodyStyle,
              ),
              const SizedBox(height: 24),

              // ==================== METIN ALANI ====================
              Semantics(
                textField: true,
                label: "Özel durum veya rahatsızlık metin alanı",
                hint: "Lütfen buraya rahatsızlığınızı veya özel durumunuzu yazın. "
                    "Örneğin: Migreni, Astım, Diyabet.",
                enabled: !_saving,
                child: TextField(
                  controller: _conditionController,
                  enabled: !_saving,
                  maxLines: 6,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    labelText: "Özel Durum",
                    hintText: "Örn: Migreni, Astım, Diyabet, vb.",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outline,
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outline,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 3,
                      ),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  style: esAccessibleBodyStyle(context)?.copyWith(fontSize: 18),
                ),
              ),

              const SizedBox(height: 32),

              // ==================== BUTONLAR ====================
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Kaydet ve Devam Et Butonu
                  esPrimaryButton(
                    context: context,
                    semanticLabel: "Kaydet ve devam et butonu",
                    semanticHint: "Özel durumunuzu kaydederek önceki ekrana dön",
                    onPressed: _saving ? null : _onSaveAndContinue,
                    text: _saving
                        ? "⏳ Kaydediliyor…"
                        : "✅ Kaydet ve Devam Et",
                  ),
                  const SizedBox(height: 12),

                  // İptal Butonu
                  esPrimaryButton(
                    context: context,
                    semanticLabel: "İptal butonu",
                    semanticHint: "Bu ekranı kapatır ve önceki sayfaya döner",
                    onPressed: _saving ? null : _onCancel,
                    text: "❌ İptal",
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ==================== ÖRNEK ====================
              Semantics(
                container: true,
                label: "Örnek özel durumlar kartı",
                child: esAccessibleCard(
                  context: context,
                  semanticLabel: "Örnek özel durumlar",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Örnek:",
                        style: titleStyle,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "• Migreni (baş ağrısı)\n"
                        "• Astım (solunum sorunu)\n"
                        "• Diyabet (kan şekeri)\n"
                        "• Kalp hastalığı\n"
                        "• Böbrek hastalığı\n"
                        "• Ruh sağlığı (depresyon, anksiyete)\n"
                        "• Uyku bozukluğu",
                        style: bodyStyle,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
