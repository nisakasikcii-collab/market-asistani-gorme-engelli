# ES (EYESHOPPER AI) - Geliştirme Görev Listesi

Bu liste `prd.md` dokümanındaki gereksinimlere göre, adım adım geliştirme için hazırlanmıştır.

## 0) Proje Kurulumu ve Temel Altyapı
- [x] Mobil teknoloji seçimi yap (Flutter veya React Native) ve karar kaydı oluştur.
- [x] Proje iskeletini oluştur (klasör yapısı, ortam değişkenleri, build ayarları).
- [x] Firebase projesini aç, uygulamayı bağla (Auth/Firestore gerekli ise etkinleştir). *(Altyapı: `FirebaseBootstrap` + `firebase_core`; `.env` üzerinden platforma göre `Firebase.initializeApp` etkin.)*
- [x] Gizli anahtar ve API yapılandırmalarını güvenli şekilde yönet (dotenv/secrets).
- [x] Temel hata izleme ve loglama altyapısı ekle.

## 1) Erişilebilirlik Temeli (Kritik)
- [x] Uygulama genelinde ekran okuyucu uyumluluğu (TalkBack/VoiceOver etiketleri) ekle.
- [x] Dokunma hedefleri, kontrast ve yazı boyutu erişilebilirlik kontrolü yap.
- [x] TTS (Text-to-Speech) altyapısını kur, ortak bir `speak()` servisi yaz.
- [x] STT (Speech-to-Text) altyapısını kur, ortak bir `listen()` servisi yaz.
- [x] Sesli geri bildirim tonu ve öncelik seviyeleri tanımla (uyarı/bilgi/kritik).

## 2) Kullanıcı Sağlık Profili (Setup Ekranı)
- [x] İlk açılış onboarding akışını oluştur.
- [x] Kısıtlama seçeneklerini ekle: Diyabet/Şeker, Çölyak/Gluten, Vegan, Süt Alerjisi.
- [x] Profil verisini yerel + Firebase’de sakla.
- [x] Profil güncelleme ekranını ve veri doğrulamalarını ekle.
- [x] Tarama sırasında kullanılacak “profil eşleştirme” kural motorunu yaz.

## 3) Kamera ve Anlık Tarama Altyapısı
- [x] Kamera izinleri ve kamera önizleme ekranını hazırla.
- [x] Görüntü akışı işleme katmanını kur (frame throttling/performance).
- [x] ML Kit barkod ve OCR (hızlı metin okuma) entegrasyonunu yap.
- [x] Gemini 1.5 Flash entegrasyonunu yap (ürün analizi/hasar/navigasyon için istemci katmanı).
- [x] Ağ hatası ve düşük ışık gibi durumlar için kullanıcıya sesli durum mesajları ekle.

## 4) MVP Özelliği #1 - Ürünü Tanı ve İsmini Söyle
- [x] Barkoddan ürün tanıma akışını oluştur (varsa ürün veritabanı eşleştirmesi).
- [x] Barkod yoksa OCR + görsel analiz ile ürün adını çıkar.
- [x] Güven skoru eşiklerini tanımla (emin değilse tekrar tarama öner).
- [x] Sonucu TTS ile seslendir: “Bu ürün: X”.
- [x] Bu akış için birim ve entegrasyon testleri yaz.

## 5) MVP Özelliği #2 - Profil Uyum Kontrolü ve Sesli Uyarı
- [x] OCR’dan içerik/metin alanlarını çıkar (içindekiler, alerjen ibareleri).
- [x] Ürün içeriğini kullanıcı kısıtlarıyla karşılaştıran kontrol motoru yaz.
- [x] Uyarı şablonlarını ekle: “Bu ürün şeker içeriyor, profilinize uygun değil.”
- [x] Belirsiz durumda “emin değilim” mesajı ve yeniden tarama akışı ekle.
- [x] Yanlış pozitif/negatif durumları azaltmak için kural iyileştirmesi yap.

## 6) MVP Özelliği #3 - Fiyat Etiketi Okuma ve Seslendirme
- [x] Etiket bölgesi tespiti (kamera görüntüsünden fiyat alanı adayları). *(OCR blok/satırlarından fiyat sinyalli metinleri aday bölge olarak seçen heuristic eklendi.)*
- [x] OCR ile fiyat ve indirimli fiyat bilgisi çıkarma akışı ekle.
- [x] Para birimi normalizasyonu (TL) ve metin temizleme kuralları yaz.
- [x] TTS mesajı ekle: “Ürün fiyatı 45 TL, indirimli fiyat 38 TL.”
- [x] Farklı etiket formatları için test senaryoları ekle.

## 7) MVP Özelliği #4 - “Neredeyim?” Reyon Tahmini
- [x] STT ile “Neredeyim?” komutunu algıla.
- [x] Kameradaki nesne gruplarını toplayıp sınıflandır (örn. un/şeker/makarna). *(MVP heuristic: OCR'dan gözlenen ürün/raf metinlerini nesne grubu sinyali olarak kullanır.)*
- [x] Nesne gruplarından reyon tahminleme kuralı veya model çıktısı oluştur.
- [x] Sonucu TTS ile ilet: “Şu an Temel Gıda reyonundasınız.”
- [x] Tahmin güven skoru düşükse alternatif yönlendirme mesajı ver.

## 8) Akıllı Alışveriş Listesi (PRD Bölüm C)
- [x] Sesli komutla listeye ürün ekleme akışını geliştir.
- [x] Liste veri modeli ve kalıcı saklamayı ekle.
- [x] Taranan ürün bulunduğunda listeden otomatik düşme kuralı yaz. *(MVP'de "tamamlandı" olarak işaretleme uygulanır.)*
- [x] Liste durumunu sesli ve görsel olarak geri bildir.
- [x] Liste yönetimi için temel testleri ekle.

## 9) Topluluk Geri Bildirim Ekranı (PRD Bölüm E)
- [x] Sesli not alma arayüzünü oluştur.
- [x] “Yanlış fiyat etiketi / reyon değişimi” gibi etiketli bildirim tipleri ekle.
- [x] Bildirimleri Firebase’e kaydetme ve listeleme akışı yaz.
- [x] Kötüye kullanımı azaltmak için temel doğrulama ve rate limit ekle.
- [x] Erişilebilir geri bildirim geçmişi ekranını tamamla.

## 10) Kalite, Güvenlik, Performans
- [x] Uçtan uca test senaryoları yaz (4 MVP kriterinin tamamı için).
- [x] Düşük ağ, düşük ışık, bulanık görüntü gibi zor koşul testleri ekle.
- [x] Model/API maliyet ve gecikme optimizasyonu yap.
- [x] Kişisel veri, ses ve görüntü işleme için gizlilik politikası/izin metinlerini hazırla.
- [x] Crash/analytics panellerini kontrol ederek release öncesi hata kapat. *(MVP: global crash yakalama + release checklist dokumani eklendi.)*

## 11) MVP Çıkış Kontrol Listesi (v1.0)
- [x] Paketli gıda tanıma doğrulandı ve sesli okunuyor.
- [x] Profil kısıtı karşılaştırması doğru çalışıyor ve sesli uyarıyor.
- [x] Fiyat etiketi okunuyor ve doğru seslendiriliyor.
- [x] “Neredeyim?” komutu ile reyon tahmini kabul edilebilir doğrulukta çalışıyor.
- [x] Erişilebilirlik ve temel stabilite testlerinden geçti.

## 12) Phase 2 Backlog (PRD Bölüm 6)
- [x] Market canlı yoğunluk haritası için veri modeli ve ekran tasarımı. *(Tasarım notları: `docs/phase2_design_notes_tr.md`)*
- [x] “Yardım Çağır” butonu için görevliye bildirim mekanizması tasarımı. *(Tasarım notları: `docs/phase2_design_notes_tr.md`)*
