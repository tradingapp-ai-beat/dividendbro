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
            {'type': 'text', 'text': 'Analyze this image and determine if it is a trading chart. If it is, extract the timeframe and say in plural eg. if xm you say minutes, if xh you say hours. if xd you say days, etc... alwys give answer of time frame type in plural as mentioned before. .'},
            {'type': 'image_url', 'image_url': {'url': imageUrl}},
          ],
        },
      ],
      'max_tokens': 2500,
    });

 //   print('Sending analyzeImageFromUrl request: $requestBody');

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: requestBody,
      );

  //    print('Received analyzeImageFromUrl response: ${response.body}');

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        String text = responseData['choices'][0]['message']['content'];
    //    print('Analysis text content: $text');
        bool isChart = text.contains('trading chart');
        String timeframe = extractTimeframe(text);
  //      print('Matched timeframe: $timeframe');
        return {
          'isChart': isChart.toString(),
          'timeframe': timeframe,
        };
      } else {
        throw Exception('Failed to analyze image: ${response.body}');
      }
    } catch (e) {
   //   print('Error analyzing image: $e');
      rethrow;
    }
  }

  static String extractTimeframe(String text) {
   // print('Input text for regex: $text');

    // Updated regex to handle various formats including quotes and punctuation
    RegExp regex = RegExp(r'(minutes|hours|days|weeks|months)', caseSensitive: false);
    Match? match = regex.firstMatch(text);

    if (match != null) {
      String matched = match.group(1)!.toLowerCase();
 //     print('Matched timeframe: $matched');
      return matched;
    } else {
   //   print('No timeframe matched.');
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
            {'type': 'text', 'text': 'Please analyze the provided chart image and give detailed trading advice. Follow the structured prompts below for a comprehensive analysis:'},
            {
              'type': 'text',
              'text': '1. **Financial Product and Time Frame Extraction:**\n'
                  '- Extract the financial product name and the time frame from the provided chart.\n\n'
                  '2. **Strategy Evaluation:**\n'
                  '- Analyze the chosen strategy: $strategy.\n'
                  '- Provide a judgment on whether this strategy is suitable for the identified financial product and time frame: $extractedTimeframe.\n'
                  '- Include any additional considerations related to: $additionalParameter.\n\n'
                  '3. **Trade Recommendations:**\n'
                  '- Based on your analysis, indicate whether to buy or sell the financial product.\n'
                  '- Specify recommended take profit and stop loss levels.\n'
                  '- Discuss the use of pips for trading and provide buy/sell recommendations in pips if applicable.\n'
                  '- If trading contracts are involved, include relevant details about the contracts.\n\n'
                  '4. **Technical Analysis:**\n'
                  '- Conduct a candlestick analysis, identifying any patterns present in the chart.\n'
                  '- Describe the pattern and its implications for trading decisions.\n\n'
                  '5. **Leverage and Risk Management:**\n'
                  '- Provide advice on the appropriate leverage to use given the current market conditions and the analyzed strategy.\n'
                  '- Offer comprehensive risk management advice, focusing on safe trading practices and minimizing potential losses.\n\n'
                  '6. **Market Timing:**\n'
                  '- Assess whether it is an optimal moment to enter the market or if it is advisable to wait.\n'
                  '- Justify your recommendation based on the current market conditions and chart analysis.\n\n'
                  '7. **General Market Insights:**\n'
                  '- Include any additional market insights or trends that could influence trading decisions.\n\n'
                  '8. **Final Advice:**\n'
                  '- Summarize your analysis and provide a clear and actionable recommendation based on all the factors considered.\n\n'
                  'Image URL: $imageUrl\n\n'
                  'Please ensure that your analysis is thorough and provides actionable insights for effective trading decisions. Thank you.'
            },
            {'type': 'image_url', 'image_url': {'url': imageUrl}}, // Including the image URL again
          ],
        },
      ],
      'max_tokens': 3000,
    });

  //  print('Sending getAdviceFromImage request: $requestBody');

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: requestBody,
      );

  //    print('Received getAdviceFromImage response: ${response.body}');

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        return responseData['choices'][0]['message']['content'];
      } else {
        throw Exception('Failed to load advice: ${response.body}');
      }
    } catch (e) {
  //    print('Error getting advice from image: $e');
      rethrow;
    }
  }
}