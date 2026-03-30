# 🛒 ES (EYESHOPPER AI) Adım Adım Kullanıcı Akışı
Bu akış, uygulamanın sesli asistan rehberliğinde ve ekran okuyucu (TalkBack/VoiceOver) dostu bir arayüzle çalıştığı varsayımıyla kurgulanmıştır.

## 1. Profil Oluşturma (Setup)
**Kullanıcı:** Uygulamayı ilk kez açar. Ekrana çift dokunarak sesli asistanı başlatır.

**İşlem:** Sistem; "Diyabet", "Çölyak" veya "Vegan" gibi seçenekleri sesli okur.

**Sonuç:** Kullanıcı seçimini yapar ve bu veriler Firebase profilinde saklanır.

## 2. Akıllı Alışveriş Listesi Hazırlama
**Kullanıcı:** Ana ekrandaki mikrofon simgesine basılı tutarak konuşur: "Listeme 1 litre süt ve glütensiz bisküvi ekle".

**İşlem:** STT (Ses-Metin) teknolojisi bu ürünleri dijital listeye işler.

**Sonuç:** Uygulama onay verir: "Anlaşıldı, iki ürün listenize eklendi".

## 3. "Neredeyim?" Sorusu (Navigasyon)
**Kullanıcı:** Market içinde yürürken telefonu etrafa tutar ve "Neredeyim?" butonuna tıklar.

**İşlem:** Gemini 1.5 Flash, kameranın gördüğü raflardaki ürün gruplarını analiz eder.

**Sonuç:** Sesli yanıt: "Etrafınızda un ve şeker paketleri var. Şu an Temel Gıda reyonundasınız".

## 4. Ürün Analizi ve Fiyat Okuma
**Kullanıcı:** Raftan bir paket alır ve telefonu pakete doğru tutar.

**İşlem:** AI aynı anda üç kontrol yapar:

- Fiyat: Etiketteki fiyatı okur (Örn: "45 TL").
- Sağlık: Ürünü kullanıcının profiliyle kıyaslar.
- Fiziksel: Pakette yırtık veya hasar arar.

**Sonuç:** Sesli uyarı: "Bu bisküvi glüten içeriyor, profilinize uygun değil. Ayrıca paketin sağ üstünde bir yırtık algılandı".

## 5. Liste Güncelleme
**Kullanıcı:** Uygun bir ürünü sepetine atar.

**İşlem:** Kullanıcı ürünü onayladığında sistem bunu listeden otomatik olarak düşer.

**Sonuç:** Uygulama bildirir: "Bisküvi listeden silindi. Sırada süt var".

## 6. Geri Bildirim Merkezi (Topluluk)
**Kullanıcı:** Reyonda bir sorun fark ederse (örn: fiyat etiketi yanlış) ekranın alt kısmına basılı tutar.

**İşlem:** "Bu raftaki fiyat etiketi güncel değil" diyerek sesli not bırakır.

**Sonuç:** Bu geri bildirim diğer kullanıcılar için sisteme kaydedilir.