import "package:flutter/material.dart";

import "../../core/accessibility/es_accessibility.dart";
import "../../core/accessibility/voice_navigation_parser.dart";
import "../../core/logging/app_logger.dart";
import "../../core/voice/voice_feedback.dart";
import "../profile/data/user_profile_repository.dart";
import "../profile/domain/dietary_restriction.dart";
import "../profile/domain/user_health_profile.dart";
import "../profile/logic/profile_match_engine.dart";
import "../profile/profile_edit_screen.dart";
import "../scan/scan_screen.dart";
import "../community_feedback/community_feedback_screen.dart";
import "../shopping_list/data/shopping_list_repository.dart";
import "../shopping_list/shopping_list_screen.dart";
import "logic/voice_command_parser.dart";

/// Ana ekran: erişilebilir kontroller, profil özeti ve TTS/STT duman testi.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final VoiceFeedback _voice = VoiceFeedback.instance;
  final VoiceCommandParser _commandParser = VoiceCommandParser();
  final VoiceNavigationParser _navigationParser = VoiceNavigationParser();
  String _lastHeard = "";
  bool _listening = false;

  @override
  void initState() {
    super.initState();
    UserProfileRepository.instance.addListener(_onProfile);
    ShoppingListRepository.instance.addListener(_onProfile);
    
    // Ekran açıldığında otomatik sesli bilgilendirme
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // TTS'nin hazırlanmasını beklemek için biraz delay ekle
      await Future<void>.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        await _onWelcome();
      }
    });
  }

  void _onProfile() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    UserProfileRepository.instance.removeListener(_onProfile);
    ShoppingListRepository.instance.removeListener(_onProfile);
    super.dispose();
  }

  Future<void> _openProfile() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => const ProfileEditScreen(),
      ),
    );
  }

  Future<void> _openScan() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => const ScanScreen(),
      ),
    );
  }

  Future<void> _openShoppingList() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => const ShoppingListScreen(),
      ),
    );
  }

  Future<void> _openCommunityFeedback() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => const CommunityFeedbackScreen(),
      ),
    );
  }

  Future<void> _onWelcome() async {
    try {
      await _voice.speakInfo(
        "Eyeshopper AI'ye hoş geldiniz. Tarama, alışveriş listesi, topluluk geri bildirimi ve ayarlarını kullanabilirsiniz.",
      );
    } catch (e, st) {
      AppLogger.e("TTS hata", e, st);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sesli okuma başarısız. TTS ayarlarını kontrol edin.")),
        );
      }
    }
  }

  Future<void> _onPriorityDemo() async {
    await _voice.speakInfo("Bilgi: Tarama moduna hazırsınız.");
    await Future<void>.delayed(const Duration(milliseconds: 400));
    await _voice.speakWarning("Uyarı: Bu ürün profilinize uygun olmayabilir.");
    await Future<void>.delayed(const Duration(milliseconds: 400));
    await _voice.speakCritical("Kritik: Ağ bağlantısı yok. Tekrar deneyin.");
  }

  Future<void> _onListen() async {
    if (_listening) return;
    setState(() {
      _listening = true;
      _lastHeard = "";
    });
    try {
      await _voice.speakInfo("Dinliyorum.");
      final text = await _voice.listenOnce(
        listenFor: const Duration(seconds: 15),
        localeId: "tr_TR",
      );
      setState(() => _lastHeard = text ?? "");
      if (text != null && text.isNotEmpty) {
        // Önce eski komut yapısını kontrol et (backward compatibility)
        final oldCommand = _commandParser.parseCommand(text);
        
        if (oldCommand != VoiceCommand.unknown) {
          switch (oldCommand) {
            case VoiceCommand.openProfile:
              await _voice.speakInfo("Profil ayarları açılıyor.");
              if (!mounted) return;
              await _openProfile();
              break;
            case VoiceCommand.openScan:
              await _voice.speakInfo("Tarama ekranı açılıyor.");
              if (!mounted) return;
              await _openScan();
              break;
            case VoiceCommand.openShoppingList:
              await _voice.speakInfo("Alışveriş listesi açılıyor.");
              if (!mounted) return;
              await _openShoppingList();
              break;
            case VoiceCommand.openCommunityFeedback:
              await _voice.speakInfo("Topluluk geri bildirimi açılıyor.");
              if (!mounted) return;
              await _openCommunityFeedback();
              break;
            case VoiceCommand.unknown:
              break;
          }
        } else {
          // Yeni navigation komut yapısını kontrol et
          final navCommand = _navigationParser.parseNavigation(text);
          
          switch (navCommand) {
            case VoiceNavigationCommand.scanOpen:
              await _voice.speakInfo("Tarama ekranı açılıyor.");
              if (!mounted) return;
              await _openScan();
              break;
            case VoiceNavigationCommand.listOpen:
            case VoiceNavigationCommand.listOpen2:
              await _voice.speakInfo("Alışveriş listesi açılıyor.");
              if (!mounted) return;
              await _openShoppingList();
              break;
            case VoiceNavigationCommand.profileOpen:
            case VoiceNavigationCommand.profileOpen2:
              await _voice.speakInfo("Profil ayarları açılıyor.");
              if (!mounted) return;
              await _openProfile();
              break;
            case VoiceNavigationCommand.communityOpen:
              await _voice.speakInfo("Topluluk geri bildirimi açılıyor.");
              if (!mounted) return;
              await _openCommunityFeedback();
              break;
            case VoiceNavigationCommand.help:
            case VoiceNavigationCommand.helpOpen:
              await _voice.speakInfo(_navigationParser.getAllCommandsDescription());
              break;
            case VoiceNavigationCommand.repeat:
            case VoiceNavigationCommand.repeatDescription:
              await _onWelcome();
              break;
            case VoiceNavigationCommand.unknown:
              await _voice.speakWarning(
                "Komut algılanmadı. Yardım almak için 'Yardım' deyin. "
                "Veya şu komutlardan birini deneyin: Tarama aç, Listeyi aç, Profili aç.",
              );
              break;
            default:
              await _voice.speakWarning("Bu komut şu an desteklenmiyor.");
          }
        }
      } else {
        await _voice.speakWarning("Konuşma algılanmadı. Tekrar deneyin.");
      }
    } catch (e, st) {
      AppLogger.e("STT hata", e, st);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sesli komut hatası.")),
        );
      }
    } finally {
      if (mounted) setState(() => _listening = false);
    }
  }

  Future<void> _onSpeakShoppingListStatus() async {
    final items = ShoppingListRepository.instance.items;
    if (items.isEmpty) {
      await _voice.speakInfo("Alışveriş listeniz boş.");
      return;
    }
    final pending = items.where((e) => !e.isCompleted).toList();
    if (pending.isEmpty) {
      await _voice.speakInfo("Listedeki tüm ürünler bulundu.");
      return;
    }
    await _voice.speakInfo("Listede ${pending.length} ürün bekliyor.");
  }

  Future<void> _onAddToShoppingListByVoice() async {
    if (_listening) return;
    setState(() {
      _listening = true;
      _lastHeard = "";
    });
    try {
      await _voice.speakInfo("Ürün adını söyleyin. Listeye eklenecek.");
      final productName = await _voice.listenOnce(
        listenFor: const Duration(seconds: 10),
        localeId: "tr_TR",
      );
      if (productName != null && productName.isNotEmpty) {
        setState(() => _lastHeard = productName);
        await ShoppingListRepository.instance.addItem(productName);
        await _voice.speakInfo("$productName listeye eklendi.");
      } else {
        await _voice.speakWarning("Ürün algılanmadı. Tekrar deneyin.");
      }
    } catch (e, st) {
      AppLogger.e("Listeye sesle ekle hatası", e, st);
      await _voice.speakWarning("Ürün eklenemedi. Tekrar deneyin.");
    } finally {
      if (mounted) setState(() => _listening = false);
    }
  }

  /// Örnek içindekiler metni — profil motoru duman testi.
  Future<void> _onMatchDemo() async {
    final repo = UserProfileRepository.instance;
    final profile = repo.profile ?? const UserHealthProfile(restrictions: {});
    const sample =
        "İçindekiler: tam buğday unu, şeker, süt tozu, whey protein, yumurta.";
    final result = ProfileMatchEngine.evaluate(
      profile: profile,
      productText: sample,
    );
    if (!result.hasConflict) {
      await _voice.speakInfo(
        "Örnek metinde seçtiğiniz kısıtlarla çakışma bulunmadı.",
      );
      return;
    }
    final first = result.violations.values.first;
    await _voice.speakWarning(first);
  }

  String _profileSummaryLine() {
    final p = UserProfileRepository.instance.profile;
    final set = p?.restrictions ?? {};
    if (set.isEmpty) {
      return "Kayıtlı kısıt yok. İsterseniz profilden ekleyebilirsiniz.";
    }
    final names = set.map((r) => r.displayNameTr).join(", ");
    return "Seçili kısıtlar: $names";
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = esAccessibleTitleStyle(context);
    final bodyStyle = esAccessibleBodyStyle(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          header: true,
          label: "Eyeshopper AI ana ekran",
          child: const Text("Eyeshopper AI"),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================== ANA İŞLEMLER ====================
              Text("Ana İşlemler", style: titleStyle),
              const SizedBox(height: 16),
              esPrimaryButton(
                context: context,
                semanticLabel: "Kamera ile ürün tarama ekranını aç",
                semanticHint: "Kamera önizleme görüntülenir",
                onPressed: _openScan,
                text: "📷 Tarama ekranını aç",
              ),
              const SizedBox(height: 12),
              esPrimaryButton(
                context: context,
                semanticLabel: "Alışveriş listesine git",
                semanticHint: "Liste ürünlerini görüntüle",
                onPressed: _openShoppingList,
                text: "📝 Alışveriş listesine git",
              ),
              const SizedBox(height: 12),
              esPrimaryButton(
                context: context,
                semanticLabel: "Alışveriş listesine sesle ürün ekle",
                semanticHint: "Mikrofon ile ürün adını söyleyin",
                onPressed: _listening ? null : _onAddToShoppingListByVoice,
                text: _listening ? "⏺️ Dinleniyor…" : "🎤 Listeye sesle ürün ekle",
              ),
              const SizedBox(height: 12),
              esPrimaryButton(
                context: context,
                semanticLabel: "Topluluk geri bildirim ekranını aç",
                semanticHint: "Sesli not bırakabilirsiniz",
                onPressed: _openCommunityFeedback,
                text: "💬 Topluluk geri bildirimi",
              ),
              const SizedBox(height: 12),
              esPrimaryButton(
                context: context,
                semanticLabel: "Akıllı alışveriş listesi özeti",
                semanticHint: "Liste durumunu seslendir",
                onPressed: _onSpeakShoppingListStatus,
                text: "📊 Akıllı alışveriş listesi",
              ),
              const SizedBox(height: 32),
              // ==================== AYARLAR ====================
              Text("Ayarlar", style: titleStyle),
              const SizedBox(height: 16),
              // --- Profiliniz Kartı ---
              Card(
                color: theme.colorScheme.surfaceContainer,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person, 
                            color: theme.colorScheme.primary, 
                            size: 28),
                          const SizedBox(width: 12),
                          Text(
                            "Profiliniz",
                            style: titleStyle?.copyWith(fontSize: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _profileSummaryLine(),
                        style: bodyStyle?.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: Semantics(
                          button: true,
                          label: "Profili düzenle butonu",
                          hint: "Sağlık kısıtlarını ekle veya değiştir",
                          child: ElevatedButton.icon(
                            onPressed: _openProfile,
                            icon: const Icon(Icons.edit),
                            label: const Text("Profili düzenle"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // --- Ses Kartı ---
              Card(
                color: theme.colorScheme.surfaceContainer,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.volume_up, 
                            color: theme.colorScheme.primary, 
                            size: 28),
                          const SizedBox(width: 12),
                          Text(
                            "Ses Ayarları",
                            style: titleStyle?.copyWith(fontSize: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "TTS/STT test ve öncelik seviyeleri",
                        style: bodyStyle?.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: Semantics(
                          button: true,
                          label: "Karşılamayı seslendir butonu",
                          hint: "Uygulama tanıtımını dinle",
                          child: ElevatedButton.icon(
                            onPressed: _onWelcome,
                            icon: const Icon(Icons.play_arrow),
                            label: const Text("Karşılamayı seslendir"),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: Semantics(
                          button: true,
                          label: "Öncelik tonlarını dinle butonu",
                          hint: "Bilgi, uyarı ve kritik ses seviyelerini dene",
                          child: ElevatedButton.icon(
                            onPressed: _onPriorityDemo,
                            icon: const Icon(Icons.info),
                            label: const Text("Öncelik tonlarını dinle"),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: Semantics(
                          button: true,
                          label: "Sesli komut dinle butonu",
                          hint: "Mikrofon ile komut ver",
                          child: ElevatedButton.icon(
                            onPressed: _listening ? null : _onListen,
                            icon: Icon(_listening ? Icons.stop : Icons.mic),
                            label: Text(_listening ? "Dinleniyor…" : "Sesli komut (dinle)"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // --- Erişilebilirlik Kartı ---
              Card(
                color: theme.colorScheme.surfaceContainer,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.accessibility, 
                            color: theme.colorScheme.primary, 
                            size: 28),
                          const SizedBox(width: 12),
                          Text(
                            "Erişilebilirlik",
                            style: titleStyle?.copyWith(fontSize: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Bu uygulama ekran okuyucu ve sesli komutlar ile kullana bilir. Dokunma hedefleri 48dp minimum.",
                        style: bodyStyle?.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: Semantics(
                          button: true,
                          label: "Profil uyarısını dene butonu",
                          hint: "Sağlık profili uyarısı örneğini dinle",
                          child: ElevatedButton.icon(
                            onPressed: _onMatchDemo,
                            icon: const Icon(Icons.check_circle),
                            label: const Text("Profil uyarısını dene"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // --- Son Konuşma ---
              if (_lastHeard.isNotEmpty)
                Semantics(
                  label: "Son algılanan konuşma metni",
                  value: _lastHeard,
                  child: Text(
                    "Son konuşma: $_lastHeard",
                    style: bodyStyle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
