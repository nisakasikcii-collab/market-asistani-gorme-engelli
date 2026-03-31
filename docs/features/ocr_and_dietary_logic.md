# Derin İçerik Dedektörü (OCR & Dietary Logic)

Gelişmiş metin tarama mantığı sayesinde, ürün ambalajındaki en küçük yazılar bile taranarak yasaklı maddeler aranır.

## Kısıtlama Kategorileri ve Yasaklı Kelimeler

### Çölyak (Gluten Hassasiyeti)
- un, buğday, gluten, arpa, çavdar, nişasta, wheat, barley, rye, oat, yulaf.

### Diyabet (Şeker Hassasiyeti)
- şeker, seker, sugar, glikoz, glukoz, fruktoz, sakkaroz, sukroz, tatlandırıcı, tatlandirici, aspartam, asesülfam, sakarin, sukraloz, maltitol, ksilitol, sorbitol, mısır şurubu, misir surubu, surup, şurup, karamel, maltodekstrin, agave, stevia, karbonhidrat.

### Tansiyon (Sodyum Hassasiyeti)
- tuz, sodyum, natrium, tursu, turşu, salamura, salt, sodium, trans yağ, doymuş yağ.

### Vegan (Hayvansal Gıda Hassasiyeti)
- süt, sut, yumurta, bal, peynir, et, jelatin, kazein, laktoz, laktos, milk, egg, honey, cheese, meat, gelatin, casein, lactose, yoğurt, yogurt.

## Mantık Önceliği
OCR metninde bir eşleşme yakalandığı anda, barkod veritabanı sonucu ne olursa olsun kullanıcıya kısıtlama uyarısı verilir. Bu, veritabanında eksik olan ürünler için bir güvenlik katmanı oluşturur.
