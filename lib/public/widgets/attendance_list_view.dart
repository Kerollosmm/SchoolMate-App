import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:school_management_system/public/controllers/attendance_controller.dart';
import 'package:school_management_system/public/models/attendance_model.dart';
import 'package:school_management_system/public/models/student_model.dart';
import 'package:school_management_system/public/utils/constant.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AttendanceListView extends StatelessWidget {
  final AttendanceController controller;

  const AttendanceListView({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Date Picker Header
        Container(
          padding: EdgeInsets.all(16.w),
          color: white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios, size: 20.sp),
                onPressed: () => controller.setDate(controller.selectedDate.value.subtract(Duration(days: 1))),
              ),
              Obx(() => Text(
                DateFormat('EEE, MMM d, yyyy').format(controller.selectedDate.value),
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: darkGray),
              )),
              IconButton(
                icon: Icon(Icons.arrow_forward_ios, size: 20.sp),
                onPressed: () => controller.setDate(controller.selectedDate.value.add(Duration(days: 1))),
              ),
            ],
          ),
        ),

        // Student List
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return Center(child: CircularProgressIndicator());
            }
            if (controller.students.isEmpty) {
              return Center(child: Text("No students found"));
            }
            return ListView.separated(
              itemCount: controller.students.length,
              separatorBuilder: (context, index) => Divider(),
              itemBuilder: (context, index) {
                Student student = controller.students[index];
                return _buildStudentRow(student);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildStudentRow(Student student) {
    return Obx(() {
      AttendanceRecord? record = controller.attendanceRecords[student.id];
      String status = record?.status ?? 'present'; // Default to present visually if null? Or explicit null?
      // Requirement: "Servant can mark attendance".
      // Let's assume default is null (unmarked) or we default to Present?
      // Usually attendance apps default to Present or show Unmarked.
      // I'll show 'present' as selected if record is null for smoother UX, or gray if unmarked.
      // Let's treat null as "Unmarked".

      bool isSynced = record?.syncStatus == 'synced';
      bool isConflict = record?.syncStatus == 'conflict';

      return ListTile(
        leading: CircleAvatar(
          backgroundImage: student.urlAvatar.isNotEmpty
              ? NetworkImage(student.urlAvatar)
              : null,
          child: student.urlAvatar.isEmpty ? Text(student.firstName[0]) : null,
        ),
        title: Text(student.fullName, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(student.grade),
            if (record != null)
              Text(
                isConflict ? "Conflict!" : (isSynced ? "Synced" : "Pending"),
                style: TextStyle(
                  color: isConflict ? Colors.red : (isSynced ? Colors.green : Colors.orange),
                  fontSize: 10.sp
                ),
              )
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _statusButton(student.id, 'present', Icons.check_circle, Colors.green, status),
            SizedBox(width: 8.w),
            _statusButton(student.id, 'absent', Icons.cancel, Colors.red, status),
            SizedBox(width: 8.w),
            _statusButton(student.id, 'excused', Icons.info, Colors.orange, status),
          ],
        ),
      );
    });
  }

  Widget _statusButton(String studentId, String statusKey, IconData icon, Color color, String currentStatus) {
    bool isSelected = currentStatus == statusKey;
    return InkWell(
      onTap: () => controller.markAttendance(studentId, statusKey),
      child: Icon(
        icon,
        color: isSelected ? color : lightGray,
        size: 30.sp,
      ),
    );
  }
}
