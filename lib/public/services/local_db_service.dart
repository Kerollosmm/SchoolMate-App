import 'package:hive_flutter/hive_flutter.dart';

class LocalDBService {
  static const String boxStudents = 'students_box';
  static const String boxAttendance = 'attendance_box';
  static const String boxConflicts = 'conflicts_box';
  static const String boxServantProfile = 'servant_profile_box';
  static const String boxServantsDirectory = 'servants_directory_box';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Open boxes
    await Hive.openBox(boxStudents);
    await Hive.openBox(boxAttendance);
    await Hive.openBox(boxConflicts);
    await Hive.openBox(boxServantProfile);
    await Hive.openBox(boxServantsDirectory);
  }

  static Box get studentsBox => Hive.box(boxStudents);
  static Box get attendanceBox => Hive.box(boxAttendance);
  static Box get conflictsBox => Hive.box(boxConflicts);
  static Box get profileBox => Hive.box(boxServantProfile);
  static Box get servantsDirectoryBox => Hive.box(boxServantsDirectory);

  // Clear all data (on logout)
  static Future<void> clearAll() async {
    await studentsBox.clear();
    await attendanceBox.clear();
    await conflictsBox.clear();
    await profileBox.clear();
    await servantsDirectoryBox.clear();
  }
}
