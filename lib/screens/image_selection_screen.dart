import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'chatgpt_response_screen.dart';

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
    final pickedFile = await _picker.getImage(source: source);
    if (pickedFile != null) {
      dynamic image;
      if (kIsWeb) {
        image = await pickedFile.readAsBytes(); // Uint8List for web
        print('Picked a Uint8List image');
      } else {
        image = File(pickedFile.path); // File for mobile
        if (!await image.exists()) {
          print('File does not exist');
          return;
        }
        print('Picked a File image');
      }

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      String imageUrl = await userProvider.uploadImage(image);
      if (imageUrl.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatGPTResponseScreen(
              imagePath: imageUrl,
              subscribedTimeFrames: widget.subscribedTimeFrames,
              name: widget.name,
              selectedStrategy: widget.selectedStrategy,
            ),
          ),
        );
      } else {
        print('Failed to upload image');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Image')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => _pickImage(ImageSource.camera),
              child: Text('Capture Image'),
            ),
            ElevatedButton(
              onPressed: () => _pickImage(ImageSource.gallery),
              child: Text('Upload Image'),
            ),
          ],
        ),
      ),
    );
  }
}