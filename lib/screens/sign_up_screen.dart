import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'email_verification_screen.dart'; // Import the new screen

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  Future<void> _sendVerificationEmail(User user) async {
    try {
      await user.sendEmailVerification().then((_) {
        print("Verification email sent to ${user.email}");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmailVerificationScreen(
              email: _emailController.text,
              password: _passwordController.text,
              name: _nameController.text,
            ),
          ),
        );
      }).catchError((error) {
        print("Failed to send verification email: $error");
        _showErrorDialog("Failed to send verification email. Please try again.");
      });
    } catch (e) {
      print("Unexpected error sending verification email: $e");
      _showErrorDialog("Unexpected error sending verification email. Please try again.");
    }
  }

  void _signUpAndVerifyEmail() async {
    if (_formKey.currentState!.validate()) {
      print("Form validated successfully");

      try {
        print("Creating user with email: ${_emailController.text}");
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        User? user = userCredential.user;
        if (user != null && !user.emailVerified) {
          print("User created successfully: ${user.email}");
          print("Sending verification email...");
          await _sendVerificationEmail(user);
        } else {
          print("User creation failed or user already verified");
        }
      } catch (e) {
        print("Failed to create user: $e");
        _showErrorDialog(e.toString());
      }
    } else {
      print("Form validation failed");
    }
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

  String? _validateEmail(String? value) {
    print("Validating email: $value");
    if (value == null || value.isEmpty) {
      print("Email cannot be empty");
      return 'Email cannot be empty';
    }
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(value)) {
      print("Enter a valid email address");
      return 'Enter a valid email address';
    }
    print("Email is valid");
    return null;
  }

  String? _validatePassword(String? value) {
    print("Validating password: $value");
    if (value == null || value.isEmpty) {
      print("Password cannot be empty");
      return 'Password cannot be empty';
    }
    if (value.length < 8) {
      print("Password must be at least 8 characters long");
      return 'Password must be at least 8 characters long';
    }
    final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    if (!regex.hasMatch(value)) {
      print("Password must contain an uppercase letter, a lowercase letter, a number, and a special character");
      return 'Password must contain an uppercase letter, a lowercase letter, a number, and a special character';
    }
    print("Password is valid");
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    print("Validating confirm password: $value");
    if (value == null || value.isEmpty) {
      print("Confirm Password cannot be empty");
      return 'Confirm Password cannot be empty';
    }
    if (value != _passwordController.text) {
      print("Passwords do not match");
      return 'Passwords do not match';
    }
    print("Confirm Password is valid");
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Sign Up'),
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 600;
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 600),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Create an Account',
                          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Please fill in the details below to create your account.',
                          style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'First Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          validator: _validateEmail,
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          obscureText: true,
                          validator: _validatePassword,
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          obscureText: true,
                          validator: _validateConfirmPassword,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _signUpAndVerifyEmail,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            textStyle: TextStyle(fontSize: 16.0),
                          ),
                          child: Text('Next'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
