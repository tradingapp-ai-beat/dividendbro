import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trading_advice_app_v2/screens/signupPlans_screen.dart';
//import 'package:trading_advice_app_v2/screens/signin_screen.dart';

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
    _addBeforeUnloadListener();
  }

  void _addBeforeUnloadListener() {
    html.window.onBeforeUnload.listen((html.Event event) {
      final message = 'Are you sure you want to leave this page? Any unsaved changes will be lost.';
      (event as html.BeforeUnloadEvent).returnValue = message;
    });
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
    // Remove the event listener before navigating away
    html.window.onBeforeUnload.listen(null);
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

  Future<bool> _onWillPop() async {
    bool shouldLeave = false;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Exit'),
        content: Text('Are you sure you want to leave this page? Any unsaved changes will be lost.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // User cancelled the action
            },
            child: Text('Stay'),
          ),
          TextButton(
            onPressed: () {
              shouldLeave = true;
              Navigator.of(context).pop(true); // User confirmed the action
            },
            child: Text('Leave'),
          ),
        ],
      ),
    );

    if (shouldLeave) {
      // Log out the user and redirect to the sign-in page
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SignInScreen(),
        ),
      );
    }

    return Future.value(false); // Prevent default back navigation
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Email Verification'),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'A verification email has been sent to ${widget.email}.',
                  style: TextStyle(fontSize: 16.0),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  'Please check your inbox and click on the link to verify your email address.\n\n',
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
        ),
      ),
    );
  }
}

class SignInScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: Center(
        child: Text('Please sign in to continue.'),
      ),
    );
  }
}

class NextScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Next Screen'),
      ),
      body: Center(
        child: Text('Welcome! Your email has been verified.'),
      ),
    );
  }
}
