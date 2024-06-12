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

    print('Getting advice from image URL...');
    return await ApiService.getAdviceFromImage(imageUrl, strategy, timeframes, additionalParameter);
  }
}
