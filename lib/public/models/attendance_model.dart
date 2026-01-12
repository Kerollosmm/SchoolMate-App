class AttendanceRecord {
  final String id; // usually composite: date_studentId
  final String studentId;
  final String studentName;
  final String grade;
  final String date; // YYYY-MM-DD
  final String status; // 'present', 'absent', 'excused'
  final String recordedBy; // uid of servant/admin
  final String syncStatus; // 'synced', 'pending', 'conflict'
  final int timestamp;

  AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.grade,
    required this.date,
    required this.status,
    required this.recordedBy,
    required this.syncStatus,
    required this.timestamp,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] ?? '',
      studentId: json['studentId'] ?? '',
      studentName: json['studentName'] ?? '',
      grade: json['grade'] ?? '',
      date: json['date'] ?? '',
      status: json['status'] ?? 'present',
      recordedBy: json['recordedBy'] ?? '',
      syncStatus: json['syncStatus'] ?? 'synced',
      timestamp: json['timestamp'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'grade': grade,
      'date': date,
      'status': status,
      'recordedBy': recordedBy,
      'syncStatus': syncStatus,
      'timestamp': timestamp,
    };
  }

  AttendanceRecord copyWith({
    String? status,
    String? syncStatus,
    String? recordedBy,
  }) {
    return AttendanceRecord(
      id: id,
      studentId: studentId,
      studentName: studentName,
      grade: grade,
      date: date,
      status: status ?? this.status,
      recordedBy: recordedBy ?? this.recordedBy,
      syncStatus: syncStatus ?? this.syncStatus,
      timestamp: timestamp,
    );
  }
}
