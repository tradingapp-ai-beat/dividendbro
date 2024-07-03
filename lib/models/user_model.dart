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
  bool isWin;

  HistoryEntry({
    required this.imagePath,
    required this.response,
    required this.timestamp,
    required this.imageUrl,
    this.imageBytes,
    this.rating = 0,
    this.title = '',
    this.isWin = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'imagePath': imagePath,
      'response': response,
      'timestamp': timestamp.toIso8601String(),
      'imageUrl': imageUrl,
      'imageBytes': imageBytes != null ? base64Encode(imageBytes!) : null,
      'rating': rating,
      'isWin': isWin,
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
      isWin: json['isWin'],
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
  bool isPaidSubscription;
  DateTime signupDate;
  DateTime? cancellationDate;
  bool isCanceled;
  String uid;
  DateTime subscriptionEndDate;
  String password;
  DateTime paymentDate;

  UserModel({
    required this.email,
    required this.name,
    required this.subscriptionType,
    required this.timeFrames,
    required this.history,
    required this.isFreeTrial,
    required this.signupDate,
    this.cancellationDate,
    this.isCanceled = false,
    required this.uid,
    required this.subscriptionEndDate,
    this.isPaidSubscription = false,
    required this.password,
    required this.paymentDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'subscriptionType': subscriptionType,
      'timeFrames': timeFrames,
      'history': history.map((e) => e.toJson()).toList(),
      'isFreeTrial': isFreeTrial,
      'isPaidSubscription': isPaidSubscription,
      'signupDate': signupDate.toIso8601String(),
      'cancellationDate': cancellationDate?.toIso8601String(),
      'isCanceled': isCanceled,
      'uid': uid,
      'subscriptionEndDate': subscriptionEndDate.toIso8601String(),
      'password': password,
      'paymentDate': paymentDate.toIso8601String(),
    };
  }

  static UserModel fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'],
      name: json['name'],
      subscriptionType: json['subscriptionType'],
      timeFrames: List<String>.from(json['timeFrames']),
      history: (json['history'] as List).map((e) => HistoryEntry.fromJson(e)).toList(),
      isFreeTrial: json['isFreeTrial'],
      isPaidSubscription: json['isPaidSubscription'] ?? false,
      signupDate: DateTime.parse(json['signupDate']),
      cancellationDate: json['cancellationDate'] != null ? DateTime.parse(json['cancellationDate']) : null,
      isCanceled: json['isCanceled'],
      uid: json['uid'],
      subscriptionEndDate: DateTime.parse(json['subscriptionEndDate']),
      password: json['password'],
      paymentDate: DateTime.parse(json['paymentDate']),
    );
  }
}
