# ES (EYESHOPPER AI)

Bu proje `prd.md` ve `tasks.md` temel alınarak adım adım geliştirilmektedir.

## Hızlı Genel Bakış

- `mobile/flutter_app`: Mobil uygulama klasörü (Flutter seçildi, kurulum adımları içeride).
- `backend`: Flask tabanlı API ve servis altyapısı.
- `docs/adr`: Mimari karar kayıtları.
- `firebase`: Firebase kurulum notları ve örnek yapılandırmalar.

## Başlangıç

1. Python 3.11+ kur.
2. `backend/.env.example` dosyasını `backend/.env` olarak kopyala.
3. `backend` altında sanal ortam açıp bağımlılıkları yükle.
4. API'yi `python run.py` ile ayağa kaldır.

## Not

Geliştirme listesi `C:\Users\nisak\Documents\tasks.md` sırasına göre ilerler.

**Tamamlanan (liste güncel):** Bölüm 0’un çoğu (Firebase konsol bağlantısı hariç) ve Bölüm 1 (erişilebilirlik + TTS/STT). Mobil kod: `mobile/flutter_app`; ilk derleme için `scripts\bootstrap_flutter.ps1` çalıştırın.
