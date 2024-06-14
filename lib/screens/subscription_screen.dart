import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/user_provider.dart';
import 'payment_screen.dart';

class SubscriptionScreen extends StatefulWidget {
  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int _selectedSubscriptionType = 0;
  List<String> _selectedTimeFrames = [];

  Future<void> _subscribe() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (_selectedSubscriptionType == 0) {
      _selectedTimeFrames = ['minutes'];
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          subscriptionType: _selectedSubscriptionType,
          timeFrames: _selectedTimeFrames,
          email: userProvider.user.email,
          name: userProvider.user.name,
          previousScreen: 'subscription',
          isSignUp: false,
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
          description: 'Unlimited Beats time frames',
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
