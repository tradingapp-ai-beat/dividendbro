import 'package:trading_advice_app_v2/services/api_service.dart';
import 'package:trading_advice_app_v2/services/image_service.dart';

class WebImageService implements ImageService {
  @override
  Future<String> processImage(String imageUrl, String strategy, List<String> timeframes, String additionalParameter) async {
    print('Web - Image URL: $imageUrl');
    print('Strategy: $strategy');
    print('Timeframes: $timeframes');
    print('Additional Parameter: $additionalParameter');

    print('Analyzing image from URL...');
    Map<String, String> analysisResult = await ApiService.analyzeImageFromUrl(imageUrl);
    print('Analysis result: $analysisResult');

    bool isChart = analysisResult['isChart'] == 'true';
    String? extractedTimeframe = analysisResult['timeframe']?.toLowerCase();
    print('Extracted timeframe: $extractedTimeframe');

    if (!isChart) {
      return 'The uploaded image is not a trading chart. Please upload a valid trading chart image.';
    }

    if (extractedTimeframe == null || extractedTimeframe.isEmpty) {
      return 'The uploaded chart image does not contain clear information. Please upload a better-quality image with more detail.';
    }

    // Normalize the timeframes for comparison
    // Normalize the timeframes for comparison
    Set<String> normalizedTimeframes = timeframes
        .map((t) => t.toLowerCase())
        .expand((t) => [
      t,
      t.replaceAllMapped(RegExp(r'(\d+)([a-z]+|m|mn)', caseSensitive: false), (Match m) => '${m[2]}${m[1]}'),
      t.replaceAllMapped(RegExp(r'([a-z]+|m|mn)(\d+)', caseSensitive: false), (Match m) => '${m[2]}${m[1]}')
    ])
        .toSet();

    print('Possible timeframes for comparison: $normalizedTimeframes');

    if (!normalizedTimeframes.contains(extractedTimeframe) && !normalizedTimeframes.contains(extractedTimeframe.replaceAll(RegExp(r'(\d+)([a-z]+)', caseSensitive: false), r'$2$1'))) {
      return 'The time frame of the uploaded chart is $extractedTimeframe which is not in your subscription plan. Please upgrade your plan.';
    }

    print('Getting advice from image URL...');
    return await ApiService.getAdviceFromImage(imageUrl, strategy, timeframes, additionalParameter, extractedTimeframe);
  }
}