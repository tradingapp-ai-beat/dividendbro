import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/user_model.dart';
import '../provider/user_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/top_bar.dart';
import '../services/image_service.dart';
import 'history_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChatGPTResponseScreen extends StatefulWidget {
  final String imagePath;
  final List<String> subscribedTimeFrames;
  final String name;
  final String? selectedStrategy;

  ChatGPTResponseScreen({
    required this.imagePath,
    required this.subscribedTimeFrames,
    required this.name,
    this.selectedStrategy,
  });

  @override
  _ChatGPTResponseScreenState createState() => _ChatGPTResponseScreenState();
}

class _ChatGPTResponseScreenState extends State<ChatGPTResponseScreen> {
  String _response = '';
  bool _isImageExpanded = true;
  bool _isLoading = true;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  Future<void> _processImage() async {
    try {
      String response = await ImageService.processImage(
        widget.imagePath,
        widget.selectedStrategy ?? 'default strategy',
        widget.subscribedTimeFrames,
      );
      setState(() {
        _response = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _response = 'Failed to process image: ${e.toString()}';
        _isLoading = false;
      });
    }

    // Save history with timestamp
    Provider.of<UserProvider>(context, listen: false).addHistoryEntry(
      HistoryEntry(
        imagePath: widget.imagePath,
        response: _response,
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> _showUploadOptions() async {
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

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.getImage(source: source);
    if (pickedFile != null) {
      String imagePath = pickedFile.path;
      Navigator.pushReplacement(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(name: widget.name),
      drawer: AppDrawer(),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Text(
                  'Time Frames: ${widget.subscribedTimeFrames.join(', ')}',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
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
                      child: kIsWeb
                          ? Image.network(widget.imagePath)
                          : Image.file(File(widget.imagePath)),
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
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (!_isImageExpanded)
            Positioned(
              top: 40,
              left: 20,
              child: FloatingActionButton(
                mini: true,
                onPressed: () {
                  setState(() {
                    _isImageExpanded = true;
                  });
                },
                child: Icon(Icons.image),
              ),
            ),
          if (_isImageExpanded)
            Positioned(
              top: 40,
              right: 20,
              child: FloatingActionButton(
                mini: true,
                onPressed: () {
                  setState(() {
                    _isImageExpanded = false;
                  });
                },
                child: Icon(Icons.close),
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
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: TextButton(
            onPressed: _showUploadOptions,
            child: SvgPicture.asset(
              'assets/beat.svg',
              height: 30,
              width: 30,
            ),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
}
