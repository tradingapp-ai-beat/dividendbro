import 'package:flutter/material.dart';
import 'package:trading_advice_app_v2/screens/questions_screen.dart';
import 'image_selection_screen.dart';
import '../widgets/top_bar.dart';

class PaymentScreen extends StatelessWidget {
  final int subscriptionType;
  final List<String> timeFrames;
  final String email;
  final String name;

  PaymentScreen({required this.subscriptionType, required this.timeFrames, required this.email, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Subscription Type: $subscriptionType',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            Text(
              'Time Frames: ${timeFrames.join(', ')}',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 20),
            Text(
              'Payment Simulation',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'This is a simulated payment screen. In a real app, you would integrate a payment gateway here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuestionsScreen(subscribedTimeFrames: [], name: '',),
                  ),
                      (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                textStyle: TextStyle(fontSize: 16.0),
              ),
              child: Text('Complete Payment'),
            ),
          ],
        ),
      ),
    );
  }
}
