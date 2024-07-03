import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static final String serverUrl = dotenv.env['SERVER_URL']!; // Your server URL

  static Future<Map<String, String>> analyzeImageFromUrl(String imageUrl) async {
    final requestBody = jsonEncode({'imageUrl': imageUrl});

    try {
      final response = await http.post(
        Uri.parse('$serverUrl/analyze'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        return {
          'isChart': responseData['isChart'],
          'timeframe': responseData['timeframe'],
        };
      } else {
        throw Exception('Failed to analyze image: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<String> getAdviceFromImage(String imageUrl, String strategy, List<String> timeframes, String additionalParameter, String extractedTimeframe) async {
    final requestBody = jsonEncode({
      'imageUrl': imageUrl,
      'strategy': strategy,
      'timeframes': timeframes,
      'additionalParameter': additionalParameter,
      'extractedTimeframe': extractedTimeframe,
    });

    try {
      final response = await http.post(
        Uri.parse('$serverUrl/advice'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        return responseData['advice'];
      } else {
        throw Exception('Failed to get advice from image: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
