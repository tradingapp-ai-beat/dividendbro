import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> sendPasswordResetEmail(String email) async {
  final url = Uri.parse(
      'https://us-central1-dividendbeat.cloudfunctions.net/sendPasswordResetEmail');

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
   //   print('Password reset email sent successfully');
    } else {
      print('Failed to send password reset email: ${response
          .statusCode} ${response.body}');
    }
  } catch (error) {
  //  print('Error sending password reset email: $error');
  }
}