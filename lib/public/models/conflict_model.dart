class ConflictRecord {
  final String id;
  final String studentId;
  final String studentName;
  final String date;
  final Map<String, dynamic> localVersion; // The pending record
  final Map<String, dynamic> remoteVersion; // The existing record on server
  final String detectedAt;

  ConflictRecord({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.date,
    required this.localVersion,
    required this.remoteVersion,
    required this.detectedAt,
  });

  factory ConflictRecord.fromJson(Map<String, dynamic> json) {
    return ConflictRecord(
      id: json['id'] ?? '',
      studentId: json['studentId'] ?? '',
      studentName: json['studentName'] ?? '',
      date: json['date'] ?? '',
      localVersion: Map<String, dynamic>.from(json['localVersion'] ?? {}),
      remoteVersion: Map<String, dynamic>.from(json['remoteVersion'] ?? {}),
      detectedAt: json['detectedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'date': date,
      'localVersion': localVersion,
      'remoteVersion': remoteVersion,
      'detectedAt': detectedAt,
    };
  }
}
