# Örnek: Screen Dönüştürme (Yaşlı → Erişilebilir)

## 📝 Dönüştürme Örneği: ProfileScreen

### ❌ ÖNCESİ (Erişilebilir DEĞİL)

```dart
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profilim")),
      body: Column(
        children: [
          // SORUN 1: Text'in semantics etiketi yok
          Text("Sağlık Kısıtlamalarım", style: TextStyle(fontSize: 18)),
          
          // SORUN 2: Button 48dp'den küçük, semantics yok
          ElevatedButton(
            onPressed: () => _editProfile(),
            child: Text("Düzenle"),
          ),
          
          // SORUN 3: GestureDetector'un semantics'i yok
          GestureDetector(
            onTap: () => _navigateToSettings(),
            child: Container(
              width: 40, // SORUN: 60dp'den küçük
              height: 40,
              child: Icon(Icons.settings),
            ),
          ),
          
          // SORUN 4: TextField'ın hint'i yok
          TextField(
            decoration: InputDecoration(labelText: "Adı"),
          ),
        ],
      ),
    );
  }
}
```

### ⚠️ SORUNLAR
1. ❌ Buton 40dp (minimum 60dp olmalı)
2. ❌ Hiç Semantics etiketi yok
3. ❌ TextField'da hint/description yok
4. ❌ Yazı tipi boyutu küçük (18px)
5. ❌ TTS duyurusu yok
6. ❌ Ekran başlığı AccessibleScreen değil

### ✅ SONRASI (Erişilebilir)

```dart
import "../../core/accessibility/accessible_screen.dart";
import "../../core/accessibility/es_accessibility.dart";
import "../../core/accessibility/smart_assistant.dart";

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // ✅ EKLEME 1: Ekran açıldığında sesli duyuru
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        await SmartAssistant.instance.announceScreen(
          "Profilim",
          "Burada sağlık kısıtlamalarınız ve ayarlarınız yer alıyor. "
          "Profili düzenlemek için 'Düzenle' düğmesini kullanın.",
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ EKLEME 2: AccessibleScreen wrapper kullan
    return AccessibleScreen(
      title: "Profilim",
      description: "Sağlık kısıtlamalarınız ve ayarlarınız",
      screenLabel: "Profil ekranı",
      additionalHint:
          "Düzenle butonunu kullanarak profili güncelleyebilirsiniz. "
          "Sesli komutlar için 'Yardım' deyin.",
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ DÜZELTME 1: Semantics + büyük yazı tipi
            Semantics(
              label: "Sağlık kısıtlamaları bölümü",
              enabled: true,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  "Sağlık Kısıtlamalarım",
                  style: esAccessibleHeadingStyle(context), // 28px, kalın
                ),
              ),
            ),

            // ✅ DÜZELTME 2: esAccessibleCard + Semantics
            esAccessibleCard(
              context: context,
              semanticLabel: "Sağlık kısıtlamalarının listesi",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Aktif Kısıtlamalar",
                    style: esAccessibleTitleStyle(context), // 24px, kalın
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Gluten, Süt, Yer fıstığı",
                    style: esAccessibleBodyStyle(context), // 18px
                  ),
                  const SizedBox(height: 16),
                  // ✅ DÜZELTME 3: esPrimaryButton + Semantics
                  esPrimaryButton(
                    context: context,
                    semanticLabel: "Profili düzenle butonu",
                    semanticHint: "Sağlık kısıtlamalarınızı güncellemek için",
                    onPressed: () async {
                      // ✅ EKLEME 3: Hoşlanılan TTS bildirimi
                      await SmartAssistant.instance
                          .announceAction("Profili düzenle ekranı açılıyor.");
                      if (!mounted) return;
                      _editProfile();
                    },
                    text: "✏️ Profili Düzenle",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ✅ DÜZELTME 4: Semantics başlık
            Semantics(
              label: "Ayarlar bölümü",
              enabled: true,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  "Ayarlar",
                  style: esAccessibleHeadingStyle(context), // 28px, kalın
                ),
              ),
            ),

            // ✅ DÜZELTME 5: esIconButton + Semantics (60x60dp min)
            Row(
              children: [
                esIconButton(
                  context: context,
                  semanticLabel: "Ayarları açan buton",
                  semanticHint: "Uygulamayı yapılandırmak için",
                  icon: Icons.settings,
                  onPressed: () async {
                    await SmartAssistant.instance
                        .announceAction("Ayarlar açılıyor.");
                    if (!mounted) return;
                    _navigateToSettings();
                  },
                ),
                const SizedBox(width: 12),
                Text(
                  "Ayarları Düzenle",
                  style: esAccessibleBodyStyle(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ✅ DÜZELTME 6: Semantics metin alanı + hint
            Semantics(
              textField: true,
              label: "Kullanıcı adı metin alanı",
              hint: "Profiliniz için adınızı yazın",
              enabled: true,
              child: TextField(
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "Adınız",
                  hintText: "Örn: Ali Yılmaz",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                style: esAccessibleBodyStyle(context), // 18px
              ),
            ),

            const SizedBox(height: 16),

            // ✅ DÜZELTME 7: Bölüm ayırıcısı
            esAccessibleDivider(
              context: context,
              label: "İstatistikler",
            ),

            const SizedBox(height: 16),

            // ✅ DÜZELTME 8: İstatistikler kartı
            esAccessibleCard(
              context: context,
              semanticLabel: "Profil istatistikleri kartı",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "İstatistiklerim",
                    style: esAccessibleTitleStyle(context),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Tarama Sayısı: 234\nListede: 45 ürün\nSeviye: Altın",
                    style: esAccessibleBodyStyle(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editProfile() async {
    // Profil düzenleme işlemleri
    await SmartAssistant.instance.announceSuccess("Profil güncellendi");
  }

  Future<void> _navigateToSettings() async {
    // Ayarlar ekranına gitme
  }
}
```

### 📊 KARŞILAŞTIRMA

| Kriter | Öncesi | Sonrası |
|--------|--------|---------|
| Buton Boyutu | 40dp ❌ | 60dp ✅ |
| Semantics Etiketi | Yok ❌ | Tümü var ✅ |
| Yazı Boyutu | 18px ❌ | 24-28px ✅ |
| TTS Duyurusu | Yok ❌ | Tam ✅ |
| Ekran Açıldığında Ses | Yok ❌ | Evet ✅ |
| Metin Alanı Hint | Yok ❌ | Var ✅ |
| Kontrastı Kontrol | Hayır ❌ | Evet ✅ |
| Satır Aralığı | 1.4 ❌ | 1.5 ✅ |

---

## 🎯 ÖnemliDEĞİŞİKLİKLER

### 1️⃣ **AccessibleScreen Wrapper**
- StatekullMi: Scaffold → AccessibleScreen
- Avantaj: Başlık + açıklama + otomatik duyuru

### 2️⃣ **Buton Boyutlandırması**
- Eski: 40x40dp
- Yeni: 60x60dp (minimum WCAG)

### 3️⃣ **Semantics Ekleme**
- Her etkileşimli öğeye `label` + `hint` + tür
- Widget paketlemek: `Semantics( ... , child: widget)`

### 4️⃣ **Yazı Tipi Ölçeklendirmesi**
- Başlık: 18px → 24-28px
- Artan fonksıyonları kullan: `esAccessibleHeadingStyle()`

### 5️⃣ **EntryPoint TTS**
- `initState()` içinde `SmartAssistant.announceScreen()`
- `WidgetsBinding.instance.addPostFrameCallback()`

### 6️⃣ **Olay Takibini TTS**
- `onPressed` işleme öncesi: `announceAction()`
- Sonrası: `announceSuccess()` veya `announceError()`

---

## ✨ ÖnEMLİ: DIĞ ÇABUKLIK

Tüm değişiklikler:
- ✅ **Yapı değişmedi** (yine Column/Row/Card)
- ✅ **İşlevsellik aynı** (navigasyon hala çalışıyor)
- ✅ **Ek depencency yok** (yalnızca es_accessibility kullan)
- ✅ **Tek satırlık kodu 5'e çıktı** (5x daha açıklayıcı ama hala okunaklı)

---

## 🧪 SONUÇ: Başarı Kriteri

Dönüşüm başarılı ise, bu kontroller geçer:

- [ ] TalkBack Android: +8 duyurusu ekranın başına / buton tiklanmasında
- [ ] VoiceOver iOS: "+8 öğe okumalar her navigasyonda
- [ ] Butonlar: 60dp touch target
- [ ] Metni: 24px+ başlık, 18px+ gövde
- [ ] Kontrast: Beyaz metin koyu arka planda

