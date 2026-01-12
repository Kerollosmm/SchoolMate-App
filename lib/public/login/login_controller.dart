import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:school_management_system/public/config/user_information.dart';
import 'package:school_management_system/public/models/servant_model.dart';
import 'package:school_management_system/public/services/local_db_service.dart';
import 'package:school_management_system/routes/app_pages.dart';

class LoginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage storage = GetStorage();

  var isLoading = false.obs;
  var isPasswordVisible = true.obs;

  // Selected Role
  var selectedRole = 'student'.obs; // student, teacher, parent, admin

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _setupFCM();
    // Check offline login
    _checkOfflineLogin();
  }

  void _setupFCM() {
    FirebaseMessaging.instance.getToken().then((token) {
      if (token != null) {
        UserInformation.Token = token;
      }
    });
  }

  void _checkOfflineLogin() {
    String? uid = storage.read('uid');
    String? role = storage.read('role'); // We need to save role on login

    if (uid != null && uid.isNotEmpty) {
      // If we have a stored session, try to navigate based on cached role
      // For Phase 1, we focus on Admin/Servant offline access
      if (role == 'admin') {
        Get.offAllNamed('/admin_home'); // Need to add this route
      } else if (role == 'servant') {
        Get.offAllNamed('/servant_home'); // Need to add this route
      } else if (role == 'student') {
         Get.offAllNamed(AppPages.Studenthome);
      } else if (role == 'teacher') {
         Get.offAllNamed(AppPages.Teacherhome);
      }
    }
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void selectRole(String role) {
    selectedRole.value = role;
  }

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter email and password');
      return;
    }

    isLoading.value = true;
    try {
      // 1. Firebase Auth Login
      UserCredential userCred = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      String uid = userCred.user!.uid;
      UserInformation.User_uId = uid;

      // 2. Check Role & Collection
      bool success = false;

      if (selectedRole.value == 'student') {
        success = await _verifyStudent(uid);
      } else if (selectedRole.value == 'teacher') {
        success = await _verifyTeacher(uid);
      } else if (selectedRole.value == 'parent') {
        // Parent logic (legacy, seemed implemented via Google Sign In mostly in UI, but let's see)
        // Leaving as placeholder or copying legacy logic if needed.
        // Legacy used Google Sign In for parent mainly.
        Get.snackbar("Notice", "Parent login via email not fully supported in this refactor yet.");
        success = false;
      } else if (selectedRole.value == 'admin') {
        // This covers both Admin and Servant
        success = await _verifyServantOrAdmin(uid);
      }

      if (success) {
        storage.write('uid', uid);
        storage.write('role', selectedRole.value == 'admin' ? _determineAdminOrServant(uid) : selectedRole.value);
        // Navigation happens inside verify methods or generic here
      } else {
        Get.snackbar('Error', 'User not found in selected role or account inactive');
        await _auth.signOut();
      }

    } on FirebaseAuthException catch (e) {
      Get.snackbar('Login Failed', e.message ?? 'Unknown error');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  String _determineAdminOrServant(String uid) {
    // Helper to distinguish stored role string
    // This is a bit tricky since we just verified it.
    // We'll rely on what we found in _verifyServantOrAdmin
    return _cachedRole;
  }

  String _cachedRole = 'admin';

  Future<bool> _verifyServantOrAdmin(String uid) async {
    // Check 'servants' collection
    DocumentSnapshot doc = await _firestore.collection('servants').doc(uid).get();

    if (doc.exists) {
      ServantProfile profile = ServantProfile.fromJson(doc.data() as Map<String, dynamic>);

      if (!profile.isActive) {
        Get.snackbar('Error', 'Account is deactivated');
        return false;
      }

      // Save to Hive for offline use
      await LocalDBService.profileBox.put('profile', profile.toJson());

      _cachedRole = profile.role; // 'admin' or 'servant'

      if (profile.role == 'admin') {
        Get.offAllNamed('/admin_home');
      } else {
         Get.offAllNamed('/servant_home');
      }
      return true;
    }
    return false;
  }

  Future<bool> _verifyStudent(String uid) async {
    QuerySnapshot snap = await _firestore.collection('students').where('uid', isEqualTo: uid).get();
    if (snap.docs.isNotEmpty) {
      var data = snap.docs.first.data() as Map<String, dynamic>;
      // Legacy UserInformation population
      UserInformation.first_name = data['first_name'];
      UserInformation.last_name = data['last_name'];
      // ... fill others as needed by legacy app

      Get.offAllNamed(AppPages.Studenthome);
      return true;
    }
    return false;
  }

  Future<bool> _verifyTeacher(String uid) async {
    QuerySnapshot snap = await _firestore.collection('teacher').where('uid', isEqualTo: uid).get();
    if (snap.docs.isNotEmpty) {
      var data = snap.docs.first.data() as Map<String, dynamic>;
       // Legacy UserInformation population
      UserInformation.first_name = data['first_name'];

      Get.offAllNamed(AppPages.Teacherhome);
      return true;
    }
    return false;
  }
}
