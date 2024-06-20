import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'chatgpt_response_screen.dart';
import 'questions_screen2.dart'; // Import the new screen
import 'image_selection_screen.dart'; // Import the image selection screen
//import 'chat_gpt_response_screen.dart'; // Import the chat screen

class QuestionsScreen extends StatefulWidget {
  final List<String> subscribedTimeFrames;
  final String name;
  final String previousScreen; // Add this line

  QuestionsScreen({
    required this.subscribedTimeFrames,
    required this.name,
    required this.previousScreen,
  });

  @override
  _QuestionsScreenState createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  List<String> strategies = [
    "Day Trading - Short-term time frames",
    "Scalping - Short-term time frames",
    "Swing Trading - Short/medium-term time frames",
    "Position trading - Long-term time frames",
    "I don't know, leave it to AI best approach!",
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

  void _navigateBack() {
    if (widget.previousScreen == 'ImageSelectionScreen') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ImageSelectionScreen(
            name: widget.name, // Provide the necessary parameters
            subscribedTimeFrames: widget.subscribedTimeFrames, // Provide the necessary parameters
          ),
        ),
      );
    } else if (widget.previousScreen == 'ChatGPTResponseScreen') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChatGPTResponseScreen(
            analysisResponse: '', // Provide the necessary parameters
            imagePath: '', // Provide the necessary parameters
            name: widget.name, // Provide the necessary parameters
            subscribedTimeFrames: widget.subscribedTimeFrames, // Provide the necessary parameters
          ),
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        automaticallyImplyLeading: widget.previousScreen != 'PaymentScreen' && widget.previousScreen != 'PaymentScreen2',
        leading: widget.previousScreen != 'PaymentScreen' && widget.previousScreen != 'PaymentScreen2'
            ? IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: _navigateBack,
        )
            : null,
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
                  '',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Text(
                  'Do you have a strategy that you like more? Choose an option:',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isWideScreen ? 3 : 2,
                      childAspectRatio: isWideScreen ? 3 : 2,
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
                            color: selectedStrategy == strategies[index] ? Colors.black.withOpacity(0.5) : Colors.transparent,
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Center(
                            child: AutoSizeText(
                              strategies[index],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: selectedStrategy == strategies[index] ? FontWeight.bold : FontWeight.normal,
                              ),
                              minFontSize: 10,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
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
      case "Day Trading - Short-term time frames":
        return "This strategy involves making dozens of trades in a single day based on technical analysis and sophisticated charting systems.";
      case "Scalping - Short-term time frames":
        return "Scalping involves profiting off small price changes and making a fast profit off reselling.";
      case "Swing Trading - Short/medium-term time frames":
        return "Swing trading tries to capture short- to medium-term gains in a stock over a period of a few days to several weeks.";
      case "Position trading - Long-term time frames":
        return "Position trading involves holding a position in a stock for a long period of time, typically months to years.";
      default:
        return "The AI will choose the best strategy based on the uploaded photo.";
    }
  }
}
