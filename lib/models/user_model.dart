import 'dart:convert';
import 'dart:typed_data';

class HistoryEntry {
  String imagePath;
  String response;
  DateTime timestamp;
  String imageUrl;
  Uint8List? imageBytes;
  int rating;
  String title;

  HistoryEntry({
    required this.imagePath,
    required this.response,
    required this.timestamp,
    required this.imageUrl,
    this.imageBytes,
    this.rating = 0,
    this.title = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'imagePath': imagePath,
      'response': response,
      'timestamp': timestamp.toIso8601String(),
      'imageUrl': imageUrl,
      'imageBytes': imageBytes != null ? base64Encode(imageBytes!) : null,
      'rating': rating,
      'title': title,
    };
  }

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      imagePath: json['imagePath'],
      response: json['response'],
      timestamp: DateTime.parse(json['timestamp']),
      imageUrl: json['imageUrl'],
      imageBytes: json['imageBytes'] != null ? base64Decode(json['imageBytes']) : null,
      rating: json['rating'],
      title: json['title'], // Parse title from JSON
    );
  }
}
class UserModel {
  String email;
  String name;
  int subscriptionType;
  List<String> timeFrames;
  List<HistoryEntry> history;
  bool isFreeTrial;
  DateTime signupDate;
  String uid; // Add the uid field
  bool isCanceled;
  DateTime? cancellationDate;

  UserModel({
    required this.email,
    required this.name,
    required this.subscriptionType,
    required this.timeFrames,
    required this.history,
    required this.isFreeTrial,
    required this.signupDate,
    required this.uid, // Add the uid parameter
    this.isCanceled = false,
    this.cancellationDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'subscriptionType': subscriptionType,
      'timeFrames': timeFrames,
      'history': history.map((e) => e.toJson()).toList(),
      'isFreeTrial': isFreeTrial,
      'signupDate': signupDate.toIso8601String(),
      'uid': uid, // Add the uid parameter
      'isCanceled': isCanceled,
      'cancellationDate': cancellationDate?.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'],
      name: json['name'],
      subscriptionType: json['subscriptionType'],
      timeFrames: List<String>.from(json['timeFrames']),
      history: List<HistoryEntry>.from(json['history'].map((e) => HistoryEntry.fromJson(e))),
      isFreeTrial: json['isFreeTrial'],
      signupDate: DateTime.parse(json['signupDate']),
      uid: json['uid'], // Add the uid parameter
      isCanceled: json['isCanceled'] ?? false,
      cancellationDate: json['cancellationDate'] != null ? DateTime.parse(json['cancellationDate']) : null,
    );
  }
}
