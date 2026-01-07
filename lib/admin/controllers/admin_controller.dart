import 'package:get/get.dart';
import 'package:school_management_system/admin/controllers/admin_servants_controller.dart';
import 'package:school_management_system/public/controllers/attendance_controller.dart';

class AdminController extends GetxController {
  // We can manage tab index here if we use bottom nav,
  // but for TabBarView inside AppBar, DefaultTabController is easier.

  // Initialize sub-controllers
  final AdminServantsController servantsController = Get.put(AdminServantsController());
  final AttendanceController attendanceController = Get.put(AttendanceController());

  @override
  void onInit() {
    super.onInit();
    // Admin sees all grades by default, or we can add a grade filter UI for Attendance
    attendanceController.setGradeFilter(''); // Clear filter to see all
  }

  void logout() {
      Get.offAllNamed('/login');
  }
}
