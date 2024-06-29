import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/user_provider.dart';
import 'payment_screen2.dart';

class SubscriptionScreen extends StatefulWidget {
  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int _selectedSubscriptionType = 1; // Default to Beat 1 which includes all features.

  Future<void> _subscribe() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Automatically assign all timeframes
    List<String> selectedTimeFrames = ['minutes', 'hours', 'days', 'weeks', 'months'];

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen2(
          subscriptionType: _selectedSubscriptionType,
          timeFrames: selectedTimeFrames,
          email: userProvider.user.email,
          name: userProvider.user.name,
          previousScreen: 'subscription',
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

  Widget _buildSubscriptionCard() {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        title: Text(
          'Premium Plan',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('14.99€ / month', style: TextStyle(color: Colors.green)),
            Text('All time frames included for unlimited AI analysis.', style: TextStyle(fontSize: 14.0)),
          ],
        ),
        trailing: Radio<int>(
          value: 1,
          groupValue: _selectedSubscriptionType,
          onChanged: null,  // Make the radio button non-interactive
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
      body: LayoutBuilder(
        builder: (context, constraints) {
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
                    _buildSubscriptionCard(),
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
        },
      ),
    );
  }
}
