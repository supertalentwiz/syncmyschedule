class ShiftModel {
  final String day;
  final String date;
  final String code;

  ShiftModel({required this.day, required this.date, required this.code});

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    return ShiftModel(
      day: json['day'] ?? '',
      date: json['date'] ?? '',
      code: json['code'] ?? '',
    );
  }
}
