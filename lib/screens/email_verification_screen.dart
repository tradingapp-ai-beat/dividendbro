import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trading_advice_app_v2/screens/signupPlans_screen.dart';
//import 'sign_up_plans_screen.dart'; // Import your SignUpPlansScreen

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final String password;
  final String name;

  EmailVerificationScreen({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  _EmailVerificationScreenState createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    _startVerificationCheck();
  }

  void _startVerificationCheck() {
    Future.delayed(Duration(seconds: 5), () async {
      await _checkEmailVerified();
      if (!_isVerified) {
        _startVerificationCheck(); // Continue checking if not verified
      }
    });
  }

  Future<void> _checkEmailVerified() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload();
      if (user.emailVerified) {
        setState(() {
          _isVerified = true;
        });
        _navigateToNextScreen();
      }
    }
  }

  void _navigateToNextScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SignUpPlansScreen(
          email: widget.email,
          password: widget.password,
          name: widget.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Email Verification'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'A verification email has been sent to ${widget.email}.',
              style: TextStyle(fontSize: 16.0),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'Please check your inbox and click on the link to verify your email address.',
              style: TextStyle(fontSize: 16.0),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkEmailVerified,
              child: Text('I have verified my email'),
            ),
            if (_isVerified)
              Text(
                'Email verified! Redirecting...',
                style: TextStyle(fontSize: 16.0, color: Colors.green),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
