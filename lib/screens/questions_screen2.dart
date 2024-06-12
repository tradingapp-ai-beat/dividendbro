import 'package:flutter/material.dart';
//import 'package:trading_advice_app_v2/screens/image_selection_dummy_screan.dart';
import 'chatgpt_response_screen.dart';
import 'image_selection_screen.dart';

class QuestionsScreen2 extends StatefulWidget {
  final List<String> subscribedTimeFrames;
  final String name;
  final String? selectedStrategy;

  QuestionsScreen2({required this.subscribedTimeFrames, required this.name, this.selectedStrategy});

  @override
  _QuestionsScreen2State createState() => _QuestionsScreen2State();
}

class _QuestionsScreen2State extends State<QuestionsScreen2> {
  List<String> options = [
    "1:2",
    "1:3",
    "1:4",
    "1:5",
    "Leave it to dividendBeat",
  ];

  String? selectedOption;

  void toggleSelection(String option) {
    setState(() {
      if (selectedOption == option) {
        selectedOption = null;
      } else {
        selectedOption = option;
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
          selectedStrategy: widget.selectedStrategy,
          additionalParameter: selectedOption, // Pass the selected option
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Further Questions'),
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
                  'Additional Parameters for DividendBeat',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Text(
                  'Choose an additional parameter for better analysis:',
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
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(options[index]),
                              content: Text(_getOptionDescription(options[index])),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                        onTap: () => toggleSelection(options[index]),
                        child: Container(
                          decoration: BoxDecoration(
                            color: selectedOption == options[index] ? Colors.blue.withOpacity(0.5) : Colors.transparent,
                            border: Border.all(color: Colors.blue),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Center(
                            child: Text(
                              options[index],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: selectedOption == options[index] ? FontWeight.bold : FontWeight.normal,
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
                    onPressed: selectedOption != null ? _navigateToImageSelection : null,
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

  String _getOptionDescription(String option) {
    switch (option) {
      case "2% rule":
        return "This rule suggests that you should never risk more than 2% of your total trading capital on a single trade.";
      case "1:3":
        return "A risk/reward ratio of 1:3 means you aim to make three times the amount you are risking.";
      case "1:4":
        return "A risk/reward ratio of 1:4 means you aim to make four times the amount you are risking.";
      case "1.5":
        return "A risk/reward ratio of 1:1.5 means you aim to make one and a half times the amount you are risking.";
      default:
        return "The AI will choose the best parameter based on the uploaded photo.";
    }
  }
}
