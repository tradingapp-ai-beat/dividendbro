import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../provider/user_provider.dart';
import '../models/user_model.dart';
import '../services/image_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/top_bar.dart';
import 'chatgpt_response_screen.dart';
import 'history_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'questions_screen.dart';  // Import the QuestionsScreen

class ImageSelectionScreen extends StatefulWidget {
  final List<String> subscribedTimeFrames;
  final String name;
  final String? selectedStrategy;
  final String? additionalParameter;

  ImageSelectionScreen({
    required this.subscribedTimeFrames,
    required this.name,
    this.selectedStrategy,
    this.additionalParameter,
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
        _analyzeImageAndFetchAdvice(imageUrl);
      } else {
        print('Failed to upload image');
      }
    } else {
      print('No image picked');
    }
  }

  Future<void> _analyzeImageAndFetchAdvice(String imageUrl) async {
    try {
      print('Analyzing image...');
      String analysisResponse = await getImageService().processImage(
        imageUrl,
        widget.selectedStrategy ?? '',
        widget.subscribedTimeFrames,
        widget.additionalParameter ?? '',
      );
      print('Analysis response: $analysisResponse');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatGPTResponseScreen(
            imagePath: imageUrl,
            subscribedTimeFrames: widget.subscribedTimeFrames,
            name: widget.name,
            selectedStrategy: widget.selectedStrategy,
            additionalParameter: widget.additionalParameter,
            analysisResponse: analysisResponse,
          ),
        ),
      );
    } catch (e) {
      print('Error processing image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to process image: $e')),
      );
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
          /*
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text('Capture Image'),
            onTap: () {
              _pickImage(ImageSource.camera);
              Navigator.of(context).pop();
            },
          ),

           */
        ],
      ),
    );
  }

  void _navigateToQuestionnaire() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionsScreen(
          subscribedTimeFrames: widget.subscribedTimeFrames,
          name: widget.name,
        ),
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
      appBar: TopBar(name: widget.name),
      drawer: AppDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth > 600 ? 600 : double.infinity,
                ),
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
                      'PRO Tip - dividendBeat recommends using RSI, MACD, EMA 20, EMA 50, EMA 200 and Bollinger Bands to make informed decisions and maximize your trading potential.\n'
                          '1. Capture and upload an image of your trading chart.\n'
                          '2. Our system will analyze the chart and provide the best trading insights.\n'
                          '3. Follow the given instructions to make more informed trading decisions.',
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
                      label: Text('Select Chart'),
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
            ),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton(
                mini: true,
                onPressed: _navigateToQuestionnaire,
                child: Icon(Icons.settings),
              ),
              SizedBox(width: 20),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
