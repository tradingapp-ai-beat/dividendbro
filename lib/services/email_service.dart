import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  final String username = 'dividend';
  final String password = '!Yy2u3ae02';



  Future<void> sendOtp(String recipientEmail, String otp) async {
    final smtpServer = SmtpServer(
      'webdomain04.dnscpanel.com', // e.g., smtp.yourdomain.com
      username: username,
      password: password,
      // Use port 465 for SSL
      port: 465,
      ssl: true,
    );

    final message = Message()
      ..from = Address(username, 'Dividend Beat Support')
      ..recipients.add(recipientEmail)
      ..subject = 'Your OTP Code'
      ..text = 'Your OTP code is: $otp';

    try {
      print('Attempting to send email to $recipientEmail');
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent. \n${e.toString()}');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
      throw Exception('Failed to send OTP email');
    }
  }
}
