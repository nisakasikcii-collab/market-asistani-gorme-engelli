# Phase 2 Tasarim Notlari

## 1) Market canli yogunluk haritasi
- Veri modeli:
  - `store_id`
  - `aisle_id`
  - `crowd_level` (0-100)
  - `updated_at`
- Ekran:
  - Renk kodlu yogunluk katmani (dusuk/orta/yuksek)
  - Sesli ozet: "Temel gida reyonu su an yogun."
- Guncelleme:
  - Periyodik toplu veri cekme
  - Dusuk baglantida son bilinen durum gosterimi

## 2) Yardim Cagir butonu
- Veri modeli:
  - `request_id`
  - `user_id`
  - `store_id`
  - `status` (opened/accepted/resolved)
  - `created_at`
- Akis:
  - Kullanici butona basar veya sesli komut verir.
  - Gorevliye anlik bildirim gider.
  - Kullaniciya "yardim talebiniz alindi" sesli geri bildirimi verilir.
