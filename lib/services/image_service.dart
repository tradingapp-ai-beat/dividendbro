import 'dart:convert';
import 'dart:io';
import 'api_service.dart';

class ImageService {
  static Future<String> processImage(String imagePath, String strategy, List<String> timeframes) async {
    File imageFile = File(imagePath);
    String base64Image = base64Encode(imageFile.readAsBytesSync());

    Map<String, String> analysisResult = await ApiService.analyzeImage(base64Image);

    if (analysisResult['isChart'] == 'false') {
      return 'The uploaded image is not a trading chart. Please upload a valid trading chart image.';
    }

    String? extractedTimeframe = analysisResult['timeframe'];

    if (extractedTimeframe == null || extractedTimeframe.isEmpty) {
      return 'The uploaded chart image does not contain clear information. Please upload a better-quality image with more detail.';
    }

    if (!timeframes.contains(extractedTimeframe)) {
      return 'The timeframe of the uploaded chart is $extractedTimeframe which is not in your subscription plan. Please upgrade your plan.';
    }

    return await ApiService.getAdviceFromImage(base64Image, strategy, timeframes);
  }
}
