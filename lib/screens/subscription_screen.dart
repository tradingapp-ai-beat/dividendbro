import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/user_provider.dart';

class SubscriptionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Subscription Plans'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (userProvider.isTrialPeriodActive)
              Text(
                'You are currently on a free trial period. You will be notified to pay for a subscription after 30 days.',
                style: TextStyle(color: Colors.green),
              ),
            if (!userProvider.isTrialPeriodActive)
              Column(
                children: [
                  ListTile(
                    title: Text('Beat 1 - 9.99€ / month'),
                    onTap: () {
                      _choosePlan(context, 1, ['1m']);
                    },
                  ),
                  ListTile(
                    title: Text('Beat 2 - 19.99€ / month'),
                    onTap: () {
                      _choosePlan(context, 2, ['1m', '5m']);
                    },
                  ),
                  ListTile(
                    title: Text('Beat 3 - 29.99€ / month'),
                    onTap: () {
                      _choosePlan(context, 3, ['1m', '5m', '15m', '30m', '1h', '4h', '1d', '1w']);
                    },
                  ),
                ],
              ),
            if (!userProvider.isTrialPeriodActive)
              ListTile(
                title: Text('Cancel Plan'),
                onTap: () {
                  Provider.of<UserProvider>(context, listen: false).cancelSubscription();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _choosePlan(BuildContext context, int subscriptionType, List<String> timeFrames) {
    Provider.of<UserProvider>(context, listen: false).updateSubscription(subscriptionType, timeFrames);
    Navigator.pop(context);
  }
}
