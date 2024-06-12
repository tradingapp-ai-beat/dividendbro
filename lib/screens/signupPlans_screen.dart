import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../provider/user_provider.dart';
import 'image_selection_screen.dart';
import 'payment_screen.dart';
import 'questions_screen.dart';

class SignUpPlansScreen extends StatefulWidget {
  final String email;
  final String password;
  final String name;

  SignUpPlansScreen({required this.email, required this.password, required this.name});

  @override
  _SignUpPlansScreenState createState() => _SignUpPlansScreenState();
}

class _SignUpPlansScreenState extends State<SignUpPlansScreen> {
  int _selectedSubscriptionType = 0;
  List<String> _selectedTimeFrames = [];

  Future<void> _signUp() async {
    try {
      print("Starting sign-up process...");

      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: widget.email,
        password: widget.password,
      );

      UserModel newUser = UserModel(
        uid: userCredential.user!.uid,
        email: widget.email,
        name: widget.name,
        subscriptionType: _selectedSubscriptionType,
        timeFrames: _selectedTimeFrames,
        signupDate: DateTime.now(),
        isFreeTrial: _selectedSubscriptionType == 0,
        history: [],
        isCanceled: false,
        cancellationDate: null,
      );

      await Provider.of<UserProvider>(context, listen: false).signUp(newUser);
      print("User signed up and data saved to Firestore.");

      if (_selectedSubscriptionType == 0) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QuestionsScreen(subscribedTimeFrames: [], name: widget.name),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(
              subscriptionType: _selectedSubscriptionType,
              timeFrames: _selectedTimeFrames,
              email: widget.email,
              name: widget.name,
            ),
          ),
        );
      }
    } catch (e) {
      print("Error during sign-up: $e");
      _showErrorDialog(e.toString());
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

  Widget _buildSubscriptionOptions() {
    return Column(
      children: [
        _buildSubscriptionCard(
          title: 'Free Trial',
          price: '0.00€ / 14 days',
          description: '15 minutes Beats time frame',
          subscriptionType: 0,
          maxSelections: 1,
        ),
        _buildSubscriptionCard(
          title: 'Beat 1',
          price: '9.99€ / month',
          description: 'Choose 1 Beat time frame',
          subscriptionType: 1,
          maxSelections: 1,
        ),
        _buildSubscriptionCard(
          title: 'Beat 2',
          price: '19.99€ / month',
          description: 'Choose 3 Beats time frames',
          subscriptionType: 2,
          maxSelections: 3,
        ),
        _buildSubscriptionCard(
          title: 'Beat 3',
          price: '49.99€ / month',
          description: 'Unlimited Beats time frames',
          subscriptionType: 3,
          maxSelections: 8,
        ),
      ],
    );
  }

  Widget _buildSubscriptionCard({
    required String title,
    required String price,
    required String description,
    required int subscriptionType,
    required int maxSelections,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ExpansionTile(
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(price, style: TextStyle(color: Colors.green)),
            Text(description, style: TextStyle(fontSize: 14.0)),
          ],
        ),
        onExpansionChanged: (bool expanded) {
          if (expanded && _selectedSubscriptionType != subscriptionType) {
            setState(() {
              _selectedSubscriptionType = subscriptionType;
              if (subscriptionType == 0) {
                _selectedTimeFrames = ['15m'];
              } else {
                _selectedTimeFrames = [];
              }
            });
          }
        },
        children: [
          ListTile(
            title: Text(description),
            trailing: Radio<int>(
              value: subscriptionType,
              groupValue: _selectedSubscriptionType,
              onChanged: (int? value) {
                setState(() {
                  _selectedSubscriptionType = value!;
                  if (value == 0) {
                    _selectedTimeFrames = ['15m'];
                  } else {
                    _selectedTimeFrames = [];
                  }
                });
              },
            ),
          ),
          if (_selectedSubscriptionType == subscriptionType && subscriptionType != 0)
            _buildTimeFrameSelector(maxSelections),
        ],
      ),
    );
  }

  Widget _buildTimeFrameSelector(int maxSelections) {
    final timeFrames = ['1m', '5m', '15m', '30m', '1h', '4h', '1d', '1w'];
    return Column(
      children: timeFrames.map((timeFrame) {
        return CheckboxListTile(
          title: Text(timeFrame),
          value: _selectedTimeFrames.contains(timeFrame),
          onChanged: (bool? value) {
            if (value == true && _selectedTimeFrames.length < maxSelections) {
              setState(() {
                _selectedTimeFrames.add(timeFrame);
              });
            } else if (value == false) {
              setState(() {
                _selectedTimeFrames.remove(timeFrame);
              });
            }
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Disable the back button
      child: Scaffold(
        appBar: AppBar(
          title: Text('Select a Plan'),
          automaticallyImplyLeading: false, // Hide the back arrow
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context); // Navigate back to the previous screen
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
                  constraints: BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Choose a Subscription Plan',
                        style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      _buildSubscriptionOptions(),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _signUp,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          textStyle: TextStyle(fontSize: 16.0),
                        ),
                        child: Text('Sign Up'),
                      ),
                    ],
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
