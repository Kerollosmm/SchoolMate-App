import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:school_management_system/public/models/attendance_model.dart';
import 'package:school_management_system/public/models/conflict_model.dart';
import 'package:school_management_system/public/services/local_db_service.dart';

class ConflictController extends GetxController {
  var conflicts = <ConflictRecord>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadConflicts();
  }

  void loadConflicts() {
    var box = LocalDBService.conflictsBox;
    conflicts.value = box.values
        .map((e) => ConflictRecord.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> resolveConflict(ConflictRecord conflict, bool useLocal) async {
    try {
       // Target Attendance Record ID
       String attendanceId = "${conflict.date}_${conflict.studentId}";

       if (useLocal) {
         // Force push local version
         AttendanceRecord record = AttendanceRecord.fromJson(conflict.localVersion);
         AttendanceRecord syncedRecord = record.copyWith(syncStatus: 'synced', status: record.status); // Keep status

         await FirebaseFirestore.instance.collection('attendance').doc(attendanceId).set(syncedRecord.toJson());
         await LocalDBService.attendanceBox.put(attendanceId, syncedRecord.toJson());
       } else {
         // Adopt remote version
         AttendanceRecord record = AttendanceRecord.fromJson(conflict.remoteVersion);
         await LocalDBService.attendanceBox.put(attendanceId, record.toJson());
       }

       // Remove conflict
       await LocalDBService.conflictsBox.delete(conflict.id);
       loadConflicts();
       Get.back(); // Close dialog
       Get.snackbar('Resolved', 'Conflict resolved successfully');

    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}
