import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/network_service.dart';
import '../provider/user_provider.dart';
import 'questions_screen.dart'; // Import the QuestionsScreen
import 'sign_up_screen.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signIn() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    bool success = await Provider.of<UserProvider>(context, listen: false).signIn(email, password);
    if (success) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuestionsScreen(
            subscribedTimeFrames: userProvider.user.timeFrames ?? [],
            name: userProvider.user.name ?? '', previousScreen: '',
          ),
        ),
      );
    } else {
      _showErrorDialog("Sign-in failed");
    }
  }

  Future<void> _sendPasswordResetEmail(String email) async {
    if (email.isNotEmpty) {
      await sendPasswordResetEmail(email);
      _showSuccessDialog('Password reset email sent successfully');
    } else {
      print('Email is required');
      _showErrorDialog('Email is required');
    }
  }

  void _showForgotPasswordDialog() {
    final TextEditingController _forgotPasswordEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Forgot Password"),
          content: TextField(
            controller: _forgotPasswordEmailController,
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("OK"),
              onPressed: () async {
                Navigator.of(context).pop();
                await _sendPasswordResetEmail(_forgotPasswordEmailController.text.trim());
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Success"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
        automaticallyImplyLeading: false, // This removes the back arrow
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 600;
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 600),
                child: Column(
                  children: <Widget>[
                    Image.asset(
                      'assets/logo.png', // Path to your logo.png asset
                      height: 100, // Adjust the height as needed
                      width: 100, // Adjust the width as needed
                    ),
                    SizedBox(height: 20),
                    Text(
                      'dividendBeat AI is on the House!',
                      style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Please sign in to continue.',
                      style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _signIn,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        textStyle: TextStyle(fontSize: 16.0),
                      ),
                      child: Text('Sign In'),
                    ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: _showForgotPasswordDialog,
                      child: Text('Forgot Password?'),
                    ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpScreen()),
                        );
                      },
                      child: Text('Don\'t have an account? Sign Up'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}