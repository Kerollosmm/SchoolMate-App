import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management_system/admin/controllers/data_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class DataView extends StatelessWidget {
  const DataView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DataController controller = Get.put(DataController());
    final Rx<DateTime> selectedDate = DateTime.now().obs;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() => controller.isLoading.value
              ? CircularProgressIndicator()
              : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Import Section
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        children: [
                          Icon(Icons.upload_file, size: 50.sp, color: Colors.blue),
                          SizedBox(height: 10.h),
                          Text("Import Students", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                          Text("Format: Name, Grade, Email(opt)"),
                          SizedBox(height: 10.h),
                          ElevatedButton(
                            onPressed: controller.importStudents,
                            child: Text("Select Excel File"),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Export Section
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        children: [
                          Icon(Icons.download, size: 50.sp, color: Colors.green),
                          SizedBox(height: 10.h),
                          Text("Export Attendance", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                          SizedBox(height: 10.h),
                          Obx(() => Text("Date: ${DateFormat('yyyy-MM-dd').format(selectedDate.value)}")),
                          TextButton(
                            onPressed: () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate.value,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) selectedDate.value = picked;
                            },
                            child: Text("Change Date"),
                          ),
                          SizedBox(height: 10.h),
                          ElevatedButton(
                            onPressed: () => controller.exportAttendance(selectedDate.value),
                            child: Text("Export to Excel"),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ),
          ],
        ),
      ),
    );
  }
}
