import 'package:flutter/material.dart';
import 'payment_screen.dart';

class SignUpPlansScreen extends StatefulWidget {
  final String email;
  final String password;
  final String name;

  SignUpPlansScreen({required this.email, required this.password, required this.name});

  @override
  _SignUpPlansScreenState createState() => _SignUpPlansScreenState();
}

class _SignUpPlansScreenState extends State<SignUpPlansScreen> {
  int? _selectedSubscriptionType;

  Future<void> _subscribe() async {
    if (_selectedSubscriptionType == null) {
      _showErrorDialog("Please select a subscription plan.");
      return;
    }

    List<String> selectedTimeFrames = [];
    if (_selectedSubscriptionType == 1) {
      selectedTimeFrames.add('days'); // Automatically include 'days' for free plan
    } else if (_selectedSubscriptionType == 2) {
      selectedTimeFrames = ['minutes', 'hours', 'days', 'weeks', 'months']; // All timeframes for premium
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          subscriptionType: _selectedSubscriptionType!,
          timeFrames: selectedTimeFrames,
          email: widget.email,
          name: widget.name,
          password: widget.password,
          previousScreen: 'sign_up',
        ),
      ),
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

  Widget _buildSubscriptionOptions() {
    return Column(
      children: [
        _buildSubscriptionCard(
          title: 'Free Trial',
          price: '0.00€ / 14 days',
          description: 'Includes "days" time frames AI analysis.',
          subscriptionType: 1,
        ),
        _buildSubscriptionCard(
          title: 'Beat Premium',
          price: '14.99€ / month',
          description: 'All time frames included for unlimited AI analysis',
          subscriptionType: 2,
        ),
      ],
    );
  }

  Widget _buildSubscriptionCard({
    required String title,
    required String price,
    required String description,
    required int subscriptionType,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(price, style: TextStyle(color: Colors.green)),
            Text(description),
          ],
        ),
        trailing: Radio<int>(
          value: subscriptionType,
          groupValue: _selectedSubscriptionType,
          onChanged: (int? value) {
            setState(() {
              _selectedSubscriptionType = value;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select a Plan'),
        automaticallyImplyLeading: false, // Hide the back arrow
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Choose a Subscription Plan',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              _buildSubscriptionOptions(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _subscribe,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  textStyle: TextStyle(fontSize: 16.0),
                ),
                child: Text('Subscribe'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
