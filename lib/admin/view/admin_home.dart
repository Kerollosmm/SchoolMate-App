import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management_system/admin/controllers/admin_controller.dart';
import 'package:school_management_system/admin/view/conflicts_view.dart';
import 'package:school_management_system/admin/view/data_view.dart';
import 'package:school_management_system/admin/view/servants_view.dart';
import 'package:school_management_system/public/utils/constant.dart';
import 'package:school_management_system/public/widgets/attendance_list_view.dart';

class AdminHome extends GetView<AdminController> {
  const AdminHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(gradient: gradientColor),
          ),
          title: const Text("Admin Dashboard"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Attendance", icon: Icon(Icons.check)),
              Tab(text: "Servants", icon: Icon(Icons.people)),
              Tab(text: "Data", icon: Icon(Icons.storage)),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.warning_amber_rounded),
              onPressed: () => Get.to(() => ConflictsView()),
            ),
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: controller.logout,
            )
          ],
        ),
        body: TabBarView(
          children: [
            AttendanceListView(controller: controller.attendanceController),
            const ServantsView(),
            const DataView(),
          ],
        ),
      ),
    );
  }
}
