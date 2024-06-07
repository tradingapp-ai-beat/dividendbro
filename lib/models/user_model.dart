class HistoryEntry {
  String imagePath;
  String response;
  DateTime timestamp;
  int rating;

  HistoryEntry({
    required this.imagePath,
    required this.response,
    required this.timestamp,
    this.rating = 0,
  });

  Map<String, dynamic> toJson() => {
    'imagePath': imagePath,
    'response': response,
    'timestamp': timestamp.toIso8601String(),
    'rating': rating,
  };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
    imagePath: json['imagePath'],
    response: json['response'],
    timestamp: DateTime.parse(json['timestamp']),
    rating: json['rating'] ?? 0,
  );
}

class UserModel {
  final String email;
  late String name;
  int? subscriptionType;
  List<String> timeFrames;
  List<HistoryEntry> history;
  bool isFreeTrial;
  bool isCanceled;
  DateTime signupDate;
  DateTime? cancellationDate;

  UserModel({
    required this.email,
    required this.name,
    this.subscriptionType,
    List<String>? timeFrames,
    List<HistoryEntry>? history,
    this.isFreeTrial = true,
    this.isCanceled = false,
    this.cancellationDate,
    required this.signupDate,
  })  : this.timeFrames = timeFrames ?? [],
        this.history = history ?? [];

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      subscriptionType: json['subscriptionType'],
      timeFrames: json['timeFrames'] != null ? List<String>.from(json['timeFrames']) : [],
      history: json['history'] != null ? List<HistoryEntry>.from((json['history'] as List).map((entry) => HistoryEntry.fromJson(entry))) : [],
      isFreeTrial: json['isFreeTrial'] ?? true,
      isCanceled: json['isCanceled'] ?? false,
      cancellationDate: json['cancellationDate'] != null ? DateTime.parse(json['cancellationDate']) : null,
      signupDate: json['signupDate'] != null ? DateTime.parse(json['signupDate']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'subscriptionType': subscriptionType,
      'timeFrames': timeFrames,
      'history': history.map((entry) => entry.toJson()).toList(),
      'isFreeTrial': isFreeTrial,
      'isCanceled': isCanceled,
      'cancellationDate': cancellationDate?.toIso8601String(),
      'signupDate': signupDate.toIso8601String(),
    };
  }
}