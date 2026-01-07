import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:school_management_system/public/models/student_model.dart';
import 'package:school_management_system/public/services/local_db_service.dart';
import 'package:school_management_system/public/controllers/attendance_controller.dart';
import 'package:intl/intl.dart';

class DataController extends GetxController {
  var isLoading = false.obs;

  // Import Students from Excel
  Future<void> importStudents() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result != null) {
        isLoading.value = true;
        File file = File(result.files.single.path!);
        var bytes = file.readAsBytesSync();
        var excel = Excel.decodeBytes(bytes);

        int count = 0;

        for (var table in excel.tables.keys) {
          // Assuming first sheet
          for (var row in excel.tables[table]!.rows) {
            // Skip header if needed, check logic
            if (row.isEmpty) continue;

            // Simple validation: expect at least 2 columns (Name, Grade)
            // Adjust indices based on expected template.
            // Let's assume: Col 0: Name, Col 1: Grade, Col 2: Email (Optional)
            if (row.length < 2) continue;

            String name = row[0]?.value?.toString() ?? '';
            String grade = row[1]?.value?.toString() ?? '';
            String email = row.length > 2 ? row[2]?.value?.toString() ?? '' : '';

            if (name.isEmpty || grade.isEmpty) continue;
            if (name.toLowerCase() == 'name') continue; // Skip header row

            // Create Student
            // Split name?
            String firstName = name.split(' ').first;
            String lastName = name.contains(' ') ? name.substring(name.indexOf(' ') + 1) : '';
            String uid = DateTime.now().millisecondsSinceEpoch.toString() + count.toString();

            Student student = Student(
              id: uid,
              firstName: firstName,
              lastName: lastName,
              email: email,
              phone: '',
              parentPhone: '',
              grade: grade,
              className: 'A', // Default
              fees: '',
              urlAvatar: '',
            );

            // Save to Firestore & Hive
            await FirebaseFirestore.instance.collection('students').doc(uid).set(student.toJson());
            await LocalDBService.studentsBox.put(uid, student.toJson());
            count++;
          }
        }

        Get.snackbar("Success", "Imported $count students");
      }
    } catch (e) {
      Get.snackbar("Error", "Import failed: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Export Attendance to Excel
  Future<void> exportAttendance(DateTime date) async {
    isLoading.value = true;
    try {
      // Get attendance data
      // We can reuse AttendanceController logic or fetch directly
      final AttendanceController attendanceController = Get.find<AttendanceController>();
      await attendanceController.loadAttendanceForDate(date); // Ensure loaded

      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];

      // Headers
      List<String> headers = ["Student Name", "Grade", "Date", "Status", "Recorded By", "Sync Status"];
      sheetObject.appendRow(headers.map((e) => TextCellValue(e)).toList());

      // Rows
      // Iterate students to match structure
      for (var student in attendanceController.students) {
         var record = attendanceController.attendanceRecords[student.id];
         String status = record?.status ?? 'Unmarked';
         String recordedBy = record?.recordedBy ?? '';
         String syncStatus = record?.syncStatus ?? '';
         String dateStr = DateFormat('yyyy-MM-dd').format(date);

         sheetObject.appendRow([
            TextCellValue(student.fullName),
            TextCellValue(student.grade),
            TextCellValue(dateStr),
            TextCellValue(status),
            TextCellValue(recordedBy),
            TextCellValue(syncStatus),
         ]);
      }

      // Save file
      var fileBytes = excel.save();
      String dateFile = DateFormat('yyyy-MM-dd').format(date);

      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory(); // or getApplicationDocumentsDirectory
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      String path = "${directory!.path}/attendance_$dateFile.xlsx";
      File(path)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes!);

      Get.snackbar("Success", "Exported to $path");

      // Open file
      await OpenFile.open(path);

    } catch (e) {
      Get.snackbar("Error", "Export failed: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
