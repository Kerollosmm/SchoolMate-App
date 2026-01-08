import '../entities/attendance_record.dart';
import '../entities/conflict_record.dart';

abstract class AttendanceRepository {
  Future<List<AttendanceRecord>> getAttendance(String grade, DateTime date);
  Future<void> markAttendance(AttendanceRecord record);
  Future<List<ConflictRecord>> getConflicts();
  Future<void> resolveConflict(String conflictId, AttendanceRecord resolvedRecord);
}
