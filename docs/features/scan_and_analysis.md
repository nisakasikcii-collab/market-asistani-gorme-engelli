# Akıllı Ürün Tarama ve Analiz (Scan & Analysis)

Bu modül, ML Kit ve geleneksel görüntü işleme tekniklerini kullanarak ürünleri saniyeler içinde analiz eder.

## Teknik Özellikler

### Paralel ML İşleme
Barkod tarama, nesne algılama, görsel etiketleme (Image Labeling) ve metin tanıma (OCR) işlemleri aynı anda çalışır. Bu sayede analiz süresi minimize edilir.

### Dinamik Sağlık Puanı
Ürünün kullanıcı profiline uygunluğuna göre (0-100 arası) bir sağlık puanı hesaplanır.
- **Tehlikeli:** -40 puan
- **Riskli:** -20 puan
- **Uygun:** +10 puan
- **Hasarlı Paket:** -50 puan

### Hasar ve Yırtık Tespiti
Ambalaj üzerindeki fiziksel hasarlar, delikler veya yırtıklar hem yapay zeka hem de kenar algılama (Edge Detection) algoritmalarıyla tespit edilir. 
- **AI Kontrolü:** 'torn', 'damaged', 'ripped' etiketleri taranır.
- **Geleneksel Kontrol:** Sobel operatörü ile kenar yoğunluğu ve düzensizliği analiz edilir.

### Performans Optimizasyonu
Saniyede 2 kare (500ms throttle) sınırlamasıyla düşük donanımlı cihazlarda bile akıcı çalışma sağlanır. Analiz bitmeden yeni bir kare işleme alınmaz.
