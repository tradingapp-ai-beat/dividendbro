import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/user_provider.dart';

class ChoosePlanScreen extends StatefulWidget {
  @override
  _ChoosePlanScreenState createState() => _ChoosePlanScreenState();
}

class _ChoosePlanScreenState extends State<ChoosePlanScreen> {
  int _selectedSubscriptionType = 0;
  List<String> _selectedTimeFrames = [];

  void _onSubscriptionTypeChanged(int subscriptionType, List<String> timeFrames) {
    setState(() {
      _selectedSubscriptionType = subscriptionType;
      _selectedTimeFrames = timeFrames;
    });
  }

  Future<void> _subscribe() async {
    if (_selectedSubscriptionType != 0) {
      await Provider.of<UserProvider>(context, listen: false).updateSubscription(
        _selectedSubscriptionType,
        _selectedTimeFrames,
      );
      Navigator.pop(context); // Return to the previous screen
    } else {
      // Show an error if no subscription type is selected
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Please select a subscription plan."),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose a Plan'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Select a Subscription Plan',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _buildSubscriptionOptions(),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
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
            ),
          ],
        ),
      ),
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
            _onSubscriptionTypeChanged(subscriptionType, []);
          }
        },
        children: [
          ListTile(
            title: Text(description),
            trailing: Radio<int>(
              value: subscriptionType,
              groupValue: _selectedSubscriptionType,
              onChanged: (int? value) {
                _onSubscriptionTypeChanged(value!, []);
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
    final timeFrames = ['1m', '5m', '15m', '30m', '1h', '4h', '1d', '1w', 'M'];
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
}
