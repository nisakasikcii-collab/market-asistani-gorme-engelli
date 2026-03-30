# EyeShopper AI - Akıllı Market Asistanı

EyeShopper AI, görme engelli bireylerin market alışverişlerini daha güvenli ve bağımsız hale getirmek için geliştirilmiş yapay zeka destekli bir mobil asistandır.

## 🚀 Öne Çıkan Özellikler

- **Gelişmiş Kamera Analizi (ML Kit):** Gerçek zamanlı nesne algılama ve barkod tarama.
- **Akıllı İçerik Dedektörü (OCR):** Ürün ambalajlarını saniyeler içinde tarayarak kritik içerikleri tespit eder.
- **Kişiselleştirilmiş Sağlık Kontrolü:** 
  - **Çölyak:** Gluten, buğday, un tespiti.
  - **Diyabet:** Şeker, glikoz, tatlandırıcı tespiti.
  - **Tansiyon:** Yüksek sodyum ve tuz tespiti.
  - **Vegan:** Hayvansal gıda tespiti.
- **Hasar Tespiti:** Ambalajdaki yırtık, delik veya hasarları algılayarak kullanıcıyı uyarır.
- **Erişilebilir Geri Bildirim:** "Dikkat!" uyarılarıyla sertleştirilmiş, akıllı TTS (Sesli Yanıt) sistemi.
- **Yüksek Performans:** Paralel ML işlemleri ve saniyede 2 kare (throttle) ile kasmadan akıcı çalışma.

## 📂 Proje Yapısı

- `mobile/flutter_app`: Flutter ile geliştirilmiş erişilebilir mobil uygulama.
- `backend`: Flask tabanlı API ve veri işleme altyapısı.
- `docs/adr`: Mimari karar kayıtları (Architecture Decision Records).
- `firebase`: Firebase yapılandırması ve bulut entegrasyonu.

## 🛠️ Kurulum

### Mobil (Flutter)
1. `mobile/flutter_app` klasörüne gidin.
2. `flutter pub get` komutunu çalıştırın.
3. Uygulamayı başlatmak için `flutter run` komutunu kullanın.

### Backend (Flask)
1. Python 3.11+ yüklü olduğundan emin olun.
2. `backend` klasöründe bir sanal ortam oluşturun ve `pip install -r requirements.txt` ile bağımlılıkları yükleyin.
3. `python run.py` ile API'yi başlatın.

---
*Bu proje, görme engelli bireylerin günlük yaşam kalitesini artırmak amacıyla geliştirilmektedir.*
