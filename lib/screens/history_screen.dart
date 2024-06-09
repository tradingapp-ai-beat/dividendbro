import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/user_provider.dart';
import '../models/user_model.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;

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
                    entry.title.isNotEmpty
                        ? entry.title
                        : 'Beat ${index + 1} - ${entry.timestamp.day}/${entry.timestamp.month}/${entry.timestamp.year} ${entry.timestamp.hour}:${entry.timestamp.minute.toString().padLeft(2, '0')}',
                  ),
                  subtitle: Text(entry.response, maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: PopupMenuButton<String>(
                    onSelected: (String result) {
                      if (result == 'change_name') {
                        _showChangeNameDialog(context, entry, index);
                      } else if (result == 'delete') {
                        _showDeleteConfirmationDialog(context, index);
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'change_name',
                        child: Text('Change Beat Name'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                  onTap: () {
                    _showDetailDialog(context, entry);
                  },
                ),
                _buildRatingRow(context, entry, index),
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

  Widget _buildRatingRow(BuildContext context, HistoryEntry entry, int index) {
    return Row(
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

  void _showChangeNameDialog(BuildContext context, HistoryEntry entry, int index) {
    final TextEditingController _controller = TextEditingController(text: entry.title.isNotEmpty
        ? entry.title
        : 'Beat ${index + 1} - ${entry.timestamp.day}/${entry.timestamp.month}/${entry.timestamp.year} ${entry.timestamp.hour}:${entry.timestamp.minute.toString().padLeft(2, '0')}');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Beat Name'),
        content: TextField(
          controller: _controller,
          decoration: InputDecoration(labelText: 'Beat Name'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<UserProvider>(context, listen: false).updateHistoryEntryName(index, _controller.text);
              Navigator.of(context).pop();
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Beat'),
        content: Text('Are you sure you want to delete this beat?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<UserProvider>(context, listen: false).deleteHistoryEntry(index);
              Navigator.of(context).pop();
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
