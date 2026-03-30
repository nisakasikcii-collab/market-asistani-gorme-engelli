# 📄 EYESHOPPER AI: Proje Rehberi (Başlangıç Seviyesi)

ES, görme engelli bireylerin market içerisinde kimseye ihtiyaç duymadan, sağlık profillerine uygun ve fiziksel olarak sağlam ürünleri bulmalarını sağlayan bir yardımcıdır.

## 🛠️ 1. Teknoloji Yığını (Neden Seçtik?)

Başlangıç seviyesinde hız ve sadelik için aşağıdaki yapıyı kullanıyoruz:

| Katman | Teknoloji | Seçilme Nedeni |
| --- | --- | --- |
| Frontend | Flutter | Tek kodla iOS ve Android çıktı. Güçlü erişilebilirlik (TalkBack/VoiceOver) desteği. |
| Zekâ (AI) | Gemini 1.5 Flash | Çok hızlı, düşük gecikmeli ve ücretsiz kullanım kotası geniş. Görüntü analizi için ideal. |
| Backend | Firebase | Sunucu kurmaya gerek kalmadan veri saklama (Firestore) ve ses dosyası depolama (Storage). |
| Cihaz İçi | Google ML Kit | İnternet yavaş olsa bile hızlıca barkod ve metin tarama. |

## 🚀 2. Kurulum ve Başlangıç Adımları

### Adım 1: Yazılım Ortamı

Flutter SDK kurun ve bir kod editörü (VS Code önerilir) indirin.
Google AI Studio üzerinden Gemini API Key'inizi alın.

### Adım 2: Proje ve Paketler

Terminalde projenizi oluşturun ve gerekli kütüphaneleri ekleyin:

```bash
flutter create eyeshopper_ai
cd eyeshopper_ai
flutter pub add google_generative_ai camera firebase_core cloud_firestore record audioplayers
```

### Adım 3: İlk "Zekâ" Bağlantısı

`lib/main.dart` dosyanızda Gemini'yi şu basit komutla başlatabilirsiniz:

```dart
import 'package:google_generative_ai/google_generative_ai.dart';

final model = GenerativeModel(
  model: 'gemini-1.5-flash',
  apiKey: 'SİZİN_API_ANAHTARINIZ',
);
```

## 💡 Geri Bildirim İçin İpucu

Geri bildirim kısmında kullanıcının bıraktığı ses kayıtlarını Firebase Storage'a yüklerken, dosya ismine market koordinatlarını eklemek, bilgiyi yerelleştirmek için en basit yoldur.
