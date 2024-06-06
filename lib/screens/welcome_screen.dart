import 'package:flutter/material.dart';
import 'sign_in_screen.dart'; // Make sure this import points to your SignInScreen file

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isSwiped = false;

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (details.primaryDelta != null && details.primaryDelta! > 0) {
      setState(() {
        _isSwiped = true;
      });
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_isSwiped) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignInScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onHorizontalDragUpdate: _onHorizontalDragUpdate,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Text(
                'dividendBeat',
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              const Text(
                'Enhance your trading confidence with dividendBeat, your AI-powered personal trading advisor. Empowering you to make informed decisions and optimize your trading strategies for financial success. ',
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 18,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 50),
              Stack(
                children: [
                  Container(
                    width: 200,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  AnimatedPositioned(
                    duration: Duration(milliseconds: 300),
                    left: _isSwiped ? 150 : 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Icon(
                        Icons.arrow_forward,
                        size: 30.0,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              const Text(
                'Swipe to continue',
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              const Text(
                'Before diving into trading, it''s crucial to understand the risks involved. Always trade responsibly. Now, a PRO Tip from dividendBeat: Enhance dividendBeat analysis with key indicators on your chart images. dividendBeat recommends using RSI, MACD, EMA 20, and Bollinger Bands to make informed decisions and maximize your trading potential.',
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 14,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
