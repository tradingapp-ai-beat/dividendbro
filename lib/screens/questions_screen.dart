import 'package:flutter/material.dart';
import 'questions_screen2.dart'; // Import the new screen

class QuestionsScreen extends StatefulWidget {
  final List<String> subscribedTimeFrames;
  final String name;
  final String previousScreen; // Add this line

  QuestionsScreen({required this.subscribedTimeFrames, required this.name, required this.previousScreen});

  @override
  _QuestionsScreenState createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  List<String> strategies = [
    "Day Trading - Short-term time frames",
    "Scalping - Short-term time frames ",
    "Swing Trading - Short/medium-term time frames ",
    "Position trading - Long-term time frames",
    "I dont know, leave it to dividendBeat!",
  ];

  String? selectedStrategy;

  void toggleSelection(String strategy) {
    setState(() {
      if (selectedStrategy == strategy) {
        selectedStrategy = null;
      } else {
        selectedStrategy = strategy;
      }
    });
  }

  void _navigateToNextQuestion() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionsScreen2(
          subscribedTimeFrames: widget.subscribedTimeFrames,
          name: widget.name,
          selectedStrategy: selectedStrategy,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Questions'),
        automaticallyImplyLeading: widget.previousScreen != 'signup' && widget.previousScreen != 'signin', // Conditionally show back arrow
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 600;
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Welcome to dividendBeat',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Text(
                  'Do you have a strategy that you like more? Choose one!',
                  style: TextStyle(fontSize: 18.0),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isWideScreen ? 3 : 2,
                      childAspectRatio: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: strategies.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(strategies[index]),
                              content: Text(_getStrategyDescription(strategies[index])),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                        onTap: () => toggleSelection(strategies[index]),
                        child: Container(
                          decoration: BoxDecoration(
                            color: selectedStrategy == strategies[index] ? Colors.blue.withOpacity(0.5) : Colors.transparent,
                            border: Border.all(color: Colors.blue),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Center(
                            child: Text(
                              strategies[index],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: selectedStrategy == strategies[index] ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: selectedStrategy != null ? _navigateToNextQuestion : null,
                    child: Text('OK'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      textStyle: TextStyle(fontSize: 16.0),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getStrategyDescription(String strategy) {
    switch (strategy) {
      case "Moving Average Crossover":
        return "This strategy involves using two moving averages...";
      case "Support and Resistance Trading":
        return "This approach involves identifying key support and resistance levels...";
    // Add descriptions for other strategies
      default:
        return "The AI will choose the best strategy based on the uploaded photo.";
    }
  }
}
