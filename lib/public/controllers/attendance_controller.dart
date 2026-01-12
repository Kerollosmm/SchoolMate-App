import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:school_management_system/public/models/attendance_model.dart';
import 'package:school_management_system/public/models/student_model.dart';
import 'package:school_management_system/public/services/local_db_service.dart';
import 'package:school_management_system/public/services/sync_service.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class AttendanceController extends GetxController {
  final SyncService syncService = Get.put(SyncService());
  var selectedDate = DateTime.now().obs;
  var students = <Student>[].obs;
  var attendanceRecords = <String, AttendanceRecord>{}.obs; // Key: studentId
  var isLoading = false.obs;

  // Filter
  var currentGrade = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadStudents();
    loadAttendanceForDate(selectedDate.value);
  }

  void setGradeFilter(String grade) {
    currentGrade.value = grade;
    loadStudents();
  }

  void setDate(DateTime date) {
    selectedDate.value = date;
    loadAttendanceForDate(date);
  }

  Future<void> loadStudents() async {
    isLoading.value = true;
    try {
      Box box = LocalDBService.studentsBox;
      // Get all students from Hive
      List<Student> allStudents = box.values
          .map((e) => Student.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      if (currentGrade.value.isNotEmpty) {
        students.value = allStudents.where((s) => s.grade == currentGrade.value).toList();
      } else {
        students.value = allStudents;
      }
    } catch (e) {
      print("Error loading students: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAttendanceForDate(DateTime date) async {
    String dateStr = DateFormat('yyyy-MM-dd').format(date);
    Box box = LocalDBService.attendanceBox;

    // Key format: YYYY-MM-DD_studentId
    // We scan the box. For performance, we might want a better structure,
    // but for <1000 records, iterating values is okay or using composite keys.
    // Efficient way: box.get('YYYY-MM-DD_studentId') for each student currently displayed.

    // We will clear current map and reload
    Map<String, AttendanceRecord> records = {};

    for (var student in students) {
      String key = "${dateStr}_${student.id}";
      var data = box.get(key);
      if (data != null) {
        records[student.id] = AttendanceRecord.fromJson(Map<String, dynamic>.from(data));
      }
    }

    attendanceRecords.value = records;
  }

  Future<void> markAttendance(String studentId, String status) async {
    String dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);
    String key = "${dateStr}_${studentId}";

    Student? student = students.firstWhereOrNull((s) => s.id == studentId);
    if (student == null) return;

    AttendanceRecord record = AttendanceRecord(
      id: key,
      studentId: studentId,
      studentName: student.fullName,
      grade: student.grade,
      date: dateStr,
      status: status,
      recordedBy: 'current_user', // TODO: Get from AuthService
      syncStatus: 'pending',
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    // Save to Hive
    await LocalDBService.attendanceBox.put(key, record.toJson());

    // Update local state
    attendanceRecords[studentId] = record;

    // Trigger Sync
    // We can run this in background
    syncService.syncAll();
  }

  Future<void> manualSync() async {
    isLoading.value = true;
    await syncService.syncAll();
    await loadAttendanceForDate(selectedDate.value);
    isLoading.value = false;
  }
}
