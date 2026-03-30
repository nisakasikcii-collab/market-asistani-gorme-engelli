# Firebase Kurulum Notları

Bu klasör, yerel geliştirme sırasında kullanılan Firebase yapılandırma dosyaları için ayrılmıştır.

## Adımlar

1. Firebase Console üzerinden proje oluştur.
2. Gerekli servisleri etkinleştir:
   - Authentication
   - Firestore Database
3. Service account anahtarını indir ve bu klasöre `service-account.json` adıyla koy.
4. `backend/.env` içinde:
   - `FIREBASE_PROJECT_ID`
   - `GOOGLE_APPLICATION_CREDENTIALS`
     alanlarını güncelle.

## Güvenlik

- `service-account.json` dosyasını asla sürüm kontrolüne ekleme.
- Üretim ortamında secret manager kullan.
