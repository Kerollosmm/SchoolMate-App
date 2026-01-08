import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:developer' as developer;

import '../config/user_information.dart';

// Simple Result class for error handling
class Result<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  Result.success(this.data) : error = null, isSuccess = true;
  Result.failure(this.error) : data = null, isSuccess = false;
}

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googlSignIn = GoogleSignIn();
  GetStorage storage = GetStorage();
  var uid;

  Future<Result<String>> loginStudent({
    required String email,
    required String password,
  }) async {
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        String currentuser = _auth.currentUser!.uid;
        UserInformation.User_uId = currentuser;
        await storage.write('uid', UserInformation.User_uId);
        developer.log("User logged in successfully: ${UserInformation.User_uId}");
        return Result.success("success");
      } else {
        return Result.failure("Please enter all the fields");
      }
    } catch (err) {
      return Result.failure(err.toString());
    }
  }
}
