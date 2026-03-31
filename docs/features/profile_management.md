# Kullanıcı Sağlık Profili (Profile Management)

Kullanıcının diyet kısıtlamalarını yönettiği ve uygulamanın bu verilere göre kişiselleştiği merkezdir.

## Teknik Detaylar

### Veri Saklama
- **Yerel Saklama:** Hive NoSQL veritabanı kullanılarak veriler cihazda hızlı erişim için saklanır.
- **Bulut Senkronizasyonu:** Firestore kullanılarak anonim kullanıcı hesapları üzerinden veriler buluta yedeklenir.

### İlk Kurulum (Onboarding)
Uygulama ilk açıldığında, kullanıcının kısıtlamaları sesli rehberlik eşliğinde alınır. Kullanıcı "Devam Et" butonuna bastığında profili otomatik olarak oluşturulur.

### Erişilebilir Arayüz
Profil düzenleme ekranı, ekran okuyucular (TalkBack/VoiceOver) için optimize edilmiş Semantics etiketlerine sahiptir.
