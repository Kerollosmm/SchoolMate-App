import 'package:get/get.dart';
import 'package:school_management_system/public/controllers/attendance_controller.dart';
import 'package:school_management_system/public/models/servant_model.dart';
import 'package:school_management_system/public/services/local_db_service.dart';

class ServantController extends GetxController {
  final AttendanceController attendanceController = Get.put(AttendanceController());
  var servantName = ''.obs;
  var assignedGrade = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadProfile();
  }

  void _loadProfile() {
    var profileData = LocalDBService.profileBox.get('profile');
    if (profileData != null) {
      ServantProfile profile = ServantProfile.fromJson(Map<String, dynamic>.from(profileData));
      servantName.value = profile.name;
      assignedGrade.value = profile.assignedGrade;

      // Apply filter
      attendanceController.setGradeFilter(profile.assignedGrade);
    }
  }

  void logout() {
     // TODO: Implement logout (clear session)
     Get.offAllNamed('/login');
  }
}
