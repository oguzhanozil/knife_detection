class CameraRecords {
  final DateTime date;
  final String filePath;

  CameraRecords({
    required this.date,
    required this.filePath,
  });

  factory CameraRecords.fromJson(Map<String, dynamic> json) {
    return CameraRecords(
      date: DateTime.parse(json['date']),
      filePath: json['filepath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'filepath': filePath,
    };
  }
}