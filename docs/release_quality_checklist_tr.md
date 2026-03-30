# Release Oncesi Kalite Kontrol

## Test ve stabilite
- `flutter test` tum testler gecer.
- MVP senaryo testleri (`mvp_end_to_end_scenarios_test.dart`) gecer.
- Zor kosul testleri (`challenging_conditions_test.dart`) gecer.

## Performans ve maliyet
- Gemini istemcisinde tekrarli prompt cache ve timeout/retry aktif.
- Tarama akisinda frame throttling aktif.

## Crash ve gozlemlenebilirlik
- `FlutterError.onError` ve `PlatformDispatcher.instance.onError` aktif.
- Hata kayitlari `AppLogger` ile toplanir.

## Manuel smoke test
- Paketli gida tanima sesli okunur.
- Profil uyum uyari metni calisir.
- Fiyat etiketi seslendirilir.
- "Neredeyim?" komutu anlamli sonuc verir.
