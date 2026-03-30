import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';
import 'dart:ui';
import 'dart:typed_data';

import '../../../core/logging/app_logger.dart';
import '../../profile/domain/dietary_restriction.dart';

class CameraAnalysisResult {
  final List<String> objectLabels;
  final bool isDefected;
  final double healthScore;
  final String? barcode;
  final List<Rect> objectBounds;
  final String? defectType;
  final double? defectConfidence;
  final List<String> imageLabels;
  final List<ImageLabel> rawImageLabels;
  final String ocrText;

  CameraAnalysisResult({
    required this.objectLabels,
    required this.isDefected,
    required this.healthScore,
    required this.objectBounds,
    required this.imageLabels,
    required this.rawImageLabels,
    required this.ocrText,
    this.barcode,
    this.defectType,
    this.defectConfidence,
  });
}

class MlKitService {
  MlKitService._() {
    _objectDetector = ObjectDetector(
      options: ObjectDetectorOptions(
        mode: DetectionMode.stream,
        classifyObjects: true,
        multipleObjects: true,
      ),
    );
    _barcodeScanner = BarcodeScanner();
    _imageLabeler = ImageLabeler(options: ImageLabelerOptions());
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  }

  static final MlKitService instance = MlKitService._();

  late final ObjectDetector _objectDetector;
  late final BarcodeScanner _barcodeScanner;
  late final ImageLabeler _imageLabeler;
  late final TextRecognizer _textRecognizer;

  InputImage _cameraImageToInputImage(CameraImage image, int sensorOrientation) {
    try {
      final rotation = _sensorToRotation(sensorOrientation);
      final int width = image.width;
      final int height = image.height;
      
      if (Platform.isAndroid) {
        // Android için NV21 dönüşümü (ImageFormat not supported hatası çözümü)
        if (image.planes.length < 3) {
          throw Exception('YUV_420_888 formatı için en az 3 plane gereklidir.');
        }

        final planeY = image.planes[0];
        final planeU = image.planes[1];
        final planeV = image.planes[2];

        final yBytes = planeY.bytes;
        final uBytes = planeU.bytes;
        final vBytes = planeV.bytes;

        // pixelStride yerine bytesPerPixel kullan (camera plugin versiyonuna göre)
        final uPixelStride = planeU.bytesPerPixel ?? 1;
        final vPixelStride = planeV.bytesPerPixel ?? 1;

        // NV21 formatı: Y düzlemi + (V ve U düzlemleri interleave edilmiş)
        final nv21Bytes = Uint8List(width * height * 3 ~/ 2);
        
        // Y düzlemini kopyala (Padding'i kaldırarak optimize et)
        if (planeY.bytesPerRow == width) {
          nv21Bytes.setRange(0, width * height, yBytes);
        } else {
          for (int row = 0; row < height; row++) {
            final int yRowStart = row * planeY.bytesPerRow;
            final int nvRowStart = row * width;
            nv21Bytes.setRange(nvRowStart, nvRowStart + width, yBytes.getRange(yRowStart, yRowStart + width));
          }
        }

        // V ve U düzlemlerini interleave et (NV21: V, U, V, U...)
        int i = width * height;
        final int heightHalf = height ~/ 2;
        final int widthHalf = width ~/ 2;
        
        for (int row = 0; row < heightHalf; row++) {
          final int vRowStart = row * planeV.bytesPerRow;
          final int uRowStart = row * planeU.bytesPerRow;
          for (int col = 0; col < widthHalf; col++) {
            final int vIndex = vRowStart + col * vPixelStride;
            final int uIndex = uRowStart + col * uPixelStride;
            
            if (vIndex < vBytes.length && uIndex < uBytes.length && i + 1 < nv21Bytes.length) {
              nv21Bytes[i++] = vBytes[vIndex];
              nv21Bytes[i++] = uBytes[uIndex];
            }
          }
        }

        final metadata = InputImageMetadata(
          size: Size(width.toDouble(), height.toDouble()),
          rotation: rotation,
          format: InputImageFormat.nv21,
          bytesPerRow: width,
        );

        return InputImage.fromBytes(bytes: nv21Bytes, metadata: metadata);
      } else {
        // iOS için BGRA8888
        final bytes = image.planes[0].bytes;
        final metadata = InputImageMetadata(
          size: Size(width.toDouble(), height.toDouble()),
          rotation: rotation,
          format: InputImageFormat.bgra8888,
          bytesPerRow: image.planes[0].bytesPerRow,
        );
        return InputImage.fromBytes(bytes: bytes, metadata: metadata);
      }
    } catch (e) {
      AppLogger.d('[ImageConverter] Dönüştürme hatası: $e');
      rethrow;
    }
  }

  InputImageRotation _sensorToRotation(int degrees) {
    switch (degrees) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      case 0:
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  Future<CameraAnalysisResult> analyzeFrame(CameraImage image, int sensorOrientation) async {
    try {
      final inputImage = _cameraImageToInputImage(image, sensorOrientation);

      // ML Kit işlemlerini paralel çalıştırarak hızı artır
      final results = await Future.wait([
        _barcodeScanner.processImage(inputImage),
        _objectDetector.processImage(inputImage),
        _imageLabeler.processImage(inputImage),
        _textRecognizer.processImage(inputImage),
      ]);

      // 1. Barkod
      final barcodes = results[0] as List<Barcode>;
      final barcodeValue = barcodes.isNotEmpty ? barcodes.first.rawValue : null;

      // 2. Nesne Algılama
      final objects = results[1] as List<DetectedObject>;
      final labelsSet = <String>{};
      final bounds = <Rect>[];
      for (final obj in objects) {
        if (obj.labels.isNotEmpty) {
          labelsSet.addAll(obj.labels.map((e) => e.text.toLowerCase()));
        }
        bounds.add(obj.boundingBox);
      }
      final objectLabels = labelsSet.toList();

      // 3. Image Labeling
      final labels = results[2] as List<ImageLabel>;
      final imageLabelsStr = labels.map((e) => e.label.toLowerCase()).toList();

      // 4. Text Recognition (OCR)
      final recognizedText = results[3] as RecognizedText;
      final ocrText = recognizedText.text.toLowerCase();

      // Defect kontrolü
      final defectResult = evaluateDefect(objects, labels);
      final defectDetected = defectResult['isDefected'] as bool;
      final defectType = defectResult['type'] as String?;
      final defectConfidence = defectResult['confidence'] as double?;

      // Puanlama: Defect veya Şeker tespiti puanı düşürür
      final isSugarInOcr = parseDietaryIssuesFromText(ocrText).contains(DietaryRestriction.diabetes);
      final baseScore = 100 - (defectDetected ? 50 : 0) - (isSugarInOcr ? 40 : 0) - (objectLabels.length * 2);
      final healthScore = baseScore.clamp(0, 100).toDouble();

      return CameraAnalysisResult(
        objectLabels: objectLabels,
        imageLabels: imageLabelsStr,
        rawImageLabels: labels,
        ocrText: ocrText,
        isDefected: defectDetected,
        healthScore: healthScore,
        objectBounds: bounds,
        barcode: barcodeValue,
        defectType: defectType,
        defectConfidence: defectConfidence,
      );
    } catch (e) {
      AppLogger.d('analyzeFrame hatası: $e');
      return CameraAnalysisResult(
        objectLabels: [],
        imageLabels: [],
        rawImageLabels: [],
        ocrText: '',
        isDefected: false,
        healthScore: 0,
        objectBounds: [],
        barcode: null,
        defectType: null,
        defectConfidence: null,
      );
    }
  }

  Future<String?> scanBarcode(CameraImage image, int sensorOrientation) async {
    final inputImage = _cameraImageToInputImage(image, sensorOrientation);
    final barcodes = await _barcodeScanner.processImage(inputImage);
    if (barcodes.isEmpty) return null;
    return barcodes.first.rawValue;
  }

  Map<String, dynamic> evaluateDefect(List<DetectedObject> objects, List<ImageLabel> imageLabels) {
    // **KRİTİK HASAR/YIRTIK ANAHTAR KELİMELERİ**
    final damageKeywords = [
      'torn', 'damaged', 'ripped', 'waste', 'hole', 'plastic wrap',
      'smash', 'crushed', 'broken', 'rip', 'yırtık', 'hasarlı', 'delik', 'bozuk'
    ];

    String? detectedDefectType;
    double maxConfidence = 0.0;

    // 1. Image Labeler sonuçlarını kontrol et (Kullanıcının istediği en kritik nokta)
    for (final labelObj in imageLabels) {
      final label = labelObj.label.toLowerCase();
      for (final keyword in damageKeywords) {
        if (label.contains(keyword)) {
          // Özel durum: 'hole' için güven skoru yüksek olmalı
          if (keyword == 'hole' && labelObj.confidence < 0.7) continue;
          
          detectedDefectType = 'Paket yırtık veya hasarlı!';
          maxConfidence = labelObj.confidence;
          break;
        }
      }
      if (detectedDefectType != null) break;
    }

    // 2. Object Detector etiketlerini kontrol et
    if (detectedDefectType == null) {
      for (final obj in objects) {
        for (final objLabel in obj.labels) {
          final label = objLabel.text.toLowerCase();
          for (final keyword in damageKeywords) {
            if (label.contains(keyword)) {
              // Özel durum: 'hole' için güven skoru yüksek olmalı
              if (keyword == 'hole' && objLabel.confidence < 0.7) continue;

              detectedDefectType = 'Paket yırtık!';
              maxConfidence = objLabel.confidence;
              break;
            }
          }
          if (detectedDefectType != null) break;
        }
        if (detectedDefectType != null) break;
      }
    }

    final isDefected = detectedDefectType != null;

    return {
      'type': detectedDefectType,
      'confidence': isDefected ? maxConfidence : null,
      'isDefected': isDefected,
    };
  }

  static Set<DietaryRestriction> parseDietaryIssuesFromText(String text) {
    final lower = text.toLowerCase();
    
    final parser = <DietaryRestriction, List<String>>{
      DietaryRestriction.diabetes: [
        'şeker', 'seker', 'sugar', 'glikoz', 'glukoz', 'fruktoz', 'sakkaroz', 'sukroz',
        'tatlandırıcı', 'tatlandirici', 'aspartam', 'asesülfam', 'sakarin', 'sukraloz', 
        'maltitol', 'ksilitol', 'sorbitol', 'mısır şurubu', 'misir surubu', 'surup', 'şurup',
        'karamel', 'maltodekstrin', 'agave', 'stevia', 'karbonhidrat'
      ],
      DietaryRestriction.celiac: [
        'un', 'buğday', 'bugday', 'gluten', 'arpa', 'çavdar', 'cavdar', 'nişasta', 'nisasta', 
        'wheat', 'barley', 'rye', 'oat', 'yulaf'
      ],
      DietaryRestriction.vegan: [
        'süt', 'sut', 'yumurta', 'bal', 'peynir', 'et', 'jelatin', 'kazein', 'laktoz', 'laktos',
        'milk', 'egg', 'honey', 'cheese', 'meat', 'gelatin', 'casein', 'lactose', 'yoğurt', 'yogurt'
      ],
      DietaryRestriction.milkAllergy: [
        'süt', 'sut', 'peynir', 'yoğurt', 'yogurt', 'krema', 'laktos', 'lactose', 'milk', 'cream', 'cheese', 'kazein'
      ],
      DietaryRestriction.hypertension: [
        'tuz', 'sodyum', 'natrium', 'tursu', 'turşu', 'salamura', 'salt', 'sodium', 'trans yağ', 'doymuş yağ'
      ],
    };

    final found = <DietaryRestriction>{};
    for (final entry in parser.entries) {
      if (entry.value.any((keyword) => lower.contains(keyword))) {
        found.add(entry.key);
      }
    }
    return found;
  }

  void close() {
    _objectDetector.close();
    _barcodeScanner.close();
    _imageLabeler.close();
    _textRecognizer.close();
  }
}
