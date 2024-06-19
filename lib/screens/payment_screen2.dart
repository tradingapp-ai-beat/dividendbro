import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trading_advice_app_v2/screens/questions_screen.dart';
import '../models/user_model.dart';
import '../provider/user_provider.dart';
import 'image_selection_screen.dart';

class PaymentScreen2 extends StatelessWidget {
  final int subscriptionType;
  final List<String> timeFrames;
  final String email;
  final String name;
  final String? password;
  final String previousScreen;

  PaymentScreen2({
    required this.subscriptionType,
    required this.timeFrames,
    required this.email,
    required this.name,
    this.password,
    required this.previousScreen,
  });

  Future<void> _completePayment(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (password != null) {
      // Sign up process
      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password!,
        );

        User? user = userCredential.user;
        if (user != null && !user.emailVerified) {
          await user.sendEmailVerification();
        }

        UserModel newUser = UserModel(
          uid: userCredential.user!.uid,
          email: email,
          name: name,
          subscriptionType: subscriptionType,
          timeFrames: timeFrames,
          signupDate: DateTime.now(),
          isFreeTrial: subscriptionType == 0,
          history: [],
          isCanceled: false,
          cancellationDate: null,
          subscriptionEndDate: DateTime.now().add(Duration(days: 30)),
          password: password!,
          paymentDate: DateTime.now(),
        );

        await userProvider.signUp(newUser);
        print("User signed up and data saved to Firestore.");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ImageSelectionScreen(
              subscribedTimeFrames: timeFrames,
              name: name,
            ),
          ),
        );
      } catch (e) {
        print("Error during sign-up: $e");
        _showErrorDialog(context, e.toString());
      }
    } else {
      // Subscription update process
      try {
        await userProvider.updateSubscription(subscriptionType, timeFrames);
        print("Subscription updated successfully.");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QuestionsScreen(
              subscribedTimeFrames: timeFrames,
              name: name,
              previousScreen: '',
            ),
          ),
        );
      } catch (e) {
        print("Error during subscription update: $e");
        _showErrorDialog(context, e.toString());
      }
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth > 600 ? 600 : double.infinity,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Subscription Type: $subscriptionType',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Time Frames: ${timeFrames.join(', ')}',
                      style: TextStyle(fontSize: 18.0),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Payment Simulation',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'This is a simulated payment screen. In a real app, you would integrate a payment gateway here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () => _completePayment(context),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          textStyle: TextStyle(fontSize: 16.0),
                        ),
                        child: Text('Complete Payment'),
                      ),
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