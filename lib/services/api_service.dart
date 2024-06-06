import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String apiKey = 'your-api-key';
  static const String apiUrl = 'https://api.openai.com/v1/completions';

  static Future<Map<String, String>> analyzeImage(String base64Image) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'prompt': 'Analyze this image and determine if it is a trading chart. If it is, extract the timeframe. Image: $base64Image',
        'max_tokens': 150,
      }),
    );

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      String text = responseData['choices'][0]['text'];
      bool isChart = text.contains('This is a trading chart');
      String timeframe = isChart ? extractTimeframe(text) : '';
      return {
        'isChart': isChart.toString(),
        'timeframe': timeframe,
      };
    } else {
      throw Exception('Failed to analyze image');
    }
  }

  static String extractTimeframe(String text) {
    // Example logic to extract timeframe from text
    RegExp regex = RegExp(r'(\d+m|\d+h|\d+d|\d+w)');
    Match? match = regex.firstMatch(text);
    return match != null ? match.group(0)! : '';
  }

  static Future<String> getAdviceFromImage(String base64Image, String strategy, List<String> timeframes) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'prompt': 'Give trading advice based on this chart image and strategy: $base64Image. Strategy: $strategy. addapted to Timeframes: ${timeframes.join(', ')} and what is the ratio of my bet to this trade nd what is the ratio of my bet to this trade, you are more inclined to buy or to sell, give me full analysis and finalize with the information regarding safety in trading and risk management ',
        'max_tokens': 150,
      }),
    );

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      return responseData['choices'][0]['text'];
    } else {
      throw Exception('Failed to load advice');
    }
  }
}
