👁️ EyeShopper - Görme Engelliler İçin Kişiselleştirilmiş Sağlık ve Alışveriş Asistanı

🚨 Problem

Görme engelli bireyler için market alışverişi, paketli gıdaların içeriğine dair kritik bilgilerin (şeker, tuz, gluten, alerjenler vb.) ulaşılamaz olması nedeniyle ciddi bir sağlık riski ve bağımsızlık kısıtı barındırır. Mevcut teknolojiler sadece metin okumaya odaklanırken, kullanıcının özel sağlık profilini dikkate alan ve onlara güvenli tüketim kararı aldıran bir çözüm eksikliği bulunmaktadır.

✨ Çözüm

EyeShopper, görme engelli bireylerin cebindeki "akıllı göz" ve "dijital diyetisyen"dir.

Kişiselleştirilmiş Sağlık Profili: Kullanıcılar; diyabet, çölyak, hipertansiyon gibi durumlarını ve beslenme tercihlerini (vegan vb.) uygulamaya bir kez tanımlar.

Yapay Zeka Destekli Analiz: Google Gemini AI, ürün içeriğini sadece okumakla kalmaz; kullanıcının sağlık profiliyle veriyi eşleştirerek "tüketilebilir" veya "riskli" şeklinde sesli kararlar üretir.

Sesli Geri Bildirim Sistemi: Kullanıcılar, içeriği hatalı veya eksik ürünler için market yönetimine anında sesli geri bildirim bırakarak aktif birer denetleyiciye dönüşür.

Akıllı Alışveriş Listesi: Onaylanan ve güvenli bulunan ürünler, tek bir komutla alışveriş listesine eklenerek dijital bir alışveriş hafızası oluşturulur.

🔗 Canlı Demo
Yayın Linki: https://eyeshopper-e8cba.web.app

Demo Video: https://youtube.com/shorts/_TlLjZVZ-bs?feature=share

🛠️ Kullanılan Teknolojiler

Frontend: Flutter (Web & Mobile)

AI Engine: Google Gemini 3 Flash (Görüntü İşleme & Akıl Yürütme)

Backend & Hosting: Firebase (Auth, Firestore, Hosting)

Erişilebilirlik: Flutter Semantics (TalkBack & VoiceOver tam uyumluluğu)

Ses Teknolojileri: Google Speech-to-Text (Sesli geri bildirimler için)

🚀 Nasıl Çalıştırılır?

Projeyi Klonlayın:

Bash
git clone https://github.com/nisakasikcii-collab/market-asistani-gorme-engelli.git
cd eyeshopper_ai/mobile/flutter_app

Bağımlılıkları Yükleyin:

Bash
flutter pub get

Uygulamayı Çalıştırın:

Bash
flutter run -d chrome

Web İçin Derleme (Build) Almak ve Deploy Etmek:
Bash
flutter build web --release
firebase deploy
