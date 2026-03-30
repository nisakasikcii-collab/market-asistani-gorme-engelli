import "dart:async";
import "dart:math";

import "package:sensors_plus/sensors_plus.dart";

import "../logging/app_logger.dart";

typedef ShakeCallback = void Function();

/// Cihazın sallama hareketini algılayan servis.
/// Kullanıcı telefonu hafifçe salladığında dinleme modunu etkinleştirir.
/// sensors_plus paketi kullanarak gerçek accelerometer verisi kullanır.
class ShakeDetector {
  ShakeDetector._();

  static final ShakeDetector instance = ShakeDetector._();

  ShakeCallback? _onShake;
  bool _isListening = false;
  DateTime? _lastShake;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  // Shake detection parametreleri
  static const _shakeThreshold = 15.0; // m/s² - sallama eşiği
  static const _shakeSuppressInterval = Duration(milliseconds: 500); // Sallama sıklığı limiti
  static const _minTimeBetweenShakes = Duration(seconds: 1); // Minimum sallama aralığı

  /// Sallama algılaması başlat
  Future<void> startListeningForShake(ShakeCallback onShake) async {
    _onShake = onShake;
    _isListening = true;
    _lastShake = null;

    try {
      // Accelerometer event'lerini dinlemeye başla
      _accelerometerSubscription = accelerometerEventStream().listen(
        _onAccelerometerEvent,
        onError: (error) {
          AppLogger.e("Accelerometer error: $error");
        },
      );

      AppLogger.i("Sallama algılaması başlatıldı (gerçek accelerometer)");
    } catch (e) {
      AppLogger.e("Sallama algılaması başlatılırken hata: $e");
      _isListening = false;
    }
  }

  /// Sallama algılaması durdur
  Future<void> stopListeningForShake() async {
    _isListening = false;

    // Stream subscription'ı iptal et
    await _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;

    AppLogger.i("Sallama algılaması durduruldu");
  }

  /// Accelerometer event işleme
  void _onAccelerometerEvent(AccelerometerEvent event) {
    if (!_isListening) return;

    // Toplam ivme hesapla (x, y, z eksenlerinin karekök toplamı)
    final acceleration = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z
    );

    // Yerçekimi ivmesini çıkar (cihaz hareketsizken yaklaşık 9.8 m/s²)
    final linearAcceleration = acceleration - 9.8;

    // Sallama eşiği aşıldı mı kontrol et
    if (linearAcceleration.abs() > _shakeThreshold) {
      _triggerShakeEvent();
    }
  }

  /// Shake event tetikle
  void _triggerShakeEvent() {
    final now = DateTime.now();

    // Son sallamadan beri yeterli zaman geçti mi kontrol et
    if (_lastShake != null &&
        now.difference(_lastShake!) < _minTimeBetweenShakes) {
      return; // Çok sık sallama engelle
    }

    // Kısa süreli suppress kontrolü
    if (_lastShake != null &&
        now.difference(_lastShake!) < _shakeSuppressInterval) {
      return;
    }

    _lastShake = now;
    _onShake?.call();
    AppLogger.d("Shake event tetiklendi - Acceleration threshold aşıldı");
  }

  /// Test amaçlı simüle edilmiş shake (debug için)
  Future<void> simulateShake() async {
    if (!_isListening) return;
    _triggerShakeEvent();
    AppLogger.d("Simüle edilmiş shake event tetiklendi");
  }

  /// Dinleme durumu
  bool get isListening => _isListening;
}

