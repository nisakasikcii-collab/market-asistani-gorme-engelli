# ADR-0001: Mobil Teknoloji Seçimi

## Durum
Kabul edildi

## Bağlam
ES uygulaması görme engelli kullanıcılar için erişilebilirlik odaklı bir mobil deneyim sunmalıdır. PRD gereği kamera, TTS/STT, Firebase ve AI servisleri ile entegrasyon ihtiyacı vardır.

## Karar
MVP için **Flutter** seçildi.

## Gerekçe
- Tek kod tabanıyla iOS/Android çıktısı.
- Erişilebilirlik (semantics, screen reader) araçlarının güçlü olması.
- Kamera ve ML/Firebase eklenti ekosisteminin olgunluğu.
- Performans gereksinimleri için tutarlı çalışma modeli.

## Sonuçlar
- Mobil geliştirme akışı Flutter SDK üzerinden yürütülecek.
- Takımda Flutter kurulum standardı oluşturulacak.
- Gerekirse web paneli ve backend bağımsız geliştirilir.

## Alternatifler
- React Native: güçlü seçenek, ancak bu MVP için erişilebilirlik ve plugin tutarlılığı nedeniyle Flutter geride bırakıldı.
