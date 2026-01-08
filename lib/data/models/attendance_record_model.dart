import 'package:hive/hive.dart';
import '../../core/constants/enums.dart';
import '../../domain/entities/attendance_record.dart';

part 'attendance_record_model.g.dart';

@HiveType(typeId: 2)
class AttendanceRecordModel extends AttendanceRecord {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String studentId;
  @HiveField(2)
  final DateTime date;
  @HiveField(3)
  final String statusString;
  @HiveField(4)
  final String markedByUserId;
  @HiveField(5)
  final DateTime markedAt;
  @HiveField(6)
  final String syncStatusString;
  @HiveField(7)
  final String? conflictId;

  AttendanceRecordModel({
    required this.id,
    required this.studentId,
    required this.date,
    required this.statusString,
    required this.markedByUserId,
    required this.markedAt,
    required this.syncStatusString,
    this.conflictId,
  }) : super(
          id: id,
          studentId: studentId,
          date: date,
          status: _parseStatus(statusString),
          markedByUserId: markedByUserId,
          markedAt: markedAt,
          syncStatus: _parseSyncStatus(syncStatusString),
          conflictId: conflictId,
        );

  static AttendanceStatus _parseStatus(String status) {
    switch (status) {
      case 'present': return AttendanceStatus.present;
      case 'absent': return AttendanceStatus.absent;
      case 'excused': return AttendanceStatus.excused;
      default: return AttendanceStatus.absent;
    }
  }

  static SyncStatus _parseSyncStatus(String status) {
    switch (status) {
      case 'synced': return SyncStatus.synced;
      case 'pending': return SyncStatus.pending;
      case 'conflict': return SyncStatus.conflict;
      default: return SyncStatus.pending;
    }
  }

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    return AttendanceRecordModel(
      id: json['id'] ?? '',
      studentId: json['studentId'] ?? '',
      date: DateTime.parse(json['date']),
      statusString: json['status'] ?? 'absent',
      markedByUserId: json['markedByUserId'] ?? '',
      markedAt: DateTime.parse(json['markedAt']),
      syncStatusString: json['syncStatus'] ?? 'pending',
      conflictId: json['conflictId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'date': date.toIso8601String().split('T')[0],
      'status': statusString,
      'markedByUserId': markedByUserId,
      'markedAt': markedAt.toIso8601String(),
      'syncStatus': syncStatusString,
      'conflictId': conflictId,
    };
  }

  factory AttendanceRecordModel.fromEntity(AttendanceRecord entity) {
    String statusString;
    switch(entity.status) {
      case AttendanceStatus.present: statusString = 'present'; break;
      case AttendanceStatus.absent: statusString = 'absent'; break;
      case AttendanceStatus.excused: statusString = 'excused'; break;
    }

    String syncStatusString;
    switch(entity.syncStatus) {
      case SyncStatus.synced: syncStatusString = 'synced'; break;
      case SyncStatus.pending: syncStatusString = 'pending'; break;
      case SyncStatus.conflict: syncStatusString = 'conflict'; break;
    }

    return AttendanceRecordModel(
      id: entity.id,
      studentId: entity.studentId,
      date: entity.date,
      statusString: statusString,
      markedByUserId: entity.markedByUserId,
      markedAt: entity.markedAt,
      syncStatusString: syncStatusString,
      conflictId: entity.conflictId,
    );
  }
}
