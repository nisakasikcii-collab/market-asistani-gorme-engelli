import 'package:camera/camera.dart';

import '../../../core/ai/gemini_client.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/voice/voice_feedback.dart';
import '../../profile/data/user_profile_repository.dart';

class ObjectDetectorWithTts {
  ObjectDetectorWithTts._();
  static final ObjectDetectorWithTts instance = ObjectDetectorWithTts._();

  final VoiceFeedback _voice = VoiceFeedback.instance;

  bool _isProcessing = false;
  DateTime _lastSpokenAt = DateTime.fromMillisecondsSinceEpoch(0);

  static const Duration _minSpeakInterval = Duration(seconds: 4);

  Future<void> detectAndSpeakProductDetails(
    CameraImage image, {
    required int sensorOrientation,
  }) async {
    if (_isProcessing) return;

    final now = DateTime.now();
    if (now.difference(_lastSpokenAt) < _minSpeakInterval) return;

    _isProcessing = true;

    try {
      final profile = UserProfileRepository.instance.profile;
      final restrictions = profile?.restrictions ?? <dynamic>{};

      final result = await GeminiClient.analyzeImageForProductDetails(
        cameraImage: image,
        sensorOrientation: sensorOrientation,
        userRestrictions: restrictions,
      );

      if (result == null || result.isEmpty) return;

      await _voice.speakInfo(result);
      _lastSpokenAt = now;
    } catch (e, st) {
      AppLogger.d("ObjectDetector hata", e, st);
    } finally {
      _isProcessing = false;
    }
  }
}