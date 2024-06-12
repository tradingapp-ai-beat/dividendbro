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
import 'history_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'questions_screen.dart';  // Import the QuestionsScreen
import 'questions_screen2.dart'; // Import the QuestionsScreen2

class ChatGPTResponseScreen extends StatefulWidget {
  final String imagePath;
  final List<String> subscribedTimeFrames;
  final String name;
  final String? selectedStrategy;
  final String? additionalParameter;
  final String analysisResponse;

  ChatGPTResponseScreen({
    required this.imagePath,
    required this.subscribedTimeFrames,
    required this.name,
    this.selectedStrategy,
    this.additionalParameter,
    required this.analysisResponse,
  });

  @override
  _ChatGPTResponseScreenState createState() => _ChatGPTResponseScreenState();
}

class _ChatGPTResponseScreenState extends State<ChatGPTResponseScreen> {
  String _response = '';
  bool _isImageExpanded = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  Future<void> _processImage() async {
    try {
      print('Processing image...');
      String response = await getImageService().processImage(
        widget.imagePath,
        widget.selectedStrategy ?? '',
        widget.subscribedTimeFrames,
        widget.additionalParameter ?? '',
      );

      print('Image processed, received response: $response');

      setState(() {
        _response = response;
        _isLoading = false;
      });

      Provider.of<UserProvider>(context, listen: false).addHistoryEntry(
        HistoryEntry(
          imagePath: widget.imagePath,
          response: _response,
          timestamp: DateTime.now(),
          imageUrl: widget.imagePath,
        ),
      );
    } catch (e) {
      print('Error processing image: $e');
      setState(() {
        _response = 'Failed to process image: ${e.toString()}';
        _isLoading = false;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: TopBar(name: widget.name),
      drawer: AppDrawer(),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 800),
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    Text(
                      'Your available time frames: ${widget.subscribedTimeFrames.join(', ')}',
                      style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    if (_isImageExpanded)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isImageExpanded = false;
                          });
                        },
                        child: InteractiveViewer(
                          boundaryMargin: EdgeInsets.all(20.0),
                          minScale: 0.1,
                          maxScale: 4.0,
                          child: Image.network(widget.imagePath),
                        ),
                      ),
                    SizedBox(height: 10),
                    if (_isLoading)
                      CircularProgressIndicator()
                    else
                      Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            _response,
                            style: TextStyle(fontSize: 18.0),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: FloatingActionButton(
                  mini: true,
                  onPressed: () {
                    setState(() {
                      _isImageExpanded = !_isImageExpanded;
                    });
                  },
                  child: Icon(_isImageExpanded ? Icons.close : Icons.image),
                ),
              ),
              Positioned(
                top: 40,
                left: 20,
                child: FloatingActionButton(
                  mini: true,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HistoryScreen(),
                      ),
                    );
                  },
                  child: Icon(Icons.replay),
                ),
              ),
              Positioned(
                bottom: 100,
                right: 20,
                child: FloatingActionButton(
                  mini: true,
                  onPressed: _navigateToQuestionnaire,
                  child: Icon(Icons.settings),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ElevatedButton.icon(
            onPressed: () => _showUploadOptions(context),
            icon: SvgPicture.asset(
              'assets/beat.svg',
              height: 50,
              width: 50,
            ),
            label: Text('Select your Chart'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
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

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    final pickedFile = await _picker.getImage(source: source);
    if (pickedFile != null) {
      dynamic image;
      if (kIsWeb) {
        image = await pickedFile.readAsBytes(); // Uint8List for web
        print('Picked a Uint8List image');
      } else {
        image = File(pickedFile.path); // File for mobile
      }
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      print('Starting image upload from _pickImage');
      String imageUrl = await userProvider.uploadImage(image);
      if (imageUrl.isNotEmpty) {
        print('Image uploaded successfully, URL: $imageUrl');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChatGPTResponseScreen(
              imagePath: imageUrl,
              subscribedTimeFrames: widget.subscribedTimeFrames,
              name: widget.name,
              selectedStrategy: widget.selectedStrategy,
              additionalParameter: widget.additionalParameter,
              analysisResponse: '',
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
}
