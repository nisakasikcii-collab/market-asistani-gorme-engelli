# Gizlilik ve Izin Metinleri (MVP)

## Toplanan veriler
- Kamera goruntusu: urun tanima, fiyat okuma ve reyon tahmini icin anlik islenir.
- Mikrofon sesi: sesli komut algilama ve sesli not alma icin kullanilir.
- Saglik profili: kisisel kisitlara gore urun uyumlulugu kontrolu yapilir.
- Topluluk geri bildirim notlari: market kalitesi icin paylasilir.

## Saklama politikasi
- Saglik profili ve alisveris listesi cihazda saklanir.
- Firebase etkinse profil ve topluluk bildirimi buluta senkronlanabilir.
- Ham ses kaydi kalici tutulmaz; sadece metin sonuc islenir.

## Kullanici izin metni (uygulama ici ozet)
- Kamera izni: "Urunleri tanimak ve fiyat etiketlerini okumak icin kamera erisimi gerekir."
- Mikrofon izni: "Sesli komutlari anlayip size daha hizli yardim etmek icin mikrofon erisimi gerekir."

## Guvenlik notlari
- API anahtarlari `.env` dosyasinda tutulur, repoya commit edilmez.
- Kisisel veri minumum prensibi ile islenir; gereksiz alan toplanmaz.
