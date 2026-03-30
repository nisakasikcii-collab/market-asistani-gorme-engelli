# Eyeshopper AI - Erişilebilirlik ve Sesli Navigasyon Rehberi

## 📋 Genel Bakış

Bu belge, Eyeshopper AI uygulamasındaki görme engelli kullanıcılar için uygulanmış erişilebilirlik ve sesli navigasyon özelliklerini açıklamaktadır.

---

## 1. 🎯 Erişilebilirlik Özelliği Değişiklikleri

### 1.1 Geliştirilmiş Metin Stilleri (`es_accessibility.dart`)

#### Değişiklikler:
- **Başlık boyutu**: 22px → 24px (daha büyük ve net)
- **Gövde metni satır yüksekliği**: 1.4 → 1.5 (okuma rahatı)
- **Harf aralığı** eklendi: 0.5 (daha iyi okunaklılık)

#### Yeni Stil Fonksiyonları:
```dart
esAccessibleHeadingStyle() // 28px başlık (sayfa başlığı için)
esAccessibleButtonStyle() // 18px buton metni
```

### 1.2 Geliştirilmiş Butonlar

#### `esPrimaryButton()` - Temel buton
- **Boyut**: 60dp yükseklik (WCAG standart minimum touch target)
- **Semantics**: `button: true, label, hint, enabled`
- **Stil**: Kalın yazı tipi, yüksek kontrast

#### `esIconButton()` - İkon buton
- **Touch target**: Minimum 60x60dp
- **Ikon boyutu**: 36dp
- **Splash radius**: 30dp (daha geniş geri bildirim)
- **Semantics**: Açık etiket ve ipucu

#### Örnek Kullanım:
```dart
esIconButton(
  context: context,
  semanticLabel: "Profili düzenle butonu",
  semanticHint: "Sağlık kısıtlarını ekle veya değiştir",
  icon: Icons.edit,
  onPressed: _openProfile,
)
```

### 1.3 Yeni Erişilebilir Widget'lar

#### `esAccessibleScreenHeader()`
Ekran başlığı + açıklama + ipucu gösterir:
```dart
esAccessibleScreenHeader(
  context: context,
  title: "Tarama Ekranı",
  subtitle: "Ürünleri kamera ile tarayın",
  screenLabel: "Tarama ekranı başlığı",
)
```
- Ekran okuyucu önce başlığı okur
- Açıklama otomatik seslendirilir

#### `esAccessibleCard()`
Yüksek kontrast kartı:
- **Kenarlık**: 2px kalınlığı (görünürlük)
- **Elevation**: 6 (daha belirgin)
- **Renk**: surfaceContainer (yüksek kontrast)

#### `esAccessibleDivider()`
Bölüm ayırıcı:
- **Kalınlık**: 3px
- **Semantics**: "Bölüm ayırıcı" etiketi

---

## 2. 🎙️ Sesli Komut Sistemi

### 2.1 Yeni Komut Parser (`voice_navigation_parser.dart`)

#### Desteklenen Komutlar:
```
Tarama aç          → Ürün tarama ekranını aç
Listeyi aç         → Alışveriş listesine git
Profili aç         → Sağlık ayarlarını aç
Topluluk aç        → Geri bildirim ekranını aç
Geri dön           → Önceki ekrana dön
İleri git          → Sonraki öğeye geç
Seç / Tamam        → Mevcut öğeyi seç
Tekrar oku         → Başlığı tekrar dinle
Yardım             → Tüm komutları listele
```

#### Özellikler:
- **Fuzzy matching**: "Tara" → "Tarama aç" olarak tanınır
- **Çeşitli söyleyişler**: "Listeyi aç" veya "Liste aç" çalışır
- **Hata işleme**: Tanınmayan komutlara yardım sunulur

#### Kullanımı:
```dart
final parser = VoiceNavigationParser();
final command = parser.parseNavigation("tarama aç");
// command == VoiceNavigationCommand.scanOpen

// Tüm komutları öğren
final help = parser.getAllCommandsDescription();
```

---

## 3. 🤖 Akıllı Asistan Modu (`smart_assistant.dart`)

### 3.1 İlk Açılış Rehberliği
Uygulama ilk kez açıldığında:

```
1. Hoş geldiniz mesajı (uygulamanın amacı)
2. Tarama özelliği (kamera ile ürün analizi)
3. Alışveriş listesi (sesle ürün ekleme)
4. Profil ayarları (sağlık kısıtlamaları)
5. Sesli komutlar (navigation yöntemleri)
6. Hazırluk bitişi (uygulamaya başlamaya hazır)
```

### 3.2 Akıllı Duyurular

#### `announceScreen(screenName, description)`
Yeni ekrana girildiğinde:
```dart
await SmartAssistant.instance.announceScreen(
  "Tarama Ekranı",
  "Ürünü kameranın ortasına getirerek analiz edin"
);
```

#### `announceAction(actionName)`
Buton eylemi sonrası:
```dart
await SmartAssistant.instance.announceAction("Profili kaydet");
// Seslendiririr: "Profili kaydet seçildi."
```

#### `announceError(error)` ve `announceSuccess(message)`
Hata/başarı durumları seslendirilir.

---

## 4. 📱 Ekran Yükleme TTS Otomasyonu (`accessible_screen.dart`)

### 4.1 Otomatik Ekran Duyuruları

`AccessibleScreenAnnouncer` widget'ı ekran yüklendiğinde otomatik olarak:
1. Ekran başlığını okur
2. Açıklamayı seslendiriilir
3. İpuçlarını ekler

#### Kullanımı:
```dart
AccessibleScreenAnnouncer(
  screenTitle: "Tarama Ekranı",
  screenDescription: "Ürün taraması yapabilirsiniz",
  additionalHint: "Sesli komut için 'Yardım' deyin",
  delay: Duration(milliseconds: 500),
  child: MyScreenContent(),
)
```

### 4.2 AccessibleScreen Widget'ı
Hazır screen yapısı:

```dart
AccessibleScreen(
  title: "Alışveriş Listesi",
  description: "Ürünlerinizi yönetin",
  screenLabel: "Alışveriş listesi ekranı",
  autoAnnounce: true,
  body: ListViewWidget(),
)
```

---

## 5. 🔊 Sesli Navigasyon Entegrasyonu

### 5.1 Ana Ekranda (`home_screen.dart`)

Ses komutu tetiklendiğinde:

```dart
// 1. Eski komut formatını kontrol et (backward compat.)
final oldCommand = _commandParser.parseCommand(text);

// 2. Yeni navigation komutunu kontrol et
final navCommand = _navigationParser.parseNavigation(text);

// 3. Uygun işlemi gerçekleştir
switch(navCommand) {
  case VoiceNavigationCommand.scanOpen:
    await _openScan();
    break;
  case VoiceNavigationCommand.help:
    await _voice.speakInfo(_navigationParser.getAllCommandsDescription());
    break;
  // ... diğer komutlar
}
```

---

## 6. 🎨 UI Tasarım İyileştirmeleri

### 6.1 Kontras Oranları
- **Arka plan**: Koyu gri (#2A2A2A)
- **Metin**: Beyaz (#FFFFFF)
- **Vurgu**: Sarı (#FFC107)
- **Kontrast oranı**: 4.5:1 ve üstü (WCAG AA geçer)

### 6.2 Touch Target Boyutları
- **Butonlar**: Minimum 60x60dp
- **İkonlar**: 36dp boyutunda
- **Dokunma alanı**: Tüm interaktif öğeler 48dp+ 

### 6.3 Yazı Tipi Seçimleri
- **Başlık**: 24-28px, kalın (Font Weight 600-700)
- **Gövde**: 18px, 1.5 satır yüksekliği
- **Harf aralığı**: Eklenmiş (0.3-0.5)

---

## 7. 🧭 Semantics Öğeleri

### 7.1 Tüm Butonlara Eklenen Etiketler

```dart
Semantics(
  button: true,
  label: "Ne olduğu" (örn: "Profili düzenle butonu"),
  hint: "Ne yapacağı" (örn: "Sağlık kısıtlarını ekle"),
  enabled: true/false,
  child: Button(),
)
```

### 7.2 Metin Alanları

```dart
Semantics(
  textField: true,
  label: "Diğer özel kısıtlamalar metin alanı",
  hint: "Virgülle ayırarak yazın",
  child: TextField(),
)
```

### 7.3 Görseller

```dart
Semantics(
  image: true,
  label: "Kamera önizlemesi, ürün tarama için aktif",
  hint: "Ürünü çerçeveye getirerek analiz edin",
  child: CameraPreview(),
)
```

---

## 8. 🧪 Test Etme Rehberi

### Android - TalkBack ile Test

1. **Ayarlar > Erişilebilirlik > TalkBack** açın
2. **Homescreen'i açın** - Akıllı asistan rehberliğini dinleyin
3. **Sesli komut deneyin** - "Tarama aç" deyin
4. **Butonları kaydırarak keşfedin** - Etiketler okunacak
5. **Butonlara zar vurarak aktivasyonu deneyin**

### iOS - VoiceOver ile Test

1. **Ayarlar > Erişilebilirlik > VoiceOver** açın
2. **HomeScreen'i açın** - Duyurular başlayacak
3. **Jestler ile navigasyon**: Z hareketi (geri), U hareketi (ileri)
4. **Seçti tutarak koş** - Buton açıklamasını dinleyin

### Sesli Komut Testi
```
1. İlk ekranda "Yardım" deyin → Komut listesi seslendirilir
2. "Tarama aç" deyin → Tarama ekranı açılır + duyuru yapılır
3. "Listeyi aç" deyin → Alışveriş listesi açılır
4. Geri butonuna dokunun → Önceki ekrana dönülür
```

---

## 9. 📚 Dosya Listesi

### Yeni Oluşturulan Dosyalar:
- `lib/core/accessibility/smart_assistant.dart` - Akıllı asistan
- `lib/core/accessibility/voice_navigation_parser.dart` - Komut parser
- `lib/core/accessibility/accessible_screen.dart` - Screen helpers

### Güncellenmiş Dosyalar:
- `lib/core/accessibility/es_accessibility.dart` - Yeni widget'lar
- `lib/app_entry.dart` - Akıllı asistan başlatması
- `lib/features/home/home_screen.dart` - Voice navigation
- `lib/features/onboarding/onboarding_screen.dart` - Semantics
- `lib/features/profile/widgets/restriction_selector_section.dart` - Semantics
- `lib/features/scan/scan_screen.dart` - Semantics
- Birçok buton ve widget'a Semantics eklendi

---

## 10. ✅ Uygunluk Kontrol Listesi

- [x] Tüm butonlara açık etiketler eklendi
- [x] Minimum 60dp touch target boyutu sağlandı
- [x] Yüksek kontrast renk şeması kullanıldı
- [x] Sesli komut navigation sistemi eklendi
- [x] TTS ekran duyuruları başlatıldı
- [x] Akıllı asistan rehberliği eklendi
- [x] Screen reader (TalkBack/VoiceOver) uyumluluğu
- [x] Semantics hiyerarşi düzeltildi
- [x] Error handling iyileştirildi

---

## 11. 🚀 Gelecek İyileştirmeler

1. **Arama geçmişi seslendir** - Daha önce taranmış ürünler
2. **Tarama sonuçları sesli özetle** - Fiyat, kalori vb.
3. **Büyütme modu** - 200% zoom seçeneği
4. **Koşu modu** - Hızlı seçim için kısayollar
5. **Kişiselleştirilmiş sesli rehberlik** - Ses tercihine göre

---

## 📞 Destek

Sorun veya soru için lütfen konuşmayı devam ettirin.

---

**Son Güncellenme**: 28 Mart 2026
**Uyum**: WCAG 2.1 AA Standardı
