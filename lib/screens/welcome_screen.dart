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
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 600;
          return GestureDetector(
            onHorizontalDragUpdate: _onHorizontalDragUpdate,
            onHorizontalDragEnd: _onHorizontalDragEnd,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 800),
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
                          'No more endless time consuming analysing trading charts, NO setups need, with just 1 or 3 simple clicks, simply and fastly enhance your trading strategy with confidence and keep track of all your trades analysis, dividendBeat is your AI-powered personal trading advisor. Empowering you to make informed decisions in a blink of an eye and optimize your trading strategies for financial success. ',
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
                              width: isMobile ? 200 : 400,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            AnimatedPositioned(
                              duration: Duration(milliseconds: 300),
                              left: _isSwiped ? (isMobile ? 150 : 350) : 0,
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
                          'Before diving into trading, it\'s crucial to understand the risks involved. Always trade responsibly.',
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
              ),
            ),
          );
        },
      ),
    );
  }
}
