import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trading_advice_app_v2/screens/questions_screen.dart';
import 'package:trading_advice_app_v2/screens/history_screen.dart';
import 'package:trading_advice_app_v2/screens/image_selection_screen.dart';
import 'package:trading_advice_app_v2/screens/settings_screen.dart';
import '../provider/user_provider.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Main Screen'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome, ${user.name}!',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QuestionsScreen(subscribedTimeFrames: [], name: '',)),
                );
              },
              child: Text('Answer Questions'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImageSelectionScreen(
                      subscribedTimeFrames: user.timeFrames,
                      name: user.name,
                    ),
                  ),
                );
              },
              child: Text('Upload Image'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HistoryScreen()),
                );
              },
              child: Text('View History'),
            ),
          ],
        ),
      ),
    );
  }
}
