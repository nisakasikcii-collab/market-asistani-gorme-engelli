# Erişilebilirlik Hızlı Referans Kartı

## 📋 Yeni Widget Eklerken Kontrol Listesi (30 saniye)

```
□ Boyut: 60x60dp minimum touch target
□ Font: 18px+, kalın (600+)
□ Kontrast: Beyaz metin (#FFFFFF) + koyu arka plan (#2A2A2A)
□ Semantics: label + hint + button:true/false
□ Ses: önemli işlemlerde TTS duyurusu
```

---

## 🎨 Hızlı Kod Şablonları

### Buton
```dart
esPrimaryButton(
  context: context,
  semanticLabel: "Eylem butonu",
  semanticHint: "Açıklama: ne yapacak?",
  onPressed: _onTap,
  text: "📌 Buton Metni",
)
```

### Kart
```dart
esAccessibleCard(
  context: context,
  semanticLabel: "Ürün kartı",
  child: Column(
    children: [
      Text("Başlık", style: esAccessibleTitleStyle(context)),
      Text("İçerik", style: esAccessibleBodyStyle(context)),
    ],
  ),
)
```

### Metin Alanı
```dart
Semantics(
  textField: true,
  label: "İsim metin alanı",
  hint: "Adınızı yazın",
  child: TextField(
    decoration: InputDecoration(labelText: "Ad"),
  ),
)
```

### Basit Tıklanabilir Öğe
```dart
Semantics(
  button: true,
  label: "Seçeneği seç",
  hint: "Bu öğeyi seçmek için dokunun",
  onTap: () => _select(),
  child: Container(/* ... */),
)
```

---

## 🔊 Sesli Komutlar (13 Komut)

| Komut | Işlev |
|-------|--------|
| Tarama aç | → ScanScreen |
| Listeyi aç | → ShoppingListScreen |
| Profili aç | → ProfileScreen |
| Topluluk aç | → CommunityScreen |
| Geri dön | → pop() |
| İleri git | → next item |
| Seç / Tamam | → select |
| Tekrar oku | → repeat |
| Yardım | → help |

---

## ✨ Stil Fonksiyonları

```dart
// Başlık (24px, kalın)
Text("Başlık", style: esAccessibleTitleStyle(context))

// Gövde (18px, kalın)  
Text("Gövde", style: esAccessibleBodyStyle(context))

// Buton metni (18px, kalın)
Text("Buton", style: esAccessibleButtonStyle(context))

// Açlık başlık (28px, kalın)
Text("Ekran", style: esAccessibleHeadingStyle(context))
```

---

## 🧪 TalkBack Test (Android)

```
1. Settings > Accessibility > TalkBack > ON
2. Ekrana tıklayın (double-tap to activate)
3. Öğeler arasında nav ekştirilir (swipe right/left)
4. Sesli "Tekrar oku" testi: "Tekrar oku" deyin
```

---

## 📏 Minimum Boyutlar

| Öğe | Minimum |
|-----|---------|
| Buton (touch) | 60x60dp |
| Ikon | 36dp |
| Metin | 18px |
| Başlık | 24px+ |
| Satır aralığı | 1.5 |
| Kontrast | 4.5:1 |

---

## 🚨 Sık Hata (ve Çözüm)

**❌ Hata:** Widget'ım Semantics etiketi taşımıyor
**✅ Çözüm:** 
```dart
// Yok
Button(label: "Text")

// Vardı
esPrimaryButton(
  semanticLabel: "Buton açıklaması",
  semanticHint: "Ne yapacak?",
  // ...
)
```

**❌ Hata:** Buton 48dp'den küçük
**✅ Çözüm:** `esPrimaryButton()` veya `esIconButton()` kullan (auto 60dp)

**❌ Hata:** Ayrı TTS duyurusu yok
**✅ Çözüm:**
```dart
await SmartAssistant.instance.announceSuccess("İşlem başarılı");
```

---

## 🎯 Ekstra İpuçları

- **Her screen için:** AccessibleScreen wrapper kullan
- **Her buton için:** esPrimaryButton() veya esIconButton() kullan
- **Her kart için:** esAccessibleCard() kullan
- **Tüm metinler:** esAccessibleTitleStyle() / esAccessibleBodyStyle() kullan
- **Sesli duyuru:** SmartAssistant.instance.announceX() kullan

---

**Version:** 1.0 | **Last Updated:** 28.03.2026
