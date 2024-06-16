import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../provider/user_provider.dart';
import '../services/image_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/top_bar.dart';
import 'chatgpt_response_screen.dart';
import 'examples_screen.dart';
import 'history_screen.dart';
import 'questions_screen.dart';

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
    final pickedFile = await _picker.getImage(source: source);
    if (pickedFile != null) {
      dynamic image;
      if (kIsWeb) {
        image = await pickedFile.readAsBytes();
      } else {
        image = File(pickedFile.path);
        if (!await image.exists()) {
          return;
        }
      }

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      String imageUrl = await userProvider.uploadImage(image);
      if (imageUrl.isNotEmpty) {
        _analyzeImageAndFetchAdvice(imageUrl);
      }
    }
  }

  Future<void> _analyzeImageAndFetchAdvice(String imageUrl) async {
    try {
      String analysisResponse = await getImageService().processImage(
        imageUrl,
        widget.selectedStrategy ?? '',
        widget.subscribedTimeFrames,
        widget.additionalParameter ?? '',
      );

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
          previousScreen: '',
        ),
      ),
    );
  }

  void _navigateToExamples() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ExamplesScreen()),
    );
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
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'PRO Tip - dividendBeat recommends using ',
                            style: TextStyle(fontSize: 16.0, color: Colors.black),
                          ),
                          TextSpan(
                            text: 'RSI, MACD, EMA 20, EMA 50, EMA 200, Bollinger Bands or other indicators ',
                            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          TextSpan(
                            text: 'to help dividendBeat create more detailed analysis to help you maximize your trading potential.\n\n',
                            style: TextStyle(fontSize: 16.0, color: Colors.black),
                          ),
                          TextSpan(
                            text: '1. Capture and upload an image of a trading chart from any charts platform. \n\n',
                            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          TextSpan(
                            text: 'Examples: \n',
                            style: TextStyle(fontSize: 16.0, color: Colors.black),
                          ),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: _navigateToExamples,
                              child: Text(
                                'Click to see.',
                                style: TextStyle(fontSize: 16.0, color: Colors.blue, decoration: TextDecoration.underline),
                              ),
                            ),
                          ),
                          TextSpan(
                            text: '\n\n',
                            style: TextStyle(fontSize: 16.0, color: Colors.black),
                          ),
                          TextSpan(
                            text: '2. dividenBeat will beat the chart and provide the best trading insights based on the technical analysis.\n\n',
                            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          TextSpan(
                            text: '3. Leave emotions aside. Make more informed decisions.',
                            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ],
                      ),
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
