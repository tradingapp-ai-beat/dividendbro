import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../provider/user_provider.dart';
import 'choose_plan_screen.dart';
import 'subscription_screen.dart';

class PlanScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Subscriptions',
          style: TextStyle(
            fontFamily: 'RobotoMono',
            fontSize: 24,
          ),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildSubscriptionDetails(userProvider, user),
                    SizedBox(height: 20),
                    if (userProvider.isSubscriptionStillActive && userProvider.isCanceled)
                      _buildCancellationMessage(userProvider),
                    SizedBox(height: 20),
                    if (user.subscriptionType != null && user.subscriptionType != 0 && !userProvider.isCanceled)
                      _buildCancelButton(context),
                    if (userProvider.isCanceled && !userProvider.isSubscriptionStillActive)
                      _buildSubscribeButton(context),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubscriptionDetails(UserProvider userProvider, UserModel user) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your DividendBeat Plan:',
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              userProvider.isCanceled ? _getPlanName(userProvider.previousSubscriptionType) : _getPlanName(user.subscriptionType),
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 16,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Beats Time Frames:',
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              user.timeFrames.join(', '),
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancellationMessage(UserProvider userProvider) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Your plan was canceled and will be active until ${userProvider.user.cancellationDate!.add(Duration(days: 1)).toLocal().toString().split(' ')[0]}',
          style: TextStyle(
            fontFamily: 'RobotoMono',
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _showCancelConfirmationDialog(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white38,
        padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        textStyle: TextStyle(fontFamily: 'RobotoMono', fontSize: 16),
      ),
      child: Text('Cancel Plan'),
    );
  }

  Widget _buildSubscribeButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SubscriptionScreen()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade50,
        padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        textStyle: TextStyle(fontFamily: 'RobotoMono', fontSize: 16),
      ),
      child: Text('Subscribe to a Plan'),
    );
  }

  String _getPlanName(int? subscriptionType) {
    switch (subscriptionType) {
      case 0:
        return 'Free Subscription';
      case 1:
        return 'One Beat Time Frame';
      case 2:
        return 'Two Beats Time Frames';
      case 3:
        return 'Unlimited Beats Time Frames';
      default:
        return 'No Subscription';
    }
  }

  void _showCancelConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Cancel Plan",
            style: TextStyle(
              fontFamily: 'RobotoMono',
            ),
          ),
          content: Text(
            "Are you sure you want to cancel your plan?",
            style: TextStyle(
              fontFamily: 'RobotoMono',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                "No",
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                "Yes",
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                ),
              ),
              onPressed: () async {
                await Provider.of<UserProvider>(context, listen: false).cancelSubscription();
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => PlanScreen()),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
