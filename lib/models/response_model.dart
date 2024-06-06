class ResponseModel {
  final String advice;

  ResponseModel({required this.advice});

  factory ResponseModel.fromJson(Map<String, dynamic> json) {
    return ResponseModel(
      advice: json['choices'][0]['text'],
    );
  }
}
