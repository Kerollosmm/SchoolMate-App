import 'package:uuid/uuid.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/entities/conflict_record.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/local/hive_service.dart';
import '../models/attendance_record_model.dart';
import '../../core/constants/enums.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final HiveService _hiveService;

  AttendanceRepositoryImpl({required HiveService hiveService}) : _hiveService = hiveService;

  @override
  Future<List<AttendanceRecord>> getAttendance(String grade, DateTime date) async {
    // 1. Get all students (we need to filter by grade)
    final allStudents = _hiveService.getAllStudents();
    final studentsInGrade = allStudents.where((s) => s.grade == grade).map((s) => s.id).toSet();

    // 2. Get attendance for date
    final records = _hiveService.getAttendance(grade, date);

    // 3. Filter by student IDs in grade
    return records.where((r) => studentsInGrade.contains(r.studentId)).toList();
  }

  @override
  Future<void> markAttendance(AttendanceRecord record) async {
    final model = AttendanceRecordModel.fromEntity(record);
    await _hiveService.saveAttendance(model);
  }

  @override
  Future<List<ConflictRecord>> getConflicts() async {
    // Phase 1: Conflicts are detected during sync or manually flagged.
    // For now, scan for records with SyncStatus.conflict

    final allRecords = _hiveService.attendance.values;
    final conflictRecords = allRecords.where((r) => r.syncStatus == SyncStatus.conflict).toList();

    return conflictRecords.map((r) {
      // Assuming conflictId is stored in the record, or we generate one for the view
      final cId = r.conflictId ?? const Uuid().v4();

      return ConflictRecord(
        id: cId,
        studentId: r.studentId,
        date: r.date,
        conflictingRecords: [r],
      );
    }).toList();
  }

  @override
  Future<void> resolveConflict(String conflictId, AttendanceRecord resolvedRecord) async {
    // Update local with resolved
    final model = AttendanceRecordModel.fromEntity(resolvedRecord);
    // Force sync status to pending so it overwrites remote
    final finalModel = AttendanceRecordModel(
      id: model.id,
      studentId: model.studentId,
      date: model.date,
      statusString: model.statusString,
      markedByUserId: model.markedByUserId,
      markedAt: DateTime.now(),
      syncStatusString: 'pending',
      conflictId: null,
    );
    await _hiveService.saveAttendance(finalModel);
  }
}
