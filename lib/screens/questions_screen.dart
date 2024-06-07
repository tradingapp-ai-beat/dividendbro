import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'chatgpt_response_screen.dart';
import 'image_selection_screen.dart';

class QuestionsScreen extends StatefulWidget {
  final List<String> subscribedTimeFrames;
  final String name;

  QuestionsScreen({required this.subscribedTimeFrames, required this.name});

  @override
  _QuestionsScreenState createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  List<String> strategies = [
    "Moving Average Crossover",
    "Support and Resistance Trading",
    "Trend Following",
    "Breakout Trading",
    "Reversal Trading",
    "Momentum Trading",
    "Scalping",
    "Swing Trading",
    "Mean Reversion",
    "Pairs Trading",
    "Give me your best Beat!"
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

  void _navigateToImageSelection() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ImageSelectionScreen(
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
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Welcome to DividendBeat',
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
                  crossAxisCount: 2,
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
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: selectedStrategy != null ? _navigateToImageSelection : null,
              child: Text('OK'),
            ),
          ],
        ),
      ),
    );
  }

  String _getStrategyDescription(String strategy) {
    switch (strategy) {
      case "Moving Average Crossover":
        return "This strategy involves using two moving averages...";
      case "Support and Resistance Trading":
        return "This approach involves identifying key support and resistance levels...";
   
      default:
        return "The AI will choose the best strategy based on the uploaded photo.";
    }
  }
}