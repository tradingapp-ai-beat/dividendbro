import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ApiService {
  static const String apiKey = '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';
  static const String apiUrl = 'https://api.openai.com/v1/chat/completions';

  static Future<Map<String, String>> analyzeImageFromUrl(String imageUrl) async {
    final requestBody = jsonEncode({
      'model': 'gpt-4o',
      'messages': [
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': 'Analyze this image and determine if it is a trading chart. If it is, extract the timeframe and say if its minutes or minute, hours or hour, days or day, weeks or week, months or month and always say in plural .'},
            {'type': 'image_url', 'image_url': {'url': imageUrl}},
          ],
        },
      ],
      'max_tokens': 2500,
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
        print('Analysis text content: $text');
        bool isChart = text.contains('trading chart');
        String timeframe = extractTimeframe(text);
        print('Matched timeframe: $timeframe');
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
    print('Input text for regex: $text');

    // Updated regex to handle various formats including quotes and punctuation
    RegExp regex = RegExp(r'(minutes|hours|days|weeks|months)', caseSensitive: false);
    Match? match = regex.firstMatch(text);

    if (match != null) {
      String matched = match.group(1)!.toLowerCase();
      print('Matched timeframe: $matched');
      return matched;
    } else {
      print('No timeframe matched.');
      return ''; // Ensure a non-null value is returned
    }
  }

  static Future<String> getAdviceFromImage(String imageUrl, String strategy, List<String> timeframes, String additionalParameter, String extractedTimeframe) async {
    final requestBody = jsonEncode({
      'model': 'gpt-4o',
      'messages': [
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': 'Give trading advice based on this chart image and strategy.'},
            {
              'type': 'text',
              'text': 'Give trading advice based on this chart image,strategy: $strategy., extract the financial product name and give an judge opinion on what the strategy chosen is good or not for the type of financial product, adapted to Time frames: $extractedTimeframe and additional parameter: $additionalParameter.,Image URL: $imageUrl are you more inclined to buy or to sell? Analise candle sticks if possible, and inform about the pattern, Give user full analysis of the chart, give me advice about leverage when applicable, and finalize with information regarding safety in trading and risk management. .',
            },
            {'type': 'image_url', 'image_url': {'url': imageUrl}}, // Including the image URL again
          ],
        },
      ],
      'max_tokens': 2500,
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