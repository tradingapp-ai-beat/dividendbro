import 'package:flutter/material.dart';
import 'package:trading_advice_app_v2/screens/questions_screen.dart';
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
      appBar: TopBar(name: name), // Use your custom TopBar widget
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Subscription Type: $subscriptionType',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Time Frames: ${timeFrames.join(', ')}',
                      style: TextStyle(fontSize: 18.0),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Payment Simulation',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'This is a simulated payment screen. In a real app, you would integrate a payment gateway here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuestionsScreen(
                                subscribedTimeFrames: timeFrames,
                                name: name,
                              ),
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
