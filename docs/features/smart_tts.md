# Erişilebilir Sesli Geri Bildirim (Smart TTS)

Görme engelli kullanıcılar için optimize edilmiş, akıllı bir seslendirme sistemidir.

## Özellikler

### Sertleştirilmiş Uyarılar
Tehlikeli içerik tespit edildiğinde veya paket hasarlı olduğunda cümle başına "Dikkat!" uyarısı eklenir. Mesajlar doğrudan içeriğe odaklanır.

### Ses Çakışması Önleme
Yeni bir bilgi söylenmeden önce önceki seslendirme otomatik olarak durdurulur. `stop & speak` mantığı ile seslerin üst üste binmesi engellenir.

### Akıllı Cooldown ve Filtreleme
- **3 Saniye Kuralı:** Her seslendirme arasında en az 3 saniyelik zorunlu bekleme süresi bulunur.
- **Tekrar Engelleme:** Aynı barkod veya sonuç için 10 saniyelik bir seslendirme limiti uygulanır.
- **Dinamik Bekleme:** Cümlenin kelime sayısına göre konuşma süresi tahmini yapılarak analiz döngüsü kilitlenir.
