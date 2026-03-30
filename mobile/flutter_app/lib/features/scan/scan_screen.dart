import 'dart:async';
import 'dart:io' show Platform;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image/image.dart' as img;

import '../../core/logging/app_logger.dart';
import '../../core/voice/tts_service.dart';
import '../../core/voice/voice_feedback.dart';
import '../profile/data/user_profile_repository.dart';
import '../profile/domain/dietary_restriction.dart';
import 'data/barcode_cache_store.dart';
import 'domain/scan_analyzer.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  CameraController? _controller;
  bool _isProcessing = false;
  DateTime _lastProcessedAt = DateTime.fromMillisecondsSinceEpoch(0);
  final Duration _minFrameInterval = const Duration(milliseconds: 500); // 2 FPS max (kasılmaları önlemek için)
  DateTime? _lastSpokenAt;
  String? _lastSpokenMessage;
  bool _isSpeaking = false; // TTS çakışmalarını önlemek için bayrak

  String _detectedProduct = "Bekleniyor...";
  String _defectStatus = "Paket kontrolü bekleniyor.";
  String _profileStatus = "Profil kontrolü bekleniyor.";
  String _finalDecision = "Taranmamış";
  double _healthScore = 0.0; // UI veya debug için açık bırakıldı

  @override
  void initState() {
    super.initState();
    UserProfileRepository.instance.ensureLoaded();

    Hive.initFlutter().then((_) async {
      await BarcodeCacheStore.instance.init();
    }).catchError((e) {
      debugPrint('Hive init hatası: $e');
    });

    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      setState(() {
        _detectedProduct = "Kamera bulunamadı.";
      });
      return;
    }

    final camera = cameras.first;

    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.yuv420 : ImageFormatGroup.bgra8888,
    );

    await _controller!.initialize();

    _controller!.startImageStream((image) {
      processCameraImage(image);
    });

    setState(() {});
  }

  Future<void> processCameraImage(CameraImage image) async {
    // 1. Throttle check (max 2 frames per second)
    final now = DateTime.now();
    if (now.difference(_lastProcessedAt) < _minFrameInterval) return;

    // 2. İşleme kilidi (Analiz bitmeden yeni kare alma)
    if (_isProcessing) return;
    _isProcessing = true;
    _lastProcessedAt = now;

    try {
      final sensorOrientation = _controller?.description.sensorOrientation ?? 0;
      
      // Ağır image işlemesi (ML Kit analysis)
      final scanResult = await ScanAnalyzer.instance.analyze(image, sensorOrientation);

      // Composite TTS mesajı oluştur
      final message = _buildCompositeMessage(scanResult);

      // UI state'i güncelle
      if (mounted) {
        final issues = scanResult.detectedIssues;
        String profileDetail = 'Profil uyumu: ${scanResult.healthRisk}';
        if (issues.isNotEmpty) {
          profileDetail += ' (${issues.map((e) => e.displayNameTr).join(', ')})';
        }

        setState(() {
          _detectedProduct = scanResult.productText;
          _defectStatus = scanResult.defectDetected ? 'Paket yırtık/hasarlı!' : 'Paket sağlam.';
          _profileStatus = profileDetail;
          _healthScore = scanResult.healthScore;
          _finalDecision = _composeDecision(scanResult.defectDetected, scanResult.healthRisk, scanResult.healthScore);
        });
      }

      // TTS tetikleme (Sadece analiz sonuçları değişince veya throttle ile)
      if (message.isNotEmpty && mounted) {
        await _speakCompositeMessage(message);
      }
    } catch (e, st) {
      _globalErrorHandler(e, st);
    } finally {
      _isProcessing = false;
    }
  }

  String _buildCompositeMessage(ScanResult scanResult) {
    final issues = scanResult.detectedIssues;
    final List<String> warnings = [];

    // 1. Kritik Diyet Uyarıları (ÖNCELİKLİ)
    if (issues.contains(DietaryRestriction.celiac)) {
      warnings.add('gluten içeriyor, Çölyak için uygun değil');
    }
    if (issues.contains(DietaryRestriction.hypertension)) {
      warnings.add('yüksek sodyum, tansiyon için uygun değil');
    }
    if (issues.contains(DietaryRestriction.diabetes)) {
      warnings.add('şeker içeriyor, diyabet için uygun değil');
    }
    if (issues.contains(DietaryRestriction.vegan)) {
      warnings.add('hayvansal gıda içeriyor, vegan için uygun değil');
    }

    // 2. Paket Durumu
    if (scanResult.defectDetected) {
      warnings.add('paket yırtık veya hasarlı');
    }

    // 3. İçerik Belirlenememe Durumu
    final bool isContentUnknown = scanResult.productText.contains('belirlenemedi') || 
                                 scanResult.healthRisk == 'Belirlenemedi';

    // Mesajı Oluştur
    if (warnings.isNotEmpty) {
      return 'Dikkat! ${warnings.join('. ')}.';
    }

    if (isContentUnknown) {
      return 'İçerik bilgisine ulaşılamadı, lütfen paketi daha yakından gösterin.';
    }

    // Her şey uygunsa kısa özet
    return '${scanResult.productText}. size uygun, paket sağlam.';
  }

  Future<void> _speakCompositeMessage(String message) async {
    // 1. Eğer halihazırda konuşuluyorsa veya mesaj aynıysa atla
    if (_isSpeaking) return;
    
    final now = DateTime.now();
    final bool isSameMessage = message == _lastSpokenMessage;
    
    // 2. Cooldown: Aynı veya farklı mesaj için en az 3 saniye bekle
    if (_lastSpokenAt != null && now.difference(_lastSpokenAt!) < const Duration(seconds: 3)) {
      return;
    }

    // 3. Aynı mesaj ise ve ekran değişmediyse (veya yeterince süre geçmediyse) tekrar etme
    if (isSameMessage && _lastSpokenAt != null && 
        now.difference(_lastSpokenAt!) < const Duration(seconds: 10)) {
      return; // Aynı sonucu 10 saniyede bir defadan fazla söyleme (gürültü kirliliği)
    }

    _isSpeaking = true;
    _lastSpokenAt = now;
    _lastSpokenMessage = message;

    try {
      // 4. Kesin stop: Seslerin üst üste binmesini engelle
      await TtsService.instance.stop();
      await Future.delayed(const Duration(milliseconds: 100)); // Motorun durması için küçük bir ara
      
      // 5. Seslendir
      await VoiceFeedback.instance.speakInfo(message);
      
      // 6. Mesaj uzunluğuna göre bir bekleme (Tahmini: her 10 kelime için 2-3 sn)
      final wordCount = message.split(' ').length;
      final speechWaitTime = Duration(seconds: (wordCount / 5).ceil().clamp(2, 6));
      
      await Future.delayed(speechWaitTime);
    } catch (e) {
      debugPrint('TTS composite mesaj hatası: $e');
    } finally {
      _isSpeaking = false; // Kilidi kaldır
    }
  }


  String _composeDecision(bool defectDetected, String healthRisk, double healthScore) {
    if (defectDetected || healthRisk == 'Tehlikeli') {
      return 'Tüketmeyin: Sağlık riskli veya paket yırtık.';
    }

    if (healthRisk == 'Belirlenemedi') {
      return 'İçerik belirlenemedi, lütfen daha yakından tutun.';
    }

    if (healthScore < 40 || healthRisk == 'Riskli') {
      return 'Dikkat: Ürün riskli, kontrol et.';
    }

    return 'Uygun: Ürün uygun. Sağlık puanı = ${healthScore.toStringAsFixed(0)}';
  }

  void _globalErrorHandler(Object error, StackTrace stackTrace) {
    debugPrint('Global hata: $error');
    debugPrint('$stackTrace');

    if (!mounted) return;

    final msg = 'Bir hata oluştu. Lütfen tekrar deneyin.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  List<int> convertToJpeg(CameraImage image) {
    final width = image.width;
    final height = image.height;
    final plane = image.planes[0].bytes;

    final imgImage = img.Image.fromBytes(
      width: width,
      height: height,
      bytes: plane.buffer,
      numChannels: 1,
      order: img.ChannelOrder.red,
      format: img.Format.uint8,
    );

    return img.encodeJpg(imgImage);
  }

  @override
  void dispose() {
    _controller?.stopImageStream();
    _controller?.dispose();
    TtsService.instance.stop().catchError((e) {
      debugPrint('TTS stop hatası: $e');
    });
    super.dispose();
  }

  Color _decisionColor() {
    if (_finalDecision.contains('Tüketmeyin')) {
      return const Color.fromRGBO(255, 82, 82, 1.0); // redAccent
    }
    if (_finalDecision.contains('Dikkat') || _finalDecision.contains('belirlenemedi')) {
      return Colors.orangeAccent;
    }
    return const Color.fromRGBO(26, 255, 117, 1.0); // greenAccent
  }

  Widget _buildStatusOverlay() {
    final overlayColor = _decisionColor().withAlpha(204); // %80 alpha
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(12),
        color: Colors.black54,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusText('Ürün: $_detectedProduct'),
            const SizedBox(height: 4),
            _buildStatusText('Paket Durumu: $_defectStatus'),
            const SizedBox(height: 4),
            _buildStatusText(_profileStatus),
            const SizedBox(height: 4),
            _buildStatusText('Sağlık Puanı: ${_healthScore.toStringAsFixed(0)}'),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              decoration: BoxDecoration(
                color: overlayColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _finalDecision,
                style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusText(String text) {
    return Text(text, style: const TextStyle(color: Colors.white, fontSize: 14));
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('AI Kamera - Tarama')),
      body: Stack(
        children: [
          CameraPreview(_controller!),
          _buildStatusOverlay(),
        ],
      ),
    );
  }
}