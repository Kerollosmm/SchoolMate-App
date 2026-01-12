import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:school_management_system/public/models/servant_model.dart';
import 'package:school_management_system/public/models/student_model.dart';
import 'package:school_management_system/public/services/local_db_service.dart';

class AdminServantsController extends GetxController {
  var servants = <ServantProfile>[].obs;
  var isLoading = false.obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    loadServants();
  }

  Future<void> loadServants() async {
    isLoading.value = true;
    try {
      // 1. Try to fetch from Firestore to update cache
      // Ideally use a SyncService, but for list we can fetch-and-cache
      QuerySnapshot snap = await _firestore.collection('servants').get();
      List<ServantProfile> remoteList = snap.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        // Ensure uid is set from doc id if missing
        if (data['uid'] == null || data['uid'] == '') {
            data['uid'] = doc.id;
        }
        return ServantProfile.fromJson(data);
      }).toList();

      // 2. Update Hive
      var box = LocalDBService.servantsDirectoryBox;
      await box.clear();
      for (var servant in remoteList) {
        await box.put(servant.uid, servant.toJson());
      }

      // 3. Load from Hive to UI
      servants.value = box.values
          .map((e) => ServantProfile.fromJson(Map<String, dynamic>.from(e)))
          .toList();

    } catch (e) {
      print("Error loading servants: $e");
      // Fallback to Hive
      var box = LocalDBService.servantsDirectoryBox;
      servants.value = box.values
          .map((e) => ServantProfile.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addServant(String name, String email, String grade, String password) async {
    // Note: creating Auth user from here is tricky without Cloud Functions.
    // We will create the Firestore Profile.
    try {
      String uid = DateTime.now().millisecondsSinceEpoch.toString(); // Temporary UID
      ServantProfile newServant = ServantProfile(
        uid: uid,
        name: name,
        email: email,
        role: 'servant',
        isActive: true,
        assignedGrade: grade,
      );

      await _firestore.collection('servants').doc(uid).set(newServant.toJson());
      await LocalDBService.servantsDirectoryBox.put(uid, newServant.toJson());
      loadServants();
      Get.back();
      Get.snackbar('Success', 'Servant added (Profile Only)');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> deleteServant(String uid) async {
    // Check constraints
    ServantProfile? servant = servants.firstWhereOrNull((s) => s.uid == uid);
    if (servant == null) return;

    // Check if students exist in this grade
    var studentsBox = LocalDBService.studentsBox;
    bool hasStudents = studentsBox.values.any((s) {
      var student = Student.fromJson(Map<String, dynamic>.from(s));
      return student.grade == servant.assignedGrade;
    });

    if (hasStudents) {
      Get.snackbar('Error', 'Cannot delete servant with assigned students in ${servant.assignedGrade}');
      return;
    }

    try {
      await _firestore.collection('servants').doc(uid).delete();
      await LocalDBService.servantsDirectoryBox.delete(uid);
      loadServants();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> toggleActivation(String uid, bool currentStatus) async {
     try {
      await _firestore.collection('servants').doc(uid).update({'isActive': !currentStatus});
      // Update local
      var data = LocalDBService.servantsDirectoryBox.get(uid);
      if (data != null) {
          data['isActive'] = !currentStatus;
          await LocalDBService.servantsDirectoryBox.put(uid, data);
      }
      loadServants();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}
