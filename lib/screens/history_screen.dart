import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'dart:io';
import '../provider/user_provider.dart';
import '../models/user_model.dart';

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
                  leading: kIsWeb
                      ? Image.network(entry.imagePath)
                      : Image.file(File(entry.imagePath)),
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

  void _showDetailDialog(BuildContext context, HistoryEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detail'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              kIsWeb
                  ? Image.network(entry.imagePath)
                  : Image.file(File(entry.imagePath)),
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
