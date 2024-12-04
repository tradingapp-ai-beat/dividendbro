import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ApiService {
  static const String apiKey = 'xxxxxxxx';
  static const String apiUrl = 'https://api.openai.com/v1/chat/completions';

  static Future<Map<String, String>> analyzeImageFromUrl(String imageUrl) async {
    final requestBody = jsonEncode({
      'model': 'gpt-4o',
      'messages': [
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': 'Analyze this image and determine if it is a trading chart. If it is, extract the timeframe.'},
            {'type': 'image_url', 'image_url': {'url': imageUrl}},
          ],
        },
      ],
      'max_tokens': 1050,
    });

    print('Sending analyzeImageFromUrl request: $requestBody');

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: requestBody,
      );

      print('Received analyzeImageFromUrl response: ${response.body}');

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        String text = responseData['choices'][0]['message']['content'];
        bool isChart = text.contains('trading chart');
        String timeframe = extractTimeframe(text);
        return {
          'isChart': isChart.toString(),
          'timeframe': timeframe,
        };
      } else {
        throw Exception('Failed to analyze image: ${response.body}');
      }
    } catch (e) {
      print('Error analyzing image: $e');
      rethrow;
    }
  }


  static String extractTimeframe(String text) {
    RegExp regex = RegExp(r'(\d+m|\d+h|\d+d|\d+w|\d+min)');
    Match? match = regex.firstMatch(text);
    return match != null ? match.group(0)! : '';
  }

  static Future<String> getAdviceFromImage(String imageUrl, String strategy, List<String> timeframes, String additionalParameter) async {
    final requestBody = jsonEncode({
      'model': 'gpt-4o',
      'messages': [
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': 'Give trading advice based on this chart image and strategy.'},
            {
              'type': 'text',
              'text': 'Strategy: $strategy\nTime frames: ${timeframes.join(', ')}\nAdditional parameter: $additionalParameter\nImage URL: $imageUrl',
            },
            {'type': 'image_url', 'image_url': {'url': imageUrl}}, // Including the image URL again
          ],
        },
      ],
      'max_tokens': 1050,
    });

    print('Sending getAdviceFromImage request: $requestBody');

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: requestBody,
      );

      print('Received getAdviceFromImage response: ${response.body}');

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        return responseData['choices'][0]['message']['content'];
      } else {
        throw Exception('Failed to load advice: ${response.body}');
      }
    } catch (e) {
      print('Error getting advice from image: $e');
      rethrow;
    }
  }
}
