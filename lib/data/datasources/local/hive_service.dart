import 'package:hive_flutter/hive_flutter.dart';
import 'package:csms_app/data/models/user_profile_model.dart';
import 'package:csms_app/data/models/student_model.dart';
import 'package:csms_app/data/models/attendance_record_model.dart';

class HiveService {
  static const String servantsBox = 'servants_box';
  static const String studentsBox = 'students_box';
  static const String attendanceBox = 'attendance_box';
  static const String syncQueueBox = 'sync_queue_box';
  static const String syncMetaBox = 'sync_meta_box';
  static const String conflictsBox = 'conflicts_box';

  static Future<void> init() async {
    Hive.registerAdapter(UserProfileModelAdapter());
    Hive.registerAdapter(StudentModelAdapter());
    Hive.registerAdapter(AttendanceRecordModelAdapter());

    await Hive.openBox<UserProfileModel>(servantsBox);
    await Hive.openBox<StudentModel>(studentsBox);
    await Hive.openBox<AttendanceRecordModel>(attendanceBox);
    await Hive.openBox(syncQueueBox);
    await Hive.openBox(syncMetaBox);
  }

  Box<UserProfileModel> get servants => Hive.box<UserProfileModel>(servantsBox);
  Box<StudentModel> get students => Hive.box<StudentModel>(studentsBox);
  Box<AttendanceRecordModel> get attendance => Hive.box<AttendanceRecordModel>(attendanceBox);
  Box get syncQueue => Hive.box(syncQueueBox);
  Box get syncMeta => Hive.box(syncMetaBox);

  // Basic CRUD for Servants
  List<UserProfileModel> getAllServants() {
    return servants.values.toList();
  }

  Future<void> saveServant(UserProfileModel servant) async {
    await servants.put(servant.id, servant);
  }

  Future<void> deleteServant(String id) async {
    await servants.delete(id);
  }

  // Basic CRUD for Students
  List<StudentModel> getAllStudents() {
    return students.values.toList();
  }

  Future<void> saveStudent(StudentModel student) async {
    await students.put(student.id, student);
  }

  Future<void> deleteStudent(String id) async {
    await students.delete(id);
  }

  // Basic CRUD for Attendance
  List<AttendanceRecordModel> getAttendance(String grade, DateTime date) {
    final dateStr = date.toIso8601String().split('T')[0];
    return attendance.values.where((record) {
      final recordDate = record.date.toIso8601String().split('T')[0];
      return recordDate == dateStr;
    }).toList();
  }

  Future<void> saveAttendance(AttendanceRecordModel record) async {
    await attendance.put(record.id, record);
    // Add to sync queue
    await addToSyncQueue(record.toJson(), 'attendance', 'save');
  }

  Future<void> addToSyncQueue(Map<String, dynamic> data, String collection, String action) async {
    await syncQueue.add({
      'collection': collection,
      'action': action,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  DateTime? getLastSyncTime() {
    final str = syncMeta.get('lastSyncAt');
    if (str != null) return DateTime.parse(str);
    return null;
  }

  Future<void> updateLastSyncTime(DateTime time) async {
    await syncMeta.put('lastSyncAt', time.toIso8601String());
  }
}
