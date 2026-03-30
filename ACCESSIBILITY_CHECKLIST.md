# Erişilebilirlik Uygulanması İçin Kontrol Listesi

## 🎯 Yeni Feature Eklemesi: Adım Adım Kontrol Listesi

**Kullanım Zamanı:** Yeni ekran, dialog, widget veya feature ekliyorsanız, aşağıdaki adımları takip edin.

---

## 📋 FAZE 1: Planlama (Başlangıç)

### Sorunlu Sorular
- [ ] Bu ekran ne yapacak? (açı: İnsan/Makine)
- [ ] Hangi etkileşimler var? (button, input, toggle, vb?)
- [ ] Hangi sesli komutlar gerekli? (eğer varsa)
- [ ] Hangi TTS duyuruları gerekli? (ekran açılışı, başarı, hata)

### Referanslar
- [ ] ACCESSIBILITY_QUICK_REFERENCE.md oku (2 dakika)
- [ ] ACCESSIBILITY_MIGRATION_EXAMPLE.md'de örneği gözden geçir

---

## 🎨 FAZE 2: Implementasyon

### A. Ekran Yapısı
```
1. [ ] AccessibleScreen wrapper kullan (base scaffold)
2. [ ] title, description, screenLabel parametreleri doldur
3. [ ] Tüm title/heading'e esAccessibleHeadingStyle() ekle
4. [ ] Tüm body metnine esAccessibleBodyStyle() ekle
```

### B. Butonlar ve Interaktif Öğeler
```
3. [ ] ElevatedButton/TextButton → esPrimaryButton() dönüştür
4. [ ] IconButton/GestureDetector → esIconButton() dönüştür
5. [ ] Her butona semanticLabel ekle ("X yapart butonu")
6. [ ] Her butona semanticHint ekle ("Neden tıklanmalı?")
7. [ ] Buton boyutu: 60dp+ doğrula
8. [ ] Font size: 18px+ doğrula
```

### C. Kartlar ve Konteynerlar
```
9. [ ] Card widget → esAccessibleCard() dönüştür
10. [ ] esAccessibleCard(semanticLabel: "...") ekle
11. [ ] İçeriği padding 12-16dp ile ayarla
```

### D. Metin Alanları
```
12. [ ] TextField'a Semantics wrapper ekle
13. [ ] textField: true, label, hint parametreleri doldur
14. [ ] placeholder/hintText örneği ekle
15. [ ] Font size: 18px+ doğrula
```

### E. Bölümler / Dividers
```
16. [ ] Bölüm ayırıcıları: Divider() → esAccessibleDivider()
17. [ ] Semantik label ekle ("İstatistikler", vb)
```

### F. Görseller
```
18. [ ] Anlamlı resim varsa: Semantics(image: true, label: "...") ekle
19. [ ] İkon: esIconButton() veya esPrimaryButton() ile sarı
```

---

## 🔊 FAZE 3: Sesli Duyurular (TTS)

### Ekran Açılışında
```
20. [ ] initState() içinde SmartAssistant.announceScreen() ekle
      await SmartAssistant.instance.announceScreen(
        "Ekran Başlığı",
        "Açıklama...",
      );
21. [ ] Duyuru gecikmesi: 500ms doğrula
```

### Buton Tıklaması
```
22. [ ] onPressed önce: announceAction("...") ekle
23. [ ] Başarılı işlemde: announceSuccess("...") ekle
24. [ ] Hata durumunda: announceError("...") ekle
```

### Sesli Komut (Varsa)
```
25. [ ] Yeni komut gerekli mi? (voice_navigation_parser.dart'a ekle)
26. [ ] home_screen.dart _onListen()'e handle ekle
27. [ ] Ses geri bildirimi: "X açılıyor." ekle
```

---

## 📏 FAZE 4: Stil ve Boyut Kontolü

### Tipografi
```
28. [ ] Başlık: 24px+ (esAccessibleHeadingStyle 28px)
29. [ ] Gövde: 18px+ (esAccessibleBodyStyle)
30. [ ] Buton metni: 18px+ (esAccessibleButtonStyle)
31. [ ] Yazı kalınlığı: 600+ (kalın)
32. [ ] Satır aralığı: 1.5
```

### Boyutlandırma
```
33. [ ] Button/touch target: 60dp+ minimum
34. [ ] İkon boyutu: 36dp+ minimum
35. [ ] Padding: 12-20dp (rahat aralık)
36. [ ] Margin: 8-16dp (birbirinden ayrı)
```

### Renk ve Kontrast
```
37. [ ] Metin rengi: Beyaz (#FFFFFF) veya açık gri
38. [ ] Arka plan: Koyu (#2A2A2A, #3A3A3A)
39. [ ] Accent: Sarı (#FFC107)
40. [ ] Kontrast: 4.5:1+ doğrula (kullan: WebAIM Contrast Checker)
```

---

## 🧪 FAZA 5: Test Etme

### Android (TalkBack)
```
41. [ ] TalkBack aç: Settings > Accessibility > TalkBack > ON
42. [ ] Ekrana tıklayın → Başlık seslendirilir mi?
43. [ ] Tüm butonları kaydırarak geçin → Her biri açık mı okunuyor?
44. [ ] Her butona çift tıklayın → Doğru işlem yapılıyor mu?
45. [ ] Hata meselei: TTS seslendirilir mi?
46. [ ] Sesli komut (varsa): "Komut metni" deyin → Çalışıyor mu?
```

### iOS (VoiceOver)
```
47. [ ] VoiceOver aç: Settings > Accessibility > VoiceOver > ON
48. [ ] Ekrana dokunun → Başlık seslendirilir mi?
49. [ ] Swipe right/left ile nav → Her öğenin açıklaması var mı?
50. [ ] Double-tap seç → Işlem başarılı mı?
51. [ ] Rotor kullanın (2 parmakla döndür) → Başlıklar listeleniyor mu?
```

### Yazılı Test
```
52. [ ] flutter analyze → 0 error olmalı
53. [ ] Lint warning: "unused" varsa kontrol et
54. [ ] Code review: İş arkadaşı kontrol etsin
```

---

## 📱 FAZA 6: Versiyon Denetimi

### Dosyalar
```
55. [ ] Yeni dosyalar created (varsa)
56. [ ] Değişiklik yapılan dosyalar: git diff kontrol
57. [ ] Breakline yok mu? (Semantics parentthesis)
58. [ ] Import var mı? (es_accessibility, SmartAssistant, vs)
```

### Yapılandırma
```
59. [ ] AndroidManifest.xml: Permissions ekleme gerek mi?
60. [ ] info.plist: iOS permissions ekleme gerek mi?
```

---

## 📚 REFERANS: Özetle

| Öğe | Widget/Fonksiyon | Min Boyut | Min Font |
|-----|-----------------|----------|---------|
| Buton | `esPrimaryButton()` | 60x60dp | 18px |
| Ikon Butonu | `esIconButton()` | 60x60dp | 36dp |
| Kart | `esAccessibleCard()` | - | 18px |
| Başlık | `esAccessibleHeadingStyle()` | - | 28px |
| Gövde | `esAccessibleBodyStyle()` | - | 18px |
| Divider | `esAccessibleDivider()` | - | - |
| Metin | `TextField` | - | 18px |

---

## ✅ FONKSİYON ÇAĞRISI ŞABLONLARI

### Ekran Başında Duyurusu
```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      await SmartAssistant.instance.announceScreen(
        "Ekran Başlığı",
        "Bu ekranın amacı...",
      );
    }
  });
}
```

### Başarı Bildirimi
```dart
await SmartAssistant.instance.announceSuccess("İşlem tamamlandı.");
```

### Hata Bildirimi
```dart
await SmartAssistant.instance.announceError("Bir Problem oluştu.");
```

### Action Duyurusu
```dart
esPrimaryButton(
  onPressed: () async {
    await SmartAssistant.instance.announceAction("İşlem başlatılıyor...");
    // İşlemi yap
  },
)
```

---

## 🎓 ÖĞRENİM KAYNAKLARI

| Kaynak | Konusu | Dosya |
|--------|--------|--------|
| Kısa Referans | Hızlı kopy-paste | ACCESSIBILITY_QUICK_REFERENCE.md |
| Developer Guide | Adım adım gider | DEVELOPER_ACCESSIBILITY_GUIDE.md |
| Örnek | Önce/Sonra karşılaş | ACCESSIBILITY_MIGRATION_EXAMPLE.md |
| Kapsamlı | Tüm açıklamalar | ACCESSIBILITY_GUIDE.md |
| Bu Dosya | Kontrol Listesi | ACCESSIBILITY_CHECKLIST.md (şu dosya) |

---

## ❓ SIKÇA SORULAN SORULAR

**S: Bu tüm adımları takip etmeliyim mi?**
C: Evet! İlk dört faza (kısmi öğeler) bitmeden sonra, faza 5 ve 6'yı sadece yeni feature/screen için yaparsınız.

**S: TTS geri bildirimleri zorunlu mu?**
C: Başlık/açıklama: Evet. Bu ve işlem sonuçları: Evet. Her tıklamada ses: Hayır (sık kullanıcıları rahatsız eder).

**S: Semantics labels neden önemli?**
C: Ekran okuyucu kullanıcısı "bir şeflik" duyuyor. Label yoksa "button #23" gibi anlamsız.

**S: Font boyutu 17px olabilir mi?**
C: Tercih olarak 18px+. 17px sınırda; kontrastı ve komşu öğeleri kontrol edin.

**S: Widget'ı özelleştirmeliyim mi?**
C: `esPrimaryButton()` gibi sağlanan widget'ları kullan. Özelleştirme ihtiyacı varsa `es_accessibility.dart` güncelleyin.

---

## 📞 DESTEK

**Hata bulduysanız:**
1. Yukarı git → Related section dön
2. ACCESSIBILITY_GUIDE.md'ye bak (kapsamlı)
3. Code review isteyin

**Sorular:**
- Flutter Semantics: [Flutter Docs](https://flutter.dev/docs/development/accessibility-and-localization/accessibility)
- WCAG 2.1: [W3C Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)

---

**Son Update:** 28 Mart 2026  
**Versiyon:** 1.0  
**Kontrol Listesi Maddesi Sayısı:** 60+
