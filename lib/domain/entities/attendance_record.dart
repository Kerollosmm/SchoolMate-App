import 'package:equatable/equatable.dart';
import '../../core/constants/enums.dart';

class AttendanceRecord extends Equatable {
  final String id;
  final String studentId;
  final DateTime date;
  final AttendanceStatus status;
  final String markedByUserId;
  final DateTime markedAt;
  final SyncStatus syncStatus;
  final String? conflictId;

  const AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.date,
    required this.status,
    required this.markedByUserId,
    required this.markedAt,
    this.syncStatus = SyncStatus.pending,
    this.conflictId,
  });

  @override
  List<Object?> get props => [id, studentId, date, status, markedByUserId, markedAt, syncStatus, conflictId];
}
