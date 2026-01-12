import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management_system/public/utils/constant.dart';
import 'package:school_management_system/public/widgets/attendance_list_view.dart';
import 'package:school_management_system/servant/controllers/servant_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ServantHome extends GetView<ServantController> {
  const ServantHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: gradientColor),
        ),
        title: Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome, ${controller.servantName}"),
            Text(
              "Grade: ${controller.assignedGrade}",
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400)
            ),
          ],
        )),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: controller.logout,
          )
        ],
      ),
      body: AttendanceListView(controller: controller.attendanceController),
    );
  }
}
