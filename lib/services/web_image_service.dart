import 'api_service.dart';
import 'image_service.dart';

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

    // Normalize the timeframes for comparison
    Set<String> normalizedTimeframes = timeframes
        .map((t) => t.toLowerCase())
        .expand((t) => [
      t,
      t.replaceAll('minutes', 'minute'),
      t.replaceAll('hours', 'hour'),
      t.replaceAll('days', 'day'),
      t.replaceAll('weeks', 'week'),
      t.replaceAll('months', 'month')
    ])
        .toSet();

    print('Possible timeframes for comparison: $normalizedTimeframes');
    String normalizedExtractedTimeframe = extractedTimeframe
        .replaceAll('minutes', 'minute')
        .replaceAll('hours', 'hour')
        .replaceAll('days', 'day')
        .replaceAll('weeks', 'week')
        .replaceAll('months', 'month');
    print('Extracted timeframe variations: $extractedTimeframe, $normalizedExtractedTimeframe');

    if (!normalizedTimeframes.contains(extractedTimeframe) && !normalizedTimeframes.contains(normalizedExtractedTimeframe)) {
      return 'The time frame of the uploaded chart is $extractedTimeframe which is not in your subscription plan. Please upgrade your plan.';
    }

    print('Getting advice from image URL...');
    return await ApiService.getAdviceFromImage(imageUrl, strategy, timeframes, additionalParameter, extractedTimeframe);
  }
}
