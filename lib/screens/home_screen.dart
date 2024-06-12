import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/user_provider.dart';

import 'chatgpt_response_screen.dart';
import 'image_selection_screen.dart';


class HomeScreen extends StatelessWidget {
  final String subscriptionType;
  final List<String> timeFrames;

  HomeScreen({required this.subscriptionType, required this.timeFrames});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome, ${userProvider.user?.name}',
              style: TextStyle(fontSize: 24.0),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImageSelectionScreen(
                      subscribedTimeFrames: userProvider.user!.timeFrames,
                      name: userProvider.user!.name,
                    ),
                  ),
                );
              },
              child: Text('Upload or Capture Image'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatGPTResponseScreen(imagePath: '', subscribedTimeFrames: [], name: '', analysisResponse: '',),
                  ),
                );
              },
              child: Text('Display Data'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                //userProvider.printAllUsers(); // Print all users on button press
              },
              child: Text('Print All Users'),
            ),
          ],
        ),
      ),
    );
  }
}
