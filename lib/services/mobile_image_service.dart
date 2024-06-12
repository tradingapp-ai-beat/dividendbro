import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:trading_advice_app_v2/services/api_service.dart';
import 'package:trading_advice_app_v2/services/image_service.dart';

class MobileImageService implements ImageService {
  @override
  Future<String> processImage(String imageUrl, String strategy, List<String> timeframes, String additionalParameter) async {
    print('Mobile - Image URL: $imageUrl');
    print('Strategy: $strategy');
    print('Timeframes: $timeframes');
    print('Additional Parameter: $additionalParameter');

    // Download the image from the URL
    final response = await http.get(Uri.parse(imageUrl));
    print('Download response status: ${response.statusCode}');
    if (response.statusCode != 200) {
      throw Exception('Failed to download image');
    }

    // Save the image to a temporary file
    final tempDir = Directory.systemTemp;
    final tempFile = File('${tempDir.path}/temp_image.jpg');
    await tempFile.writeAsBytes(response.bodyBytes);
    print('Image saved to temp file: ${tempFile.path}');

    // Analyze the original image
    print('Analyzing image...');
    Map<String, String> analysisResult = await ApiService.analyzeImageFromUrl(imageUrl);
    print('Analysis result: $analysisResult');

    if (analysisResult['isChart'] == 'false') {
      return 'The uploaded image is not a trading chart. Please upload a valid trading chart image.';
    }

    String? extractedTimeframe = analysisResult['timeframe'];
    print('Extracted timeframe: $extractedTimeframe');

    if (extractedTimeframe == null || extractedTimeframe.isEmpty) {
      return 'The uploaded chart image does not contain clear information. Please upload a better-quality image with more detail.';
    }

    if (!timeframes.contains(extractedTimeframe)) {
      return 'The time frame of the uploaded chart is $extractedTimeframe which is not in your subscription plan. Please upgrade your plan.';
    }

    // Resize and compress the image for base64 encoding
    img.Image? image = img.decodeImage(tempFile.readAsBytesSync());
    if (image == null) {
      throw Exception('Failed to decode image');
    }
    img.Image resizedImage = img.copyResize(image, width: 800);
    List<int> resizedBytes = img.encodeJpg(resizedImage, quality: 70);
    String base64Image = base64Encode(resizedBytes);
    print('Base64 Image length: ${base64Image.length}');

    // Get trading advice from the image
    print('Getting advice from image...');
    return await ApiService.getAdviceFromImage(base64Image, strategy, timeframes, additionalParameter);
  }
}
