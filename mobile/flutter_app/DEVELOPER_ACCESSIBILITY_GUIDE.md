# Geliştiriciler için Erişilebilirlik Rehberi

## 🎯 Yeni Screen Oluştururken Adımlar

### Adım 1: AccessibleScreen Widget'ını Kullan

```dart
import "package:flutter/material.dart";
import "../../core/accessibility/accessible_screen.dart";
import "../../core/accessibility/es_accessibility.dart";

class MyNewScreen extends StatefulWidget {
  const MyNewScreen({super.key});

  @override
  State<MyNewScreen> createState() => _MyNewScreenState();
}

class _MyNewScreenState extends State<MyNewScreen> {
  @override
  Widget build(BuildContext context) {
    return AccessibleScreen(
      title: "Ekran Başlığı",
      description: "Burada ne yapılacağını açıkla",
      screenLabel: "Ekran okuyucu etiketi",
      additionalHint: "Sesli komutlar için 'Yardım' deyin",
      autoAnnounce: true, // Otomatik announcement
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // İçerik buraya ekle
          ],
        ),
      ),
    );
  }
}
```

### Adım 2: Butonlara Erişilebilirlik Ekle

```dart
// ✅ DOĞRU - Semantics ile
esPrimaryButton(
  context: context,
  semanticLabel: "Profili kaydet butonu",
  semanticHint: "Değişiklikleri kaydetmek için",
  onPressed: _saveProfile,
  text: "📁 Profili Kaydet",
)

// ✅ DOĞRU - İkon butonu
esIconButton(
  context: context,
  semanticLabel: "Tarama başlat butonu",
  semanticHint: "Kamera ile ürün tara",
  icon: Icons.camera,
  onPressed: _startScan,
)

// ❌ YANLIŞ - Semantics olmadan
ElevatedButton(
  onPressed: _save,
  child: const Text("Kaydet"), // Ekran okuyucu bağlamı yok
)
```

### Adım 3: Kartları Erişilebilir Yap

```dart
esAccessibleCard(
  context: context,
  semanticLabel: "Ürün bilgileri kartı",
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("Ürün Adı", style: esAccessibleTitleStyle(context)),
      const SizedBox(height: 8),
      Text("Açıklama", style: esAccessibleBodyStyle(context)),
    ],
  ),
)
```

### Adım 4: Metin Alanlarına Semantics Ekle

```dart
Semantics(
  textField: true,
  label: "Ürün adı metin alanı",
  hint: "Ürün ismini yazın",
  child: TextField(
    decoration: InputDecoration(
      labelText: "Ürün Adı",
      hintText: "Örn: Süt, Ekmek",
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
)
```

### Adım 5: GestureDetector/InkWell'e Semantics Ekle

```dart
// ❌ YANLIŞ
GestureDetector(
  onTap: () => _selectItem(item),
  child: Container(child: /*  */),
)

// ✅ DOĞRU
Semantics(
  button: true,
  label: "Ürün seç: ${item.name}",
  hint: "Bu ürünü seçmek için dokunun",
  onTap: () => _selectItem(item),
  child: GestureDetector(
    onTap: () => _selectItem(item),
    child: Container(/* */),
  ),
)
```

---

## 🎙️ Sesli Komut Ekle

### Yeni Navigasyon Komutu Tanımlama

```dart
// 1. voice_navigation_parser.dart'a ekle
enum VoiceNavigationCommand {
  myNewFeature("Yeni özellik aç"),
  // ...
}

// 2. parseNavigation() metodunda pattern ekle
if (normalized.contains("yeni özellik")) {
  return VoiceNavigationCommand.myNewFeature;
}

// 3. home_screen.dart'da _onListen()'de kullan
case VoiceNavigationCommand.myNewFeature:
  await _voice.speakInfo("Yeni özellik açılıyor.");
  if (!mounted) return;
  await _openMyNewFeature();
  break;
```

---

## 🔊 Ses Bildirimleri Ekle

### Ekran Açıldığında Sesle Bildir

```dart
@override
void initState() {
  super.initState();
  
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      await SmartAssistant.instance.announceScreen(
        "Alışveriş Listesi",
        "Liste öğeleriniz burada yer alıyor. "
        "Yeni ürün eklemek için 'Sesle ürün ekle' düğmesini kullanın.",
      );
    }
  });
}
```

### Buton Tıklandığında Ses Geri Bildirimi

```dart
Future<void> _saveProfile() async {
  try {
    // Kayıt işlemleri...
    await SmartAssistant.instance.announceSuccess("Profil kaydedildi");
  } catch (e) {
    await SmartAssistant.instance.announceError("Profil kaydedilemedi");
  }
}
```

---

## 📏 Minimum Gereklilikler Kontrol Listesi

Yeni bir screen/widget oluştururken:

- [ ] Tüm butonlar en az 60x60dp boyutta
- [ ] Tüm tıklanabilir öğelere Semantics etiketi eklendi
- [ ] Başlık Text > 20pt, body text > 16pt
- [ ] Kontrast oranı 4.5:1 üstünde
- [ ] Hata mesajları TTS ile seslendirilir
- [ ] Başarı bildirimleri seslendirilir
- [ ] Screen başlığı AccessibleScreen ile seslendirilir
- [ ] Yazı tipi ağırlığı kalın (600+)
- [ ] Hatt aralığı en az 1.4
- [ ] TextField'lara label ve hint eklenmiş

---

## 🧪 Test Etme Kılavuzu

### Kendi Widget'ını Test Et

```dart
// TalkBack etkin Android cihazda:
1. Ekrana tıklayın
2. TalkBack butonlarıyla gezinin
3. Tüm öğelerin açık açıklaması var mı kontrolü

// VoiceOver etkin iOS cihazda:
1. Ekrana tıklayın
2. Swipe gesturesle gezinin
3. Ses geri bildirimlerini kontrol edin
```

### Otomasyonlu Testler (İleride)

```dart
testWidgets('Button semantics test', (tester) async {
  await tester.pumpWidget(MyApp());
  
  expect(
    find.bySemanticsLabel("Profili kaydet butonu"),
    findsOneWidget,
  );
});
```

---

## 📚 Referans

### es_accessibility.dart'da Mevcut Fonksiyonlar

| Fonksiyon | Kullanım |
|-----------|---------|
| `esAccessibleTitleStyle()` | Sayfa başlıkları (24px) |
| `esAccessibleHeadingStyle()` | Ana başlıklar (28px) |
| `esAccessibleBodyStyle()` | Gövde metni (18px) |
| `esAccessibleButtonStyle()` | Buton metni (18px) |
| `esPrimaryButton()` | Temel buton widget |
| `esIconButton()` | İkon butonu |
| `esAccessibleScreenHeader()` | Screen header |
| `esAccessibleCard()` | Yüksek kontrast kartı |
| `esAccessibleDivider()` | Bölüm ayırıcısı |

### Semantics Türleri

| Tür | Örnek |
|-----|--------|
| `button: true` | Tıklanabilir düğme |
| `toggled: true/false` | On/off durumu |
| `textField: true` | Metin giriş alanı |
| `image: true` | Görsel öğe |
| `header: true` | Bölüm başlığı |
| `container: true` | Grup/konteyner |
| `label` | Ne olduğu |
| `hint` | Ne yapacağı |

---

## 💡 İyi Uygulamalar

✅ **Yapılacaklar:**
- Tüm öğelere açık etiketler ekle
- Semantics'i uyumlu olduğundan emin ol
- TTS duyuruları önemli eylemlerde kullan
- Text: 16pt+, touch target: 48dp+
- Kontrast: 4.5:1 (AA standar)
- Yazı tipi: Kalın ve ne kadar mümkünse büyük

❌ **Yapılmayacaklar:**
- Boş butonlar (etiket olmadan)
- 48dp'den küçük touch target
- Düşük kontrast renk kombinasyonları
- İnce yazı tipi (font weight < 500)
- Çok hızlı TTS sesleri
- Anlamlı olmayan error mesajları

---

**Son Update**: 28 Mart 2026
