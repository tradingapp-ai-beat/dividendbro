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
  List<String> _selectedTimeFrames = [];

  Future<void> _subscribe() async {
    if (_selectedSubscriptionType == null) {
      _showErrorDialog("Please select a subscription plan.");
      return;
    }

    if ((_selectedSubscriptionType == 1 && _selectedTimeFrames.length != 1) ||
        (_selectedSubscriptionType == 2 && _selectedTimeFrames.length != 2) ||
        (_selectedSubscriptionType == 3 && _selectedTimeFrames.length != 5)) {
      _showErrorDialog("Please select the correct number of time frames.");
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          subscriptionType: _selectedSubscriptionType!,
          timeFrames: _selectedTimeFrames,
          email: widget.email,
          name: widget.name,
          password: widget.password, // Pass the password for sign up
          previousScreen: 'sign_up', // Indicate that this is a sign-up process
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
          description: 'Choose 1 Beat time frame',
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
          description: 'Choose 2 Beats time frames',
          subscriptionType: 2,
          maxSelections: 2,
        ),
        _buildSubscriptionCard(
          title: 'Beat 3',
          price: '49.99€ / month',
          description: 'All Beats time frames',
          subscriptionType: 3,
          maxSelections: 5,
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
              _selectedTimeFrames = [];
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
                  _selectedTimeFrames = [];
                });
              },
            ),
          ),
          if (_selectedSubscriptionType == subscriptionType)
            _buildTimeFrameSelector(maxSelections),
        ],
      ),
    );
  }

  Widget _buildTimeFrameSelector(int maxSelections) {
    final timeFrames = ['minutes', 'hours', 'days', 'weeks', 'months'];
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
        },
      ),
    );
  }
}
