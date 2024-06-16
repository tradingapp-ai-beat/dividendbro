import 'package:flutter/material.dart';
import 'image_gallery_screen.dart';

class ExamplesScreen extends StatelessWidget {
  final List<String> mobileImages = [
    'assets/mobile1.png',
    'assets/mobile2.png',
  ];

  final List<String> webImages = [
    'assets/web1.png',
    'assets/web2.png',
  ];

  void _navigateToImageGallery(BuildContext context, List<String> images) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageGalleryScreen(images: images),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Charts Examples'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: () => _navigateToImageGallery(context, mobileImages),
                child: Container(
                  width: 200,  // Set a fixed width for uniform size
                  decoration: BoxDecoration(
                    color: Colors.black54.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: Colors.black54, width: 2),
                  ),
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(Icons.smartphone, size: 50, color: Colors.black54),
                      SizedBox(height: 10),
                      Text(
                        'Mobile Charts',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () => _navigateToImageGallery(context, webImages),
                child: Container(
                  width: 200,  // Set a fixed width for uniform size
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: Colors.grey, width: 2),
                  ),
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(Icons.desktop_windows, size: 50, color: Colors.grey),
                      SizedBox(height: 10),
                      Text(
                        'Web Charts',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
