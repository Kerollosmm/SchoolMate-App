import 'package:equatable/equatable.dart';
import 'attendance_record.dart';

class ConflictRecord extends Equatable {
  final String id;
  final String studentId;
  final DateTime date;
  final List<AttendanceRecord> conflictingRecords;
  final bool isResolved;
  final String? resolvedBy;

  const ConflictRecord({
    required this.id,
    required this.studentId,
    required this.date,
    required this.conflictingRecords,
    this.isResolved = false,
    this.resolvedBy,
  });

  @override
  List<Object?> get props => [id, studentId, date, conflictingRecords, isResolved, resolvedBy];
}
