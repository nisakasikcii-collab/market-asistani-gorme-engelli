# Eyeshopper AI — Flutter uygulaması

PRD ve `tasks.md` **Bölüm 0** (kurulum) ile **Bölüm 1** (erişilebilirlik + TTS/STT) bu pakette uygulanmıştır.

## Önkoşullar

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (PATH’te `flutter`)
- Android Studio / Xcode (hedef platforma göre)

## İlk kurulum

Proje kökünden veya buradan:

```powershell
cd C:\Users\nisak\Documents\eyeshopper_ai
.\scripts\bootstrap_flutter.ps1
```

Bu betik `flutter create .` çalıştırarak `android/`, `ios/` vb. platform dosyalarını üretir; `pubspec.yaml` ve `lib/` korunur.

### Gizli yapılandırma

- Şablon: `assets/config/.env.example`
- Çalışma zamanı: `assets/config/.env` (boş anahtarlarla repoda; gerçek anahtarları yerelde tutun)
- API anahtarları repoya commit etmeyin.

### Çalıştırma

```bash
cd mobile/flutter_app
flutter pub get
flutter run
```

**STT (Android):** `bootstrap_flutter.ps1` sonrası `android/app/src/main/AndroidManifest.xml` içinde `<manifest>` altına şunu ekleyin (yoksa):

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

### Firebase

`firebase_core` bağımlılığı projeye eklendi ve `lib/bootstrap/firebase_bootstrap.dart` içinde koşullu `Firebase.initializeApp` aktif edildi.

1. Firebase projesi oluşturun ve uygulama kimliklerini alın.
2. `assets/config/.env` içine bu alanları doldurun:
   - `FIREBASE_PROJECT_ID`
   - `FIREBASE_API_KEY`
   - `FIREBASE_MESSAGING_SENDER_ID`
   - `FIREBASE_APP_ID_ANDROID` / `FIREBASE_APP_ID_IOS` / `FIREBASE_APP_ID_WEB` (hedef platforma göre)
   - Opsiyonel: `FIREBASE_STORAGE_BUCKET`, `FIREBASE_AUTH_DOMAIN`
3. `flutter pub get` çalıştırın ve uygulamayı başlatın.

Not: Bu aşamada Auth/Firestore kullanımı zorunlu değil; bu görevde hedef Firebase çekirdek bağlantısının çalışır olmasıdır.

## Kod yapısı

| Klasör | Açıklama |
|--------|----------|
| `lib/core/config` | `AppConfig`, dotenv |
| `lib/core/logging` | `AppLogger` |
| `lib/core/voice` | `TtsService`, `SttService`, `VoiceFeedback`, `SpeechPriority` |
| `lib/core/accessibility` | Erişilebilir tipografi ve düğme yardımcıları |
| `lib/features/home` | Ana ekran (TalkBack/semantic denemeleri) |

## Erişilebilirlik

- `Semantics` ile açık düğme/hint metinleri
- Minimum 48 dp dokunma hedefi (`ElevatedButton` tema + yükseklik)
- TTS öncelik seviyeleri: bilgi / uyarı / kritik (konuşma hızı ve ses seviyesi)

## Kalite ve uyumluluk dokumanlari

- Gizlilik ve izin metinleri: `docs/privacy_and_permissions_tr.md`
- Release kalite kontrol listesi: `docs/release_quality_checklist_tr.md`
- Phase 2 tasarim notlari: `docs/phase2_design_notes_tr.md`
- Smoke test adimlari: `docs/SMOKE_TEST_STEPS.md`
