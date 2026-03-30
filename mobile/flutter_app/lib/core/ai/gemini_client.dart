import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

import '../api/api_client.dart';

class GeminiClient {
  static const String apiKey = "AIzaSyDIRPeXdWdRAWaevgiboKKCX4tvxNNQ4g8";
  static const String url =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro-vision:generateContent?key=$apiKey";

  static Future<String?> analyzeImage(List<int> imageBytes) async {
    final base64Image = base64Encode(imageBytes);

    final body = {
      "contents": [
        {
          "parts": [
            {"text": "Bu görüntüdeki ürünü söyle."},
            {
              "inline_data": {
                "mime_type": "image/jpeg",
                "data": base64Image
              }
            }
          ]
        }
      ]
    };

    final isOnline = await ApiClient.instance.isConnected();
    if (!isOnline) {
      print('Ağ yok, local yorumlama yapılıyor.');
      return null;
    }

    try {
      final resp = await ApiClient.instance.post(url, data: body);
      if (resp.statusCode == 404) {
        print('Gemini 404 endpoint hatası: $url');
        return null;
      }
      if (resp.statusCode != 200) {
        print("HATA: ${resp.statusCode} ${resp.data}");
        return null;
      }
      final data = resp.data;
      if (data is Map<String, dynamic>) {
        return data['candidates']?[0]?["content"]?["parts"]?[0]?["text"] as String?;
      }
      return null;
    } catch (e) {
      print("Gemini API hatası: $e");
      return null;
    }
  }

  static Future<String?> analyzeImageForProductDetails({
    required CameraImage cameraImage,
    required int sensorOrientation,
    required Set<dynamic> userRestrictions,
  }) async {
    final jpegBytes = _convertToJpeg(cameraImage);
    final restrictionsText = userRestrictions.isNotEmpty
        ? "Kullanıcı kısıtlamaları: ${userRestrictions.map((e) => e.toString()).join(', ')}."
        : "";

    final base64Image = base64Encode(jpegBytes);

    final prompt =
        "Bu fotoğraftaki ürünü tanımla ve beslenme bilgilerini kısa bir şekilde ver. "
        "$restrictionsText "
        "Öncelikle ürün adıyla başla.";

    final body = {
      "contents": [
        {
          "parts": [
            {"text": prompt},
            {
              "inline_data": {
                "mime_type": "image/jpeg",
                "data": base64Image
              }
            }
          ]
        }
      ]
    };

    final isOnline = await ApiClient.instance.isConnected();
    if (!isOnline) {
      return null;
    }

    try {
      final resp = await ApiClient.instance.post(url, data: body);
      if (resp.statusCode == 404) {
        print('Gemini 404 endpoint hatası: $url');
        return null;
      }
      if (resp.statusCode != 200) {
        print("HATA: ${resp.statusCode} ${resp.data}");
        return null;
      }
      final data = resp.data;
      if (data is Map<String, dynamic>) {
        return data['candidates']?[0]?["content"]?["parts"]?[0]?["text"] as String?;
      }
      return null;
    } catch (e) {
      print("Gemini API hatası: $e");
      return null;
    }
  }

  static List<int> _convertToJpeg(CameraImage image) {
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
}
