import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trading_advice_app_v2/screens/sign_up_screen.dart';
import '../provider/user_provider.dart';
import 'auth_screen.dart';
import 'subscription_screen.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (userProvider.isTrialPeriodActive && user.subscriptionType == 0)
              Text(
                'You are currently on a free trial period. You will be notified to pay for a subscription after 30 days.',
                style: TextStyle(color: Colors.green),
              ),
            if (!userProvider.isTrialPeriodActive && user.subscriptionType != null && user.subscriptionType != 0)
              ListTile(
                title: Text('Cancel Plan'),
                onTap: () {
                  Provider.of<UserProvider>(context, listen: false).cancelSubscription();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SubscriptionScreen()),
                  );
                },
              ),
            ListTile(
              title: Text('Cancel Account'),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Confirm Account Cancellation'),
                    content: Text('Are you sure you want to cancel your account? This action cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text('No'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text('Yes'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await Provider.of<UserProvider>(context, listen: false).deleteAccount();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpScreen()),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
