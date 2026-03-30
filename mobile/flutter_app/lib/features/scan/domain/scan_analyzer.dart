import 'package:camera/camera.dart';

import '../data/product_info_service.dart';
import '../logic/ml_kit_service.dart';
import '../../profile/data/user_profile_repository.dart';
import '../../profile/domain/dietary_restriction.dart';

class ScanResult {
  final String productText;
  final bool defectDetected;
  final String healthRisk;
  final double healthScore;
  final List<String> objectLabels;
  final String? defectType;
  final double? defectConfidence;
  final Set<DietaryRestriction> detectedIssues;

  ScanResult({
    required this.productText,
    required this.defectDetected,
    required this.healthRisk,
    required this.healthScore,
    required this.objectLabels,
    required this.detectedIssues,
    this.defectType,
    this.defectConfidence,
  });
}

class ScanAnalyzer {
  ScanAnalyzer._();
  static final ScanAnalyzer instance = ScanAnalyzer._();

  Future<ScanResult> analyze(CameraImage image, int sensorOrientation) async {
    final analysis = await MlKitService.instance.analyzeFrame(image, sensorOrientation);

    var productText = '';
    bool isProductResolved = false;

    // 1. Barkod kontrolü
    if (analysis.barcode != null && analysis.barcode!.isNotEmpty) {
      final resolved = await ProductInfoService.instance.resolveProduct(analysis.barcode!);
      if (resolved != null && resolved.isNotEmpty) {
        productText = resolved;
        isProductResolved = true;
      } else {
        productText = 'Barkod: ${analysis.barcode}';
      }
    }

    // 2. Barkod ile bulunamadıysa nesne etiketlerini veya OCR'ı kullan
    if (!isProductResolved) {
      if (analysis.objectLabels.isNotEmpty) {
        productText = 'Algılanan: ${analysis.objectLabels.join(', ')}';
      } else if (analysis.ocrText.isNotEmpty) {
        productText = analysis.ocrText.split('\n').first;
      } else {
        productText = 'Ürün içeriği belirlenemedi';
      }
    }

    // 3. OCR ve Ürün İsmi Üzerinden Diyet Kontrolü (ÖNCELİKLİ)
    final combinedText = '${analysis.ocrText} $productText'.toLowerCase();
    final issues = MlKitService.parseDietaryIssuesFromText(combinedText);
    
    final String healthRisk;
    if (!isProductResolved && issues.isEmpty && (analysis.ocrText.isEmpty || analysis.ocrText.length < 5)) {
      healthRisk = 'Belirlenemedi';
    } else {
      healthRisk = _determineRisk(issues);
    }

    // Defect tespiti
    final bool isDefected = analysis.isDefected || 
        analysis.objectLabels.any((l) => 
          l.contains('torn') || l.contains('damaged') || l.contains('yırtık') || 
          l.contains('rip') || l.contains('smash') || l.contains('crushed'));

    // Sağlık puanı hesapla
    final healthScore = _calculateHealthScore(isDefected, healthRisk, analysis.healthScore);

    return ScanResult(
      productText: productText,
      defectDetected: isDefected,
      healthRisk: healthRisk,
      healthScore: healthScore,
      objectLabels: analysis.objectLabels,
      detectedIssues: issues,
      defectType: isDefected ? (analysis.defectType ?? 'Paket yırtık!') : null,
      defectConfidence: analysis.defectConfidence,
    );
  }

  String _determineRisk(Set<DietaryRestriction> issues) {
    final profile = UserProfileRepository.instance.profile;
    if (profile == null) return 'Profil bulunamadı';

    final intersect = profile.restrictions.intersection(issues);
    if (intersect.isEmpty) return 'Uygun';
    if (intersect.length == 1) return 'Riskli';
    return 'Tehlikeli';
  }

  double _calculateHealthScore(bool defect, String risk, double mlBaseScore) {
    // mlBaseScore zaten defect durumunu içeriyor olabilir, 
    // ancak biz burada ScanAnalyzer seviyesinde puanı rafine ediyoruz.
    var score = mlBaseScore;
    
    // Risk bazlı ek puan düşüşleri
    switch (risk) {
      case 'Tehlikeli':
        score -= 40;
        break;
      case 'Riskli':
        score -= 20;
        break;
      case 'Uygun':
        score += 10;
        break;
      default:
        score -= 10;
    }
    return score.clamp(0, 100).toDouble();
  }
}
