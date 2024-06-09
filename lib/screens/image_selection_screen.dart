import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'chatgpt_response_screen.dart';
import '../widgets/app_drawer.dart';
import '../widgets/top_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    print('Starting image picking process');
    final pickedFile = await _picker.getImage(source: source);
    if (pickedFile != null) {
      print('Image picked successfully');
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
      print('Uploading image');
      String imageUrl = await userProvider.uploadImage(image);
      if (imageUrl.isNotEmpty) {
        print('Image uploaded successfully, URL: $imageUrl');
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
    } else {
      print('No image picked');
    }
  }

  Future<void> _showUploadOptions(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.photo_library),
            title: Text('Upload Image'),
            onTap: () {
              _pickImage(ImageSource.gallery);
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text('Capture Image'),
            onTap: () {
              _pickImage(ImageSource.camera);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    Provider.of<UserProvider>(context, listen: false).logout();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout(context);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 'logout',
                  child: Text('Logout'),
                ),
              ];
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 20),
            Text(
              'Welcome, ${widget.name}!',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            Text(
              'Instructions',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'PRO Tip - dividendBeat recommends using RSI, MACD, EMA 20, and Bollinger Bands to make informed decisions and maximize your trading potential\n'
                  '1. Capture or upload an image of your trading chart.\n'
                  '2. Our system will analyze the chart and provide insights.\n'
                  '3. Follow the given instructions to make informed trading decisions.',
              style: TextStyle(fontSize: 16.0),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            Text(
              'Now, let\'s start by uploading your chart!',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _showUploadOptions(context),
              icon: SvgPicture.asset(
                'assets/beat.svg',
                height: 30,
                width: 30,
              ),
              label: Text('Select Image'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            SizedBox(height: 30),
            Text(
              'Trading involves significant risk and can result in substantial losses. Ensure you understand the risks involved before proceeding.',
              style: TextStyle(fontSize: 12.0, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
