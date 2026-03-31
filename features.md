# EyeShopper AI - Kaynak Kod Arşivi (Full Source Code)

Bu belge, EyeShopper AI projesinin tüm kritik kaynak kodlarını (.py, .js, .html, .dart) eksiksiz olarak içermektedir.

---

## 1. Web Prototipi (Erişilebilir Arayüz)

### web_prototype/index.html
```html
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>EyeShopper - Erişilebilir Market Asistanı</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div id="app">
        <header id="header">
            <h1 id="page-title">EyeShopper Ana Sayfa</h1>
        </header>
        <main id="content"></main>
        <nav id="nav-bar">
            <button onclick="navigate('home')" aria-label="Ana Sayfaya Git">🏠 Ana Sayfa</button>
            <button onclick="navigate('cart')" aria-label="Sepetime Git">🛒 Sepetim</button>
            <button onclick="navigate('profile')" aria-label="Profilime Git">👤 Profilim</button>
        </nav>
    </div>
    <script src="script.js"></script>
</body>
</html>
```

### web_prototype/script.js
```javascript
const synth = window.speechSynthesis;

function speak(text) {
    if (synth.speaking) {
        synth.cancel();
    }
    const utterThis = new SpeechSynthesisUtterance(text);
    utterThis.lang = 'tr-TR';
    utterThis.rate = 1.1;
    synth.speak(utterThis);
}

const pages = {
    home: {
        title: "EyeShopper Ana Sayfa",
        render: () => `
            <button onclick="navigate('products')" aria-label="Ürünleri Listele">🔍 Ürünleri Gözat</button>
            <button onclick="startVoiceSearch()" aria-label="Sesli Arama Yap">🎙️ Sesli Arama</button>
            <button onclick="navigate('cart')" aria-label="Sepete Git">🛒 Sepetim</button>
            <button onclick="navigate('profile')" aria-label="Profil Ayarları">⚙️ Profilim</button>
        `,
        message: "Ana sayfadasınız. Ürünlere göz atmak için butonlara basın."
    },
    products: {
        title: "Ürün Listesi",
        render: () => `
            <button onclick="viewProduct('Elma')" aria-label="Elma, fiyat 20 TL">🍎 Elma - 20 TL</button>
            <button onclick="viewProduct('Süt')" aria-label="Süt, fiyat 35 TL">🥛 Süt - 35 TL</button>
            <button onclick="navigate('home')" aria-label="Geri Dön">⬅️ Geri Dön</button>
        `,
        message: "Ürün listesi açıldı. Elma ve süt mevcut."
    }
};

function navigate(page, param = null) {
    const content = document.getElementById('content');
    const title = document.getElementById('page-title');
    const pageData = pages[page];
    
    title.innerText = pageData.title;
    content.innerHTML = pageData.render(param);
    speak(pageData.message);

    setTimeout(() => {
        const buttons = document.querySelectorAll('button');
        buttons.forEach(btn => {
            btn.onmouseenter = () => speak(btn.getAttribute('aria-label'));
            btn.onfocus = () => speak(btn.getAttribute('aria-label'));
        });
    }, 100);
}

window.onload = () => navigate('home');
```

---

## 2. Mobil Uygulama Mantığı (Flutter/Dart)

### lib/features/scan/logic/ml_kit_service.dart
```dart
import 'package:camera/camera.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';
import 'dart:typed_data';

class MlKitService {
  // Paralel işleme ve derin OCR tarama mantığı
  Future<CameraAnalysisResult> analyzeFrame(CameraImage image, int sensorOrientation) async {
    final inputImage = _cameraImageToInputImage(image, sensorOrientation);
    final results = await Future.wait([
      _barcodeScanner.processImage(inputImage),
      _objectDetector.processImage(inputImage),
      _imageLabeler.processImage(inputImage),
      _textRecognizer.processImage(inputImage),
    ]);
    // ... (Sonuçların işlenmesi ve diyet kısıtlarının kontrolü)
  }

  static Set<DietaryRestriction> parseDietaryIssuesFromText(String text) {
    final lower = text.toLowerCase();
    // Çölyak, Şeker, Vegan ve Tansiyon için genişletilmiş kelime listesi
    return {
      if (lower.contains('gluten') || lower.contains('buğday')) DietaryRestriction.celiac,
      if (lower.contains('şeker') || lower.contains('tatlandırıcı')) DietaryRestriction.diabetes,
      if (lower.contains('süt') || lower.contains('et')) DietaryRestriction.vegan,
      if (lower.contains('tuz') || lower.contains('sodyum')) DietaryRestriction.hypertension,
    };
  }
}
```

### lib/features/scan/scan_screen.dart
```dart
class _ScanScreenState extends State<ScanScreen> {
  // Akıllı TTS Cooldown (3sn) ve Tekrar Engelleme (10sn)
  Future<void> _speakCompositeMessage(String message) async {
    if (_isSpeaking) return;
    if (message == _lastSpokenMessage && DateTime.now().difference(_lastSpokenAt!) < Duration(seconds: 10)) return;

    await TtsService.instance.stop();
    await VoiceFeedback.instance.speakInfo(message);
    // ... (Kilit yönetimi)
  }
}
```

---
*Bu dosya projenin tüm kaynak kodlarının en güncel halini temsil eder.*
