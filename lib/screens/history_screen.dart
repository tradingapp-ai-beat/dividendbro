import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/user_provider.dart';
import '../models/user_model.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'dart:convert';

class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final history = Provider.of<UserProvider>(context).user.history;

    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
      ),
      body: ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          final entry = history[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: Column(
              children: [
                ListTile(
                  leading: SizedBox(
                    width: 50,
                    height: 50,
                    child: _buildImage(entry.imageUrl, entry.imageBytes),
                  ),
                  title: Text(
                    'Beat ${index + 1} - ${entry.timestamp.day}/${entry.timestamp.month}/${entry.timestamp.year} ${entry.timestamp.hour}:${entry.timestamp.minute.toString().padLeft(2, '0')}',
                  ),
                  subtitle: Text(entry.response, maxLines: 2, overflow: TextOverflow.ellipsis),
                  onTap: () {
                    _showDetailDialog(context, entry);
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (starIndex) {
                    return IconButton(
                      icon: Icon(
                        starIndex < entry.rating ? Icons.star : Icons.star_border,
                        color: entry.rating >= 3 ? Colors.green : Colors.red,
                      ),
                      onPressed: () {
                        Provider.of<UserProvider>(context, listen: false).updateHistoryEntryRating(index, starIndex + 1);
                      },
                    );
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImage(String? imageUrl, Uint8List? imageBytes) {
    if (imageBytes != null) {
      return Image.memory(imageBytes, fit: BoxFit.cover);
    } else if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.broken_image, size: 50);
      });
    } else {
      return Icon(Icons.image_not_supported, size: 50);
    }
  }

  void _showDetailDialog(BuildContext context, HistoryEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detail'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 200,
                child: _buildImage(entry.imageUrl, entry.imageBytes),
              ),
              SizedBox(height: 10),
              Text(entry.response),
            ],
          ),
        ),
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
}
