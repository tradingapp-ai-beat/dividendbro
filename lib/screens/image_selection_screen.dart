import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'chatgpt_response_screen.dart';
import '../widgets/top_bar.dart';
import '../widgets/app_drawer.dart';
import '../provider/user_provider.dart';

class ImageSelectionScreen extends StatefulWidget {
  final List<String> subscribedTimeFrames;
  final String name;
  final String? selectedStrategy;

  ImageSelectionScreen({
    required this.subscribedTimeFrames,
    required this.name,
    this.selectedStrategy,
  });

  @override
  _ImageSelectionScreenState createState() => _ImageSelectionScreenState();
}

class _ImageSelectionScreenState extends State<ImageSelectionScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.hasActiveSubscription && !userProvider.isSubscriptionStillActive) {
      _showSubscriptionDialog();
      return;
    }
    final pickedFile = await _picker.getImage(source: source);
    if (pickedFile != null) {
      String imagePath = pickedFile.path;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatGPTResponseScreen(
            imagePath: imagePath,
            subscribedTimeFrames: widget.subscribedTimeFrames,
            name: widget.name,
            selectedStrategy: widget.selectedStrategy,
          ),
        ),
      );
    }
  }

  void _showSubscriptionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Subscription Required'),
        content: Text('You need an active subscription to upload images and get tips.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(name: widget.name),
      drawer: AppDrawer(),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome!',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Please upload an image of your trading chart or capture a new one to get trading advice.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: Icon(Icons.camera_alt),
              label: Text('Capture Image'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                textStyle: TextStyle(fontSize: 16.0),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: Icon(Icons.photo_library),
              label: Text('Upload Image'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                textStyle: TextStyle(fontSize: 16.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
