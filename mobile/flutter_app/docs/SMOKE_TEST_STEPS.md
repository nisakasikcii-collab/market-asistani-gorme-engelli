# Eyeshopper AI - Smoke Test Steps

Bu dokuman, release oncesi 5-10 dakikalik hizli manuel dogrulama icindir.

## 0) On kosullar
- Cihazda kamera ve mikrofon izinleri verilebilir olmalidir.
- Gerekirse `assets/config/.env` icinde Firebase/Gemini anahtarlari tanimli olmalidir.
- Uygulama debug veya release modda acilabilmelidir.

## 1) Uygulama acilis ve onboarding
- [ ] Uygulama acilirken crash olmaz.
- [ ] Ilk acilista onboarding akisi gelir.
- [ ] En az bir saglik kisiti secilip kaydedilebilir.
- [ ] Ana ekrana gecis basarili olur.

## 2) Tarama ve urun tanima (MVP#1)
- [ ] Tarama ekrani acilir, kamera onizleme gorunur.
- [ ] Bir paketli urun gorulunce sesli "Bu urun: X" mesaji gelir (veya belirsizse tekrar tarama ister).
- [ ] Dusuk isikta sesli uyari gelir.

## 3) Profil uyum kontrolu (MVP#2)
- [ ] Icindekilerde kisitla uyumsuz ifade varsa sesli uyari verilir.
- [ ] Belirsiz OCR metninde "Emin degilim..." mesaji gelir.

## 4) Fiyat etiketi okuma (MVP#3)
- [ ] Etikette fiyat varsa sesli olarak okunur.
- [ ] Indirimli fiyat varsa iki deger de dogru sirayla seslendirilir.

## 5) Neredeyim komutu (MVP#4)
- [ ] "Neredeyim?" sesli komutu algilanir.
- [ ] Reyon tahmini sesli iletilir.
- [ ] Guven dusukse alternatif yonlendirme mesaji verilir.

## 6) Alisveris listesi
- [ ] "Listeme ... ekle" komutu ile urun listeye eklenir.
- [ ] "Alisveris listesine gec" komutu ile liste ekrani acilir.
- [ ] Taranan urun listede bulundu olarak isaretlenebilir.

## 7) Topluluk geri bildirim
- [ ] Topluluk geri bildirim ekrani acilir.
- [ ] Sesli not alinip etiket secilerek gonderilebilir.
- [ ] Gecmis bildirimler listede gorunur.

## 8) Son kontrol
- [ ] Kritik akislarda uygulama kapanmasi/cokmesi yok.
- [ ] Test sirasinda anlasilamayan noktalar notlandi.

## Sonuc
- Tarih:
- Testi yapan:
- Sonuc: GECTI / KISMI / KALDI
- Notlar:
