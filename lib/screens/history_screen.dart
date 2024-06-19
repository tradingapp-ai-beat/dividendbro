import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/user_provider.dart';
import '../models/user_model.dart';
import 'package:firebase_storage/firebase_storage.dart';

class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final history = Provider.of<UserProvider>(context).user.history.reversed.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
      ),
      body: ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          final entry = history[index];
          final originalIndex = history.length - 1 - index;
          return Card(
            margin: EdgeInsets.all(8.0),
            child: Column(
              children: [
                ListTile(
                  leading: SizedBox(
                    width: 50,
                    height: 50,
                    child: _buildImage(context, entry.imageUrl),
                  ),
                  title: Text(
                    entry.title.isNotEmpty
                        ? entry.title
                        : 'Beat ${history.length - index} - ${entry.timestamp.day}/${entry.timestamp.month}/${entry.timestamp.year} ${entry.timestamp.hour}:${entry.timestamp.minute.toString().padLeft(2, '0')}',
                  ),
                  subtitle: Text(entry.response, maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: PopupMenuButton<String>(
                    onSelected: (String result) {
                      if (result == 'change_name') {
                        _showChangeNameDialog(context, entry, originalIndex);
                      } else if (result == 'delete') {
                        _showDeleteConfirmationDialog(context, originalIndex);
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
                    _showFullImageDialog(context, entry.imageUrl, entry.response);
                  },
                ),
                _buildWinLossRow(context, entry, originalIndex),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImage(BuildContext context, String imageUrl) {
    if (imageUrl.isEmpty) {
      return Icon(Icons.broken_image, size: 50);
    }

    return GestureDetector(
      onTap: () => _showFullImageDialog(context, imageUrl, ""),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.broken_image, size: 50);
        },
      ),
    );
  }

  void _showFullImageDialog(BuildContext context, String imageUrl, String response) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: InteractiveViewer(
                boundaryMargin: EdgeInsets.all(20.0),
                minScale: 0.1,
                maxScale: 4.0,
                child: AspectRatio(
                  aspectRatio: 16 / 9, // Set the aspect ratio to match the image's aspect ratio
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(child: Icon(Icons.broken_image, size: 100));
                    },
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(8.0),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4, // Limit the height
              ),
              child: SingleChildScrollView(
                child: Text(
                  response,
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Close'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWinLossRow(BuildContext context, HistoryEntry entry, int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            Provider.of<UserProvider>(context, listen: false).updateHistoryEntryResult(index, true);
          },
          child: Text('Win'),
          style: ElevatedButton.styleFrom(
            backgroundColor: entry.isWin ? Colors.green : Colors.grey,
          ),
        ),
        SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {
            Provider.of<UserProvider>(context, listen: false).updateHistoryEntryResult(index, false);
          },
          child: Text('Loss'),
          style: ElevatedButton.styleFrom(
            backgroundColor: !entry.isWin ? Colors.red : Colors.grey,
          ),
        ),
      ],
    );
  }

  void _showChangeNameDialog(BuildContext context, HistoryEntry entry, int index) {
    final TextEditingController _controller = TextEditingController(
        text: entry.title.isNotEmpty
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
