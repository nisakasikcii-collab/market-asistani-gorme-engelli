import "package:camera/camera.dart";
import "package:google_mlkit_object_detection/google_mlkit_object_detection.dart";
import "dart:math";
import "dart:ui" as ui;
import "dart:typed_data";
import "dart:io";
import "package:flutter/foundation.dart";

/// Ürün spesifik kusur skorları için yardımcı sınıf
class _AdjustedScores {
  final double tearScore;
  final double puffScore;
  final double discolorationScore;

  _AdjustedScores({
    required this.tearScore,
    required this.puffScore,
    required this.discolorationScore,
  });
}

/// Ürün ambalajının fiziksel kusurlarını algılar (şişlik, yırtılma, hasar, vb.)
class DefectDetector {
  DefectDetector._() {
    // Object detector'ı başlat
    final options = ObjectDetectorOptions(
      mode: DetectionMode.single,
      classifyObjects: false,
      multipleObjects: false,
    );
    _objectDetector = ObjectDetector(options: options);
  }

  static final DefectDetector instance = DefectDetector._();

  // ML Kit Object Detector
  late final ObjectDetector _objectDetector;

  /// Kamera görüntüsünün fiziksel kusurlarını analiz eder.
  /// ML tabanlı nesne algılama + görüntü işleme kullanarak kusurları tespit eder.
  Future<DefectAnalysisResult> analyzeFrame(
    CameraImage image, {
    required int sensorOrientation,
    String? productType, // Ürün türü (örneğin: "süt", "meyve", "esnek_paket")
  }) async {
    try {
      // Görüntüyü InputImage'a dönüştür
      final inputImage = _cameraImageToInputImage(image, sensorOrientation);
      if (inputImage == null) {
        // ML başarısız olursa geleneksel yöntemle devam et
        return _analyzeTraditional(image, productType: productType);
      }

      // ML Kit ile nesne algılama
      final objects = await _objectDetector.processImage(inputImage);

      if (objects.isEmpty) {
        // Nesne algılanmadıysa geleneksel yöntem kullan
        return _analyzeTraditional(image, productType: productType);
      }

      // İlk algılanan nesneyi al (en güvenilir olan)
      final detectedObject = objects.first;

      // Nesne bölgesini çıkar
      final objectRegion = await _extractObjectRegion(image, detectedObject.boundingBox);

      if (objectRegion == null) {
        return _analyzeTraditional(image, productType: productType);
      }

      // ML destekli kusur analizi
      return await _analyzeDefectsWithML(objectRegion, detectedObject, productType);

    } catch (e) {
      // ML başarısız olursa geleneksel yöntemle fallback
      return _analyzeTraditional(image, productType: productType);
    }
  }

  /// Geleneksel görüntü işleme ile kusur analizi (fallback)
  Future<DefectAnalysisResult> _analyzeTraditional(
    CameraImage image, {
    String? productType,
  }) async {
    try {
      final int width = image.width;
      final int height = image.height;
      final int bytesPerRow = image.planes.first.bytesPerRow;

      // Görüntüyü gri tonlamaya dönüştür (kenar algılamayı basitleştirmek için)
      final grayscale = _cameraImageToGrayscale(image);
      if (grayscale == null) return DefectAnalysisResult.none();

      // Kenar algılamayı yap (Sobel operatörü basitleştirilmesi)
      final edges = _detectEdges(grayscale, width, height, bytesPerRow);

      // Kenar yoğunluğunu Analiz et (yırtılma/hasar göstergesi)
      final tearScore = _calculateTearScore(edges, width, height, bytesPerRow);

      // Kontur analizi (şişlik/deformasyon göstergesi)
      final puffScore = _calculatePuffScore(edges, width, height, bytesPerRow);

      // Renk dağılımı analizi (diskolorasyon göstergesi)
      final discolorationScore = _calculateDiscolorationScore(image);

      // Ürün spesifik kusur paternlerini uygula
      final adjustedScores = _adjustScoresForProductType(
        tearScore: tearScore,
        puffScore: puffScore,
        discolorationScore: discolorationScore,
        productType: productType,
      );

      // Sonuç oluştur
      final result = DefectAnalysisResult(
        hasTearing: adjustedScores.tearScore > 0.6,
        hasSwelling: adjustedScores.puffScore > 0.6,
        hasDiscoloration: adjustedScores.discolorationScore > 0.5,
        tearConfidence: min(1.0, adjustedScores.tearScore),
        puffConfidence: min(1.0, adjustedScores.puffScore),
        discolorationConfidence: min(1.0, adjustedScores.discolorationScore),
      );

      return result;
    } catch (e) {
      return DefectAnalysisResult.none();
    }
  }

  /// Kamera görüntüsünü gri tonlamaya dönüştürür
  List<int>? _cameraImageToGrayscale(CameraImage image) {
    try {
      // NV21 formatı (Android) için
      if (image.format.group == ImageFormatGroup.nv21) {
        return image.planes.first.bytes;
      }

      // YUV 4:2:0 formatı için
      if (image.format.group == ImageFormatGroup.yuv420) {
        final planes = image.planes;
        if (planes.isNotEmpty) {
          return planes.first.bytes;
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Sobel operatörü kullanarak kenarları algılar
  List<int> _detectEdges(List<int> grayBytes, int width, int height, int bytesPerRow) {
    final edges = List<int>.filled(grayBytes.length, 0);

    // Görüntü kenarlarını işle (1 piksel kenara bırak)
    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        // Sobel Gx ve Gy operatörleri (basitleştirilmiş)
        final int center = y * bytesPerRow + x;
        final gx = -grayBytes[(y - 1) * bytesPerRow + (x - 1)] +
            grayBytes[(y - 1) * bytesPerRow + (x + 1)] -
            2 * grayBytes[y * bytesPerRow + (x - 1)] +
            2 * grayBytes[y * bytesPerRow + (x + 1)] -
            grayBytes[(y + 1) * bytesPerRow + (x - 1)] +
            grayBytes[(y + 1) * bytesPerRow + (x + 1)];

        final gy = -grayBytes[(y - 1) * bytesPerRow + (x - 1)] -
            2 * grayBytes[(y - 1) * bytesPerRow + x] -
            grayBytes[(y - 1) * bytesPerRow + (x + 1)] +
            grayBytes[(y + 1) * bytesPerRow + (x - 1)] +
            2 * grayBytes[(y + 1) * bytesPerRow + x] +
            grayBytes[(y + 1) * bytesPerRow + (x + 1)];

        final magnitude = sqrt(gx * gx + gy * gy).toInt();
        edges[center] = min(255, magnitude);
      }
    }

    return edges;
  }

  /// Yırtılma skorunu hesapla (dar, keskin kenarlar)
  double _calculateTearScore(List<int> edges, int width, int height, int bytesPerRow) {
    if (edges.isEmpty) return 0.0;

    // Yüksek kenar yoğunluğu olan pikselleri say
    int highEdgePixels = 0;
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        if (edges[y * bytesPerRow + x] > 150) highEdgePixels++;
      }
    }
    final edgeRatio = highEdgePixels / (width * height);

    // Keskin kenarların dağılımını analiz et (yırtılma düzensiz kenarlar içerir)
    int irregularEdges = 0;
    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        final idx = y * bytesPerRow + x;
        if (edges[idx] > 100) {
          // Etrafındaki kenar yoğunluğunu kontrol et
          final neighbors = [
            edges[(y - 1) * bytesPerRow + x],
            edges[(y + 1) * bytesPerRow + x],
            edges[y * bytesPerRow + (x - 1)],
            edges[y * bytesPerRow + (x + 1)],
          ];

          final variance = _calculateVariance(neighbors.cast<double>());
          if (variance > 3000) irregularEdges++;
        }
      }
    }

    final irregularRatio = irregularEdges / (width * height);

    // Yırtılma: yüksek kenar yoğunluğu + düzensiz kenarlar
    return (edgeRatio * 0.6) + (irregularRatio * 0.4);
  }

  /// Şişlik skorunu hesapla (kontur deformasyonu)
  double _calculatePuffScore(List<int> edges, int width, int height, int bytesPerRow) {
    if (edges.isEmpty) return 0.0;

    int roundedBoundaryPixels = 0;
    int totalBoundaryPixels = 0;

    for (int y = height ~/ 4; y < (3 * height) ~/ 4; y++) {
      for (int x = width ~/ 4; x < (3 * width) ~/ 4; x++) {
        final idx = y * bytesPerRow + x;
        if (edges[idx] > 80) {
          totalBoundaryPixels++;

          final smoothness = _calculateEdgeSmoothness(edges, x, y, width, bytesPerRow);
          if (smoothness > 0.5) roundedBoundaryPixels++;
        }
      }
    }

    final roundedRatio = totalBoundaryPixels > 0
        ? roundedBoundaryPixels / totalBoundaryPixels
        : 0.0;

    return min(1.0, roundedRatio * 0.8);
  }

  /// Kenarın yumuşaklığını hesapla (şişlik göstergesi)
  double _calculateEdgeSmoothness(List<int> edges, int x, int y, int width, int bytesPerRow) {
    try {
      final neighbors = [
        edges[y * bytesPerRow + x],
        edges[(y - 1) * bytesPerRow + x],
        edges[(y + 1) * bytesPerRow + x],
        edges[y * bytesPerRow + (x - 1)],
        edges[y * bytesPerRow + (x + 1)],
      ];

      final avg = neighbors.reduce((a, b) => a + b) / neighbors.length;
      final variance = neighbors.fold<double>(
        0.0,
        (sum, val) => sum + (val - avg) * (val - avg),
      ) / neighbors.length;

      // Düşük varyans = yumuşak kenarlar
      return max(0.0, 1.0 - (variance / 10000.0));
    } catch (e) {
      return 0.0;
    }
  }

  /// Diskolorasyon skorunu hesapla (renk dağılımı analizi)
  double _calculateDiscolorationScore(CameraImage image) {
    try {
      final planes = image.planes;
      if (planes.isEmpty) return 0.0;

      // Y düzleminin (lüminans) varyansını hesapla
      final yPlane = planes.first.bytes;

      if (yPlane.length < 1000) return 0.0;

      final sample = yPlane.take(min(1000, yPlane.length)).toList();
      final variance = _calculateVariance(sample.cast<double>());

      // Yüksek varyans diskolorasyonu gösterebilir
      return min(1.0, variance / 5000.0);
    } catch (e) {
      return 0.0;
    }
  }

  /// Sayılar listesinin varyansını hesapla
  double _calculateVariance(List<num> values) {
    if (values.isEmpty) return 0.0;

    final mean = values.reduce((a, b) => a + b) / values.length;
    final sumOfSquares = values.fold<double>(
      0.0,
      (sum, val) => sum + (val - mean) * (val - mean),
    );

    return sumOfSquares / values.length;
  }

  /// CameraImage'ı ML Kit InputImage'a dönüştürür
  InputImage? _cameraImageToInputImage(CameraImage image, int sensorOrientation) {
    try {
      final rotation = _rotationFromSensorOrientation(sensorOrientation);
      
      if (Platform.isAndroid) {
        // Android için NV21 dönüşümü (ImageFormat not supported hatası çözümü)
        if (image.planes.length < 3) {
          return null; // YUV420 formatı değilse veya plane eksikse
        }

        final planeY = image.planes[0];
        final planeU = image.planes[1];
        final planeV = image.planes[2];

        final yBytes = planeY.bytes;
        final uBytes = planeU.bytes;
        final vBytes = planeV.bytes;

        final int width = image.width;
        final int height = image.height;

        final uPixelStride = planeU.bytesPerPixel ?? 1;
        final vPixelStride = planeV.bytesPerPixel ?? 1;

        final nv21Bytes = Uint8List(width * height * 3 ~/ 2);
        
        // Y düzlemini kopyala (Padding'i kaldırarak)
        for (int row = 0; row < height; row++) {
          final int yRowStart = row * planeY.bytesPerRow;
          final int nvRowStart = row * width;
          final int length = planeY.bytesPerRow >= width ? width : planeY.bytesPerRow;
          nv21Bytes.setRange(nvRowStart, nvRowStart + length, yBytes.getRange(yRowStart, yRowStart + length));
        }

        int i = width * height;
        final int heightHalf = height ~/ 2;
        final int widthHalf = width ~/ 2;
        
        for (int row = 0; row < heightHalf; row++) {
          for (int col = 0; col < widthHalf; col++) {
            final int vIndex = row * planeV.bytesPerRow + col * vPixelStride;
            final int uIndex = row * planeU.bytesPerRow + col * uPixelStride;
            
            if (vIndex < vBytes.length && uIndex < uBytes.length && i + 1 < nv21Bytes.length) {
              nv21Bytes[i++] = vBytes[vIndex];
              nv21Bytes[i++] = uBytes[uIndex];
            }
          }
        }

        final metadata = InputImageMetadata(
          size: ui.Size(width.toDouble(), height.toDouble()),
          rotation: rotation,
          format: InputImageFormat.nv21,
          bytesPerRow: width,
        );

        return InputImage.fromBytes(bytes: nv21Bytes, metadata: metadata);
      } else {
        // iOS için BGRA8888
        final metadata = InputImageMetadata(
          size: ui.Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: InputImageFormat.bgra8888,
          bytesPerRow: image.planes[0].bytesPerRow,
        );

        return InputImage.fromBytes(bytes: image.planes[0].bytes, metadata: metadata);
      }
    } catch (e) {
      return null;
    }
  }

  /// Sensor orientation'dan InputImageRotation'a dönüştürür
  InputImageRotation _rotationFromSensorOrientation(int sensorOrientation) {
    switch (sensorOrientation) {
      case 0:
        return InputImageRotation.rotation0deg;
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  /// Algılanan nesne bölgesini çıkarır
  Future<CameraImage?> _extractObjectRegion(CameraImage image, ui.Rect boundingBox) async {
    try {
      // Bounding box'ı image boyutlarına göre scale et (ileride kullanılabilir)
      // final scaleX = image.width / boundingBox.right;
      // final scaleY = image.height / boundingBox.bottom;

      // Region of interest'i çıkar (basitleştirilmiş)
      // Gerçek implementasyon için image cropping gerekli
      return image; // Şimdilik tüm görüntüyü döndür
    } catch (e) {
      return null;
    }
  }

  /// ML destekli kusur analizi
  Future<DefectAnalysisResult> _analyzeDefectsWithML(
    CameraImage image,
    DetectedObject detectedObject,
    String? productType,
  ) async {
    // Nesne algılandığı için geleneksel analizi kullan ama ML güven skorunu ekle
    final traditionalResult = await _analyzeTraditional(image, productType: productType);

    // ML güven skorunu geleneksel skorlara ekle
    final mlConfidence = detectedObject.labels.isNotEmpty
        ? detectedObject.labels.first.confidence
        : 0.5;

    // ML algılama güvenini kusur güvenlerine ekle
    return DefectAnalysisResult(
      hasTearing: traditionalResult.hasTearing,
      hasSwelling: traditionalResult.hasSwelling,
      hasDiscoloration: traditionalResult.hasDiscoloration,
      tearConfidence: min(1.0, traditionalResult.tearConfidence + (mlConfidence * 0.2)),
      puffConfidence: min(1.0, traditionalResult.puffConfidence + (mlConfidence * 0.2)),
      discolorationConfidence: min(1.0, traditionalResult.discolorationConfidence + (mlConfidence * 0.2)),
    );
  }

  /// Ürün türüne göre kusur skorlarını ayarla
  _AdjustedScores _adjustScoresForProductType({
    required double tearScore,
    required double puffScore,
    required double discolorationScore,
    String? productType,
  }) {
    if (productType == null) {
      return _AdjustedScores(
        tearScore: tearScore,
        puffScore: puffScore,
        discolorationScore: discolorationScore,
      );
    }

    switch (productType.toLowerCase()) {
      case 'esnek_paket':
      case 'poşet':
        // Esnek paketlerde hafif deformasyon normal
        return _AdjustedScores(
          tearScore: tearScore, // Yırtılma hala önemli
          puffScore: puffScore * 0.7, // Hafif şişlikleri tolere et
          discolorationScore: discolorationScore,
        );

      case 'kutu':
      case 'teneke':
        // Sert paketlerde deformasyon önemli
        return _AdjustedScores(
          tearScore: tearScore * 1.2, // Yırtılmayı daha hassas tespit et
          puffScore: puffScore * 1.3, // Şişliği daha hassas tespit et
          discolorationScore: discolorationScore,
        );

      case 'meyve':
      case 'sebze':
        // Organik ürünlerde renk değişimleri normal
        return _AdjustedScores(
          tearScore: tearScore,
          puffScore: puffScore,
          discolorationScore: discolorationScore * 0.6, // Renk değişimlerini tolere et
        );

      case 'içecek':
      case 'şişe':
        // Şişelerde şişlik kritik
        return _AdjustedScores(
          tearScore: tearScore,
          puffScore: puffScore * 1.4, // Şişliği çok hassas tespit et
          discolorationScore: discolorationScore,
        );

      default:
        // Varsayılan ayarlar
        return _AdjustedScores(
          tearScore: tearScore,
          puffScore: puffScore,
          discolorationScore: discolorationScore,
        );
    }
  }

  /// Kaynakları temizle
  void dispose() {
    _objectDetector.close();
  }
}

/// Fiziksel kusur analizi sonucu
class DefectAnalysisResult {
  final bool hasTearing;
  final bool hasSwelling;
  final bool hasDiscoloration;
  final double tearConfidence;
  final double puffConfidence;
  final double discolorationConfidence;

  DefectAnalysisResult({
    required this.hasTearing,
    required this.hasSwelling,
    required this.hasDiscoloration,
    required this.tearConfidence,
    required this.puffConfidence,
    required this.discolorationConfidence,
  });

  factory DefectAnalysisResult.none() {
    return DefectAnalysisResult(
      hasTearing: false,
      hasSwelling: false,
      hasDiscoloration: false,
      tearConfidence: 0.0,
      puffConfidence: 0.0,
      discolorationConfidence: 0.0,
    );
  }

  /// Herhangi bir kusur var mı?
  bool get hasAnyDefect => hasTearing || hasSwelling || hasDiscoloration;

  /// Türkçe kusur açıklaması
  String get defectDescriptionTr {
    final defects = <String>[];

    if (hasTearing) {
      defects.add("Yırtılma veya hasar (güven: %${(tearConfidence * 100).toInt()})");
    }
    if (hasSwelling) {
      defects.add("Şişlik veya deformasyon (güven: %${(puffConfidence * 100).toInt()})");
    }
    if (hasDiscoloration) {
      defects.add("Diskolorasyon veya leke (güven: %${(discolorationConfidence * 100).toInt()})");
    }

    if (defects.isEmpty) return "Kusur algılanmadı";
    return defects.join(", ");
  }

  @override
  String toString() => "DefectAnalysisResult(tearing: $hasTearing, "
      "swelling: $hasSwelling, discoloration: $hasDiscoloration)";
}
